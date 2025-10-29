import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50), // Space for back button
                    // Title
                    Center(
                      child: Text(
                        "Terms and Conditions",
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 1. Acceptance of Terms
                    _buildTermSection(
                      number: "1",
                      title: "Acceptance of Terms",
                      content:
                          "By accessing and using the Aid IQ application, you agree to be bound by these Terms and Conditions. If you do not agree with any part of these terms, you must not use the application.",
                    ),
                    const SizedBox(height: 24),

                    // 2. Educational Purpose
                    _buildTermSection(
                      number: "2",
                      title: "Educational Purpose",
                      content:
                          "The Aid IQ application is designed for educational purposes only. It does not provide professional medical advice, diagnosis, or treatment. For any medical concerns, you should consult a qualified healthcare provider.",
                    ),
                    const SizedBox(height: 24),

                    // 3. User Responsibility
                    _buildTermSection(
                      number: "3",
                      title: "User Responsibility",
                      content:
                          "You are solely responsible for your use of the information provided by this application. In case of a medical emergency, please immediately contact emergency services.",
                    ),
                    const SizedBox(height: 24),

                    // 4. Limitation of Liability
                    _buildTermSection(
                      number: "4",
                      title: "Limitation of Liability",
                      content:
                          "The application, its developers, owners, and affiliates shall not be liable for any harm, injury, or damages resulting from the use or misuse of this application. This includes, but is not limited to, direct, indirect, incidental, consequential, or punitive damages.",
                    ),
                    const SizedBox(height: 24),

                    // 5. Intellectual Property
                    _buildTermSection(
                      number: "5",
                      title: "Intellectual Property",
                      content:
                          "All content within the application, including but not limited to text, graphics, logos, and materials, is protected by copyright and intellectual property laws. You may not reproduce, distribute, or create derivative works without express written permission.",
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Back arrow button
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermSection({
    required String number,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$number. $title",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
