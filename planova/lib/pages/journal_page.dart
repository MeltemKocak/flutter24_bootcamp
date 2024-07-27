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
  Duration _audioDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  Map<String, Duration> _audioDurations = {};

  @override
  void initState() {
    super.initState();
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _audioDuration = duration;
      });
    });
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _currentlyPlayingUrl = null;
        _currentPosition = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializeAudioDuration(String audioUrl) async {
    if (!_audioDurations.containsKey(audioUrl)) {
      final audioPlayer = ap.AudioPlayer();
      await audioPlayer.setSourceUrl(audioUrl);
      final duration = await audioPlayer.getDuration();
      setState(() {
        _audioDurations[audioUrl] = duration ?? Duration.zero;
      });
      audioPlayer.dispose();
    }
  }

  void _playAudio(BuildContext context, String docId, Map<String, dynamic> data) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalEditPage(docId: docId, data: data, playAudioOnStart: true),
      ),
    );
  }

  void _viewPhoto(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewPage(imageUrl: imageUrl),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
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
              List<double>? waveform = data['waveform'] != null ? List<double>.from(data['waveform']) : null;

              if (audioUrl != null) {
                _initializeAudioDuration(audioUrl);
              }

              return Dismissible(
                key: Key(doc.id),
                background: Container(
                  color: Colors.red,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _moveJournalEntryToTrash(doc);
                },
                child: Card(
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
                            fontWeight: FontWeight.w300),
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
                          GestureDetector(
                            onTap: () => _playAudio(context, doc.id, data),
                            child: AudioPlayerWidget(
                              audioUrl: audioUrl,
                              currentlyPlayingUrl: _currentlyPlayingUrl,
                              waveform: waveform,
                              audioDurations: _audioDurations,
                              currentPosition: _currentPosition,
                              audioDuration: _audioDuration,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _moveJournalEntryToTrash(DocumentSnapshot entry) async {
    final data = entry.data() as Map<String, dynamic>;

    // Silinen günlüğü 'deleted_tasks' koleksiyonuna taşı
    await FirebaseFirestore.instance.collection('deleted_tasks').add({
      'name': data['name'],
      'description': data['description'],
      'deletedDate': DateTime.now(),
      'collection': 'journal',
      'docId': entry.id,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'data': data,
    });

    // Günlüğü orijinal koleksiyonundan sil
    await FirebaseFirestore.instance.collection('journal').doc(entry.id).delete();
  }
}

class AudioPlayerWidget extends StatelessWidget {
  final String audioUrl;
  final String? currentlyPlayingUrl;
  final List<double>? waveform;
  final Map<String, Duration> audioDurations;
  final Duration currentPosition;
  final Duration audioDuration;

  const AudioPlayerWidget({
    Key? key,
    required this.audioUrl,
    required this.currentlyPlayingUrl,
    this.waveform,
    required this.audioDurations,
    required this.currentPosition,
    required this.audioDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0X3F607D8B),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentlyPlayingUrl == audioUrl ? Colors.red : const Color(0XFF03DAC6),
                ),
                child: Icon(
                  currentlyPlayingUrl == audioUrl ? Icons.stop : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
              if (waveform != null)
                Expanded(
                  child: CustomPaint(
                    size: const Size(double.infinity, 30),
                    painter: WaveformPainter(waveform!),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            audioDurations.containsKey(audioUrl)
                ? _formatDuration(audioDurations[audioUrl]!)
                : "Loading...",
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        if (currentlyPlayingUrl == audioUrl)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "${_formatDuration(currentPosition)} / ${_formatDuration(audioDuration)}",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveform;

  WaveformPainter(this.waveform);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0XFF03DAC6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final maxAmplitude = size.height / 2;
    final width = size.width;
    final stepWidth = width / waveform.length;

    for (var i = 0; i < waveform.length; i++) {
      final x = i * stepWidth;
      final amplitude = maxAmplitude * (waveform[i] / 100);
      canvas.drawLine(
        Offset(x, size.height / 2 - amplitude),
        Offset(x, size.height / 2 + amplitude),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
