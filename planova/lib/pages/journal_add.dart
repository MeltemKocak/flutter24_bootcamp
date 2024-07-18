// ignore_for_file: library_private_types_in_public_api, unused_element, prefer_const_constructors, depend_on_referenced_packages, prefer_const_literals_to_create_immutables, unused_field, no_leading_underscores_for_local_identifiers, prefer_interpolation_to_compose_strings, avoid_print, unused_import

import 'dart:convert';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart'; // ignore_for_file: must_be_immutable
import 'package:intl/intl.dart'; // intl paketini ekleyin


class JournalAddSubPage extends StatefulWidget {
  const JournalAddSubPage({super.key});

  @override
  _JournalAddSubPageState createState() => _JournalAddSubPageState();
}

class _JournalAddSubPageState extends State<JournalAddSubPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController edittextController = TextEditingController();
  FocusNode taskNameFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();




//********************************************* */
XFile? _image;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Picker Example')),
      body: _buildImageSection(context),
    );
  }*/
//***************************************************** */

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0XFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildColumnVector(context),
              const SizedBox(height: 26),
             
              _buildHeaderSection(context),
              const SizedBox(height: 14),
              _buildDescriptionSection(context),
              const SizedBox(height: 24),
              _buildImageSection(context),
              const SizedBox(height: 50,),
              _buildRecordingSection(context),
              const SizedBox(height: 50),
               _buildDateTime(context),
              const SizedBox(height: 150),
            ],
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: _buildAiButton(context),
          ),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildColumnVector(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            width: double.maxFinite,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: SvgPicture.asset(
                      "assets/images/img_vector.svg",
                    ),
                  ),
                ),
                const Text(
                  "Journal Add",
                  style: TextStyle(
                    color: Color(0XFFFFFFFF),
                    fontSize: 24,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SizedBox(
                      height: 38,
                      width: 38,
                      child: SvgPicture.asset(
                        "assets/images/img_check.svg",
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.maxFinite,
            child: Row(
              children: [
                const Text(
                  "Header",
                  style: TextStyle(
                    color: Color(0XFFFFFFFF),
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: SizedBox(
                      height: 16,
                      width: 16,
                      child: SvgPicture.asset(
                        "assets/images/img_task_logo.svg",
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: double.maxFinite,
            child: TextFormField(
              controller: nameController,
              focusNode: taskNameFocusNode,
              style: const TextStyle(
                color: Colors.white, // Yazı rengi beyaz
              ),
              decoration: InputDecoration(
                hintText: "Enter Header",
                hintStyle: const TextStyle(
                  color: Color.fromARGB(150, 255, 255, 255),
                  fontSize: 15,
                  fontFamily: 'Roboto',
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  borderSide: BorderSide.none,
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  borderSide: BorderSide.none,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0X3F607D8B),
                isDense: true,
              ),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(descriptionFocusNode);
              },
            ),
          )
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildDescriptionSection(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.maxFinite,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Description",
                    style: TextStyle(
                      color: Color(0XFFFFFFFF),
                      fontSize: 15,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: SizedBox(
                    height: 12,
                    width: 10,
                    child: SvgPicture.asset(
                      "assets/images/img_describtion_logo.svg",
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: double.maxFinite,
            child: TextFormField(
              controller: edittextController,
              focusNode: descriptionFocusNode,
              style: const TextStyle(
                color: Colors.white, // Yazı rengi beyaz
              ),
              textInputAction: TextInputAction.done,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Enter Description",
                hintStyle: const TextStyle(
                  color: Color.fromARGB(150, 255, 255, 255),
                  fontSize: 15,
                  fontFamily: 'Roboto',
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  borderSide: BorderSide.none,
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  borderSide: BorderSide.none,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0X3F607D8B),
                isDense: true,
                contentPadding: const EdgeInsets.all(12),
              ),
              onFieldSubmitted: (_) {
                FocusScope.of(context).unfocus();
              },
            ),
          )
        ],
      ),
    );
  }



//******************************************************* */


Widget _buildImageSection(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.maxFinite,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Image",
                    style: TextStyle(
                      color: Color(0XFFFFFFFF),
                      fontSize: 15,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: SizedBox(
                    height: 12,
                    width: 10,
                    child: SvgPicture.asset(
                      "assets/images/img_image_logo.svg",
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: double.maxFinite,
            child: ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0X3F607D8B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.image,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Select Image",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_image != null) ...[
            const SizedBox(height: 20),
            Image.file(
              File(_image!.path),
              height: 200,
            ),
          ],
        ],
      ),
    );
  }


//******************************************************* */

  FlutterSoundRecorder? _soundRecorder;
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    _soundRecorder = FlutterSoundRecorder();
    _openRecorder();
  }

  Future<void> _openRecorder() async {
    await _soundRecorder!.openRecorder();
  }

  @override
  void dispose() {
    _soundRecorder?.closeRecorder();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      String path = 'path/to/your/audio/file.aac';
      await _soundRecorder!.startRecorder(
        toFile: path,
        codec: Codec.aacADTS,
      );
      setState(() {
        _recordedFilePath = path;
      });
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _soundRecorder!.stopRecorder();
      setState(() {});
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Widget _buildRecordingSection(BuildContext context) {
  return Container(
    width: double.maxFinite,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.maxFinite,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.center,
                child: Text(
                  "Record",
                  style: TextStyle(
                    color: Color(0XFFFFFFFF),
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: SizedBox(
                  height: 12,
                  width: 10,
                  /*child: Icon(
                    Icons.mic,
                    color: Colors.white,
                  ),*/
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: double.maxFinite,
          child: ElevatedButton(
            onPressed: _recordedFilePath == null ? _startRecording : _stopRecording,
            style: ElevatedButton.styleFrom(
              backgroundColor: _recordedFilePath == null ? Colors.red : Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _recordedFilePath == null ? Icons.mic : Icons.stop,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  _recordedFilePath == null ? "Start Recording" : "Stop Recording",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_recordedFilePath != null) ...[
          const SizedBox(height: 20),
          Text('Recorded File: $_recordedFilePath'),
        ],
      ],
    ),
  );
}


  /*@override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.maxFinite,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Image",
                    style: TextStyle(
                      color: Color(0XFFFFFFFF),
                      fontSize: 15,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: SizedBox(
                    height: 12,
                    width: 10,
                    child: SvgPicture.asset(
                      "assets/images/img_image_logo.svg",
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 2),
          _buildRecordingSection(),
          if (_recordedFilePath != null) ...[
            const SizedBox(height: 20),
            Text('Recorded File: $_recordedFilePath'),
          ],
        ],
      ),
    );
  }
*/


//***************************************************************************** */

//create datetime variable
DateTime _dateTime=DateTime.now();

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),

builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: Color.fromARGB(255, 8, 217, 193), // Başlık ve ok butonlarının rengi
            onPrimary: Colors.black, // Başlıktaki yazı rengi
            onSurface: Colors.black, // Tarih metin rengi
          ),
          dialogBackgroundColor: Colors.white,
        ),
        child: child!,
      );
}
    ).then((value) {
      setState(() {
        if (value != null) {
          _dateTime = value;
        }
      });
    });
  }

  Widget _buildDateTime(BuildContext context) {
    // Format the date to "d MMMM" (e.g., 14 April)
    String formattedDate = DateFormat('d MMMM').format(_dateTime);
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.maxFinite,
          child: Text(
            formattedDate, //_dateTime.toString(),
            style: TextStyle(
              color: Color(0XFFFFFFFF),
              fontSize: 15,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.maxFinite,
          child: MaterialButton(
            onPressed: _showDatePicker,
            color: Color.fromARGB(255, 44, 213, 204),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Choose Date',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  /// Section Widget
  Widget _buildAiButton(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 70,
      width: 70,
      padding: const EdgeInsets.all(
        0,
      ),
      decoration: BoxDecoration(
        color: const Color(0XFF03DAC6),
        borderRadius: BorderRadius.circular(
          16,
        ),
      ),
      child: const SizedBox(
        child: Icon(Icons.psychology_outlined, color: Colors.white, size: 45),
      ),
    );
  }
}