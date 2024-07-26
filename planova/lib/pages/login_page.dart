import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:planova/utilities/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool newsletterOptIn = false;
  bool isExistingUser = false;
  bool isLoading = false;
  bool showPasswordField = false;
  bool isPasswordWrong = false;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<void> checkEmail() async {
    setState(() {
      isLoading = true;
    });
    try {
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(emailController.text);
      setState(() {
        isExistingUser = methods.isNotEmpty;
        showPasswordField = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    }
  }

  Future<void> signInOrSignUp() async {
    if (isExistingUser) {
      try {
        await Auth().signin(
          email: emailController.text,
          password: passwordController.text,
          context: context,
        );
      } catch (e) {
        setState(() {
          isPasswordWrong = true;
        });
        showErrorMessage('Sifre yanlıs. Lütfen tekrar deneyin.');
      }
    } else {
      try {
        await Auth().signup(
          email: emailController.text,
          password: passwordController.text,
          context: context,
        );
      } catch (e) {
        showErrorMessage('Kayıt hatası: $e');
      }
    }
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: null,
          toolbarHeight: 100,
          titleSpacing: 0,
          title: Row(
            children: [
              IconButton(
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                    const Icon(
                      Icons.arrow_back_ios,
                      color: Color.fromARGB(255, 3, 218, 198),
                      size: 28,
                    ),
                    const Text(
                      'Geri',
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
        body: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEmailSection(context),
                if (showPasswordField) _buildPasswordSection(context),
                const SizedBox(height: 20),
                _buildForgotPassword(context),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildContinueButton(context),
      ),
    );
  }

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
              child: Image.asset("assets/images/Frame.png"),
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
            TextFormField(
              controller: emailController,
              style: const TextStyle(
                color: Color(0XFF797979),
                fontSize: 18,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
              ),
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
                    width: 2.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0XFF03DAC6),
                    width: 2.5,
                  ),
                ),
                filled: true,
                fillColor: const Color(0XFFFFFFFF),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            isExistingUser ? "Şifrenizi girin" : "Yeni sifre olusturun",
            style: const TextStyle(
              color: Color(0XFFFFFFFF),
              fontSize: 18,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            style: const TextStyle(color: Color(0XFF797979)),
            decoration: InputDecoration(
              hintText: isExistingUser ? "Sifre" : "Yeni sifre",
              hintStyle: const TextStyle(color: Color(0XFF797979)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  width: 2.5,
                  color: isPasswordWrong ? Colors.red : const Color(0XFF03DAC6),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  width: 2.5,
                  color: isPasswordWrong ? Colors.red : const Color(0XFF03DAC6),
                ),
              ),
              filled: true,
              fillColor: const Color(0XFFFFFFFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
            );
          },
          child: const Text(
            "Sifremi unuttum",
            style: TextStyle(
              color: Color(0XFF03DAC6),
              fontSize: 15,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

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
        ),
        onPressed: isLoading ? null : () async {
          if (emailController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lütfen e-posta adresinizi girin')),
            );
            return;
          }
          if (!showPasswordField) {
            await checkEmail();
          } else {
            await signInOrSignUp();
          }
        },
        child: Text(
          isLoading ? "Kontrol ediliyor..." : 
          showPasswordField ? (isExistingUser ? "Giriş Yap" : "Hesap Oluştur") : "Devam et",
          style: const TextStyle(
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

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> sendPasswordResetEmail() async {
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sifre sıfırlama e-postası gönderildi')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color.fromARGB(255, 3, 218, 198),
              size: 28,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            "Sifremi Unuttum",
            style: TextStyle(
              fontFamily: 'Lato',
              color: Color.fromARGB(255, 3, 218, 198),
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: const Color(0XFF1E1E1E),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Sifrenizi sıfırlamak için lütfen e-posta adresinizi girin",
                style: const TextStyle(
                  color: Color(0XFFFFFFFF),
                  fontSize: 16,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                style: const TextStyle(
                  color: Color(0XFF797979),
                  fontSize: 18,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w400,
                ),
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
                      width: 2.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0XFF03DAC6),
                      width: 2.5,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0XFFFFFFFF),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
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
                  ),
                  onPressed: isLoading ? null : sendPasswordResetEmail,
                  child: Text(
                    isLoading ? "Gönderiliyor..." : "Sifre Sıfırlama E-postası Gönder",
                    style: const TextStyle(
                      color: Color(0XFF03DAC6),
                      fontSize: 16,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
