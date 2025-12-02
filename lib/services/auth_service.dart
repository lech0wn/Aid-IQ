import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:aid_iq/utils/logger.dart';
import 'package:flutter/services.dart';
// image upload features removed — imports reverted

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _google = GoogleSignIn(scopes: ['email']);
  // final FirebaseStorage _storage = FirebaseStorage.instance;

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
        // Update display name if provided
        if (displayName != null &&
            displayName.isNotEmpty &&
            cred.user != null) {
          try {
            await cred.user!.updateDisplayName(displayName);
            await cred.user!.reload();
          } catch (e) {
            // If updating display name fails, continue anyway
            appLogger.w('Failed to update display name', error: e);
          }
        }
        // Get the updated user after reload
        final user = _auth.currentUser;
        if (user != null) {
          try {
            await _upsertUser(user);
          } catch (e) {
            // If Firestore write fails, still return the user (auth succeeded)
            appLogger.w('Failed to save user to Firestore', error: e);
          }
        }
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

  Future<User?> signInWithGoogle() async {
    int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        // Sign in with Google
        final acct = await _google.signIn();

        // User cancelled the sign-in
        if (acct == null) {
          appLogger.d('Google sign-in cancelled by user');
          return null;
        }

        // Get authentication details
        final auth = await acct.authentication;

        // Check if we have the required tokens
        if (auth.idToken == null) {
          throw 'Failed to get authentication token. Please try again.';
        }

        // Create Firebase credential
        final credential = GoogleAuthProvider.credential(
          idToken: auth.idToken,
          accessToken: auth.accessToken,
        );

        // Sign in to Firebase with Google credential
        final cred = await _auth.signInWithCredential(credential);

        if (cred.user == null) {
          throw 'Failed to sign in. Please try again.';
        }

        // Save user to Firestore (don't fail if this fails)
        try {
          await _upsertUser(cred.user);
        } catch (e) {
          appLogger.w(
            'Failed to save user to Firestore after Google sign-in',
            error: e,
          );
          // Continue anyway - auth succeeded
        }

        appLogger.i('Google sign-in successful for ${cred.user!.email}');
        return cred.user;
      } on FirebaseAuthException catch (e) {
        appLogger.e('Firebase auth error during Google sign-in', error: e);

        // Check if it's a network error that we should retry
        final errorCode = e.code.toLowerCase();
        final errorMessage = e.message?.toLowerCase() ?? '';

        if ((errorCode == 'unknown' ||
                errorCode == 'network-request-failed' ||
                errorMessage.contains('connection') ||
                errorMessage.contains('network') ||
                errorMessage.contains('i/o') ||
                errorMessage.contains('reset')) &&
            retryCount < maxRetries - 1) {
          retryCount++;
          appLogger.w(
            'Network error during Google sign-in, retrying ($retryCount/$maxRetries)',
            error: e,
          );
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }

        // Handle specific Firebase auth errors
        String errorMsg = _friendlyGoogleSignInError(e);
        throw errorMsg;
      } on PlatformException catch (e) {
        appLogger.e('Platform error during Google sign-in', error: e);

        // Handle specific Google Play Services error codes
        final errorCode = e.code;
        final errorMessage = e.message ?? '';

        // Error code 10 = DEVELOPER_ERROR (configuration issue)
        if (errorCode == 'sign_in_failed' &&
            (errorMessage.contains('ApiException: 10') ||
                errorMessage.contains('10:'))) {
          throw 'Google sign-in configuration error. Please ensure:\n'
              '1. SHA-1 fingerprint is added in Firebase Console\n'
              '2. Google Sign-In is enabled in Firebase Authentication\n'
              '3. OAuth client is configured correctly';
        }

        // Error code 4 = SIGN_IN_REQUIRED
        if (errorCode == 'sign_in_failed' &&
            errorMessage.contains('ApiException: 4')) {
          throw 'Please sign in to your Google account on this device first.';
        }

        // Error code 7 = NETWORK_ERROR
        if (errorCode == 'sign_in_failed' &&
            errorMessage.contains('ApiException: 7')) {
          if (retryCount < maxRetries - 1) {
            retryCount++;
            appLogger.w(
              'Network error during Google sign-in, retrying ($retryCount/$maxRetries)',
              error: e,
            );
            await Future.delayed(Duration(seconds: retryCount * 2));
            continue;
          }
          throw 'Network error: Please check your internet connection and try again.';
        }

        // Generic PlatformException handling
        if (errorCode == 'sign_in_failed') {
          throw 'Google sign-in failed: ${errorMessage.isNotEmpty ? errorMessage : "Please check your configuration"}';
        }

        throw 'Google sign-in error: ${errorMessage.isNotEmpty ? errorMessage : errorCode}';
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
            'Network error during Google sign-in, retrying ($retryCount/$maxRetries)',
            error: e,
          );
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }

        appLogger.e('Google sign-in error', error: e);

        // Provide user-friendly error messages
        if (errorString.contains('sign_in_canceled') ||
            errorString.contains('sign_in_cancelled')) {
          return null; // User cancelled - not an error
        }

        if (errorString.contains('configuration') ||
            errorString.contains('oauth') ||
            errorString.contains('client_id') ||
            errorString.contains('apiexception: 10') ||
            errorString.contains('developer_error')) {
          throw 'Google sign-in configuration error. Please ensure:\n'
              '1. SHA-1 fingerprint is added in Firebase Console\n'
              '2. Google Sign-In is enabled in Firebase Authentication\n'
              '3. OAuth client is configured correctly';
        }

        if (errorString.contains('network') ||
            errorString.contains('connection')) {
          throw 'Network error: Please check your internet connection and try again.';
        }

        // Generic error message
        final errorMsg = e.toString();
        if (errorMsg.startsWith('Exception: ')) {
          throw errorMsg.substring(11);
        }
        throw 'Google sign-in failed: ${errorMsg}';
      }
    }

    // If we exhausted all retries
    throw 'Network error: Unable to connect. Please check your internet connection and try again.';
  }

  String _friendlyGoogleSignInError(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in method.';
      case 'invalid-credential':
        return 'The credential is invalid or has expired. Please try again.';
      case 'operation-not-allowed':
        return 'Google sign-in is not enabled. Please contact support.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found. Please try again.';
      case 'wrong-password':
        return 'Invalid credentials. Please try again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Google sign-in failed: ${e.message ?? e.code}. Please try again.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await _google.signOut();
    } catch (_) {}
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

  Future<void> updateEmail(String newEmail) async {
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
          throw 'Coming Soon!';
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

  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw 'No user is currently signed in.';

    try {
      // Use dynamic call as workaround for version compatibility
      await (user as dynamic).updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'requires-recent-login':
          throw 'Coming Soon!';
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

  // uploadProfilePicture removed to revert profile-picture feature
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

      // Initialize quiz stats if user doesn't exist yet
      if (!userDoc.exists) {
        userData['quizzesTaken'] = 0;
        userData['streak'] = 0;
        userData['quizProgress'] = {};
      }

      await userRef.set(userData, SetOptions(merge: true));
    } catch (e) {
      appLogger.e('Error saving user to Firestore', error: e);
      rethrow;
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
