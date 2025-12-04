import 'package:aid_iq/screens/legal_pages/disclaimer.dart';
import 'package:aid_iq/screens/signup.dart';
import 'package:aid_iq/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aid_iq/widgets/main_layout.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aid_iq/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Modules and quizzes are now loaded from local files (no Firestore upload needed)

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
        // SIGN-UP ROUTE: '/' maps to SignUpScreen
        // This route is used for:
        // - Initial app launch
        // - Redirect after account deletion (see lib/screens/main_pages/edit_profile.dart)
        // To change sign-up route: Update both here and in edit_profile.dart _deleteAccount method
        '/': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/disclaimer': (context) => const DisclaimerPage(),
        '/main': (context) => const MainLayout(),
      },
    );
  }
}
