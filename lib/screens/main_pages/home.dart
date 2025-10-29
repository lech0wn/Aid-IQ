import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:aid_iq/screens/main_pages/learn_more.dart';
import 'package:aid_iq/widgets/main_layout.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "Annissa Balaga";
  List<Map<String, dynamic>> recentQuizzes = [];

  @override
  void initState() {
    super.initState();
    _loadRecentQuizzes();
  }

  Future<void> _loadRecentQuizzes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('quiz_progress');
    if (jsonString != null) {
      try {
        final Map<String, dynamic> data = json.decode(jsonString);
        final List<Map<String, dynamic>> quizzes = [];

        data.forEach((title, value) {
          if (value is Map<String, dynamic>) {
            quizzes.add({
              "title": title,
              "questions": 10,
              "completed": value['status'] == 'Completed',
              "score": value['score'],
              "icon": _getIconForQuiz(title),
            });
          }
        });

        // Sort by completed quizzes first and take most recent 3
        quizzes.sort(
          (a, b) => (b["completed"] ? 1 : 0) - (a["completed"] ? 1 : 0),
        );

        setState(() {
          recentQuizzes = quizzes.take(3).toList();
        });
      } catch (e) {
        // Handle parse errors silently
      }
    }
  }

  IconData _getIconForQuiz(String title) {
    switch (title) {
      case 'CPR':
        return Icons.favorite;
      case 'Wound Cleaning':
        return Icons.healing;
      case 'R.I.C.E. (Treating Sprains)':
        return Icons.accessibility_new;
      case 'First Aid Introduction':
        return Icons.medical_services;
      case 'Proper Bandaging':
        return Icons.local_hospital;
      default:
        return Icons.quiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              color: Color(0xFFd84040),
              padding: const EdgeInsets.only(
                top: 48,
                left: 24,
                right: 24,
                bottom: 24,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello,',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userName,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const CircleAvatar(radius: 20, backgroundColor: Colors.black),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for a quiz',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),

            // Introduction Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFd84040),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Introduction to AID IQ',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your pocket-sized guide to first aid knowledge',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFFd84040),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LearnMorePage(),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Learn More'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Modules Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Modules',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const [
                    _QuizCard(
                      title: 'First Aid\nIntroduction',
                      icon: Icons.medical_services,
                    ),
                    SizedBox(width: 12),
                    _QuizCard(title: 'CPR', icon: Icons.favorite),
                    SizedBox(width: 12),
                    _QuizCard(
                      title: 'Proper\nBandaging',
                      icon: Icons.local_hospital,
                    ),
                    SizedBox(width: 12),
                    _QuizCard(title: 'Wound\nCleaning', icon: Icons.healing),
                    SizedBox(width: 12),
                    _QuizCard(
                      title: 'R.I.C.E.\n(Sprains)',
                      icon: Icons.accessibility_new,
                    ),
                    SizedBox(width: 12),
                    _QuizCard(title: 'Strains', icon: Icons.healing_rounded),
                    SizedBox(width: 12),
                    _QuizCard(title: 'Animal\nBites', icon: Icons.pets),
                    SizedBox(width: 12),
                    _QuizCard(title: 'Choking', icon: Icons.warning),
                    SizedBox(width: 12),
                    _QuizCard(title: 'Fainting', icon: Icons.sick),
                    SizedBox(width: 12),
                    _QuizCard(
                      title: 'Seizure',
                      icon: Icons.medical_information,
                    ),
                    SizedBox(width: 12),
                    _QuizCard(
                      title: 'First Aid\nEquipments',
                      icon: Icons.medical_services,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Recent Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Find the MainLayout ancestor and switch to quizzes tab (index 1)
                      final mainLayout =
                          context.findAncestorStateOfType<MainLayoutState>();
                      if (mainLayout != null) {
                        mainLayout.switchToTab(1);
                      }
                    },
                    child: Text(
                      'See All',
                      style: GoogleFonts.poppins(
                        color: Color(0xFFd84040),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children:
                    recentQuizzes.map((quiz) {
                      return Column(
                        children: [
                          _RecentQuizCard(
                            title: quiz["title"],
                            questions: quiz["questions"],
                            completed: quiz["completed"],
                            icon: quiz["icon"],
                            score: quiz["score"],
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final String title;
  final IconData icon;
  const _QuizCard({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Modules coming soon!', style: GoogleFonts.poppins()),
            backgroundColor: Color(0xFFd84040),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        width: 130,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.green[700],
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentQuizCard extends StatelessWidget {
  final String title;
  final int questions;
  final bool completed;
  final IconData icon;
  final int? score;
  const _RecentQuizCard({
    required this.title,
    required this.questions,
    required this.completed,
    required this.icon,
    this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$questions questions',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (completed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                score != null ? 'Score: $score/$questions' : 'Completed',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}
