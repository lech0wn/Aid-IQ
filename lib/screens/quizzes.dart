import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizzesPage extends StatelessWidget {
  const QuizzesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QuizScreen(),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String selectedFilter = "All";

  final List<Map<String, dynamic>> quizzes = [
    {"title": "First Aid Introduction", "questions": 10, "status": "Completed"},
    {"title": "CPR", "questions": 10, "status": "Ongoing"},
    {"title": "Proper Bandaging", "questions": 10, "status": "Completed"},
    {"title": "Wound Cleaning", "questions": 10, "status": "Ongoing"},
  ];

  @override
  Widget build(BuildContext context) {
    // 🔹 Filter quizzes based on the selected category
    final filteredQuizzes = selectedFilter == "All"
        ? quizzes
        : quizzes.where((quiz) => quiz["status"] == selectedFilter).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFD32F2F),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🔺 Header
            Container(
              color: const Color(0xFFD32F2F),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Quizzes",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.health_and_safety, color: Colors.white, size: 28),
                ],
              ),
            ),

            // 🔺 Filter Buttons
            Container(
              color: const Color(0xFFD32F2F),
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ["All", "Ongoing", "Completed"].map((filter) {
                  final isSelected = selectedFilter == filter;
                  return GestureDetector(
                    onTap: () => setState(() => selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : const Color(0xFFD32F2F),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            filter == "All"
                                ? Icons.filter_list
                                : filter == "Ongoing"
                                    ? Icons.access_time
                                    : Icons.check_circle,
                            color: isSelected ? const Color(0xFFD32F2F) : Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            filter,
                            style: GoogleFonts.poppins(
                              color: isSelected ? const Color(0xFFD32F2F) : Colors.white,
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

            // 🔹 Filtered Quiz List
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
                              backgroundColor: quiz["status"] == "Completed"
                                  ? Colors.grey
                                  : Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: quiz["status"] == "Completed"
                                ? null
                                : () {
                                    setState(() {
                                      quiz["status"] = "Completed";
                                    });
                                  },
                            child: Text(
                              quiz["status"] == "Completed" ? "Done" : "Take Test",
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
      ),
    );
  }
}
