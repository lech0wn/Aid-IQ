import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aid_iq/services/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isPasswordChanged = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _authService.currentUser;
    if (user != null) {
      usernameController.text = user.displayName ?? '';
      emailController.text = user.email ?? '';
      passwordController.text = ''; // Don't show password
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Red Header
          Container(
            color: const Color(0xFFd84040),
            padding: const EdgeInsets.only(top: 48, bottom: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Edit Profile',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Balance for back button
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                          // Username Field
                          Text(
                            'Username',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: usernameController,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your username',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey[400],
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xFFd84040),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              if (RegExp(
                                r'[!@#\$%^&*(),.?":{}|<>]',
                              ).hasMatch(value)) {
                                return 'No special characters allowed';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Email Field (Read-only)
                          Text(
                            'Email',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            readOnly: true,
                            enabled: false,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your email',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey[400],
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Edit Password Field
                          Text(
                            'New Password (leave empty to keep current)',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter new password',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey[400],
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xFFd84040),
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _isPasswordChanged = value.isNotEmpty;
                              });
                            },
                            validator: (value) {
                              if (value != null &&
                                  value.isNotEmpty &&
                                  value.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 40),

                          // Save Changes Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () async {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() {
                                            _isLoading = true;
                                          });

                                          try {
                                            final user =
                                                _authService.currentUser;
                                            if (user == null) {
                                              throw 'No user is currently signed in.';
                                            }

                                            // Update username if changed
                                            final currentDisplayName =
                                                user.displayName ?? '';
                                            if (usernameController.text
                                                    .trim() !=
                                                currentDisplayName) {
                                              await _authService
                                                  .updateDisplayName(
                                                    usernameController.text
                                                        .trim(),
                                                  );
                                            }

                                            // Email is read-only and cannot be changed

                                            // Update password if provided
                                            if (_isPasswordChanged &&
                                                passwordController
                                                    .text
                                                    .isNotEmpty) {
                                              try {
                                                await _authService.updatePassword(
                                                  passwordController.text,
                                                );
                                              } catch (e) {
                                                // If re-authentication is required, prompt for current password
                                                if (e.toString().contains('Please enter your current password')) {
                                                  final currentPassword = await _showPasswordDialog(
                                                    context,
                                                    title: 'Enter Your Current Password',
                                                    subtitle: 'Please enter your current password to change your password.',
                                                  );
                                                  if (currentPassword != null && currentPassword.isNotEmpty) {
                                                    // Retry with current password
                                                    await _authService.updatePassword(
                                                      passwordController.text,
                                                      currentPassword: currentPassword,
                                                    );
                                                  } else {
                                                    throw 'Password update cancelled. Current password is required to change your password.';
                                                  }
                                                } else {
                                                  rethrow;
                                                }
                                              }
                                            }

                                            if (!mounted) return;
                                            final messenger =
                                                ScaffoldMessenger.of(context);
                                            messenger.showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Profile updated successfully!',
                                                  style: GoogleFonts.poppins(),
                                                ),
                                                backgroundColor:
                                                    Colors.green[700],
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
                                              ),
                                            );
                                            final navigator = Navigator.of(
                                              context,
                                            );
                                            navigator.pop();
                                          } catch (e) {
                                            if (!mounted) return;
                                            final messenger =
                                                ScaffoldMessenger.of(context);
                                            messenger.showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  e.toString(),
                                                  style: GoogleFonts.poppins(),
                                                ),
                                                backgroundColor: Colors.red,
                                                duration: const Duration(
                                                  seconds: 3,
                                                ),
                                              ),
                                            );
                                          } finally {
                                            if (mounted) {
                                              setState(() {
                                                _isLoading = false;
                                              });
                                            }
                                          }
                                        }
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFd84040),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                disabledBackgroundColor: Colors.grey,
                              ),
                              child:
                                  _isLoading
                                      ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        'Save Changes',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
            ),
          ],
      ),
    );
  }

  Future<String?> _showPasswordDialog(
    BuildContext context, {
    String title = 'Enter Your Password',
    String subtitle = 'Please enter your current password to change your email address.',
  }) async {
    final passwordController = TextEditingController();
    bool obscurePassword = true;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                    // Title
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    // Subtitle
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Password Field
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey[400],
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFFd84040),
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                      autofocus: true,
                      onFieldSubmitted: (value) {
                        if (value.isNotEmpty) {
                          Navigator.of(context).pop(value);
                        }
                      },
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
                        // Confirm Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final password = passwordController.text;
                              if (password.isNotEmpty) {
                                Navigator.of(context).pop(password);
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
                              'Confirm',
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
      },
    );
  }
}
