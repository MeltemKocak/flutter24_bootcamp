import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:planova/utilities/theme.dart';
import 'package:provider/provider.dart';
import 'package:planova/utilities/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Firebase Auth Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: LoginScreen(),
          );
        },
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
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
        showErrorMessage('Şifre yanlış. Lütfen tekrar deneyin.');
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
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: theme.welcomeText),
            SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: theme.checkBoxActiveColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

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
                    Icon(
                      Icons.arrow_back_ios,
                      color: theme.welcomeDotActive,
                      size: 28,
                    ),
                    Text(
                      'Geri',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        color: theme.welcomeDotActive,
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
        backgroundColor: theme.background,
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
                _buildEmailSection(context, theme),
                if (showPasswordField) _buildPasswordSection(context, theme),
                const SizedBox(height: 20),
                _buildForgotPassword(context, theme),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildContinueButton(context, theme),
      ),
    );
  }

  Widget _buildEmailSection(BuildContext context, CustomThemeData theme) {
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
            Text(
              "E-posta ile devam edin",
              style: TextStyle(
                color: theme.welcomeText,
                fontSize: 20,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "E-posta adresinin neden gerekli olduğunu açıklamak faydalıdır.",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.subText,
                fontSize: 15,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              style: TextStyle(
                color: theme.subText,
                fontSize: 18,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: "E-posta adresi",
                hintStyle: TextStyle(
                  color: theme.subText,
                  fontSize: 16,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w400,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: theme.welcomeDotActive,
                    width: 2.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: theme.welcomeDotActive,
                    width: 2.5,
                  ),
                ),
                filled: true,
                fillColor: theme.welcomeText,
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

  Widget _buildPasswordSection(BuildContext context, CustomThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            isExistingUser ? "Şifrenizi girin" : "Yeni şifre oluşturun",
            style: TextStyle(
              color: theme.welcomeText,
              fontSize: 18,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            style: TextStyle(color: theme.subText),
            decoration: InputDecoration(
              hintText: isExistingUser ? "Şifre" : "Yeni şifre",
              hintStyle: TextStyle(color: theme.subText),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  width: 2.5,
                  color: isPasswordWrong ? theme.welcomeButton : theme.welcomeDotActive,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  width: 2.5,
                  color: isPasswordWrong ? theme.welcomeButton : theme.welcomeDotActive,
                ),
              ),
              filled: true,
              fillColor: theme.welcomeText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword(BuildContext context, CustomThemeData theme) {
    return Row(
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
            );
          },
          child: Text(
            "Şifremi unuttum",
            style: TextStyle(
              color: theme.welcomeDotActive,
              fontSize: 15,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context, CustomThemeData theme) {
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
          backgroundColor: theme.welcomeButton,
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
          style: TextStyle(
            color: theme.welcomeDotActive,
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
        const SnackBar(content: Text('Şifre sıfırlama e-postası gönderildi')),
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
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: theme.welcomeDotActive,
              size: 28,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "Şifremi Unuttum",
            style: TextStyle(
              fontFamily: 'Lato',
              color: theme.welcomeDotActive,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: theme.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Şifrenizi sıfırlamak için lütfen e-posta adresinizi girin",
                style: TextStyle(
                  color: theme.welcomeText,
                  fontSize: 16,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                style: TextStyle(
                  color: theme.subText,
                  fontSize: 18,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: "E-posta adresi",
                  hintStyle: TextStyle(
                    color: theme.subText,
                    fontSize: 16,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: theme.welcomeDotActive,
                      width: 2.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: theme.welcomeDotActive,
                      width: 2.5,
                    ),
                  ),
                  filled: true,
                  fillColor: theme.welcomeText,
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
                    backgroundColor: theme.welcomeButton,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: isLoading ? null : sendPasswordResetEmail,
                  child: Text(
                    isLoading ? "Gönderiliyor..." : "Şifre Sıfırlama E-postası Gönder",
                    style: TextStyle(
                      color: theme.welcomeDotActive,
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
