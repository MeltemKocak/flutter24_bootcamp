import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planova/pages/home.dart';
import 'package:planova/pages/pattern_lock_page.dart';
import 'package:planova/utilities/theme.dart';
import 'pattern_setup_page.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planova/pages/journal_page.dart';

class PinSetupPage extends StatefulWidget {
  @override
  _PinSetupPageState createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isPinMismatch = false;

  Future<void> _setupPin() async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (_pinController.text.isEmpty || _confirmPinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PIN fields cannot be empty').tr()),
      );
      return;
    }

    if (_pinController.text != _confirmPinController.text) {
      setState(() {
        _isPinMismatch = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PINs do not match').tr()),
      );
      return;
    } else {
      setState(() {
        _isPinMismatch = false;
      });
    }

    await FirebaseFirestore.instance
        .collection('user_pins')
        .doc(user.uid)
        .set({'pin': int.parse(_pinController.text)});

    final doc = await FirebaseFirestore.instance
        .collection('user_patterns')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PatternLockPage()),
      );
    } else {
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
        title: Text(
          'Set Up PIN',
          style: GoogleFonts.didactGothic(color: theme.welcomeText),
        ).tr(),
        backgroundColor: theme.background,
        iconTheme: IconThemeData(color: theme.addButton),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Homes()),
            );
          },
        ),
      ),
      backgroundColor: theme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                style: GoogleFonts.didactGothic(color: theme.welcomeText),
                decoration: InputDecoration(
                  labelText: 'PIN'.tr(),
                  labelStyle:
                      GoogleFonts.didactGothic(color: theme.welcomeText),
                  filled: true,
                  fillColor: theme.addButton.withOpacity(0.2),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.welcomeText),
                    borderRadius: BorderRadius.circular(20.0),
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
                keyboardType: TextInputType.number,
                style: GoogleFonts.didactGothic(color: theme.welcomeText),
                decoration: InputDecoration(
                  labelText: 'Confirm PIN'.tr(),
                  labelStyle:
                      GoogleFonts.didactGothic(color: theme.welcomeText),
                  filled: true,
                  fillColor: theme.addButton.withOpacity(0.2),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: _isPinMismatch ? Colors.red : theme.welcomeText),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: _isPinMismatch ? Colors.red : theme.welcomeText),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _setupPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.addButton,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12.0),
                    side: BorderSide(
                        color: Colors.transparent),
                  ),
                ),
                child: Text(
                  'Confirm PIN',
                  style: GoogleFonts.didactGothic(
                    color: theme.addButtonIcon,
                  ),
                ).tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
