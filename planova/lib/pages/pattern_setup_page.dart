import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        _confirmPattern.add(index);
      } else {
        _pattern.add(index);
      }
    });
  }

  Future<void> _setupPattern() async {
    final user = _auth.currentUser;
    if (user == null) return;

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
        SnackBar(content: Text('Patterns do not match, try again')),
      );
    }
  }

  void _confirmPatternSetup() {
    setState(() {
      _isConfirming = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isConfirming ? 'Confirm Pattern' : 'Set Up Pattern'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      backgroundColor: const Color(0xFF1E1E1E),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              _isConfirming ? 'Draw the pattern again to confirm' : 'Draw your pattern',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 20),
            _buildPatternLock(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isConfirming ? _setupPattern : _confirmPatternSetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0XFF03DAC6),
              ),
              child: Text(_isConfirming ? 'Confirm Pattern' : 'Set Up Pattern'),
            ),
            if (_isPatternMismatch)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Patterns do not match, please try again',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternLock() {
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
                color: isSelected ? Colors.blue : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}
