import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LearnMorePage extends StatelessWidget {
  const LearnMorePage({super.key});

  final List<Map<String, String>> faqData = const [
    {
      'question': 'What is Aid IQ and what does it do?',
      'answer':
          'Aid IQ is a mobile application designed to provide quick and reliable first aid information and quizzes to help users learn and test their knowledge in emergency situations.',
    },
    {
      'question': 'Who is this app for?',
      'answer':
          'This app is for anyone interested in learning basic first aid, from individuals wanting to be prepared for emergencies to students and professionals seeking to refresh their knowledge.',
    },
    {
      'question':
          'Is the information in the app up-to-date and accurate? Where does the information in the app come from?',
      'answer':
          'The information in Aid IQ is sourced from reputable medical and first aid organizations. We strive to keep it as up-to-date as possible, but it should not replace professional medical advice.',
    },
    {
      'question': 'Is the app free to use? Are there any in-app purchases?',
      'answer':
          'Yes, Aid IQ is completely free to download and use. There are no hidden costs or in-app purchases.',
    },
    {
      'question': 'Can I use this app offline?',
      'answer':
          'Yes, once downloaded, most of the app\'s content, including first aid guides and quizzes, can be accessed offline without an internet connection.',
    },
    // Add more FAQ items here as needed:
    // {
    //   'question': 'Your question here?',
    //   'answer': 'Your answer here.',
    // },
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
                  // Logo (White version)
                  Image.asset(
                    'assets/images/AIDIQ_logo_red.png',
                    height: 80,
                    width: 80,
                    color: Colors.white, // Makes logo white
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
