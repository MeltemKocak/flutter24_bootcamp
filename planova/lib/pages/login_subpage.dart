import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:planova/pages/login_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planova/pages/home.dart';
import 'package:planova/utilities/theme.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginSubPage extends StatelessWidget {
  LoginSubPage({super.key});

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  int sliderIndex = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    double buttonWidth = MediaQuery.of(context).size.width * 0.8;
    double iconButtonWidth = MediaQuery.of(context).size.width * 0.38;

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              _buildWelcomeSlider(context, theme),
              const SizedBox(height: 10), // Reduced from 20 to 10
              _buildContinueSection(
                  context, buttonWidth, iconButtonWidth, theme),
              const SizedBox(height: 20),
              Text(
                "If you are creating a new account,\nTerms & Conditions and Privacy Policy will apply.",
                maxLines: 2,
                textAlign: TextAlign.center,
                style: GoogleFonts.didactGothic(
                  color: theme.subText,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ).tr(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSlider(BuildContext context, CustomThemeData theme) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.8, // Adjust this value to set the desired width
      margin: const EdgeInsets.symmetric(
          horizontal: 12), // Adjust the horizontal margin as needed
      child: CarouselSlider.builder(
        options: CarouselOptions(
          height: 138,
          initialPage: 0,
          autoPlay: true,
          viewportFraction: 1.0,
          enableInfiniteScroll: false,
          scrollDirection: Axis.horizontal,
          onPageChanged: (index, reason) {
            sliderIndex = index;
          },
        ),
        itemCount: 1,
        itemBuilder: (context, index, realIndex) {
          return const WelcomesliderItemWidget();
        },
      ),
    );
  }

  Widget _buildContinueSection(BuildContext context, double buttonWidth,
      double iconButtonWidth, CustomThemeData theme) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(vertical: 10), // Reduced from 14 to 10
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.welcomeButton,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12), // Reduced from 14 to 12
              minimumSize: Size(buttonWidth, 0), // Width 80%
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        LoginScreen()), // Navigate to Login screen
              );
            },
            child: Text(
              "Continue with Email",
              style: GoogleFonts.didactGothic(
                color: theme.welcomeText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ).tr(),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: theme.borderColor,
                width: 1.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: Size(buttonWidth, 0), // Width 80%
            ),
            onPressed: () =>
                _signInAnonymously(context), // Anonymous authentication
            child: Text(
              "Continue as a Guest",
              style: GoogleFonts.didactGothic(
                color: theme.welcomeText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ).tr(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconOutlinedButton(
                  context, "assets/icons/google.ico", buttonWidth, theme,
                  onPressed: () => _signInWithGoogle(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconOutlinedButton(
    BuildContext context,
    String? assetPath,
    double buttonWidth,
    CustomThemeData theme, {
    Widget? icon,
    VoidCallback? onPressed,
  }) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: theme.borderColor,
          width: 1.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: EdgeInsets.zero,
        minimumSize: Size(buttonWidth, 60), // Width 40%, fixed height
      ),
      onPressed: onPressed,
      child: SizedBox(
        width: buttonWidth, // Width 40%
        height: 60,
        child: Center(
          child: assetPath != null
              ? Image.asset(assetPath, width: 24, height: 24)
              : icon,
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final theme =
        Provider.of<ThemeProvider>(context, listen: false).currentTheme;

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        await _firebaseAuth.signInWithCredential(credential);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homes()),
        );
      }
    } catch (e) {
      showToast(context, message: "Some error occurred: $e");
    }
  }

  Future<void> _signInAnonymously(BuildContext context) async {
    final theme =
        Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    try {
      await _firebaseAuth.signInAnonymously();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Homes()),
      );
    } catch (e) {
      showToast(context, message: "Some error occurred: $e");
    }
  }

  void showToast(BuildContext context, {required String message}) {
    final theme =
        Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: GoogleFonts.didactGothic(color: theme.welcomeText),
      ),
      backgroundColor: theme.welcomeButton,
    ));
  }
}

class WelcomesliderItemWidget extends StatelessWidget {
  const WelcomesliderItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Login or Sign Up",
          style: GoogleFonts.didactGothic(
            color: theme.welcomeText,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ).tr(),
        const SizedBox(height: 8),
        Text(
          "Please select your preferred method to continue setting up your account",
          maxLines: 3,
          textAlign: TextAlign.center,
          style: GoogleFonts.didactGothic(
            color: theme.subText,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ).tr(),
      ],
    );
  }
}
