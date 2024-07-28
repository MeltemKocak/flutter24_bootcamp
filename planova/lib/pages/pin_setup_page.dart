import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planova/pages/pattern_lock_page.dart';
import 'package:planova/utilities/theme.dart';
import 'pattern_setup_page.dart'; // Import PatternSetupPage
import 'package:provider/provider.dart';

class PinSetupPage extends StatefulWidget {
  @override
  _PinSetupPageState createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _setupPin() async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (_pinController.text != _confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PINs do not match')),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('user_pins')
        .doc(user.uid)
        .set({'pin': _pinController.text});

    // Check if the pattern is already set
    final doc = await FirebaseFirestore.instance
        .collection('user_patterns')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      // If the pattern exists, navigate to the pattern lock page for confirmation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PatternLockPage()),
      );
    } else {
      // If the pattern does not exist, navigate to the pattern setup page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PatternSetupPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Set Up PIN'),
        backgroundColor: theme.appBar,
      ),
      backgroundColor: theme.background,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _pinController,
              obscureText: true,
              style: TextStyle(color: theme.welcomeText),
              decoration: InputDecoration(
                labelText: 'PIN',
                labelStyle: TextStyle(color: theme.welcomeText),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.welcomeText),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.welcomeText),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _confirmPinController,
              obscureText: true,
              style: TextStyle(color: theme.welcomeText),
              decoration: InputDecoration(
                labelText: 'Confirm PIN',
                labelStyle: TextStyle(color: theme.welcomeText),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.welcomeText),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.welcomeText),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _setupPin,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.addButton,
              ),
              child: Text('Confirm PIN'),
            ),
          ],
        ),
      ),
    );
  }
}
