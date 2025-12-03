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

  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Icon
                Icon(
                  Icons.warning_amber_rounded,
                  color: const Color(0xFFd84040),
                  size: 48,
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  'Exit Quiz?',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Message
                Text(
                  'Your progress will not be saved if you exit now.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Exit Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFd84040),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Exit',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[currentQuestionIndex];
    final options = q['options'] as List<String>;
    
    // Responsive design helpers
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isTablet = screenWidth > 600;
    final isSmallScreen = screenWidth < 360;
    
    // Responsive font sizes
    final questionFontSize = isTablet ? 28.0 : (isSmallScreen ? 20.0 : 24.0);
    final optionFontSize = isTablet ? 18.0 : (isSmallScreen ? 14.0 : 16.0);
    final buttonFontSize = isTablet ? 20.0 : (isSmallScreen ? 16.0 : 18.0);
    final titleFontSize = isTablet ? 24.0 : (isSmallScreen ? 18.0 : 20.0);
    
    // Responsive padding
    final horizontalPadding = isTablet 
        ? screenWidth * 0.1 
        : (isSmallScreen ? 16.0 : 24.0);
    final verticalPadding = isTablet ? 16.0 : 8.0;
    final questionPadding = isTablet ? 24.0 : (isSmallScreen ? 16.0 : 20.0);
    final optionPadding = isTablet 
        ? EdgeInsets.symmetric(vertical: 20, horizontal: 20)
        : EdgeInsets.symmetric(vertical: 16, horizontal: 16);

    return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, dynamic result) async {
            if (didPop) return;
            final shouldExit = await _showExitConfirmationDialog();
            if (shouldExit && mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Color(0xFFd84040)),
                onPressed: () async {
                  final shouldExit = await _showExitConfirmationDialog();
                  if (shouldExit && mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
              title: Text(
                widget.quizTitle,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: titleFontSize,
                ),
              ),
              centerTitle: false,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding, 
                  vertical: verticalPadding,
                ),
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
                          fontSize: isTablet ? 22.0 : (isSmallScreen ? 16.0 : 18.0),
                        ),
                      ),
                      Text(
                        '/${widget.questions.length}',
                        style: GoogleFonts.poppins(
                          color: Colors.grey, 
                          fontSize: isTablet ? 20.0 : (isSmallScreen ? 14.0 : 16.0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(questionPadding),
                    margin: EdgeInsets.only(
                      bottom: isTablet ? 32.0 : (isSmallScreen ? 16.0 : 24.0),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      q['questionText'] as String,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: questionFontSize,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
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
                              isSelected ? Color(0xFFd84040) : Color(0xFFD9D9D9),
                          foregroundColor: isSelected ? Colors.white : Colors.black,
                          elevation: 0,
                          padding: optionPadding,
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
                                overflow: TextOverflow.visible,
                                style: GoogleFonts.poppins(fontSize: optionFontSize),
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
                  SizedBox(height: isTablet ? 32.0 : (isSmallScreen ? 16.0 : 24.0)),
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
                                fontSize: buttonFontSize,
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
                          : () async {
                              if (currentQuestionIndex <
                                  widget.questions.length - 1) {
                                setState(() {
                                  currentQuestionIndex++;
                                });
                              } else {
                                // Calculate score
                                int score = 0;
                                for (int i = 0; i < widget.questions.length; i++) {
                                  // Check both field names for compatibility
                                  final correctIndex = widget.questions[i]['correctOptionIndex'] ?? 
                                                       widget.questions[i]['correctAnswerIndex'];
                                  if (selectedOptions[i] != null && 
                                      selectedOptions[i] == correctIndex) {
                                    score++;
                                  }
                                }

                                // Capture the navigator before the async gap, then
                                // push and await the results page. Using the captured
                                // NavigatorState avoids using a BuildContext across
                                // the async gap.
                                final navigator = Navigator.of(context);
                                final result = await navigator.push(
                                  MaterialPageRoute(
                                    builder: (context) => QuizResultsPage(
                                      questions: widget.questions,
                                      userAnswers: selectedOptions,
                                      score: score,
                                    ),
                                  ),
                                );

                                if (!mounted) return;
                                
                                // Check if user wants to retake the quiz
                                if (result is Map && result['retake'] == true) {
                                  // Reset quiz state and restart
                                  setState(() {
                                    currentQuestionIndex = 0;
                                    selectedOptions = List.filled(widget.questions.length, null);
                                  });
                                  // Don't pop - stay on quiz page to retake
                                } else {
                                  // User completed or went back, pop with result
                                  navigator.pop(result ?? {
                                    'completed': true,
                                    'score': score,
                                    'userAnswers': selectedOptions,
                                  });
                                }
                              }
                            },
                            child: Text(
                              currentQuestionIndex == widget.questions.length - 1
                                  ? 'Finish'
                                  : 'Next',
                              style: GoogleFonts.poppins(
                                fontSize: buttonFontSize,
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
            ),
          ),
        );
  }
}