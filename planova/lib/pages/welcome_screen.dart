import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:planova/utilities/theme.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:planova/pages/login_subpage.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int sliderIndex = 0;
  final CarouselController _carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.background,
        body: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  child: Image.asset(
                                    "assets/images/img_rectangle_2769.png",
                                    height: 284,
                                    width: double.maxFinite,
                                  ),
                                ),
                                const SizedBox(height: 62),
                                _buildWelcomeSlider(),
                                const SizedBox(height: 28),
                                SizedBox(
                                  height: 8,
                                  child: AnimatedSmoothIndicator(
                                    activeIndex: sliderIndex,
                                    count: 3,
                                    axisDirection: Axis.horizontal,
                                    effect: ScrollingDotsEffect(
                                      spacing: 6,
                                      activeDotColor: theme.welcomeDotActive,
                                      dotColor: theme.welcomeDot,
                                      dotHeight: 8,
                                      dotWidth: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                          _buildGetStartedButton(theme),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 16,
              right: 16,
              child: _buildThemeToggleButton(context), // Tema değiştirici buton sağ üste eklendi
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSlider() {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: CarouselSlider.builder(
        carouselController: _carouselController,
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
        itemCount: 3,
        itemBuilder: (context, index, realIndex) {
          return WelcomesliderItemWidget(index: index, theme: theme);
        },
      ),
    );
  }

  Widget _buildGetStartedButton(CustomThemeData theme) {
    return Container(
      width: double.maxFinite,
      height: 64,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 34),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.welcomeButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          visualDensity: const VisualDensity(
            vertical: -4,
            horizontal: -4,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => LoginSubPage(),
          );
        },
        child: Text(
          "Get started",
          style: TextStyle(
            color: theme.welcomeText,
            fontSize: 16,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
          ),
        ).tr(),
      ),
    );
  }

  Widget _buildThemeToggleButton(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).themeValue == 2;
    return IconButton(
      icon: Icon(
        isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
        color: Provider.of<ThemeProvider>(context).currentTheme.welcomeText,
      ),
      onPressed: () {
        Provider.of<ThemeProvider>(context, listen: false).setThemeValue(
          isDarkMode ? 1 : 2,
        );
      },
    );
  }
}

class WelcomesliderItemWidget extends StatelessWidget {
  final int index;
  final CustomThemeData theme;

  const WelcomesliderItemWidget({super.key, required this.index, required this.theme});

  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 0:
        return Column(
          children: [
            Text(
              "Welcome to Planova",
              style: TextStyle(
                color: theme.welcomeText,
                fontSize: 27,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
              ),
            ).tr(),
            const SizedBox(height: 8),
            Text(
              "Here’s a good place for a brief overview\nof the app or it’s key features.",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.subText,
                fontSize: 17,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
              ),
            ).tr(),
          ],
        );
      case 1:
        return Column(
          children: [
            Text(
              "Discover Features",
              style: TextStyle(
                color: theme.welcomeText,
                fontSize: 27,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
              ),
            ).tr(),
            const SizedBox(height: 8),
            Text(
              "Explore the various features\nthat make our app unique.",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.subText,
                fontSize: 17,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
              ),
            ).tr(),
          ],
        );
      case 2:
        return Column(
          children: [
            Text(
              "Get Started Now",
              style: TextStyle(
                color: theme.welcomeText,
                fontSize: 27,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
              ),
            ).tr(),
            const SizedBox(height: 8),
            Text(
              "Sign up and start using\nthe app today.",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.subText,
                fontSize: 17,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
              ),
            ).tr(),
          ],
        );
      default:
        return Container();
    }
  }
}
