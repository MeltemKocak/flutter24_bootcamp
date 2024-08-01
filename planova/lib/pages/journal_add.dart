import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:planova/utilities/theme.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class JournalAddSubPage extends StatefulWidget {
  const JournalAddSubPage({super.key});

  @override
  _JournalAddSubPageState createState() => _JournalAddSubPageState();
}

class _JournalAddSubPageState extends State<JournalAddSubPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final List<XFile> _images = [];
  DateTime _dateTime = DateTime.now();
  FlutterSoundRecorder? _soundRecorder;
  FlutterSoundPlayer? _soundPlayer;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedFilePath;
  final ap.AudioPlayer _audioPlayer = ap.AudioPlayer();
  double _decibelLevel = 0.0;
  Duration _recordedDuration = Duration.zero;
  final List<double> _audioWaveform = [];
  bool _isSaving = false;
  bool _isPrivate = false;

  @override
  void initState() {
    super.initState();
    _soundRecorder = FlutterSoundRecorder();
    _soundPlayer = FlutterSoundPlayer();
    _openRecorder();
    _openPlayer();
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  Future<void> _openRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print("Microphone permission not granted");
      return;
    }
    await _soundRecorder!.openRecorder();
    _soundRecorder!.setSubscriptionDuration(const Duration(milliseconds: 100));
  }

  Future<void> _openPlayer() async {
    await _soundPlayer!.openPlayer();
  }

  @override
  void dispose() {
    _soundRecorder?.closeRecorder();
    _soundPlayer?.closePlayer();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      Directory appDirectory = await getApplicationDocumentsDirectory();
      String filePath =
          '${appDirectory.path}/${DateTime.now().millisecondsSinceEpoch}.aac';
      await _soundRecorder!.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS,
      );
      _soundRecorder!.onProgress!.listen((event) {
        setState(() {
          _decibelLevel = event.decibels ?? 0;
          _recordedDuration = event.duration;
          _audioWaveform.add(_decibelLevel);
          if (_audioWaveform.length > 50) {
            _audioWaveform.removeAt(0);
          }
        });
      });
      setState(() {
        _recordedFilePath = filePath;
        _isRecording = true;
        _audioWaveform.clear();
      });
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _soundRecorder!.stopRecorder();
      setState(() {
        _isRecording = false;
      });
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  void _deleteRecording() {
    setState(() {
      _recordedFilePath = null;
      _decibelLevel = 0.0;
      _recordedDuration = Duration.zero;
      _audioWaveform.clear();
    });
  }

  Future<void> _saveJournalEntry() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });

    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('Header cannot be empty'), style: GoogleFonts.didactGothic())),
      );
      setState(() {
        _isSaving = false;
      });
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    List<String> imageUrls = [];
    for (XFile image in _images) {
      String imageUrl = await _uploadImage(image);
      imageUrls.add(imageUrl);
    }

    String? audioUrl;
    if (_recordedFilePath != null) {
      audioUrl = await _uploadAudio(_recordedFilePath!);
    }

    await FirebaseFirestore.instance.collection('journal').add({
      'userId': user.uid,
      'name': nameController.text,
      'description': descriptionController.text,
      'date': _dateTime,
      'imageUrls': imageUrls,
      'audioUrl': audioUrl,
      'waveform': _audioWaveform,
      'isPrivate': _isPrivate,
    });

    setState(() {
      _isSaving = false;
    });

    Navigator.pop(context);
  }

  Future<String> _uploadImage(XFile image) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return '';

    File file = File(image.path);
    String fileName =
        'journalPics/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    UploadTask task =
        FirebaseStorage.instance.ref().child(fileName).putFile(file);
    TaskSnapshot snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }

  Future<String> _uploadAudio(String filePath) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return '';

    File file = File(filePath);
    String fileName =
        'journalPics/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.aac';
    UploadTask task =
        FirebaseStorage.instance.ref().child(fileName).putFile(file);
    TaskSnapshot snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(image);
      });
    }
  }

  void _showDatePicker() {
    final customTheme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;

    showDatePicker(
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: customTheme.loginTextAndBorder,
              onPrimary: customTheme.addButtonIcon,
              surface: customTheme.surface,
              onSurface: customTheme.welcomeText,
            ),
            dialogBackgroundColor: customTheme.surface,
          ),
          child: child!,
        );
      },
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    ).then((value) {
      if (value != null) {
        setState(() {
          _dateTime = value;
        });
      }
    });
  }

  Future<void> _playAudio() async {
    if (_recordedFilePath != null) {
      setState(() {
        _isPlaying = true;
      });
      await _audioPlayer.play(ap.UrlSource(_recordedFilePath!));
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    String formattedDate = DateFormat('MM/dd/yyyy').format(_dateTime);
    return Scaffold(
      backgroundColor: theme.background,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(nameController, tr('Header'), theme),
              const SizedBox(height: 20),
              _buildTextField(descriptionController, tr('Description'), theme,
                  maxLines: 3),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: _buildDateField(formattedDate, theme),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 2,
                    child: _buildPrivacyButton(theme),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildImageSelection(theme),
              const SizedBox(height: 20),
              _buildAudioRecordingSection(theme),
              const SizedBox(height: 30),
              _buildConfirmButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, CustomThemeData theme,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.didactGothic(
              color: theme.welcomeText,
              fontSize: 15,
              fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 2),
        TextFormField(
          controller: controller,
          style: GoogleFonts.didactGothic(color: theme.welcomeText),
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: tr("Enter") + " $label",
            hintStyle: GoogleFonts.didactGothic(color: theme.welcomeText.withAlpha(150)),
            filled: true,
            fillColor: theme.toDoCardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String formattedDate, CustomThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr("Date"),
          style: GoogleFonts.didactGothic(
              color: theme.welcomeText,
              fontSize: 15,
              fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: _showDatePicker,
          
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.toDoCardBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: GoogleFonts.didactGothic(color: theme.welcomeText),
                ),
                Icon(Icons.calendar_today, color: theme.welcomeText),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSelection(CustomThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr("Images"),
          style: GoogleFonts.didactGothic(
              color: theme.welcomeText,
              fontSize: 15,
              fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 2),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ..._images.map((image) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(image.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )),
              if (_images.length < 5)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.toDoCardBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.add,
                        color: theme.welcomeText,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioRecordingSection(CustomThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr("Audio"),
          style: GoogleFonts.didactGothic(
              color: theme.welcomeText,
              fontSize: 15,
              fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 10),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: theme.toDoCardBackground,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: _isRecording
                    ? _stopRecording
                    : (_recordedFilePath != null
                        ? (_isPlaying ? _stopAudio : _playAudio)
                        : _startRecording),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? Colors.red : theme.addButton,
                  ),
                  child: Icon(
                    _isRecording
                        ? Icons.stop
                        : (_recordedFilePath != null
                            ? (_isPlaying ? Icons.stop : Icons.play_arrow)
                            : Icons.mic),
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: _isRecording || _recordedFilePath != null
                    ? _buildWaveform(theme)
                    : Center(
                        child: Text(
                          tr("Tap to record"),
                          style: GoogleFonts.didactGothic(color: theme.welcomeText),
                        ),
                      ),
              ),
              if (_recordedFilePath != null && !_isRecording)
                IconButton(
                  icon: Icon(Icons.delete, color: theme.welcomeText),
                  onPressed: _deleteRecording,
                ),
            ],
          ),
        ),
        if (_recordedFilePath != null && !_isRecording)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              tr("Duration") + ": ${_recordedDuration.inMinutes}:${(_recordedDuration.inSeconds % 60).toString().padLeft(2, '0')}",
              style: GoogleFonts.didactGothic(color: theme.welcomeText, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildWaveform(CustomThemeData theme) {
    return CustomPaint(
      size: const Size(double.infinity, 30),
      painter: WaveformPainter(_audioWaveform, theme.addButton),
    );
  }

  Widget _buildPrivacyButton(CustomThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr("Private"),
          style: GoogleFonts.didactGothic(
              color: theme.welcomeText,
              fontSize: 15,
              fontWeight: FontWeight.w300),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 2),
        Container(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _isPrivate = !_isPrivate;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _isPrivate ? theme.addButton.withAlpha(150) : theme.addButton,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              _isPrivate ? tr('private') : tr('Public'),
              style: GoogleFonts.didactGothic(color: theme.addButtonIcon),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(CustomThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.addButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _isSaving ? null : _saveJournalEntry,
        child: Text(tr("Save Journal Entry"),
            style: GoogleFonts.didactGothic(color: theme.addButtonIcon)),
      ),
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
