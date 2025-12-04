import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LearnMorePage extends StatelessWidget {
  const LearnMorePage({super.key});

  final List<Map<String, String>> faqData = const [
    {
      'question': 'What is Aid IQ and what does it do?',
      'answer':
          'Aid IQ is a mobile application aimed to entertain our users through gamifying the process of learning first aid techniques. ',
    },
    {
      'question': 'Who is this app for?',
      'answer':
          'Aid IQ is intended for students, more specifically, students who are a part of the red cross organization or are training to be a member. ',
    },
    {
      'question':
          'Is the information in the app up-to-date and accurate? Where does the information in the app come from?',
      'answer':
          'The information in Aid IQ is sourced from reputable medical and first aid organizations. Organizations that are credited to give people certificates that identify individuals to be capable of first aid techniques.',
    },
    {
      'question': 'Is the app free to use? Are there any in-app purchases?',
      'answer':
          'Aid IQ is a completely free app with no hidden costs or content behind any paywalls.',
    },
    {
      'question': 'Can I use this app offline?',
      'answer':
          'Aid IQ is almost completely accessible online, except for the initial sign up, the modules and quizzes are accessible offline without restrictions.',
    },
    {
      'question': 'Who can I contact if I have any questions or feedback?',
      'answer':
          'You can contact us at aidiq@gmail.com. We will be happy to help you with any questions or feedback you have.',
    },
  ];
  // ============================================================
  // END OF ACCORDION DATA STORAGE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header with Back Arrow and Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFFD84040),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Learn More',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD84040),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for back button
                ],
              ),
            ),

            // const SizedBox(height: 40),
            // Aid IQ Branding Section (Red Banner)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              decoration: BoxDecoration(
                color: const Color(0xFFD84040),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/AIDIQ_logo_white.png',
                    height: 80,
                    width: 80,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Aid IQ',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'made by Software Engineers',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Accordion/FAQ Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children:
                      faqData.map((faq) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
                              title: Text(
                                faq['question']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  child: Text(
                                    faq['answer']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black54,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
