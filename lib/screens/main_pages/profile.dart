import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aid_iq/screens/legal_pages/terms_and_conditions.dart';
import 'package:aid_iq/screens/main_pages/edit_profile.dart';
import 'package:aid_iq/services/auth_service.dart';
import 'package:aid_iq/services/quiz_service.dart';
import 'package:aid_iq/services/local_module_service.dart';
import 'package:aid_iq/utils/logger.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final LocalModuleService _moduleService = LocalModuleService();
  int _streak = 0;
  int _modulesCompleted = 0;
  int _perfectScores = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    try {
      // Load quiz stats for streak and perfect scores
      final QuizService quizService = QuizService();
      final quizProgress = await quizService.getUserQuizProgress();

      // Calculate perfect scores (quizzes with 100%)
      int perfectScores = 0;
      final quizProgressData =
          quizProgress['quizProgress'] as Map<String, dynamic>? ?? {};
      for (final entry in quizProgressData.entries) {
        final progress = entry.value;
        if (progress is Map) {
          final percentage = progress['percentage'] as int?;
          final score = progress['score'] as int?;
          final totalQuestions = progress['totalQuestions'] as int?;

          // Check if it's a perfect score (100% or score == totalQuestions)
          if (percentage == 100 ||
              (score != null &&
                  totalQuestions != null &&
                  score == totalQuestions)) {
            perfectScores++;
          }
        }
      }

      // Load module stats
      final moduleProgress = await _moduleService.getUserModuleProgress();

      setState(() {
        _streak = quizProgress['streak'] ?? 0;
        _modulesCompleted = moduleProgress['modulesCompleted'] ?? 0;
        _perfectScores = perfectScores;
        _isLoading = false;
      });
    } catch (e) {
      appLogger.e('Error loading user stats', error: e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        "Your Profile",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // White Content Card
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // User Information
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Builder(
                            builder: (context) {
                              final authService = AuthService();
                              final user = authService.currentUser;
                              final displayName = user?.displayName ?? 'User';
                              final email = user?.email ?? 'No email';
                              final creationDate = user?.metadata.creationTime;
                              final joinedText =
                                  creationDate != null
                                      ? 'Joined ${DateFormat('MMM yyyy').format(creationDate)}'
                                      : '';

                              return Column(
                                children: [
                                  // Username
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: 20,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        displayName,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Email
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.email,
                                        size: 18,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          email,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (joinedText.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    // Join Date
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 18,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          DateFormat(
                                            'MMM yyyy',
                                          ).format(creationDate!),
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Stats Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFd84040),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child:
                                _isLoading
                                    ? Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : Column(
                                      children: [
                                        // First row: Streak and Modules
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Expanded(
                                              child: _buildStatItem(
                                                'STREAK',
                                                '$_streak',
                                                Icons.local_fire_department,
                                                Colors.orange,
                                              ),
                                            ),
                                            Container(
                                              height: 50,
                                              width: 1,
                                              color: Colors.white,
                                            ),
                                            Expanded(
                                              child: _buildStatItem(
                                                'MODULES',
                                                '$_modulesCompleted',
                                                Icons.article,
                                                Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Divider
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          height: 1,
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                        // Second row: Perfect Scores (centered)
                                        _buildStatItem(
                                          'PERFECT SCORES',
                                          '$_perfectScores',
                                          Icons.star,
                                          Colors.amber,
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Options List
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              _buildOptionTile(
                                context: context,
                                title: 'Terms and Conditions',
                                icon: Icons.help_outline,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const TermsAndConditionsPage(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildOptionTile(
                                context: context,
                                title: 'Edit Profile',
                                icon: Icons.edit,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const EditProfilePage(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildOptionTile(
                                context: context,
                                title: 'Log Out',
                                icon: Icons.logout,
                                onTap: () {
                                  _showLogoutDialog(context);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white70,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFFd84040),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54, // Dim background
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white, // Explicit white background
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
                // Title
                Text(
                  'Are you sure you want to log out?',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Subtitle/Hint
                Text(
                  'Make sure you remember your password!',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFFd84040),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Log Out Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          try {
                            final authService = AuthService();
                            await authService.signOut();
                            // Navigate to signup/login screen
                            if (context.mounted) {
                              Navigator.of(
                                context,
                              ).pushNamedAndRemoveUntil('/', (route) => false);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error logging out: $e',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFd84040),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Log Out',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
    );
  }
}
