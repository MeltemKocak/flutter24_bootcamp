import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'private_journal_page.dart';
import 'pin_setup_page.dart';
import 'pattern_lock_page.dart'; // Import PatternLockPage

class PinEntryPage extends StatefulWidget {
  @override
  _PinEntryPageState createState() => _PinEntryPageState();
}

class _PinEntryPageState extends State<PinEntryPage> {
  final TextEditingController _pinController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isPinIncorrect = false;

  Future<void> _verifyPin() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final pin = _pinController.text;
    final doc = await FirebaseFirestore.instance
        .collection('user_pins')
        .doc(user.uid)
        .get();

    if (doc.exists && doc.data()!['pin'] == pin) {
      setState(() {
        _isPinIncorrect = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PrivateJournalPage(),
        ),
      );
    } else {
      setState(() {
        _isPinIncorrect = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect PIN')),
      );
    }
  }

  Future<void> _checkPinSetup() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('user_pins')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      showDialog(
        context: context,
        builder: (context) => PinSetupPage(),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPinSetup();
  }

  void _navigateToPatternLock() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatternLockPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _pinController,
              obscureText: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'PIN',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _isPinIncorrect ? Colors.red : Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _isPinIncorrect ? Colors.red : Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyPin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0XFF03DAC6),
              ),
              child: Text('Submit PIN'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _navigateToPatternLock,
              child: Text(
                'Use Pattern',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
