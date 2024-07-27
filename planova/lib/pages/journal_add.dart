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
  bool _isSaving = false; // Save işlemi devam ederken butonu işlevsiz hale getirmek için değişken

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
      String filePath = '${appDirectory.path}/${DateTime.now().millisecondsSinceEpoch}.aac';
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
    if (_isSaving) return; // İşlem devam ederken çık
    setState(() {
      _isSaving = true; // İşlem başladığında değiştir
    });

    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Header cannot be empty')),
      );
      setState(() {
        _isSaving = false; // İşlem tamamlandığında değiştir
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
      'waveform': _audioWaveform, // Save the waveform data
    });

    setState(() {
      _isSaving = false; // İşlem tamamlandığında değiştir
    });

    Navigator.pop(context);
  }

  Future<String> _uploadImage(XFile image) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return '';

    File file = File(image.path);
    String fileName = 'journalPics/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    UploadTask task = FirebaseStorage.instance.ref().child(fileName).putFile(file);
    TaskSnapshot snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }

  Future<String> _uploadAudio(String filePath) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return '';

    File file = File(filePath);
    String fileName = 'journalPics/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.aac';
    UploadTask task = FirebaseStorage.instance.ref().child(fileName).putFile(file);
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
    showDatePicker(
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0XFF03DAC6),
              onPrimary: Colors.white,
              surface: Color(0XFF1E1E1E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0XFF1E1E1E),
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
    String formattedDate = DateFormat('MM/dd/yyyy').format(_dateTime);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      backgroundColor: const Color(0xFF1E1E1E),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(nameController, "Header"),
              const SizedBox(height: 20),
              _buildTextField(descriptionController, "Description", maxLines: 3),
              const SizedBox(height: 20),
              _buildDateField(formattedDate),
              const SizedBox(height: 20),
              _buildImageSelection(),
              const SizedBox(height: 20),
              _buildAudioRecordingSection(),
              const SizedBox(height: 30),
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 2),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: "Enter $label",
            hintStyle: const TextStyle(color: Color.fromARGB(150, 255, 255, 255)),
            filled: true,
            fillColor: const Color(0X3F607D8B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String formattedDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Date",
          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: _showDatePicker,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0X3F607D8B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.white),
                ),
                const Icon(Icons.calendar_today, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }

   Widget _buildImageSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Images",
          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w300),
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
                        color: const Color(0X3F607D8B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
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

  Widget _buildAudioRecordingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Audio",
          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 10),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0X3F607D8B),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: _isRecording
                    ? _stopRecording
                    : (_recordedFilePath != null ? (_isPlaying ? _stopAudio : _playAudio) : _startRecording),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? Colors.red : const Color(0XFF03DAC6),
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
                    ? _buildWaveform()
                    : const Center(
                        child: Text(
                          "Tap to record",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ),
              if (_recordedFilePath != null && !_isRecording)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: _deleteRecording,
                ),
            ],
          ),
        ),
        if (_recordedFilePath != null && !_isRecording)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "Duration: ${_recordedDuration.inMinutes}:${(_recordedDuration.inSeconds % 60).toString().padLeft(2, '0')}",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
      ],
    );
  }


  Widget _buildWaveform() {
    return CustomPaint(
      size: const Size(double.infinity, 30),
      painter: WaveformPainter(_audioWaveform),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0XFF03DAC6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _isSaving ? null : _saveJournalEntry, // İşlem devam ederken butonu devre dışı bırak
        child: const Text("Save Journal Entry"),
      ),
    );
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
