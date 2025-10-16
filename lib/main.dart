import 'package:flutter/material.dart';
import 'package:aid_iq/widgets/main_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Navigation Example',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const MainLayout(),
    );
  }
}
