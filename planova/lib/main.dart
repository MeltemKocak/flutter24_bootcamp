import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/login_screen.dart'; // Giriş ekranını içe aktarın

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  print("API Key: ${dotenv.env['FIREBASE_API_KEY']}");
  print("App ID Android: ${dotenv.env['FIREBASE_APP_ID_ANDROID']}");
  print("App ID iOS: ${dotenv.env['FIREBASE_APP_ID_IOS']}");

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    print("Building MyApp");
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(), // Giriş ekranını ana ekran olarak ayarlayın
    );
  }
}
