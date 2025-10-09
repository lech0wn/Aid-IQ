import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestionIndex = 0;
  List<int?> selectedOptions = List.filled(10, null);

  final List<Map<String, Object>> questions = [
    {
      'questionText': 'What is the capital of France?',
      'options': ['Berlin', 'Madrid', 'Paris', 'Rome'],
      'correctOptionIndex': 2,
    },
    {
      'questionText': 'What is 2 + 2?',
      'options': ['3', '4', '5', '6'],
      'correctOptionIndex': 1,
    },
    {
      'questionText': 'What is 2 + 2?',
      'options': ['3', '4', '5', '6'],
      'correctOptionIndex': 1,
    },
    {
      'questionText': 'What is 2 + 2?',
      'options': ['3', '4', '5', '6'],
      'correctOptionIndex': 1,
    },
    {
      'questionText': 'What is 2 + 2?',
      'options': ['3', '4', '5', '6'],
      'correctOptionIndex': 1,
    },
    {
      'questionText': 'What is 2 + 2?',
      'options': ['3', '4', '5', '6'],
      'correctOptionIndex': 1,
    },
    {
      'questionText': 'What is 2 + 2?',
      'options': ['3', '4', '5', '6'],
      'correctOptionIndex': 1,
    },
    {
      'questionText': 'What is 2 + 2?',
      'options': ['3', '4', '5', '6'],
      'correctOptionIndex': 1,
    },
    {
      'questionText': 'What is 2 + 2?',
      'options': ['3', '4', '5', '6'],
      'correctOptionIndex': 1,
    },
    {
      'questionText': 'What is 2 + 2?',
      'options': ['3', '4', '5', '6'],
      'correctOptionIndex': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final q = questions[currentQuestionIndex];
    final options = q['options'] as List<String>;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'First Aid Quiz',
          style: TextStyle(
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
              value: (currentQuestionIndex + 1) / questions.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
            SizedBox(height: 8),
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
                  '/${questions.length}',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                q['questionText'] as String,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            SizedBox(height: 24),
            ...List.generate(options.length, (index) {
              final isSelected = selectedOptions[currentQuestionIndex] == index;
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSelected ? Colors.blue[100] : Colors.grey[200],
                    foregroundColor: isSelected ? Colors.blue : Colors.black,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side:
                          isSelected
                              ? BorderSide(color: Colors.red, width: 2)
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
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            }),
            Spacer(),
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
                        minimumSize: Size(0, 48),
                      ),
                      onPressed: () {
                        setState(() {
                          currentQuestionIndex--;
                        });
                      },
                      child: Text('Back', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                if (currentQuestionIndex > 0) SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      minimumSize: Size(0, 48),
                    ),
                    onPressed:
                        selectedOptions[currentQuestionIndex] == null
                            ? null
                            : () {
                              if (currentQuestionIndex < questions.length - 1) {
                                setState(() {
                                  currentQuestionIndex++;
                                });
                              } else {
                                // Show results of quiz
                              }
                            },
                    child: Text(
                      currentQuestionIndex == questions.length - 1
                          ? 'Finish'
                          : 'Check',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
