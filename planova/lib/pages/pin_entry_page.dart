import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planova/utilities/theme.dart';
import 'private_journal_page.dart';
import 'pin_setup_page.dart';
import 'pattern_lock_page.dart';
import 'pattern_setup_page.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

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

    if (pin.isEmpty) {
      setState(() {
        _isPinIncorrect = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PIN cannot be empty', style: GoogleFonts.didactGothic()).tr()),
      );
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('user_pins')
        .doc(user.uid)
        .get();

    if (doc.exists && doc.data()!['pin'] == int.parse(pin)) {
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
        SnackBar(content: Text('Incorrect PIN', style: GoogleFonts.didactGothic()).tr()),
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

  void _navigateToPatternPage() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('user_patterns')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PatternLockPage()), // Pattern oluşturulmuşsa PatternLockPage'e git
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PatternSetupPage()), // Pattern oluşturulmamışsa PatternSetupPage'e git
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        body: GestureDetector(
          onTap: () {},
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: theme.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 200,
                    child: TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      style: GoogleFonts.didactGothic(color: theme.welcomeText),
                      decoration: InputDecoration(
                        labelText: tr('PIN'),
                        labelStyle: GoogleFonts.didactGothic(color: theme.welcomeText),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: _isPinIncorrect ? Colors.red : theme.welcomeText),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: _isPinIncorrect ? Colors.red : theme.welcomeText),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _verifyPin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.addButton,
                    ),
                    child: Text(
                      'Submit PIN',
                      style: GoogleFonts.didactGothic(color: theme.addButtonIcon),
                    ).tr(),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: _navigateToPatternPage,
                    child: Text(
                      tr('Use Pattern'),
                      style: GoogleFonts.didactGothic(color: theme.subText),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
