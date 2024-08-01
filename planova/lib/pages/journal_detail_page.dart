import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:planova/pages/journal_edit_page.dart';
import 'package:planova/pages/photo_view_page.dart';
import 'package:planova/utilities/theme.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

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
  List<double> _audioWaveform = [];

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
      _initializeAudioWaveform();
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

  Future<void> _initializeAudioWaveform() async {
    setState(() {
      _audioWaveform = List<double>.from(_data['waveform'] ?? []);
    });
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
    return " $minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    List<String> imageUrls = _data['imageUrls'] != null ? List<String>.from(_data['imageUrls']) : [];
    String? audioUrl = _data['audioUrl'];
    String description = descriptionController.text.trim();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.welcomeText),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: theme.welcomeText),
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
      backgroundColor: theme.background,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(tr("Journal Header"), theme),
              const SizedBox(height: 10),
              _buildHeaderSection(theme),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildSectionTitle(tr("Journal Body"), theme),
                const SizedBox(height: 10),
                _buildBodySection(theme),
              ],
              if (imageUrls.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildSectionTitle(tr("Images"), theme),
                const SizedBox(height: 10),
                _buildImageSelection(imageUrls, theme),
              ],
              if (audioUrl != null && audioUrl.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildSectionTitle(tr("Audio"), theme),
                const SizedBox(height: 10),
                _buildAudioSection(audioUrl, theme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, CustomThemeData theme) {
    return Text(
      title,
      style: GoogleFonts.didactGothic(color: theme.welcomeText, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildHeaderSection(CustomThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: theme.toDoCardBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _data['name'],
        style: GoogleFonts.didactGothic(
          color: theme.welcomeText,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildBodySection(CustomThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: theme.toDoCardBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        descriptionController.text,
        style: GoogleFonts.didactGothic(
          color: theme.welcomeText,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildImageSelection(List<String> imageUrls, CustomThemeData theme) {
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
                  color: theme.toDoCardBackground,
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

  Widget _buildAudioSection(String audioUrl, CustomThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _currentlyPlayingUrl == audioUrl ? _stopAudio() : _playAudio(),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: theme.toDoCardBackground,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentlyPlayingUrl == audioUrl ? Colors.red : theme.addButton,
                  ),
                  child: Icon(
                    _currentlyPlayingUrl == audioUrl ? Icons.stop : Icons.play_arrow,
                    color: theme.welcomeText,
                  ),
                ),
                const SizedBox(width: 10),
                if (_audioWaveform.isNotEmpty)
                  Expanded(
                    child: CustomPaint(
                      size: const Size(double.infinity, 30),
                      painter: WaveformPainter(_audioWaveform, theme.addButton),
                    ),
                  )
                else
                  Expanded(
                    child: Text(
                      _audioDurations.containsKey(audioUrl)
                          ? _formatDuration(_audioDurations[audioUrl]!)
                          : tr("Loading..."),
                      style: GoogleFonts.didactGothic(color: theme.welcomeText, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          _audioDurations.containsKey(audioUrl)
              ? _formatDuration(_audioDurations[audioUrl]!)
              : tr("Loading..."),
          style: GoogleFonts.didactGothic(color: theme.welcomeText, fontSize: 12),
        ),
      ],
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveform;
  final Color color;

  WaveformPainter(this.waveform, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
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
