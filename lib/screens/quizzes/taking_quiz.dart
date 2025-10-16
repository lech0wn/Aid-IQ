import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  final String quizTitle; // Add this parameter
  final List<Map<String, dynamic>> questions; // Add this parameter

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
    // Initialize selectedOptions with null values for each question
    selectedOptions = List.filled(widget.questions.length, null);
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[currentQuestionIndex];
    final options = q['options'] as List<String>;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
        title: Text(
          widget.quizTitle, // Use the quiz title dynamically
          style: const TextStyle(
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
            // Progress bar
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / widget.questions.length,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${currentQuestionIndex + 1}',
                  style: TextStyle(
                    color: Colors.red[300],
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '/${widget.questions.length}',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                q['questionText'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Options
            ...List.generate(options.length, (index) {
              final isSelected = selectedOptions[currentQuestionIndex] == index;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSelected ? Colors.blue[100] : Colors.grey[200],
                    foregroundColor: isSelected ? Colors.blue : Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side:
                          isSelected
                              ? const BorderSide(color: Colors.red, width: 2)
                              : BorderSide.none,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedOptions[currentQuestionIndex] = index;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(options[index]),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const Spacer(),
            // Navigation buttons
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
                      child: const Text('Back', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                if (currentQuestionIndex > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      minimumSize: const Size(0, 48),
                    ),
                    onPressed:
                        selectedOptions[currentQuestionIndex] == null
                            ? null
                            : () {
                              if (currentQuestionIndex <
                                  widget.questions.length - 1) {
                                setState(() {
                                  currentQuestionIndex++;
                                });
                              } else {
                                // Show results of quiz
                                int score = 0;
                                for (
                                  int i = 0;
                                  i < widget.questions.length;
                                  i++
                                ) {
                                  if (selectedOptions[i] ==
                                      widget
                                          .questions[i]['correctOptionIndex']) {
                                    score++;
                                  }
                                }
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text('Quiz Completed'),
                                        content: Text(
                                          'Your score is $score/${widget.questions.length}',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                );
                              }
                            },
                    child: Text(
                      currentQuestionIndex == widget.questions.length - 1
                          ? 'Finish'
                          : 'Next',
                      style: const TextStyle(fontSize: 18),
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
