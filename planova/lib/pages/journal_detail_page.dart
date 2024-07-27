import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:planova/pages/journal_edit_page.dart';
import 'package:planova/pages/photo_view_page.dart';

class JournalDetailPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const JournalDetailPage({super.key, required this.docId, required this.data});

  @override
  _JournalDetailPageState createState() => _JournalDetailPageState();
}

class _JournalDetailPageState extends State<JournalDetailPage> {
  late TextEditingController descriptionController;
  final ap.AudioPlayer _audioPlayer = ap.AudioPlayer();
  String? _currentlyPlayingUrl;
  Duration _audioDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  Map<String, Duration> _audioDurations = {};
  late Map<String, dynamic> _data;

  @override
  void initState() {
    super.initState();
    _data = widget.data;
    descriptionController = TextEditingController(text: _data['description']);
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

    if (_data['audioUrl'] != null) {
      _initializeAudioDuration(_data['audioUrl']);
    }
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

  void _viewPhoto(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewPage(imageUrl: imageUrl),
      ),
    );
  }

  Future<void> _playAudio() async {
    await _audioPlayer.play(ap.UrlSource(_data['audioUrl']));
    setState(() {
      _currentlyPlayingUrl = _data['audioUrl'];
    });
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _currentlyPlayingUrl = null;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = _data['imageUrls'] != null ? List<String>.from(_data['imageUrls']) : [];
    String? audioUrl = _data['audioUrl'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              final updatedData = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JournalEditPage(docId: widget.docId, data: _data),
                ),
              );
              if (updatedData != null) {
                setState(() {
                  _data = updatedData;
                  descriptionController.text = _data['description'];
                });
              }
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1E1E1E),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Journal Header"),
              const SizedBox(height: 10),
              _buildHeaderSection(),
              const SizedBox(height: 20),
              _buildSectionTitle("Journal Body"),
              const SizedBox(height: 10),
              _buildBodySection(),
              const SizedBox(height: 20),
              _buildSectionTitle("Images"),
              const SizedBox(height: 10),
              _buildImageSelection(imageUrls),
              const SizedBox(height: 20),
              if (audioUrl != null && audioUrl.isNotEmpty)
                ...[
                  _buildSectionTitle("Audio"),
                  const SizedBox(height: 10),
                  _buildAudioSection(audioUrl),
                ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0X3F607D8B),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _data['name'],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildBodySection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0X3F607D8B),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        descriptionController.text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildImageSelection(List<String> imageUrls) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...imageUrls.map((imageUrl) {
            return GestureDetector(
              onTap: () => _viewPhoto(imageUrl),
              child: Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: const Color(0X3F607D8B),
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAudioSection(String audioUrl) {
    return GestureDetector(
      onTap: () => _currentlyPlayingUrl == audioUrl ? _stopAudio() : _playAudio(),
      child: Container(
        height: 60,
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
                color: _currentlyPlayingUrl == audioUrl ? Colors.red : const Color(0XFF03DAC6),
              ),
              child: Icon(
                _currentlyPlayingUrl == audioUrl ? Icons.stop : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _audioDurations.containsKey(audioUrl)
                  ? _formatDuration(_audioDurations[audioUrl]!)
                  : "Loading...",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
