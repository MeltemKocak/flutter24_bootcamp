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
  List<XFile> _images = [];
  DateTime _dateTime = DateTime.now();
  FlutterSoundRecorder? _soundRecorder;
  FlutterSoundPlayer? _soundPlayer;
  bool _isRecording = false;
  String? _recordedFilePath;
  ap.AudioPlayer _audioPlayer = ap.AudioPlayer();

  @override
  void initState() {
    super.initState();
    _soundRecorder = FlutterSoundRecorder();
    _soundPlayer = FlutterSoundPlayer();
    _openRecorder();
    _openPlayer();
  }

  Future<void> _openRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print("Microphone permission not granted");
      return;
    }
    await _soundRecorder!.openRecorder();
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
      setState(() {
        _recordedFilePath = filePath;
        _isRecording = true;
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

  Future<void> _saveJournalEntry() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Header cannot be empty')),
      );
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
    });

    Navigator.pop(context);
  }

  Future<String> _uploadImage(XFile image) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return '';

    File file = File(image.path);
    String fileName = '${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    UploadTask task = FirebaseStorage.instance.ref().child(fileName).putFile(file);
    TaskSnapshot snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }

  Future<String> _uploadAudio(String filePath) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return '';

    File file = File(filePath);
    String fileName = '${user.uid}/${DateTime.now().millisecondsSinceEpoch}.aac';
    UploadTask task = FirebaseStorage.instance.ref().child(fileName).putFile(file);
    TaskSnapshot snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(image);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _removeAudio() {
    setState(() {
      _recordedFilePath = null;
    });
  }

  void _showDatePicker() {
    showDatePicker(
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
      await _audioPlayer.play(ap.UrlSource(_recordedFilePath!));
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MM/dd/yyyy').format(_dateTime);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1E1E1E),
      ),
      backgroundColor: Color(0xFF1E1E1E),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Header',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(color: Colors.white),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: _showDatePicker,
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: List.generate(5, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: _images.length > index
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(
                                File(_images[index].path),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic),
                  SizedBox(width: 8),
                  Text(_isRecording ? 'recording' : 'start recording'),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording ? Colors.blue : Colors.red,
              ),
            ),
            if (_recordedFilePath != null) ...[
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _playAudio,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow),
                    SizedBox(width: 8),
                    Text('play'),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
            Spacer(),
            ElevatedButton(
              onPressed: _saveJournalEntry,
              child: Icon(Icons.check),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF03DAC6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
