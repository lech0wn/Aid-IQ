import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aid_iq/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<User?> signUpWithEmail(
    String email,
    String password,
    String? displayName,
  ) async {
    int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        final user = cred.user;
        if (user == null) {
          throw 'Failed to create user account.';
        }

        // Return user immediately for faster UX
        // Background tasks will complete asynchronously
        _initializeUserDataInBackground(user, displayName);
        
        return user;
      } on FirebaseAuthException catch (e) {
        // Check if it's a network error that we should retry
        final errorCode = e.code.toLowerCase();
        final errorMessage = e.message?.toLowerCase() ?? '';

        if ((errorCode == 'unknown' ||
                errorMessage.contains('connection') ||
                errorMessage.contains('network') ||
                errorMessage.contains('i/o') ||
                errorMessage.contains('reset')) &&
            retryCount < maxRetries - 1) {
          retryCount++;
          appLogger.w(
            'Network error during signup, retrying ($retryCount/$maxRetries)',
            error: e,
          );
          // Wait before retrying (exponential backoff)
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }

        throw _friendlySignUpError(e);
      } catch (e) {
        final errorString = e.toString().toLowerCase();

        // Check if it's a network error that we should retry
        if ((errorString.contains('connection') ||
                errorString.contains('network') ||
                errorString.contains('i/o') ||
                errorString.contains('reset') ||
                errorString.contains('timeout')) &&
            retryCount < maxRetries - 1) {
          retryCount++;
          appLogger.w(
            'Network error during signup, retrying ($retryCount/$maxRetries)',
            error: e,
          );
          // Wait before retrying (exponential backoff)
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }

        // Catch any other exceptions and provide a helpful message
        appLogger.e('Signup error', error: e);
        if (e is FirebaseException) {
          final errorMsg = e.message ?? e.code;
          // Check for CONFIGURATION_NOT_FOUND
          if (errorMsg.contains('CONFIGURATION_NOT_FOUND')) {
            throw 'Firebase configuration error. Please add SHA-1 fingerprint to Firebase Console.';
          }
          if (errorString.contains('connection') ||
              errorString.contains('network') ||
              errorString.contains('i/o') ||
              errorString.contains('reset')) {
            throw 'Network error: Please check your internet connection and try again.';
          }
          throw 'Firebase error: $errorMsg';
        }
        final errorStr = e.toString();
        if (errorStr.contains('CONFIGURATION_NOT_FOUND')) {
          throw 'Firebase configuration error. Please add SHA-1 fingerprint to Firebase Console.';
        }
        if (errorString.contains('connection') ||
            errorString.contains('network') ||
            errorString.contains('i/o') ||
            errorString.contains('reset')) {
          throw 'Network error: Please check your internet connection and try again.';
        }
        throw 'Sign up failed: $errorStr';
      }
    }

    // If we exhausted all retries
    throw 'Network error: Unable to connect. Please check your internet connection and try again.';
  }

  Future<User?> signInWithEmail(String email, String password) async {
    int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final cred = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Update Firestore, but don't fail login if Firestore fails
        try {
          await _upsertUser(cred.user);
        } catch (e) {
          // Log Firestore error but don't fail login
          appLogger.w('Failed to save user to Firestore', error: e);
        }
        return cred.user;
      } on FirebaseAuthException catch (e) {
        // Check if it's a network error that we should retry
        final errorCode = e.code.toLowerCase();
        final errorMessage = e.message?.toLowerCase() ?? '';

        if ((errorCode == 'unknown' ||
                errorMessage.contains('connection') ||
                errorMessage.contains('network') ||
                errorMessage.contains('i/o') ||
                errorMessage.contains('reset')) &&
            retryCount < maxRetries - 1) {
          retryCount++;
          appLogger.w(
            'Network error during login, retrying ($retryCount/$maxRetries)',
            error: e,
          );
          // Wait before retrying (exponential backoff)
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }

        appLogger.e('Login error', error: e, stackTrace: StackTrace.current);
        throw _friendlyError(e);
      } catch (e) {
        final errorString = e.toString().toLowerCase();

        // Check if it's a network error that we should retry
        if ((errorString.contains('connection') ||
                errorString.contains('network') ||
                errorString.contains('i/o') ||
                errorString.contains('reset') ||
                errorString.contains('timeout')) &&
            retryCount < maxRetries - 1) {
          retryCount++;
          appLogger.w(
            'Network error during login, retrying ($retryCount/$maxRetries)',
            error: e,
          );
          // Wait before retrying (exponential backoff)
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }

        appLogger.e('Login error', error: e);
        if (errorString.contains('connection') ||
            errorString.contains('network') ||
            errorString.contains('i/o') ||
            errorString.contains('reset')) {
          throw 'Network error: Please check your internet connection and try again.';
        }
        throw 'Login failed: ${e.toString()}';
      }
    }

    // If we exhausted all retries
    throw 'Network error: Unable to connect. Please check your internet connection and try again.';
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Deletes the user's account and clears all authentication state.
  /// 
  /// This method:
  /// 1. Re-authenticates the user with their password
  /// 2. Deletes user data from Firestore
  /// 3. Deletes the Firebase Auth account (this automatically clears auth tokens/session)
  /// 4. Explicitly signs out from Firebase
  /// 
  /// After successful deletion, the user is effectively logged out and cannot
  /// access authenticated routes. The frontend should redirect to sign-up page.
  /// 
  /// Throws an exception if deletion fails - frontend should NOT redirect on error.
  /// 
  /// @param password The user's current password for re-authentication
  /// @throws FirebaseAuthException with specific error codes
  Future<void> deleteAccount(String password) async {
    final user = _auth.currentUser;
    if (user == null) throw 'No user is currently signed in.';

    try {
      // Step 1: Re-authenticate user with password (required by Firebase for sensitive operations)
      await reauthenticateWithPassword(password);

      // Step 2: Delete user data from Firestore
      try {
        await _db.collection('users').doc(user.uid).delete();
        appLogger.d('User data deleted from Firestore');
      } catch (e) {
        appLogger.w('Failed to delete user data from Firestore', error: e);
        // Continue with account deletion even if Firestore deletion fails
      }

      // Step 3: Delete the Firebase Auth account
      // This automatically:
      // - Invalidates all auth tokens
      // - Clears the current session
      // - Logs the user out
      // - Makes currentUser return null
      await user.delete();
      appLogger.d('User account deleted successfully - auth tokens cleared');

      // Step 4: Explicitly sign out from Firebase to ensure complete session clearing
      // (user.delete() should handle this, but this ensures it)
      try {
        await _auth.signOut();
      } catch (_) {
        // Ignore sign out errors if account is already deleted
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase auth errors
      switch (e.code) {
        case 'requires-recent-login':
          throw 'Please enter your password to delete your account.';
        case 'wrong-password':
          throw 'Incorrect password. Please try again.';
        case 'invalid-credential':
          throw 'Invalid credentials. Please try again.';
        default:
          throw 'Failed to delete account: ${e.message ?? e.code}';
      }
    } catch (e) {
      appLogger.e('Error deleting account', error: e);
      rethrow;
    }
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> updateDisplayName(String displayName) async {
    final user = _auth.currentUser;
    if (user == null) throw 'No user is currently signed in.';

    try {
      await user.updateDisplayName(displayName);
      await user.reload();
      // Update Firestore
      final updatedUser = _auth.currentUser;
      if (updatedUser != null) {
        await _upsertUser(updatedUser);
      }
    } on FirebaseAuthException catch (e) {
      throw 'Failed to update username: ${e.message ?? e.code}';
    }
  }

  Future<void> reauthenticateWithPassword(String password) async {
    final user = _auth.currentUser;
    if (user == null) throw 'No user is currently signed in.';
    if (user.email == null) throw 'User email is not available.';

    try {
      // Create credential with email and password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      // Re-authenticate the user
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          throw 'Incorrect password. Please try again.';
        case 'invalid-credential':
          throw 'Invalid credentials. Please try again.';
        case 'user-mismatch':
          throw 'The provided credentials do not match the current user.';
        case 'user-not-found':
          throw 'User not found.';
        case 'invalid-email':
          throw 'Invalid email address.';
        case 'network-request-failed':
          throw 'Network error. Please check your internet connection.';
        default:
          throw 'Re-authentication failed: ${e.message ?? e.code}';
      }
    }
  }

  Future<void> updateEmail(String newEmail, {String? password}) async {
    final user = _auth.currentUser;
    if (user == null) throw 'No user is currently signed in.';

    try {
      // Try to use updateEmail - use dynamic call as workaround for version compatibility
      await (user as dynamic).updateEmail(newEmail);
      await user.reload();
      // Update Firestore
      final updatedUser = _auth.currentUser;
      if (updatedUser != null) {
        await _upsertUser(updatedUser);
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'requires-recent-login':
          // If password is provided, try to re-authenticate and retry
          if (password != null && password.isNotEmpty) {
            try {
              await reauthenticateWithPassword(password);
              // Retry the email update after re-authentication
              await (user as dynamic).updateEmail(newEmail);
              await user.reload();
              final updatedUser = _auth.currentUser;
              if (updatedUser != null) {
                await _upsertUser(updatedUser);
              }
              return; // Success
            } catch (reauthError) {
              // Re-throw the re-authentication error
              throw reauthError;
            }
          }
          throw 'Please enter your password to change your email address.';
        case 'email-already-in-use':
          throw 'This email is already in use by another account.';
        case 'invalid-email':
          throw 'Invalid email address.';
        default:
          throw 'Failed to update email: ${e.message ?? e.code}';
      }
    } catch (e) {
      // If method doesn't exist, provide helpful error
      if (e.toString().contains("isn't defined") ||
          e.toString().contains("NoSuchMethodError")) {
        throw 'Email update is not available in this version. Please contact support.';
      }
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword, {String? currentPassword}) async {
    final user = _auth.currentUser;
    if (user == null) throw 'No user is currently signed in.';

    try {
      // Use dynamic call as workaround for version compatibility
      await (user as dynamic).updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'requires-recent-login':
          // If current password is provided, try to re-authenticate and retry
          if (currentPassword != null && currentPassword.isNotEmpty) {
            try {
              await reauthenticateWithPassword(currentPassword);
              // Retry the password update after re-authentication
              await (user as dynamic).updatePassword(newPassword);
              return; // Success
            } catch (reauthError) {
              // Re-throw the re-authentication error
              throw reauthError;
            }
          }
          throw 'Please enter your current password to change your password.';
        case 'weak-password':
          throw 'The password provided is too weak.';
        default:
          throw 'Failed to update password: ${e.message ?? e.code}';
      }
    } catch (e) {
      // If method doesn't exist, provide helpful error
      if (e.toString().contains("isn't defined") ||
          e.toString().contains("NoSuchMethodError")) {
        throw 'Password update is not available in this version. Please contact support or re-authenticate.';
      }
      rethrow;
    }
  }

  Future<void> _upsertUser(User? user) async {
    if (user == null) return;
    try {
      final userRef = _db.collection('users').doc(user.uid);
      final userDoc = await userRef.get();

      Map<String, dynamic> userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'lastLogin': FieldValue.serverTimestamp(),
        'provider':
            user.providerData.isNotEmpty
                ? user.providerData.first.providerId
                : null,
      };

      // Initialize all stats to zero/empty if user doesn't exist yet
      if (!userDoc.exists) {
        userData['quizzesTaken'] = 0;
        userData['streak'] = 0;
        userData['quizProgress'] = {};
        userData['modulesCompleted'] = 0;
        userData['moduleProgress'] = {};
        userData['moduleBookmarks'] = [];
        userData['totalReadingTime'] = 0;
        // Note: lastQuizDate and lastActivityDate are not set for new users
        // They will be created when the user takes their first quiz
      }

      await userRef.set(userData, SetOptions(merge: true));
    } catch (e) {
      appLogger.e('Error saving user to Firestore', error: e);
      rethrow;
    }
  }

  /// Initialize user data in the background (non-blocking)
  /// This allows the sign-up flow to return immediately for better UX
  void _initializeUserDataInBackground(User user, String? displayName) {
    // Update display name if provided (non-blocking)
    if (displayName != null && displayName.isNotEmpty) {
      user.updateDisplayName(displayName).catchError((e) {
        appLogger.w('Failed to update display name', error: e);
      });
    }
    
    // Save user to Firestore (non-blocking)
    _upsertUser(user).catchError((e) {
      appLogger.w('Failed to save user to Firestore', error: e);
    });
    
    // Clear local stats (non-blocking)
    _clearLocalStats().catchError((e) {
      appLogger.w('Failed to clear local stats', error: e);
    });
  }

  /// Clear all local stats stored in SharedPreferences
  /// This ensures new accounts start with a clean slate
  Future<void> _clearLocalStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Clear all module-related stats
      await prefs.remove('module_progress');
      await prefs.remove('modules_completed');
      await prefs.remove('total_reading_time');
      await prefs.remove('module_bookmarks');
      appLogger.d('Cleared all local stats for new account');
    } catch (e) {
      appLogger.w('Failed to clear local stats', error: e);
      // Don't throw - this is not critical for account creation
    }
  }

  String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        // Show the actual error code and message for debugging
        return 'Login failed: ${e.code} - ${e.message ?? "Unknown error"}. Please try again.';
    }
  }

  String _friendlySignUpError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      default:
        // Check for CONFIGURATION_NOT_FOUND in the message
        if (e.message != null &&
            e.message!.contains('CONFIGURATION_NOT_FOUND')) {
          return 'Firebase configuration error. Please ensure SHA-1 fingerprint is added to Firebase Console.';
        }
        return 'Sign up failed: ${e.message ?? e.code}. Please try again.';
    }
  }
}
