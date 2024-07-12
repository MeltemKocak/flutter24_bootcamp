import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:planova/pages/login_page.dart';
import 'package:planova/pages/home.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication paketini ekledik
// Home sayfasını içe aktardık

// ignore: must_be_immutable
class LoginSubPage extends StatelessWidget {
  LoginSubPage({super.key});

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // FirebaseAuth örneği oluşturduk
  int sliderIndex = 1;

  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width * 0.8;
    double iconButtonWidth = MediaQuery.of(context).size.width * 0.38;

    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 30, 30, 30),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 30),
          _buildWelcomeSlider(context),
          const SizedBox(height: 30),
          _buildContinueSection(context, buttonWidth, iconButtonWidth),
          const SizedBox(height: 50),
          const Text(
            "If you are creating a new account,\nTerms & Conditions and Privacy Policy will apply.",
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0XFF797979),
              fontSize: 13,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSlider(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.symmetric(horizontal: 68),
      child: CarouselSlider.builder(
        options: CarouselOptions(
          height: 88,
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

  Widget _buildContinueSection(BuildContext context, double buttonWidth, double iconButtonWidth) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0XFF274F5E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: Size(buttonWidth, 0), // Genişlik %80
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()), // Login ekranına yönlendirme
              );
            },
            child: const Text(
              "Continue with Email",
              style: TextStyle(
                color: Color(0XFF03DAC6),
                fontSize: 16,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Color(0XFFD6D6D6),
                width: 1.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: Size(buttonWidth, 0), // Genişlik %80
            ),
            onPressed: () {},
            child: const Text(
              "Continue as a Guest",
              style: TextStyle(
                color: Color(0XFFFFFFFF),
                fontSize: 16,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconOutlinedButton(context, "assets/icons/google.ico", iconButtonWidth, onPressed: () => _signInWithGoogle(context)),
              SizedBox(width: MediaQuery.of(context).size.width * 0.04),
              _buildIconOutlinedButton(context, null, iconButtonWidth, icon: const Icon(
                Icons.key,
                color: Colors.white,
                size: 30,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconOutlinedButton(
    BuildContext context,
    String? assetPath,
    double buttonWidth, {
    Widget? icon,
    VoidCallback? onPressed,
  }) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(
          color: Color(0XFFD6D6D6),
          width: 1.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: EdgeInsets.zero,
        minimumSize: Size(buttonWidth, 60), // Genişlik %40, yükseklik sabit
      ),
      onPressed: onPressed,
      child: SizedBox(
        width: buttonWidth, // Genişlik %40
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

    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

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
          MaterialPageRoute(builder: (context) => const Home()), // Home sayfasına yönlendirme
        );
      }
    } catch (e) {
      showToast(context, message: "Some error occurred: $e");
    }
  }

  void showToast(BuildContext context, {required String message}) {
    // Show toast method implementation
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class WelcomesliderItemWidget extends StatelessWidget {
  const WelcomesliderItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          "Login or Sign Up",
          style: TextStyle(
            color: Color(0XFFFFFFFF),
            fontSize: 24,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Please select your preferred method to continue setting up your account",
          maxLines: 2,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0XFF797979),
            fontSize: 16,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
