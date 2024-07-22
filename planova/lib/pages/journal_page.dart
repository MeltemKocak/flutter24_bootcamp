import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:planova/pages/journal_edit_page.dart';
import 'package:planova/pages/photo_view_page.dart';
import 'package:audioplayers/audioplayers.dart' as ap;

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final ap.AudioPlayer _audioPlayer = ap.AudioPlayer();
  String? _currentlyPlayingUrl;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playAudio(String url) async {
    if (_currentlyPlayingUrl == url) {
      await _audioPlayer.stop();
      setState(() {
        _currentlyPlayingUrl = null;
      });
    } else {
      await _audioPlayer.play(ap.UrlSource(url));
      setState(() {
        _currentlyPlayingUrl = url;
      });
    }
  }



  void _viewPhoto(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewPage(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Card(
        color: Color(0xFF1E1E1E),
        child: Center(child: Text('Please sign in', style: TextStyle(color: Colors.white))),
      );
    }

    return Card(
      color: const Color(0xFF1E1E1E),
      
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('journal')
            .where('userId', isEqualTo: user.uid)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0XFF03DAC6)));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No entries found', style: TextStyle(color: Colors.white)));
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

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                color: const Color(0xFF2A2A2A),
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
                            style: const TextStyle(
                              color: Color(0XFF03DAC6),
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color(0XFF03DAC6)),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        data['description'],
                        style: const TextStyle(
                          color: Colors.white70,
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
                      const SizedBox(height: 15),
                      if (audioUrl != null && audioUrl.isNotEmpty)
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0X3F607D8B),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => _playAudio(audioUrl),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentlyPlayingUrl == audioUrl ? Colors.red : const Color(0XFF03DAC6),
                                  ),
                                  child: Icon(
                                    _currentlyPlayingUrl == audioUrl ? Icons.stop : Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

