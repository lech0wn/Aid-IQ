import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aid_iq/screens/quizzes/taking_quiz.dart'; // Import QuizPage
import 'package:aid_iq/screens/quizzes/data/cpr_questions.dart'; // Import CPR questions

class QuizzesPage extends StatefulWidget {
  const QuizzesPage({super.key});

  @override
  State<QuizzesPage> createState() => _QuizzesPageState();
}

class _QuizzesPageState extends State<QuizzesPage> {
  // State variables
  String selectedFilter = "All";

  // List of quizzes
  final List<Map<String, dynamic>> quizzes = [
    {"title": "First Aid Introduction", "questions": 10, "status": "Completed"},
    {"title": "CPR", "questions": 10, "status": "Ongoing"},
    {"title": "Proper Bandaging", "questions": 10, "status": "Completed"},
    {"title": "Wound Cleaning", "questions": 10, "status": "Ongoing"},
  ];

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
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                quiz["status"] == "Completed"
                                    ? Colors.grey
                                    : Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed:
                              quiz["status"] == "Completed"
                                  ? null
                                  : () {
                                    // Navigate to QuizPage with the appropriate questions
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => QuizPage(
                                              quizTitle: quiz["title"],
                                              questions:
                                                  quiz["title"] == "CPR"
                                                      ? cprQuestions
                                                          .map((q) => q.toMap())
                                                          .toList()
                                                      : [], // Add other quizzes here
                                            ),
                                      ),
                                    );
                                  },
                          child: Text(
                            quiz["status"] == "Completed"
                                ? "Done"
                                : "Take Test",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
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
