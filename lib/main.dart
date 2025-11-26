import 'package:aid_iq/screens/legal_pages/disclaimer.dart';
import 'package:aid_iq/screens/signup.dart';
import 'package:aid_iq/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aid_iq/widgets/main_layout.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aid_iq/firebase_options.dart';
import 'package:aid_iq/services/upload_quizzes_to_firestore.dart';
import 'package:aid_iq/services/upload_modules_to_firestore.dart';
import 'package:aid_iq/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Upload quizzes and modules to Firestore on first run (one-time operation)
  final prefs = await SharedPreferences.getInstance();

  // Upload quizzes
  final quizzesUploaded =
      prefs.getBool('quizzes_uploaded_to_firestore') ?? false;
  if (!quizzesUploaded) {
    try {
      appLogger.i('Uploading quizzes to Firestore...');
      await UploadQuizzesToFirestore.uploadAllQuizzes();
      await prefs.setBool('quizzes_uploaded_to_firestore', true);
      appLogger.i('Quizzes uploaded successfully!');
    } catch (e) {
      appLogger.e('Error uploading quizzes', error: e);
      // Don't set the flag to true if upload failed, so it will retry next time
    }
  } else {
    appLogger.d('Quizzes already uploaded (skipping upload)');
  }

  // Upload modules
  final modulesUploaded =
      prefs.getBool('modules_uploaded_to_firestore') ?? false;
  if (!modulesUploaded) {
    try {
      appLogger.i('Uploading modules to Firestore...');
      await UploadModulesToFirestore.uploadAllModules();
      await prefs.setBool('modules_uploaded_to_firestore', true);
      appLogger.i('Modules uploaded successfully!');
    } catch (e) {
      appLogger.e('Error uploading modules', error: e);
      // Don't set the flag to true if upload failed, so it will retry next time
    }
  } else {
    appLogger.d('Modules already uploaded (skipping upload)');
  }

  // Configure Google Fonts to allow runtime fetching
  GoogleFonts.config.allowRuntimeFetching = true;

  // Start app immediately - fonts will load asynchronously
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Load Poppins font theme - this is cached after first call
    // The first time may take a moment, but subsequent calls are instant
    final textTheme = GoogleFonts.poppinsTextTheme();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aid IQ',
      theme: ThemeData(
        primarySwatch: Colors.red,
        textTheme: textTheme,
        // Preload common font styles to improve performance
        appBarTheme: AppBarTheme(
          titleTextStyle: textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/disclaimer': (context) => const DisclaimerPage(),
        '/main': (context) => const MainLayout(),
      },
    );
  }
}
