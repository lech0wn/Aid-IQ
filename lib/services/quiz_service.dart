import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aid_iq/utils/logger.dart';

class QuizService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Get all quizzes from Firestore
  Future<List<Map<String, dynamic>>> getAllQuizzes() async {
    try {
      final snapshot = await _db.collection('quizzes').get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      appLogger.e('Error loading quizzes', error: e);
      return [];
    }
  }

  // Get a specific quiz by title
  Future<Map<String, dynamic>?> getQuizByTitle(String title) async {
    try {
      final snapshot =
          await _db
              .collection('quizzes')
              .where('title', isEqualTo: title)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) return null;

      return {'id': snapshot.docs.first.id, ...snapshot.docs.first.data()};
    } catch (e) {
      appLogger.e('Error loading quiz', error: e);
      return null;
    }
  }

  // Upload a quiz to Firestore
  Future<void> uploadQuiz({
    required String title,
    required List<Map<String, dynamic>> questions,
    String? description,
  }) async {
    try {
      await _db.collection('quizzes').add({
        'title': title,
        'questions': questions,
        'questionCount': questions.length,
        'description': description ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      appLogger.e('Error uploading quiz', error: e);
      rethrow;
    }
  }

  // Get user's quiz progress
  Future<Map<String, dynamic>> getUserQuizProgress() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) return {};

      final data = doc.data() ?? {};
      
      // Safely convert quizProgress to proper type
      final quizProgressData = data['quizProgress'];
      Map<String, dynamic> quizProgress = {};
      if (quizProgressData != null && quizProgressData is Map) {
        quizProgress = Map<String, dynamic>.from(quizProgressData);
      }
      
      return {
        'quizzesTaken': data['quizzesTaken'] ?? 0,
        'streak': data['streak'] ?? 0,
        'lastQuizDate': data['lastQuizDate'],
        'quizProgress': quizProgress,
      };
    } catch (e) {
      appLogger.e('Error loading user quiz progress', error: e);
      return {};
    }
  }

  // Update user quiz progress when they complete a quiz
  Future<void> updateUserQuizProgress({
    required String quizTitle,
    required int score,
    required int totalQuestions,
    List<int?>? userAnswers,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw 'No user is currently signed in.';

    try {
      final userRef = _db.collection('users').doc(user.uid);
      final userDoc = await userRef.get();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      Map<String, dynamic> currentData = {};
      if (userDoc.exists) {
        currentData = userDoc.data() ?? {};
      }

      // Get current progress - use dot notation to update nested field
      Map<String, dynamic> quizProgress = {};
      final existingProgressData = currentData['quizProgress'];
      if (existingProgressData != null && existingProgressData is Map) {
        quizProgress = Map<String, dynamic>.from(existingProgressData);
      }

      int quizzesTaken = currentData['quizzesTaken'] ?? 0;
      int streak = currentData['streak'] ?? 0;
      Timestamp? lastQuizDate = currentData['lastQuizDate'];

      // Check if this is a new quiz completion (not a retake) BEFORE updating
      bool isNewCompletion = true;
      if (quizProgress.containsKey(quizTitle)) {
        final existingProgress = quizProgress[quizTitle];
        if (existingProgress is Map) {
          final existingMap = Map<String, dynamic>.from(existingProgress);
          if (existingMap['completed'] == true) {
            // Already completed before - this is a retake
            isNewCompletion = false;
          }
        }
      }

      // Update quiz progress - use dot notation for nested update
      quizProgress[quizTitle] = {
        'completed': true,
        'score': score,
        'totalQuestions': totalQuestions,
        'percentage': (score / totalQuestions * 100).round(),
        'completedAt': FieldValue.serverTimestamp(),
        if (userAnswers != null) 'userAnswers': userAnswers,
      };

      if (isNewCompletion) {
        quizzesTaken++;
      }

      // Update streak
      if (lastQuizDate != null) {
        final lastDate = lastQuizDate.toDate();
        final lastQuizDay = DateTime(
          lastDate.year,
          lastDate.month,
          lastDate.day,
        );
        final daysDifference = today.difference(lastQuizDay).inDays;

        if (daysDifference == 0) {
          // Same day - don't change streak
        } else if (daysDifference == 1) {
          // Consecutive day - increment streak
          streak++;
        } else {
          // Streak broken - reset to 1
          streak = 1;
        }
      } else {
        // First quiz ever - start streak at 1
        streak = 1;
      }

      // Write the entire quizProgress map back to Firestore
      // IMPORTANT: We write the FULL quizProgress map to ensure all quizzes are preserved
      // First, ensure the document exists, then update with the full nested map
      if (!userDoc.exists) {
        // Create document if it doesn't exist
        await userRef.set({
          'quizzesTaken': quizzesTaken,
          'streak': streak,
          'lastQuizDate': FieldValue.serverTimestamp(),
          'quizProgress': quizProgress,
        });
      } else {
        // Update existing document - write the full quizProgress map
        await userRef.update({
          'quizzesTaken': quizzesTaken,
          'streak': streak,
          'lastQuizDate': FieldValue.serverTimestamp(),
          'quizProgress': quizProgress, // Write the entire map with all quizzes
        });
      }
      
      appLogger.d(
        'Updated quiz progress for $quizTitle: completed=true, score=$score/$totalQuestions, quizzesTaken=$quizzesTaken',
      );
      appLogger.d('Full quizProgress map keys: ${quizProgress.keys.toList()}');
      appLogger.d('Quiz $quizTitle data: ${quizProgress[quizTitle]}');
      
      // Force a small delay to ensure Firestore has processed the write
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Verify the update was saved correctly - read back immediately
      final verifyDoc = await userRef.get();
      if (verifyDoc.exists) {
        final verifyData = verifyDoc.data();
        final verifyProgressData = verifyData?['quizProgress'];
        Map<String, dynamic> verifyProgress = {};
        if (verifyProgressData != null && verifyProgressData is Map) {
          verifyProgress = Map<String, dynamic>.from(verifyProgressData);
        }
        final verifyQuiz = verifyProgress[quizTitle];
        appLogger.d(
          'Verification - Quiz $quizTitle in Firestore: exists=${verifyQuiz != null}',
        );
        if (verifyQuiz != null) {
          if (verifyQuiz is Map) {
            final verifyQuizMap = Map<String, dynamic>.from(verifyQuiz);
            appLogger.d(
              'Verification - completed=${verifyQuizMap['completed']}, score=${verifyQuizMap['score']}, type=${verifyQuizMap['completed']?.runtimeType}',
            );
            // Double-check the completed value
            final completedVal = verifyQuizMap['completed'];
            appLogger.d(
              'Verification - completed value: $completedVal, is bool: ${completedVal is bool}, equals true: ${completedVal == true}',
            );
          } else {
            appLogger.w('Verification - Quiz progress is not a Map: ${verifyQuiz.runtimeType}');
          }
        } else {
          appLogger.w('Verification - Quiz $quizTitle not found in Firestore after save!');
        }
      }
    } catch (e) {
      appLogger.e('Error updating user quiz progress', error: e);
      rethrow;
    }
  }

  // Get user's completed quizzes
  Future<List<String>> getUserCompletedQuizzes() async {
    final progress = await getUserQuizProgress();
    final quizProgress =
        progress['quizProgress'] as Map<String, dynamic>? ?? {};

    return quizProgress.entries
        .where(
          (entry) =>
              entry.value is Map && (entry.value as Map)['completed'] == true,
        )
        .map((entry) => entry.key)
        .toList();
  }
}
