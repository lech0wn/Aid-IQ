import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aid_iq/screens/quizzes/taking_quiz.dart'; // Import QuizPage
import 'package:aid_iq/screens/quizzes/quiz_results.dart'; // Import QuizResultsPage
import 'package:aid_iq/services/quiz_service.dart';
import 'package:aid_iq/services/auth_service.dart';
import 'package:aid_iq/screens/quizzes/data/cpr_questions.dart'; // Import CPR questions
import 'package:aid_iq/screens/quizzes/data/first_aid_intro_questions.dart';
import 'package:aid_iq/screens/quizzes/data/proper_bandaging_questions.dart';
import 'package:aid_iq/screens/quizzes/data/wound_cleaning_questions.dart';
import 'package:aid_iq/screens/quizzes/data/rice_questions.dart';
import 'package:aid_iq/screens/quizzes/data/strains_questions.dart';
import 'package:aid_iq/screens/quizzes/data/animal_bites_questions.dart';
import 'package:aid_iq/screens/quizzes/data/choking_questions.dart';
import 'package:aid_iq/screens/quizzes/data/fainting_questions.dart';
import 'package:aid_iq/screens/quizzes/data/seizure_questions.dart';
import 'package:aid_iq/screens/quizzes/data/first_aid_equipment_questions.dart';
import 'package:aid_iq/utils/logger.dart';

class QuizzesPage extends StatefulWidget {
  const QuizzesPage({super.key});

  @override
  State<QuizzesPage> createState() => _QuizzesPageState();
}

class _QuizzesPageState extends State<QuizzesPage> {
  // State variables
  String selectedFilter = "All";
  final QuizService _quizService = QuizService();
  final AuthService _authService = AuthService();
  bool _isLoadingQuizzes = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Lazy-loaded map: quiz questions are only converted when actually needed
  // This prevents loading all quiz data at widget initialization
  Map<String, List<Map<String, dynamic>>>? _quizTitleToQuestions;

  // Get questions lazily - load from Firestore first, fallback to local files
  Future<List<Map<String, dynamic>>> _getQuestionsForQuiz(String title) async {
    _quizTitleToQuestions ??= {};

    // Check cache first
    if (_quizTitleToQuestions!.containsKey(title)) {
      return _quizTitleToQuestions![title]!;
    }

    // Try to load from Firestore
    try {
      final quiz = await _quizService.getQuizByTitle(title);
      if (quiz != null && quiz['questions'] != null) {
        final questions =
            (quiz['questions'] as List)
                .map((q) => q as Map<String, dynamic>)
                .toList();
        _quizTitleToQuestions![title] = questions;
        return questions;
      }
    } catch (e) {
      appLogger.e('Error loading quiz from Firestore', error: e);
    }

    // Fallback to local files
    List<Map<String, dynamic>> questions = [];
    switch (title) {
      case 'CPR':
        questions = cprQuestions.map((q) => q.toMap()).toList();
        break;
      case 'First Aid Introduction':
        questions =
            firstAidIntroductionQuestions.map((q) => q.toMap()).toList();
        break;
      case 'Proper Bandaging':
        questions = properBandagingQuestions.map((q) => q.toMap()).toList();
        break;
      case 'Wound Cleaning':
        questions = woundCleaningQuestions.map((q) => q.toMap()).toList();
        break;
      case 'R.I.C.E. (Treating Sprains)':
        questions = riceQuestions.map((q) => q.toMap()).toList();
        break;
      case 'Strains':
        questions = strainsQuestions.map((q) => q.toMap()).toList();
        break;
      case 'Animal Bites':
        questions = animalBitesQuestions.map((q) => q.toMap()).toList();
        break;
      case 'Choking':
        questions = chokingQuestions.map((q) => q.toMap()).toList();
        break;
      case 'Fainting':
        questions = faintingQuestions.map((q) => q.toMap()).toList();
        break;
      case 'Seizure':
        questions = seizureQuestions.map((q) => q.toMap()).toList();
        break;
      case 'First Aid Equipments':
        questions = firstAidEquipmentQuestions.map((q) => q.toMap()).toList();
        break;
      default:
        questions = [];
        break;
    }

    _quizTitleToQuestions![title] = questions;
    return questions;
  }

  // List of quizzes - loaded from Firestore
  List<Map<String, dynamic>> quizzes = [];

  @override
  void initState() {
    super.initState();
    _loadQuizzesFromFirestore();
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
    _loadQuizzesFromFirestore();
  }

  Future<void> _loadQuizzesFromFirestore() async {
    setState(() {
      _isLoadingQuizzes = true;
    });

    try {
      // Load from SharedPreferences FIRST (primary source - works like before)
      // Make it user-specific by using user ID in the key
      final prefs = await SharedPreferences.getInstance();
      final user = _authService.currentUser;
      final userId = user?.uid ?? 'anonymous';
      final jsonString = prefs.getString('quiz_progress_$userId');
      Map<String, dynamic> localProgress = {};
      if (jsonString != null) {
        try {
          localProgress = json.decode(jsonString) as Map<String, dynamic>;
        } catch (_) {}
      }

      // Load quizzes from Firestore
      final firestoreQuizzes = await _quizService.getAllQuizzes();

      // Define hardcoded quiz list (always available)
      final List<Map<String, dynamic>> hardcodedQuizzes = [
        {"title": "First Aid Introduction", "questions": 10},
        {"title": "CPR", "questions": 10},
        {"title": "Proper Bandaging", "questions": 10},
        {"title": "Wound Cleaning", "questions": 10},
        {"title": "R.I.C.E. (Treating Sprains)", "questions": 10},
        {"title": "Strains", "questions": 10},
        {"title": "Animal Bites", "questions": 10},
        {"title": "Choking", "questions": 10},
        {"title": "Fainting", "questions": 10},
        {"title": "Seizure", "questions": 10},
        {"title": "First Aid Equipments", "questions": 10},
      ];

      // Use Firestore quizzes if available, otherwise use hardcoded list
      final List<Map<String, dynamic>> quizzesToProcess =
          firestoreQuizzes.isNotEmpty ? firestoreQuizzes : hardcodedQuizzes;

      // Convert quizzes to the format expected by the UI
      final List<Map<String, dynamic>> formattedQuizzes =
          quizzesToProcess.map((quiz) {
            final title = quiz['title'] as String;

            // Use SharedPreferences as PRIMARY source (works like before)
            final localData = localProgress[title];
            Map<String, dynamic>? progress;

            // Check local (SharedPreferences) first
            if (localData != null && localData is Map) {
              progress = Map<String, dynamic>.from(localData);
            }

            // Check completion status - simple check
            bool isCompleted = false;
            if (progress != null) {
              final status = progress['status'];
              isCompleted = status == 'Completed' || status == 'completed';

              // Also check the 'completed' boolean field if it exists
              if (!isCompleted && progress.containsKey('completed')) {
                final completedValue = progress['completed'];
                isCompleted = completedValue == true || completedValue == 1;
              }
            }

            return {
              'title': title,
              'questions': quiz['questions'] ?? quiz['questionCount'] ?? 10,
              'status': isCompleted ? 'Completed' : 'Ongoing',
              'score': progress?['score'],
              'id': quiz['id'],
            };
          }).toList();

      // Log summary of loaded quizzes
      final completedCount =
          formattedQuizzes.where((q) => q['status'] == 'Completed').length;
      appLogger.d(
        'Loaded ${formattedQuizzes.length} quizzes, ${completedCount} completed (from SharedPreferences)',
      );

      setState(() {
        quizzes = formattedQuizzes;
        _isLoadingQuizzes = false;
      });
    } catch (e) {
      appLogger.e('Error loading quizzes', error: e);
      setState(() {
        _isLoadingQuizzes = false;
      });
    }
  }

  Future<void> _saveQuizProgress(
    String title,
    String status,
    int? score, [
    List<int?>? userAnswers,
  ]) async {
    // Save to SharedPreferences FIRST (primary source - immediate and reliable)
    // Make it user-specific by using user ID in the key
    final prefs = await SharedPreferences.getInstance();
    final user = _authService.currentUser;
    final userId = user?.uid ?? 'anonymous';
    final jsonString = prefs.getString('quiz_progress_$userId');
    Map<String, dynamic> data = {};
    if (jsonString != null) {
      try {
        data = json.decode(jsonString) as Map<String, dynamic>;
      } catch (_) {}
    }
    data[title] = {
      'status': status,
      if (score != null) 'score': score,
      if (userAnswers != null) 'userAnswers': userAnswers,
    };
    await prefs.setString('quiz_progress_$userId', json.encode(data));
    appLogger.d(
      'Saved quiz progress to SharedPreferences: $title - $status (user: $userId)',
    );

    // Save to Firestore in background (for stats like quizzesTaken, streak)
    if (status == 'Completed' && score != null) {
      final scoreValue = score; // Capture for closure
      // Don't await - let it run in background, don't block UI
      _getQuestionsForQuiz(title)
          .then((questions) {
            _quizService
                .updateUserQuizProgress(
                  quizTitle: title,
                  score: scoreValue,
                  totalQuestions: questions.length,
                  userAnswers: userAnswers,
                )
                .catchError((e) {
                  appLogger.w(
                    'Background Firestore save failed (non-critical)',
                    error: e,
                  );
                });
          })
          .catchError((e) {
            appLogger.w('Error getting questions for Firestore save', error: e);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter quizzes based on the selected category and search query
    final filteredQuizzes =
        (selectedFilter == "All"
                ? quizzes
                : quizzes
                    .where((quiz) => quiz["status"] == selectedFilter)
                    .toList())
            .where((quiz) {
              if (_searchQuery.isEmpty) return true;
              final title = (quiz["title"] ?? '').toString().toLowerCase();
              return title.contains(_searchQuery);
            })
            .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header section
          Container(
            color: const Color(0xFFd84040),
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
                          color: const Color(0xFFd84040),
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Quizzes",
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
          // Filter Buttons
          Container(
            padding: const EdgeInsets.only(bottom: 12, top: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  ["All", "Ongoing", "Completed"].map((filter) {
                    final isSelected = selectedFilter == filter;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = filter;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? const Color(0xFFd84040)
                                  : const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF000000).withAlpha(51),
                              blurRadius: 3,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              filter == "All"
                                  ? Icons.filter_list
                                  : filter == "Ongoing"
                                  ? Icons.access_time
                                  : Icons.check_circle,
                              color:
                                  isSelected
                                      ? Colors.white
                                      : const Color(0xFFd84040),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              filter,
                              style: GoogleFonts.poppins(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : const Color(0xFFd84040),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search quizzes...',
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
          // Filtered Quiz List
          Expanded(
            child:
                _isLoadingQuizzes
                    ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFd84040),
                        ),
                      ),
                    )
                    : filteredQuizzes.isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'No quizzes found matching "$_searchQuery"'
                                  : 'No quizzes available',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: filteredQuizzes.length,
                      itemBuilder: (context, index) {
                        final quiz = filteredQuizzes[index];
                        return Card(
                          elevation: 2,
                          color: Color(0xFFEDEDED),
                          surfaceTintColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        quiz["title"],
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "${quiz['questions']} questions",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Show two buttons for completed quizzes, one button for ongoing
                                quiz["status"] == "Completed"
                                    ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // See Results Button
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[300],
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            minimumSize: const Size(80, 36),
                                          ),
                                          onPressed: () async {
                                            if (!mounted) return;
                                            final navigator = Navigator.of(
                                              context,
                                            );

                                            final String title =
                                                quiz["title"] as String;
                                            final questions =
                                                await _getQuestionsForQuiz(
                                                  title,
                                                );

                                            if (!mounted) return;
                                            // Load saved user answers from Firestore first, then SharedPreferences
                                            List<int?>? userAnswers;
                                            int? savedScore;

                                            try {
                                              final userProgress =
                                                  await _quizService
                                                      .getUserQuizProgress();
                                              final quizProgress =
                                                  userProgress['quizProgress']
                                                      as Map<
                                                        String,
                                                        dynamic
                                                      >? ??
                                                  {};
                                              final progress =
                                                  quizProgress[title]
                                                      as Map<String, dynamic>?;

                                              if (progress != null) {
                                                savedScore =
                                                    progress['score'] as int?;
                                                if (progress.containsKey(
                                                  'userAnswers',
                                                )) {
                                                  final answersList =
                                                      progress['userAnswers']
                                                          as List;
                                                  userAnswers =
                                                      answersList
                                                          .map((e) => e as int?)
                                                          .toList();
                                                }
                                              }
                                            } catch (_) {}

                                            // Fallback to SharedPreferences
                                            if (userAnswers == null) {
                                              final prefs =
                                                  await SharedPreferences.getInstance();
                                              final jsonString = prefs
                                                  .getString('quiz_progress');
                                              if (jsonString != null) {
                                                try {
                                                  final data =
                                                      json.decode(jsonString)
                                                          as Map<
                                                            String,
                                                            dynamic
                                                          >;
                                                  if (data.containsKey(title)) {
                                                    final entry =
                                                        data[title]
                                                            as Map<
                                                              String,
                                                              dynamic
                                                            >;
                                                    if (entry.containsKey(
                                                      'userAnswers',
                                                    )) {
                                                      final answersList =
                                                          entry['userAnswers']
                                                              as List;
                                                      userAnswers =
                                                          answersList
                                                              .map(
                                                                (e) =>
                                                                    e as int?,
                                                              )
                                                              .toList();
                                                    }
                                                    savedScore ??=
                                                        entry['score'] as int?;
                                                  }
                                                } catch (_) {}
                                              }
                                            }

                                            // If we don't have saved answers, create empty list (user can still see questions)
                                            userAnswers ??= List.filled(
                                              questions.length,
                                              null,
                                            );

                                            if (!mounted) return;
                                            navigator.push(
                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                      context,
                                                    ) => QuizResultsPage(
                                                      questions: questions,
                                                      userAnswers: userAnswers!,
                                                      score: savedScore ?? 0,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "See Results",
                                            style: GoogleFonts.poppins(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Retake Button
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFd84040,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            minimumSize: const Size(80, 36),
                                          ),
                                          onPressed: () async {
                                            if (!mounted) return;
                                            final navigator = Navigator.of(
                                              context,
                                            );

                                            final String title =
                                                quiz["title"] as String;
                                            final questions =
                                                await _getQuestionsForQuiz(
                                                  title,
                                                );

                                            if (!mounted) return;
                                            final result = await navigator.push(
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => QuizPage(
                                                      quizTitle: title,
                                                      questions: questions,
                                                    ),
                                              ),
                                            );
                                            if (!mounted) return;

                                            // Handle retake result
                                            if (result != null &&
                                                result is Map) {
                                              if (result['completed'] == true) {
                                                int? score =
                                                    result['score'] as int?;
                                                List<int?>? userAnswers =
                                                    result['userAnswers']
                                                        as List<int?>?;

                                                // Save to Firestore FIRST
                                                try {
                                                  await _saveQuizProgress(
                                                    title,
                                                    'Completed',
                                                    score,
                                                    userAnswers,
                                                  );
                                                  appLogger.d(
                                                    'Quiz saved successfully (retake): $title',
                                                  );
                                                } catch (e) {
                                                  appLogger.e(
                                                    'Error saving quiz (retake)',
                                                    error: e,
                                                  );
                                                }

                                                // Update local state - DO NOT RELOAD
                                                if (mounted) {
                                                  setState(() {
                                                    final globalIndex = quizzes
                                                        .indexWhere(
                                                          (q) =>
                                                              q['title'] ==
                                                              title,
                                                        );
                                                    if (globalIndex != -1) {
                                                      quizzes[globalIndex]['status'] =
                                                          'Completed';
                                                      quizzes[globalIndex]['score'] =
                                                          score;
                                                    }
                                                  });
                                                }
                                              }
                                            }
                                          },
                                          child: Text(
                                            "Retake",
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                    : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (!mounted) return;
                                        final navigator = Navigator.of(context);

                                        final String title =
                                            quiz["title"] as String;
                                        final questions =
                                            await _getQuestionsForQuiz(title);

                                        if (!mounted) return;
                                        final result = await navigator.push(
                                          MaterialPageRoute(
                                            builder:
                                                (context) => QuizPage(
                                                  quizTitle: title,
                                                  questions: questions,
                                                ),
                                          ),
                                        );

                                        if (!mounted) return;
                                        // If a completion result is returned, mark this quiz Completed and persist score.
                                        if (result != null && result is Map) {
                                          if (result['completed'] == true) {
                                            int? score =
                                                result['score'] as int?;
                                            List<int?>? userAnswers =
                                                result['userAnswers']
                                                    as List<int?>?;

                                            // Save to Firestore FIRST, then update local state
                                            try {
                                              await _saveQuizProgress(
                                                title,
                                                'Completed',
                                                score,
                                                userAnswers,
                                              );
                                              appLogger.d(
                                                'Quiz saved successfully: $title',
                                              );
                                            } catch (e) {
                                              appLogger.e(
                                                'Error saving quiz',
                                                error: e,
                                              );
                                              // Continue anyway to update UI
                                            }

                                            // Update local state - this ensures it shows as Completed immediately
                                            // DO NOT RELOAD - just update the state
                                            if (mounted) {
                                              setState(() {
                                                final globalIndex = quizzes
                                                    .indexWhere(
                                                      (q) =>
                                                          q['title'] == title,
                                                    );
                                                if (globalIndex != -1) {
                                                  quizzes[globalIndex]['status'] =
                                                      'Completed';
                                                  quizzes[globalIndex]['score'] =
                                                      score;
                                                }
                                              });
                                            }
                                          }
                                        }
                                      },
                                      child: Text(
                                        "Take Test",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
