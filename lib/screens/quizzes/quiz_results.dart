import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizResultsPage extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final List<int?> userAnswers;
  final int score;

  const QuizResultsPage({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.score,
  });

  @override
  State<QuizResultsPage> createState() => _QuizResultsPageState();
}

class _QuizResultsPageState extends State<QuizResultsPage> {
  final ScrollController _scrollController = ScrollController();

  // Calculate the actual score based on correct answers
  int _calculateScore() {
    int correctCount = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      final userAnswerIndex = widget.userAnswers[i];
      final correctOptionIndex = widget.questions[i]['correctOptionIndex'];

      if (userAnswerIndex != null && userAnswerIndex == correctOptionIndex) {
        correctCount++;
      }
    }
    return correctCount;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use calculated score instead of passed score
    final actualScore = _calculateScore();
    final questions = widget.questions;
    final userAnswers = widget.userAnswers;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFd84040),
        title: Text(
          'Quiz Results',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SCORE SECTION
            Center(
              child: Column(
                children: [
                  Text(
                    "Your Score",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$actualScore / ${questions.length}",
                    style: GoogleFonts.poppins(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFd84040),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // REVIEW SECTION
            ListView.builder(
              itemCount: questions.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final question = questions[index];
                final userAnswerIndex = userAnswers[index];
                final correctOptionIndex = question['correctOptionIndex'];
                final options = question['options'] as List<String>;

                final isCorrect =
                    userAnswerIndex != null &&
                    userAnswerIndex == correctOptionIndex;

                return Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isCorrect ? Colors.green : Colors.red,
                      width: 2,
                    ),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question header with number
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isCorrect ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isCorrect ? Icons.check : Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Question ${index + 1}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Question text
                        Text(
                          question['questionText'] ??
                              question['question'] ??
                              '',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Choices label
                        Text(
                          'Choices:',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Options list
                        ...List.generate(options.length, (optionIndex) {
                          final isUserAnswer = userAnswerIndex == optionIndex;
                          final isCorrectAnswer =
                              correctOptionIndex == optionIndex;

                          Color backgroundColor = Colors.transparent;
                          Color textColor = Colors.black87;
                          FontWeight fontWeight = FontWeight.normal;

                          if (isCorrectAnswer) {
                            backgroundColor = Colors.green.shade50;
                            textColor = Colors.green.shade800;
                            fontWeight = FontWeight.w600;
                          } else if (isUserAnswer && !isCorrect) {
                            backgroundColor = Colors.red.shade50;
                            textColor = Colors.red.shade800;
                            fontWeight = FontWeight.w600;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '- ',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: textColor,
                                    fontWeight: fontWeight,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    options[optionIndex],
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: textColor,
                                      fontWeight: fontWeight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 12),

                        // Response and Correct Answer labels
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Response: ',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      userAnswerIndex != null
                                          ? options[userAnswerIndex]
                                          : 'No answer',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Correct answer: ',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      options[correctOptionIndex],
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Score indicator
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Score: ',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              isCorrect ? '1 out of 1 ✓' : '0 out of 1',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: isCorrect ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // ACTION BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // See Results Button
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      // Scroll to top to show the score and first question results
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text(
                      "See Results",
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Retake Button
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFd84040),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      // Return 'retake' to indicate user wants to retake
                      Navigator.pop(context, {'retake': true});
                    },
                    child: Text(
                      "Retake",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Back to Quizzes Button
            Center(
              child: TextButton(
                onPressed: () {
                  // Pop the results page and return completion data
                  Navigator.pop(context, {
                    'completed': true,
                    'score': actualScore,
                    'userAnswers': widget.userAnswers,
                  });
                },
                child: Text(
                  "Back to Quizzes",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFd84040),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
