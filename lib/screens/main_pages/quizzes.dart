import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aid_iq/screens/quizzes/taking_quiz.dart'; // Import QuizPage
import 'package:aid_iq/screens/quizzes/quiz_results.dart'; // Import QuizResultsPage
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

class QuizzesPage extends StatefulWidget {
  const QuizzesPage({super.key});

  @override
  State<QuizzesPage> createState() => _QuizzesPageState();
}

class _QuizzesPageState extends State<QuizzesPage> {
  // State variables
  String selectedFilter = "All";

  // Lazy-loaded map: quiz questions are only converted when actually needed
  // This prevents loading all quiz data at widget initialization
  Map<String, List<Map<String, dynamic>>>? _quizTitleToQuestions;

  // Get questions lazily - only convert when accessed
  List<Map<String, dynamic>> _getQuestionsForQuiz(String title) {
    _quizTitleToQuestions ??= {};

    // Only convert if we haven't already cached this quiz's questions
    if (!_quizTitleToQuestions!.containsKey(title)) {
      switch (title) {
        case 'CPR':
          _quizTitleToQuestions![title] =
              cprQuestions.map((q) => q.toMap()).toList();
          break;
        case 'First Aid Introduction':
          _quizTitleToQuestions![title] =
              firstAidIntroductionQuestions.map((q) => q.toMap()).toList();
          break;
        case 'Proper Bandaging':
          _quizTitleToQuestions![title] =
              properBandagingQuestions.map((q) => q.toMap()).toList();
          break;
        case 'Wound Cleaning':
          _quizTitleToQuestions![title] =
              woundCleaningQuestions.map((q) => q.toMap()).toList();
          break;
        case 'R.I.C.E. (Treating Sprains)':
          _quizTitleToQuestions![title] =
              riceQuestions.map((q) => q.toMap()).toList();
          break;
        case 'Strains':
          _quizTitleToQuestions![title] =
              strainsQuestions.map((q) => q.toMap()).toList();
          break;
        case 'Animal Bites':
          _quizTitleToQuestions![title] =
              animalBitesQuestions.map((q) => q.toMap()).toList();
          break;
        case 'Choking':
          _quizTitleToQuestions![title] =
              chokingQuestions.map((q) => q.toMap()).toList();
          break;
        case 'Fainting':
          _quizTitleToQuestions![title] =
              faintingQuestions.map((q) => q.toMap()).toList();
          break;
        case 'Seizure':
          _quizTitleToQuestions![title] =
              seizureQuestions.map((q) => q.toMap()).toList();
          break;
        case 'First Aid Equipments':
          _quizTitleToQuestions![title] =
              firstAidEquipmentQuestions.map((q) => q.toMap()).toList();
          break;
        default:
          _quizTitleToQuestions![title] = [];
          break;
      }
    }

    return _quizTitleToQuestions![title] ?? [];
  }

  // List of quizzes
  final List<Map<String, dynamic>> quizzes = [
    {
      "title": "First Aid Introduction",
      "questions": 10,
      "status": "Ongoing",
      "score": null,
    },
    {"title": "CPR", "questions": 10, "status": "Ongoing", "score": null},
    {
      "title": "Proper Bandaging",
      "questions": 10,
      "status": "Ongoing",
      "score": null,
    },
    {
      "title": "Wound Cleaning",
      "questions": 10,
      "status": "Ongoing",
      "score": null,
    },
    {
      "title": "R.I.C.E. (Treating Sprains)",
      "questions": 10,
      "status": "Ongoing",
    },
    {"title": "Strains", "questions": 10, "status": "Ongoing", "score": null},
    {
      "title": "Animal Bites",
      "questions": 10,
      "status": "Ongoing",
      "score": null,
    },
    {"title": "Choking", "questions": 10, "status": "Ongoing", "score": null},
    {"title": "Fainting", "questions": 10, "status": "Ongoing", "score": null},
    {"title": "Seizure", "questions": 10, "status": "Ongoing", "score": null},
    {
      "title": "First Aid Equipments",
      "questions": 10,
      "status": "Ongoing",
      "score": null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadQuizProgress();
  }

  Future<void> _loadQuizProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('quiz_progress');
    if (jsonString == null) return;
    try {
      final Map<String, dynamic> data = json.decode(jsonString);
      setState(() {
        for (final q in quizzes) {
          final title = q['title'] as String;
          if (data.containsKey(title)) {
            final entry = data[title] as Map<String, dynamic>;
            q['status'] = entry['status'] ?? q['status'];
            q['score'] =
                entry.containsKey('score') ? entry['score'] : q['score'];
          }
        }
      });
    } catch (_) {
      // ignore parse errors
    }
  }

  Future<void> _saveQuizProgress(
    String title,
    String status,
    int? score, [
    List<int?>? userAnswers,
  ]) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('quiz_progress');
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
    await prefs.setString('quiz_progress', json.encode(data));
  }

  @override
  Widget build(BuildContext context) {
    // Filter quizzes based on the selected category
    final filteredQuizzes =
        selectedFilter == "All"
            ? quizzes
            : quizzes
                .where((quiz) => quiz["status"] == selectedFilter)
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

          // Filtered Quiz List
          Expanded(
            child: ListView.builder(
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
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    minimumSize: const Size(80, 36),
                                  ),
                                  onPressed: () async {
                                    final String title =
                                        quiz["title"] as String;
                                    final questions = _getQuestionsForQuiz(
                                      title,
                                    );

                                    // Load saved user answers
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final jsonString = prefs.getString(
                                      'quiz_progress',
                                    );
                                    List<int?>? userAnswers;
                                    int? savedScore;

                                    if (jsonString != null) {
                                      try {
                                        final data =
                                            json.decode(jsonString)
                                                as Map<String, dynamic>;
                                        if (data.containsKey(title)) {
                                          final entry =
                                              data[title]
                                                  as Map<String, dynamic>;
                                          if (entry.containsKey(
                                            'userAnswers',
                                          )) {
                                            final answersList =
                                                entry['userAnswers'] as List;
                                            userAnswers =
                                                answersList
                                                    .map((e) => e as int?)
                                                    .toList();
                                          }
                                          savedScore = entry['score'] as int?;
                                        }
                                      } catch (_) {}
                                    }

                                    // If we don't have saved answers, create empty list (user can still see questions)
                                    userAnswers ??= List.filled(
                                      questions.length,
                                      null,
                                    );

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => QuizResultsPage(
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
                                    backgroundColor: const Color(0xFFd84040),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    minimumSize: const Size(80, 36),
                                  ),
                                  onPressed: () async {
                                    final String title =
                                        quiz["title"] as String;
                                    final questions = _getQuestionsForQuiz(
                                      title,
                                    );

                                    final navigator = Navigator.of(context);
                                    final result = await navigator.push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => QuizPage(
                                              quizTitle: title,
                                              questions: questions,
                                            ),
                                      ),
                                    );

                                    // Handle retake result
                                    if (result != null && result is Map) {
                                      if (result['completed'] == true) {
                                        int? score = result['score'] as int?;
                                        List<int?>? userAnswers =
                                            result['userAnswers']
                                                as List<int?>?;

                                        setState(() {
                                          final globalIndex = quizzes
                                              .indexWhere(
                                                (q) => q['title'] == title,
                                              );
                                          if (globalIndex != -1) {
                                            quizzes[globalIndex]['status'] =
                                                'Completed';
                                            quizzes[globalIndex]['score'] =
                                                score;
                                          }
                                        });

                                        await _saveQuizProgress(
                                          title,
                                          'Completed',
                                          score,
                                          userAnswers,
                                        );
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
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () async {
                                final String title = quiz["title"] as String;
                                final questions = _getQuestionsForQuiz(title);

                                final messenger = ScaffoldMessenger.of(context);
                                final navigator = Navigator.of(context);
                                final result = await navigator.push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => QuizPage(
                                          quizTitle: title,
                                          questions: questions,
                                        ),
                                  ),
                                );

                                // If a completion result is returned, mark this quiz Completed and persist score.
                                if (result != null && result is Map) {
                                  if (result['completed'] == true) {
                                    int? score = result['score'] as int?;
                                    List<int?>? userAnswers =
                                        result['userAnswers'] as List<int?>?;

                                    setState(() {
                                      final globalIndex = quizzes.indexWhere(
                                        (q) => q['title'] == title,
                                      );
                                      if (globalIndex != -1) {
                                        quizzes[globalIndex]['status'] =
                                            'Completed';
                                        quizzes[globalIndex]['score'] = score;
                                      }
                                    });

                                    await _saveQuizProgress(
                                      title,
                                      'Completed',
                                      score,
                                      userAnswers,
                                    );

                                    // Show feedback
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          score != null
                                              ? 'Quiz "$title" completed — Score: $score/${questions.length}'
                                              : 'Quiz "$title" completed',
                                        ),
                                        backgroundColor: Colors.green[700],
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
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
