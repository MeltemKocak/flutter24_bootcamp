import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planova/utilities/theme.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

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
        title: Text(
          tr('Incoming Requests'),
          style: GoogleFonts.didactGothic(color: theme.welcomeText),
        ),
        backgroundColor: theme.background,
        iconTheme: IconThemeData(color: theme.welcomeText),
      ),
      backgroundColor: theme.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('habits')
            .where('user_id', isEqualTo: user?.uid)
            .where('isPending', isEqualTo: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(tr('Something went wrong'), style: GoogleFonts.didactGothic(color: theme.welcomeText)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: theme.checkBoxActiveColor));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(tr('No incoming requests'), style: GoogleFonts.didactGothic(color: theme.welcomeText)));
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
                            data['name'] ?? tr('No name'),
                            style: GoogleFonts.didactGothic(
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
                            child: Text(tr('Accept'), style: GoogleFonts.didactGothic()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        data['description'] ?? tr('No description'),
                        style: GoogleFonts.didactGothic(
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
