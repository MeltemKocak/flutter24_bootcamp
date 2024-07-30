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
import 'package:planova/pages/photo_view_page.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:planova/utilities/theme.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class JournalEditPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;
  final bool playAudioOnStart;

  const JournalEditPage(
      {required this.docId,
      required this.data,
      this.playAudioOnStart = false,
      super.key});

  @override
  _JournalEditPageState createState() => _JournalEditPageState();
}

class _JournalEditPageState extends State<JournalEditPage> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  final List<XFile> _newImages = [];
  late List<String> _existingImageUrls;
  late DateTime _dateTime;
  FlutterSoundRecorder? _soundRecorder;
  FlutterSoundPlayer? _soundPlayer;
  bool _isRecording = false;
  String? _recordedFilePath;
  String? _existingAudioUrl;
  final ap.AudioPlayer _audioPlayer = ap.AudioPlayer();
  double _decibelLevel = 0.0;
  Duration _recordedDuration = Duration.zero;
  List<double> _audioWaveform = [];
  bool _isPlaying = false;
  Duration _audioDuration = Duration.zero;
  Map<String, Duration> _audioDurations = {};
  bool _isAudioLoading = false;
  bool _isSaving = false;
  bool _isPrivate = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.data['name']);
    descriptionController =
        TextEditingController(text: widget.data['description']);
    _existingImageUrls = List<String>.from(widget.data['imageUrls'] ?? []);
    _dateTime = widget.data['date'] is Timestamp
        ? (widget.data['date'] as Timestamp).toDate()
        : widget.data['date'];
    _existingAudioUrl = widget.data['audioUrl'];
    _isPrivate = widget.data['isPrivate'] ?? false;
    _soundRecorder = FlutterSoundRecorder();
    _soundPlayer = FlutterSoundPlayer();
    _openRecorder();
    _openPlayer();
    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
      });
    });
    if (_existingAudioUrl != null) {
      _initializeAudioDuration(_existingAudioUrl!);
      _initializeAudioWaveform();
      if (widget.playAudioOnStart) {
        _playAudio();
      }
    }
  }

  Future<void> _initializeAudioWaveform() async {
    setState(() {
      _audioWaveform = List<double>.from(widget.data['waveform'] ?? []);
    });
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

  Future<void> _playAudio() async {
    if (_recordedFilePath != null) {
      await _audioPlayer.play(ap.UrlSource(_recordedFilePath!));
    } else if (_existingAudioUrl != null) {
      await _audioPlayer.play(ap.UrlSource(_existingAudioUrl!));
    }
    setState(() {
      _isPlaying = true;
    });
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _saveJournalEntry() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });

    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('Header cannot be empty'))),
      );
      setState(() {
        _isSaving = false;
      });
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

    await FirebaseFirestore.instance
        .collection('journal')
        .doc(widget.docId)
        .update({
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

    Navigator.pop(context, {
      'name': nameController.text,
      'description': descriptionController.text,
      'date': _dateTime,
      'imageUrls': imageUrls,
      'audioUrl': audioUrl,
      'waveform': _audioWaveform,
      'isPrivate': _isPrivate,
    });
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
        _newImages.insert(0, image);
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
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Provider.of<ThemeProvider>(context)
                  .currentTheme
                  .focusDayColor,
              onPrimary: Provider.of<ThemeProvider>(context)
                  .currentTheme
                  .calenderNumbers,
              surface:
                  Provider.of<ThemeProvider>(context).currentTheme.background,
              onSurface: Provider.of<ThemeProvider>(context)
                  .currentTheme
                  .calenderNumbers,
            ),
            dialogBackgroundColor:
                Provider.of<ThemeProvider>(context).currentTheme.background,
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

  Future<void> _deleteJournalEntry() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot journalDoc = await FirebaseFirestore.instance
        .collection('journal')
        .doc(widget.docId)
        .get();
    Map<String, dynamic> journalData =
        journalDoc.data() as Map<String, dynamic>;

    await FirebaseFirestore.instance.collection('deleted_tasks').add({
      'name': journalData['name'],
      'description': journalData['description'],
      'deletedDate': DateTime.now(),
      'collection': 'journal',
      'docId': widget.docId,
      'userId': user.uid,
      'data': journalData,
    });

    await FirebaseFirestore.instance
        .collection('journal')
        .doc(widget.docId)
        .delete();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    String formattedDate = DateFormat('MM/dd/yyyy').format(_dateTime);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.calenderNumbers),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: theme.calenderNumbers),
            onPressed: _deleteJournalEntry,
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
              _buildTextField(nameController, tr("Header"), theme),
              const SizedBox(height: 20),
              _buildTextField(descriptionController, tr("Description"), theme,
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
          style: TextStyle(
              color: theme.welcomeText,
              fontSize: 15,
              fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 2),
        TextFormField(
          controller: controller,
          style: TextStyle(color: theme.welcomeText),
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: tr("Enter") + " $label",
            hintStyle: TextStyle(color: theme.borderColor.withOpacity(0.6)),
            filled: true,
            fillColor: theme.habitCardBackground.withOpacity(0.5),
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
          style: TextStyle(
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
              color: theme.habitCardBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(color: theme.welcomeText),
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
          style: TextStyle(
              color: theme.welcomeText,
              fontSize: 15,
              fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 2),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ..._newImages.asMap().entries.map((entry) {
                return _buildImageThumbnail(entry.value.path,
                    () => _removeImage(entry.key, false), theme);
              }),
              ..._existingImageUrls.asMap().entries.map((entry) {
                return _buildImageThumbnail(
                    entry.value, () => _removeImage(entry.key, true), theme,
                    isNetwork: true);
              }),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.habitCardBackground.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.add,
                    color: theme.welcomeText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageThumbnail(
      String path, VoidCallback onRemove, CustomThemeData theme,
      {bool isNetwork = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Stack(
        children: [
          GestureDetector(
            onTap: isNetwork ? () => _viewPhoto(path) : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: isNetwork
                  ? Image.network(
                      path,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(path),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.checkBoxActiveColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: theme.welcomeText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioRecordingSection(CustomThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr("Audio"),
          style: TextStyle(
              color: theme.welcomeText,
              fontSize: 15,
              fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 10),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: theme.habitCardBackground.withOpacity(0.5),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (_isRecording) {
                    _stopRecording();
                  } else if (_isPlaying) {
                    _stopAudio();
                  } else if (_recordedFilePath != null ||
                      _existingAudioUrl != null) {
                    _playAudio();
                  } else {
                    _startRecording();
                  }
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording
                        ? theme.checkBoxActiveColor
                        : theme.addButton,
                  ),
                  child: Icon(
                    _isRecording
                        ? Icons.stop
                        : _isPlaying
                            ? Icons.stop
                            : (_recordedFilePath != null ||
                                    _existingAudioUrl != null)
                                ? Icons.play_arrow
                                : Icons.mic,
                    color: theme.welcomeText,
                  ),
                ),
              ),
              Expanded(
                child: _isRecording ||
                        _recordedFilePath != null ||
                        _existingAudioUrl != null
                    ? CustomPaint(
                        size: const Size(double.infinity, 30),
                        painter:
                            WaveformPainter(_audioWaveform, theme.addButton),
                      )
                    : Center(
                        child: Text(
                          tr("Tap to record"),
                          style: TextStyle(color: theme.welcomeText),
                        ),
                      ),
              ),
              if ((_recordedFilePath != null || _existingAudioUrl != null) &&
                  !_isRecording)
                IconButton(
                  icon: Icon(Icons.delete, color: theme.welcomeText),
                  onPressed: _removeAudio,
                ),
            ],
          ),
        ),
        if (_recordedFilePath != null || _existingAudioUrl != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _audioDurations.containsKey(_existingAudioUrl)
                  ? tr("Duration") + ": ${_formatDuration(_audioDurations[_existingAudioUrl]!)}"
                  : tr("Loading duration..."),
              style: TextStyle(color: theme.welcomeText, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildPrivacyButton(CustomThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr("Private"),
          style: TextStyle(
              color: theme.welcomeText,
              fontSize: 15,
              fontWeight: FontWeight.w300),
          textAlign: TextAlign.left,
        ),
        SizedBox(height: 2),
        Container(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _isPrivate = !_isPrivate;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isPrivate
                  ? theme.checkBoxActiveColor.withOpacity(0.6)
                  : theme.addButton,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              _isPrivate ? tr('Private') : tr('Public'),
              style: TextStyle(color: theme.addButtonIcon),
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
        child: Text(tr("Save Changes"),
            style: TextStyle(color: theme.addButtonIcon)),
      ),
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
