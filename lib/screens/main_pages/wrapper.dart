import 'package:flutter/material.dart';
import 'package:aid_iq/screens/main_pages/home.dart';
import 'package:aid_iq/screens/main_pages/quizzes.dart';
import 'package:aid_iq/screens/main_pages/profile.dart';
import 'package:aid_iq/widgets/navbar.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    QuizzesPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex, 
        onItemTapped: _onItemTapped
        ),
    );
  }
}