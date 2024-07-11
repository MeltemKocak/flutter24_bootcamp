import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // ignore_for_file: must_be_immutable

class FirstEmailScreen extends StatelessWidget {
  FirstEmailScreen({super.key});

  TextEditingController emailController = TextEditingController();

  bool newsletterOptIn = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 100,
          titleSpacing: 0,
          title: Row(
            children: [
              IconButton(
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                    Icon(
                      Icons.arrow_back_ios,
                      color: Color.fromARGB(255, 3, 218, 198),
                      size: 28,
                    ),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        color: Color.fromARGB(255, 3, 218, 198),
                        fontSize: 17,
                        
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0XFF1E1E1E),
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEmailSection(context),
              const Spacer(),
              _buildNewsletterOptIn(context),
            ],
          ),
        ),
        bottomNavigationBar: _buildContinueButton(context),
      ),
    );
  }

  /// Section Widget
  Widget _buildEmailSection(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 22),
            SizedBox(
              height: 40,
              width: 40,
              child: Image.asset(
                "assets/images/Frame.png",
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "E-posta ile devam edin",
              style: TextStyle(
                color: Color(0XFFFFFFFF),
                fontSize: 20,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "E-posta adresinin neden gerekli olduğunu açıklamak faydalıdır.",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0XFF797979),
                fontSize: 15,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: TextFormField(
                focusNode: FocusNode(),
                autofocus: true,
                controller: emailController,
                style: const TextStyle(
                  color: Color(0XFF797979),
                  fontSize: 16,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w400,
                ),
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: "E-posta adresi",
                  hintStyle: const TextStyle(
                    color: Color(0XFF797979),
                    fontSize: 16,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0XFF03DAC6),
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0XFF03DAC6),
                      width: 2,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0XFF03DAC6),
                      width: 2,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0XFF03DAC6),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0XFFFFFFFF),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildNewsletterOptIn(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          child: Checkbox(
            shape: const RoundedRectangleBorder(),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            value: newsletterOptIn,
            onChanged: (value) {
              newsletterOptIn = value ?? false;
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            "En son haberler ve kaynaklar\ndirekt olarak gelen kutunuza gelsin",
            style: TextStyle(
              color: Color(0XFF797979),
              fontSize: 15,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w400,
            ),
          ),
        )
      ],
    );
  }

  /// Section Widget
  Widget _buildContinueButton(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 54,
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
            horizontal: 30,
            vertical: 14,
          ),
        ),
        onPressed: () {},
        child: const Text(
          "Devam et",
          style: TextStyle(
            color: Color(0XFF03DAC6),
            fontSize: 16,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
