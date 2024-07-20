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
import 'package:planova/pages/photo_view_page.dart'; // Import the correct path
import 'package:audioplayers/audioplayers.dart' as ap;
import 'journal_page.dart'; // Import JournalPage

class JournalEditPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const JournalEditPage({required this.docId, required this.data, super.key});

  @override
  _JournalEditPageState createState() => _JournalEditPageState();
}

class _JournalEditPageState extends State<JournalEditPage> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  List<XFile> _newImages = [];
  late List<String> _existingImageUrls;
  DateTime _dateTime = DateTime.now();
  FlutterSoundRecorder? _soundRecorder;
  FlutterSoundPlayer? _soundPlayer;
  bool _isRecording = false;
  String? _recordedFilePath;
  String? _existingAudioUrl;
  ap.AudioPlayer _audioPlayer = ap.AudioPlayer();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.data['name']);
    descriptionController = TextEditingController(text: widget.data['description']);
    _existingImageUrls = List<String>.from(widget.data['imageUrls'] ?? []);
    _dateTime = (widget.data['date'] as Timestamp).toDate();
    _existingAudioUrl = widget.data['audioUrl'];
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

    List<String> imageUrls = [..._existingImageUrls];
    for (XFile image in _newImages) {
      String imageUrl = await _uploadImage(image);
      imageUrls.add(imageUrl);
    }

    String? audioUrl = _existingAudioUrl;
    if (_recordedFilePath != null) {
      audioUrl = await _uploadAudio(_recordedFilePath!);
    }

    await FirebaseFirestore.instance.collection('journal').doc(widget.docId).update({
      'name': nameController.text,
      'description': descriptionController.text,
      'date': _dateTime,
      'imageUrls': imageUrls,
      'audioUrl': audioUrl,
    });

    Navigator.pop(context); // Use pop instead of pushReplacement
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
        _newImages.insert(0, image); // Insert at the beginning
      });
    }
  }

  void _removeImage(int index, bool isExisting) {
    setState(() {
      if (isExisting) {
        _existingImageUrls.removeAt(index);
      } else {
        _newImages.removeAt(index);
      }
    });
  }

  void _removeAudio() {
    setState(() {
      _existingAudioUrl = null;
      _recordedFilePath = null;
    });
  }

  Future<void> _playAudio() async {
    if (_recordedFilePath != null) {
      await _audioPlayer.play(ap.UrlSource(_recordedFilePath!));
    } else if (_existingAudioUrl != null) {
      await _audioPlayer.play(ap.UrlSource(_existingAudioUrl!));
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

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _dateTime,
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

  Future<void> _deleteJournalEntry() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('journal').doc(widget.docId).delete();

    Navigator.pop(context); // Use pop instead of pushReplacement
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MM/dd/yyyy').format(_dateTime);
    return Scaffold(
      appBar: AppBar(
        title: Text('Task'),
        backgroundColor: Color(0xFF1E1E1E),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: _deleteJournalEntry,
          ),
        ],
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
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _newImages.length + _existingImageUrls.length + 1,
                itemBuilder: (context, index) {
                  if (index < _newImages.length) {
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(
                              File(_newImages[index].path),
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () => _removeImage(index, false),
                          ),
                        ),
                      ],
                    );
                  } else if (index < _newImages.length + _existingImageUrls.length) {
                    int existingIndex = index - _newImages.length;
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () => _viewPhoto(_existingImageUrls[existingIndex]),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                _existingImageUrls[existingIndex],
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () => _removeImage(existingIndex, true),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
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
            if (_existingAudioUrl != null || _recordedFilePath != null) ...[
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
