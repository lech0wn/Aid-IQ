import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomNavBar ({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });


  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.red,
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      showSelectedLabels: false,
      showUnselectedLabels: false,
       items: [
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.menu_book, 1),
          _buildNavItem(Icons.person, 2),
        ],
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, int index) {
    final bool isSelected = selectedIndex == index;
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: isSelected
        ? BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 6,
              offset: const Offset(0,2),
            ),
          ],
        )
        : null,
        child: Icon(icon, color: isSelected ? Colors.red : Colors.white),
      ),
      label: '',
    );
  }
}