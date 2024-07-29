import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:planova/pages/journal_detail_page.dart';
import 'package:planova/pages/journal_edit_page.dart';
import 'package:planova/pages/photo_view_page.dart';
import 'package:planova/utilities/theme.dart';
import 'package:provider/provider.dart';

class PrivateJournalPage extends StatefulWidget {
  const PrivateJournalPage({super.key});

  @override
  _PrivateJournalPageState createState() => _PrivateJournalPageState();
}

class _PrivateJournalPageState extends State<PrivateJournalPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeData = Provider.of<ThemeProvider>(context).currentTheme;

    if (user == null) {
      return Card(
        color: themeData.background,
        child: Center(
            child: Text('Please sign in',
                style: TextStyle(color: themeData.welcomeText))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Private Journal',
            style: TextStyle(color: themeData.welcomeText)),
        backgroundColor: themeData.background,
         leading: IconButton(
        icon: Icon(Icons.arrow_back, color: themeData.welcomeText),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      ),
      backgroundColor: themeData.background,
      body: Card(
        color: themeData.background,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('journal')
              .where('userId', isEqualTo: user.uid)
              .where('isPrivate', isEqualTo: true)
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                      color: themeData.focusDayColor));
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: TextStyle(color: themeData.welcomeText)));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                  child: Text('No entries found',
                      style: TextStyle(color: themeData.welcomeText)));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var data = doc.data() as Map<String, dynamic>;
                DateTime date = (data['date'] as Timestamp).toDate();
                String formattedDate = DateFormat('d MMMM').format(date);
                List<String> imageUrls = data['imageUrls'] != null
                    ? List<String>.from(data['imageUrls'])
                    : [];
                String? audioUrl = data['audioUrl'];
                String description = data['description'] ?? '';

                return Dismissible(
                  key: Key(doc.id),
                  background: Container(
                    color: Colors.red,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Icon(Icons.delete, color: themeData.welcomeText),
                      ),
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _moveJournalEntryToTrash(doc);
                  },
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              JournalDetailPage(docId: doc.id, data: data),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      color: themeData.toDoCardBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    color: themeData.focusDayColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                if (audioUrl != null && audioUrl.isNotEmpty)
                                  Icon(Icons.audiotrack,
                                      color: themeData.focusDayColor),
                                IconButton(
                                  icon: Icon(Icons.edit,
                                      color: themeData.focusDayColor),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => JournalEditPage(
                                            docId: doc.id, data: data),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              data['name'],
                              style: TextStyle(
                                color: themeData.welcomeText,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              description.length > 100
                                  ? '${description.substring(0, 100)}...'
                                  : description,
                              style: TextStyle(
                                color: themeData.welcomeText.withOpacity(0.7),
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 15),
                            if (imageUrls.isNotEmpty)
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: imageUrls.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () => _viewPhoto(imageUrls[index]),
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: DecorationImage(
                                            image:
                                                NetworkImage(imageUrls[index]),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _moveJournalEntryToTrash(DocumentSnapshot entry) async {
    final data = entry.data() as Map<String, dynamic>;

    await FirebaseFirestore.instance.collection('deleted_tasks').add({
      'name': data['name'],
      'description': data['description'],
      'deletedDate': DateTime.now(),
      'collection': 'private_journal',
      'docId': entry.id,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'data': data,
    });

    await FirebaseFirestore.instance
        .collection('private_journal')
        .doc(entry.id)
        .delete();
  }

  void _viewPhoto(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewPage(imageUrl: imageUrl),
      ),
    );
  }
}
