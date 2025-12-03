import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:aid_iq/screens/main_pages/learn_more.dart';
import 'package:aid_iq/widgets/main_layout.dart';
import 'package:aid_iq/services/auth_service.dart';
import 'package:aid_iq/services/quiz_service.dart';
import 'package:aid_iq/services/local_module_service.dart';
import 'package:aid_iq/screens/main_pages/module_detail.dart';
import 'package:aid_iq/utils/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "User";
  List<Map<String, dynamic>> recentQuizzes = [];
  List<Map<String, dynamic>> modules = [];
  final AuthService _authService = AuthService();
  final QuizService _quizService = QuizService();
  final LocalModuleService _moduleService = LocalModuleService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadRecentQuizzes();
    _loadModules();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Public method to refresh data (called from MainLayout)
  void refreshData() {
    _loadRecentQuizzes();
    _loadModules();
  }

  Future<void> _loadModules() async {
    try {
      final loadedModules = await _moduleService.getAllModules();
      final userProgress = await _moduleService.getUserModuleProgress();

      // Safely convert Firestore data to proper types
      final moduleProgressData = userProgress['moduleProgress'];
      Map<String, dynamic> moduleProgress = {};
      if (moduleProgressData != null && moduleProgressData is Map) {
        moduleProgress = Map<String, dynamic>.from(moduleProgressData);
      }

      // Enhance modules with progress data
      final enhancedModules =
          loadedModules.map((module) {
            final moduleId = module['id'] as String? ?? '';
            final progressData = moduleProgress[moduleId];
            // Safely convert Firestore map to Map<String, dynamic>
            Map<String, dynamic>? progress;
            if (progressData != null && progressData is Map) {
              progress = Map<String, dynamic>.from(progressData);
            }
            return {
              ...module,
              'isCompleted': progress?['completed'] == true,
              'progress': progress,
            };
          }).toList();

      setState(() {
        modules = enhancedModules;
      });
    } catch (e) {
      appLogger.e('Error loading modules', error: e);
    }
  }

  void _loadUserData() {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
      });
    }
  }

  Future<void> _loadRecentQuizzes() async {
    try {
      // Load user's quiz progress from Firestore
      final userProgress = await _quizService.getUserQuizProgress();
      final quizProgress =
          userProgress['quizProgress'] as Map<String, dynamic>? ?? {};

      // Filter to only completed quizzes
      final List<Map<String, dynamic>> completedQuizzes = [];

      quizProgress.forEach((title, progress) {
        if (progress is Map<String, dynamic> && progress['completed'] == true) {
          completedQuizzes.add({
            "title": title,
            "questions": progress['totalQuestions'] ?? 10,
            "completed": true,
            "score": progress['score'],
            "icon": _getIconForQuiz(title),
            "completedAt":
                progress['completedAt'], // For sorting by most recent
          });
        }
      });

      // Sort by most recently completed (newest first)
      completedQuizzes.sort((a, b) {
        final aDate = a['completedAt'];
        final bDate = b['completedAt'];
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        // Handle Firestore Timestamp
        try {
          if (aDate is Timestamp && bDate is Timestamp) {
            return bDate.compareTo(aDate); // Most recent first
          }
          // Fallback: if it's already a DateTime or other format
          return 0;
        } catch (e) {
          return 0;
        }
      });

      // Take most recent 3 completed quizzes
      setState(() {
        recentQuizzes = completedQuizzes.take(3).toList();
      });
    } catch (e) {
      appLogger.e('Error loading recent quizzes', error: e);
      // Fallback to SharedPreferences if Firestore fails
      final prefs = await SharedPreferences.getInstance();
      final user = _authService.currentUser;
      final userId = user?.uid ?? 'anonymous';
      final jsonString = prefs.getString('quiz_progress_$userId');
      if (jsonString != null) {
        try {
          final Map<String, dynamic> data = json.decode(jsonString);
          final List<Map<String, dynamic>> quizzes = [];

          data.forEach((title, value) {
            if (value is Map<String, dynamic> &&
                value['status'] == 'Completed') {
              quizzes.add({
                "title": title,
                "questions": 10,
                "completed": true,
                "score": value['score'],
                "icon": _getIconForQuiz(title),
              });
            }
          });

          setState(() {
            recentQuizzes = quizzes.take(3).toList();
          });
        } catch (e) {
          // Handle parse errors silently
        }
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
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search quizzes and modules',
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                            : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
              child:
                  modules.isEmpty
                      ? Container(
                        height: 120,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            'Loading modules...',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                      : Builder(
                        builder: (context) {
                          // Filter modules based on search query
                          final filteredModules =
                              _searchQuery.isEmpty
                                  ? modules
                                  : modules.where((module) {
                                    final title =
                                        (module['title'] ?? '')
                                            .toString()
                                            .toLowerCase();
                                    return title.contains(_searchQuery);
                                  }).toList();

                          if (filteredModules.isEmpty &&
                              _searchQuery.isNotEmpty) {
                            return Container(
                              height: 120,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  'No modules found',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  filteredModules.map((module) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: _ModuleCard(
                                        module: module,
                                        icon: _getIconForModule(
                                          module['title'] ?? '',
                                        ),
                                        onTap: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => ModuleDetailPage(
                                                    module: module,
                                                  ),
                                            ),
                                          );
                                          // Refresh modules if completed
                                          if (result == true) {
                                            _loadModules();
                                          }
                                        },
                                      ),
                                    );
                                  }).toList(),
                            ),
                          );
                        },
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
              child:
                  recentQuizzes.isEmpty
                      ? Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            'No completed quizzes yet.\nStart taking quizzes to see them here!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                      : Builder(
                        builder: (context) {
                          // Filter recent quizzes based on search query
                          final filteredRecentQuizzes =
                              _searchQuery.isEmpty
                                  ? recentQuizzes
                                  : recentQuizzes.where((quiz) {
                                    final title =
                                        (quiz['title'] ?? '')
                                            .toString()
                                            .toLowerCase();
                                    return title.contains(_searchQuery);
                                  }).toList();

                          if (filteredRecentQuizzes.isEmpty &&
                              _searchQuery.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Center(
                                child: Text(
                                  'No quizzes found',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }

                          return Column(
                            children:
                                filteredRecentQuizzes.map((quiz) {
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
                          );
                        },
                      ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  IconData _getIconForModule(String title) {
    if (title.toLowerCase().contains('first aid')) {
      return Icons.medical_services;
    } else if (title.toLowerCase().contains('cpr')) {
      return Icons.favorite;
    } else if (title.toLowerCase().contains('bandag')) {
      return Icons.local_hospital;
    } else if (title.toLowerCase().contains('wound')) {
      return Icons.healing;
    } else if (title.toLowerCase().contains('sprain') ||
        title.toLowerCase().contains('rice')) {
      return Icons.accessibility_new;
    } else if (title.toLowerCase().contains('strain')) {
      return Icons.healing_rounded;
    } else if (title.toLowerCase().contains('animal') ||
        title.toLowerCase().contains('bite')) {
      return Icons.pets;
    } else if (title.toLowerCase().contains('chok')) {
      return Icons.warning;
    } else if (title.toLowerCase().contains('faint')) {
      return Icons.sick;
    }
    return Icons.article;
  }
}

class _ModuleCard extends StatelessWidget {
  final Map<String, dynamic> module;
  final IconData icon;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.module,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String title = module['title'] ?? 'Module';
    final bool isCompleted = module['isCompleted'] == true;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        height: 120,
        decoration: BoxDecoration(
          color: isCompleted ? Colors.green[600] : Colors.green[700],
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
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 32),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Completion badge
            if (isCompleted)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green[700],
                    size: 16,
                  ),
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
