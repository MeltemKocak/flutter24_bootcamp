import 'package:flutter/material.dart';
import 'package:planova/pages/journal_only_text.dart';
import 'package:planova/pages/journal_text_image.dart';
import 'package:planova/pages/journal_voice.dart';
import 'package:planova/pages/journal_voice_text.dart';

class JournalPage extends StatefulWidget {
  
  const JournalPage({ Key? key }) : super(key: key);

  @override
  _TodayPageState createState() => _TodayPageState();
}

class _TodayPageState extends State<JournalPage> {



 
  @override
  Widget build(BuildContext context) {
    return Card(
                color: const Color.fromARGB(255, 30, 30, 30),

          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.only(top:50),
          ),
          
          
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  only_text(),
                  text_image(),
                  voice_text_image(),
                  voice(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}