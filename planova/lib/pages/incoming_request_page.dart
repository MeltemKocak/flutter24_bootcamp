import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planova/utilities/theme.dart';
import 'package:provider/provider.dart';

class IncomingRequestsPage extends StatefulWidget {
  @override
  _IncomingRequestsPageState createState() => _IncomingRequestsPageState();
}

class _IncomingRequestsPageState extends State<IncomingRequestsPage> {
  User? user = FirebaseAuth.instance.currentUser;

  void _acceptHabit(DocumentSnapshot document) {
    FirebaseFirestore.instance.collection('habits').doc(document.id).update({
      'isPending': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gelen İstekler'),
        backgroundColor: theme.appBar,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('habits')
            .where('user_id', isEqualTo: user?.uid)
            .where('isPending', isEqualTo: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong', style: TextStyle(color: theme.welcomeText)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: theme.checkBoxActiveColor));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No incoming requests', style: TextStyle(color: theme.welcomeText)));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

              if (data == null) {
                return const SizedBox.shrink();
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: theme.toDoCardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data['name'] ?? 'No name',
                            style: TextStyle(
                              color: theme.toDoTitle,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _acceptHabit(document);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.addButton,
                            ),
                            child: const Text('Accept'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        data['description'] ?? 'No description',
                        style: TextStyle(
                          color: theme.subText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
