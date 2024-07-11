import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:planova/pages/login_page.dart'; // Login sayfasını içe aktardık

// ignore_for_file: must_be_immutable
class LoginSubPage extends StatelessWidget {
  LoginSubPage({super.key});

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
        )
        ],
      ),
    );
  }

  /// Section Widget
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

  /// Section Widget
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
                MaterialPageRoute(builder: (context) => Login()), // Login ekranına yönlendirme
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
              _buildIconOutlinedButton(context, "assets/images/google.ico", iconButtonWidth),
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
      onPressed: () {},
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
        )
      ],
    );
  }
}
