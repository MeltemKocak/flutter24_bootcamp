import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planova/utilities/theme.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'journal_page.dart';

class PatternSetupPage extends StatefulWidget {
  @override
  _PatternSetupPageState createState() => _PatternSetupPageState();
}

class _PatternSetupPageState extends State<PatternSetupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<int> _pattern = [];
  List<int> _confirmPattern = [];
  bool _isConfirming = false;
  bool _isPatternMismatch = false;

  void _addPattern(int index) {
    setState(() {
      if (_isConfirming) {
        if (_confirmPattern.contains(index)) {
          _confirmPattern.remove(index);
        } else {
          _confirmPattern.add(index);
        }
      } else {
        if (_pattern.contains(index)) {
          _pattern.remove(index);
        } else {
          _pattern.add(index);
        }
      }
    });
  }

  Future<void> _setupPattern() async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (_pattern.isEmpty || (_isConfirming && _confirmPattern.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pattern cannot be empty').tr()),
      );
      return;
    }

    if (_pattern.join() == _confirmPattern.join()) {
      await FirebaseFirestore.instance
          .collection('user_patterns')
          .doc(user.uid)
          .set({'pattern': _pattern.join()});

      Navigator.pop(context);
    } else {
      setState(() {
        _isPatternMismatch = true;
        _pattern = [];
        _confirmPattern = [];
        _isConfirming = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Patterns do not match, try again').tr()),
      );
    }
  }

  void _confirmPatternSetup() {
    if (_pattern.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pattern cannot be empty').tr()),
      );
      return;
    }

    setState(() {
      _isConfirming = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isConfirming ? 'Confirm Pattern' : 'Set Up Pattern').tr(),
        backgroundColor: theme.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
              context,
            );
          },
        ),
      ),
      backgroundColor: theme.background,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              _isConfirming
                  ? 'Draw the pattern again to confirm'
                  : 'Draw your pattern',
              style: GoogleFonts.didactGothic(
                textStyle: TextStyle(color: theme.welcomeText, fontSize: 18),
              ),
            ).tr(),
            SizedBox(height: 20),
            _buildPatternLock(theme),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isConfirming ? _setupPattern : _confirmPatternSetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.addButton,
                foregroundColor: theme.welcomeText,
              ),
              child: Text(_isConfirming ? 'Confirm Pattern' : 'Set Up Pattern')
                  .tr(),
            ),
            if (_isPatternMismatch)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Patterns do not match, please try again',
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
          bool isSelected = _isConfirming
              ? _confirmPattern.contains(index)
              : _pattern.contains(index);
          return GestureDetector(
            onTap: () => _addPattern(index),
            child: Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.addButton
                    : theme.borderColor.withAlpha(150),
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}
