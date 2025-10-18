import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aid_iq/screens/quizzes/quiz_results.dart'; // Add this import

class QuizPage extends StatefulWidget {
  final String quizTitle;
  final List<Map<String, dynamic>> questions;

  const QuizPage({super.key, required this.quizTitle, required this.questions});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestionIndex = 0;
  List<int?> selectedOptions = [];

  @override
  void initState() {
    super.initState();
    selectedOptions = List.filled(widget.questions.length, null);
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[currentQuestionIndex];
    final options = q['options'] as List<String>;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFFd84040)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.quizTitle,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / widget.questions.length,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFd84040),
                ),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${currentQuestionIndex + 1}',
                  style: GoogleFonts.poppins(
                    color: Color(0xFFd84040),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '/${widget.questions.length}',
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                q['questionText'] as String,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(options.length, (index) {
              final isSelected = selectedOptions[currentQuestionIndex] == index;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSelected ? Color(0xFF587DBD) : Color(0xFFD9D9D9),
                    foregroundColor: isSelected ? Colors.white : Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedOptions[currentQuestionIndex] = index;
                    });
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          options[index],
                          softWrap: true,
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Color(0xFF636363),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const Spacer(),
            Row(
              children: [
                if (currentQuestionIndex > 0)
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        minimumSize: const Size(0, 48),
                      ),
                      onPressed: () {
                        setState(() {
                          currentQuestionIndex--;
                        });
                      },
                      child: Text(
                        'Back',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                if (currentQuestionIndex > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF238349),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      minimumSize: const Size(0, 48),
                    ),
                    onPressed: selectedOptions[currentQuestionIndex] == null
                        ? null
                        : () {
                            if (currentQuestionIndex <
                                widget.questions.length - 1) {
                              setState(() {
                                currentQuestionIndex++;
                              });
                            } else {
                              // Calculate score
                              int score = 0;
                              for (int i = 0; i < widget.questions.length; i++) {
                                if (selectedOptions[i] ==
                                    widget.questions[i]['correctAnswerIndex']) {
                                  score++;
                                }
                              }

                              // Navigate to results page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuizResultsPage(
                                    questions: widget.questions,
                                    userAnswers: selectedOptions,
                                    score: score,
                                  ),
                                ),
                              );
                            }
                          },
                    child: Text(
                      currentQuestionIndex == widget.questions.length - 1
                          ? 'Finish'
                          : 'Next',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}