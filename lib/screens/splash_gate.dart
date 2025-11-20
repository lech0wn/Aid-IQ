import 'package:flutter/material.dart';
import 'package:aid_iq/widgets/main_layout.dart';
import 'package:aid_iq/screens/login.dart';
import 'package:aid_iq/services/auth_service.dart';

class SplashGate extends StatelessWidget {
  const SplashGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return StreamBuilder(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const MainLayout();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
