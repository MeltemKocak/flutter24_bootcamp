import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:planova/pages/journal_detail_page.dart';
import 'package:planova/pages/journal_edit_page.dart';
import 'package:planova/pages/photo_view_page.dart';
import 'package:provider/provider.dart';
import 'package:planova/utilities/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);
    CustomThemeData theme = ThemeColors.getTheme(themeProvider.themeValue);

    if (user == null) {
      return Card(
        color: theme.background,
        child: Center(
          child: Text(
            'Please sign in',
            style: GoogleFonts.didactGothic(color: theme.toDoTitle),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.background,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('journal')
                  .where('userId', isEqualTo: user.uid)
                  .where('isPrivate', isEqualTo: false)
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: theme.habitProgress),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      tr('Error') + ': ${snapshot.error}',
                      style: GoogleFonts.didactGothic(color: theme.toDoTitle),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      tr('No entries found'),
                      style: GoogleFonts.didactGothic(color: theme.toDoTitle),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    DateTime date = (data['date'] as Timestamp).toDate();
                    String formattedDate = DateFormat('d MMMM').format(date);
                    List<String> imageUrls = data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : [];
                    String? audioUrl = data['audioUrl'];
                    String description = data['description'] ?? '';

                    return Dismissible(
                      key: Key(doc.id),
                      background: Container(
                        color: const Color.fromARGB(200, 250, 70, 60),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        bool? confirmed = await _showConfirmationDialog(context);
                        if (confirmed == true) {
                          _moveJournalEntryToTrash(doc);
                        } else {
                          setState(() {});
                        }
                      },
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JournalDetailPage(docId: doc.id, data: data),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          color: theme.toDoCardBackground,
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
                                      style: GoogleFonts.didactGothic(
                                        color: theme.habitProgress,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (audioUrl != null && audioUrl.isNotEmpty)
                                      Icon(Icons.audiotrack, color: theme.habitProgress),
                                    IconButton(
                                      icon: Icon(Icons.edit, color: theme.habitProgress),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => JournalEditPage(docId: doc.id, data: data),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  data['name'],
                                  style: GoogleFonts.didactGothic(
                                    color: theme.toDoTitle,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  description.length > 100 ? '${description.substring(0, 100)}...' : description,
                                  style: GoogleFonts.didactGothic(
                                    color: theme.toDoIcons,
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
                                            margin: const EdgeInsets.only(right: 10),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              image: DecorationImage(
                                                image: NetworkImage(imageUrls[index]),
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
        ],
      ),
    );
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      final theme = Provider.of<ThemeProvider>(context).currentTheme;
      return AlertDialog(
        backgroundColor: theme.background,
        title: Text(
          tr('Confirm Deletion'),
          style: GoogleFonts.didactGothic(color: theme.welcomeText),
        ),
        content: Text(
          tr('Are you sure you want to delete this entry?'),
          style: GoogleFonts.didactGothic(color: theme.welcomeText),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              tr('Cancel'),
              style: GoogleFonts.didactGothic(color: theme.addButton),
            ),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: Text(
              tr('Delete'),
              style: GoogleFonts.didactGothic(color: theme.addButton),
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  ) ?? false;
}


  void _moveJournalEntryToTrash(DocumentSnapshot entry) async {
    final data = entry.data() as Map<String, dynamic>;

    await FirebaseFirestore.instance.collection('deleted_tasks').add({
      'name': data['name'],
      'description': data['description'],
      'deletedDate': DateTime.now(),
      'collection': 'journal',
      'docId': entry.id,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'data': data,
    });

    await FirebaseFirestore.instance.collection('journal').doc(entry.id).delete();
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
