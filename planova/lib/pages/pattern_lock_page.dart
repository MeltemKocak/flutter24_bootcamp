import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planova/utilities/theme.dart';
import 'private_journal_page.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class PatternLockPage extends StatefulWidget {
  @override
  _PatternLockPageState createState() => _PatternLockPageState();
}

class _PatternLockPageState extends State<PatternLockPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<int> _pattern = [];
  bool _isPatternIncorrect = false;

  void _addPattern(int index) {
    setState(() {
      _pattern.add(index);
    });
  }

  Future<void> _verifyPattern() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('user_patterns')
        .doc(user.uid)
        .get();

    if (doc.exists && doc.data()!['pattern'] == _pattern.join()) {
      setState(() {
        _isPatternIncorrect = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PrivateJournalPage()),
      );
    } else {
      setState(() {
        _isPatternIncorrect = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect Pattern').tr()),
      );
      setState(() {
        _pattern = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Pattern').tr(),
        backgroundColor: theme.background,
      ),
      backgroundColor: theme.background,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Draw your pattern to unlock',
              style: TextStyle(color: theme.welcomeText, fontSize: 18),
            ).tr(),
            SizedBox(height: 20),
            _buildPatternLock(theme),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyPattern,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.addButton,
              ),
              child: Text(
                'Verify Pattern',
                style: TextStyle(color: theme.addButtonIcon),
              ).tr(),
            ),
            if (_isPatternIncorrect)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Incorrect Pattern, please try again',
                  style: TextStyle(color: Colors.red),
                ).tr(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternLock(CustomThemeData theme) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          bool isSelected = _pattern.contains(index);
          return GestureDetector(
            onTap: () => _addPattern(index),
            child: Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? theme.welcomeDotActive : theme.welcomeDot,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}
