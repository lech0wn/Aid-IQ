import 'package:flutter/material.dart';
import 'package:aid_iq/screens/main_pages/home.dart';
import 'package:aid_iq/screens/main_pages/quizzes.dart';
import 'package:aid_iq/screens/main_pages/profile.dart';
import 'package:aid_iq/services/app_usage_service.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  int _homeRefreshKey = 0;
  int _quizzesRefreshKey = 0;
  final AppUsageService _appUsageService = AppUsageService();

  // List of pages for navigation - using keys to force refresh
  List<Widget> get _pages => [
    HomePage(key: ValueKey('home_$_homeRefreshKey')),
    QuizzesPage(key: ValueKey('quizzes_$_quizzesRefreshKey')),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Refresh the home page when switching to it
    if (index == 0) {
      setState(() {
        _homeRefreshKey++;
      });
    }
    // Refresh the quizzes page when switching to it
    if (index == 1) {
      setState(() {
        _quizzesRefreshKey++;
      });
    }
  }

  // Public method to switch tabs from child widgets
  void switchToTab(int index) {
    _onItemTapped(index);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appUsageService.startSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appUsageService.stopSession();
    _appUsageService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App came to foreground - start tracking
      _appUsageService.startSession();
    } else if (state == AppLifecycleState.paused || 
               state == AppLifecycleState.inactive ||
               state == AppLifecycleState.detached) {
      // App went to background - stop tracking
      _appUsageService.stopSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFd84040),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.menu_book, 1),
          _buildNavItem(Icons.person, 2),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, int index) {
    final bool isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration:
            isSelected
                ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
                : null,
        child: Icon(icon, color: isSelected ? Color(0xFFd84040) : Colors.white),
      ),
      label: '',
    );
  }
}
