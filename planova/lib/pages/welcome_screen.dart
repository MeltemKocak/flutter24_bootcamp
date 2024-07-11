import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:planova/pages/login_subpage.dart'; // Test ekranını içe aktardık

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int sliderIndex = 0; // State içinde tanımlanmalı
  final CarouselController _carouselController = CarouselController(); // CarouselController tanımlanması

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0XFF1E1E1E),
        body: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 104,
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Image.asset(
                  "assets/images/img_rectangle_2769.png",
                  height: 284,
                  width: double.maxFinite,
                ),
              ),
              const SizedBox(height: 62),
              _buildWelcomeSlider(context),
              const SizedBox(height: 28),
              SizedBox(
                height: 8,
                child: AnimatedSmoothIndicator(
                  activeIndex: sliderIndex,
                  count: 3, // Slide sayısını 3 olarak ayarladık
                  axisDirection: Axis.horizontal,
                  effect: const ScrollingDotsEffect(
                    spacing: 6,
                    activeDotColor: Color(0XFF03DAC6),
                    dotColor: Color(0XFFD9D9D9),
                    dotHeight: 8,
                    dotWidth: 8,
                  ),
                ),
              ),
              const SizedBox(height: 4)
            ],
          ),
        ),
        bottomNavigationBar: _buildGetStartedButton(context),
      ),
    );
  }

  /// Section Widget
  Widget _buildWelcomeSlider(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: CarouselSlider.builder(
        carouselController: _carouselController, // CarouselController ekledik
        options: CarouselOptions(
          height: 108,
          initialPage: 0,
          autoPlay: true,
          viewportFraction: 1.0,
          enableInfiniteScroll: true,
          scrollDirection: Axis.horizontal,
          onPageChanged: (index, reason) {
            setState(() {
              sliderIndex = index;
            });
          },
        ),
        itemCount: 3, // Öğelerin sayısını 3 olarak ayarladık
        itemBuilder: (context, index, realIndex) {
          return WelcomesliderItemWidget(index: index);
        },
      ),
    );
  }

  /// Section Widget
  Widget _buildGetStartedButton(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 64,
      margin: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 34,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0XFF274F5E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          visualDensity: const VisualDensity(
            vertical: -4,
            horizontal: -4,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 60,
            vertical: 14,
          ),
        ),
        onPressed: () {
           // Son slayt mı kontrol ediyoruz
            // Belirtilen yere git
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => LoginSubPage(),
            );
          
        },
        child: const Text(
          "Get started",
          style: TextStyle(
            color: Color.fromARGB(200, 3, 218, 198),
            fontSize: 16,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class WelcomesliderItemWidget extends StatelessWidget {
  final int index;

  const WelcomesliderItemWidget({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    // Her slayt için farklı içerik döndürmek için index'i kullanın
    switch (index) {
      case 0:
        return const Column(
          children: [
            Text(
              "Welcome to Planova",
              style: TextStyle(
                color: Color(0XFFFFFFFF),
                fontSize: 27,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Here’s a good place for a brief overview\nof the app or it’s key features.",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0XFF797979),
                fontSize: 17,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        );
      case 1:
        return const Column(
          children: [
            Text(
              "Discover Features",
              style: TextStyle(
                color: Color(0XFFFFFFFF),
                fontSize: 27,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Explore the various features\nthat make our app unique.",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0XFF797979),
                fontSize: 17,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        );
      case 2:
        return const Column(
          children: [
            Text(
              "Get Started Now",
              style: TextStyle(
                color: Color(0XFFFFFFFF),
                fontSize: 27,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Sign up and start using\nthe app today.",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0XFF797979),
                fontSize: 17,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        );
      default:
        return Container();
    }
  }
}
