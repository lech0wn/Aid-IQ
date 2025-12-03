import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aid_iq/utils/logger.dart';
import 'dart:async';

class AppUsageService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  
  Timer? _sessionTimer;
  bool _hasCompletedToday = false;
  static const int REQUIRED_MINUTES = 15;

  // Start tracking a session
  void startSession() {
    // Check if we've already completed today's requirement
    _checkIfAlreadyCompletedToday();
    
    // Set a timer for 15 minutes
    _sessionTimer?.cancel();
    _sessionTimer = Timer(const Duration(minutes: REQUIRED_MINUTES), () {
      _onSessionComplete();
    });
    
    appLogger.d('App session started - tracking 15 minutes');
  }

  // Check if user already completed today's requirement
  Future<void> _checkIfAlreadyCompletedToday() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final userRef = _db.collection('users').doc(user.uid);
      final userDoc = await userRef.get();
      
      if (userDoc.exists) {
        final data = userDoc.data() ?? {};
        final lastActivityDate = data['lastActivityDate'] as Timestamp?;
        
        if (lastActivityDate != null) {
          final lastDate = lastActivityDate.toDate();
          final today = DateTime.now();
          final lastActivityDay = DateTime(
            lastDate.year,
            lastDate.month,
            lastDate.day,
          );
          final todayDay = DateTime(
            today.year,
            today.month,
            today.day,
          );
          
          // If last activity was today, mark as already completed
          _hasCompletedToday = lastActivityDay.isAtSameMomentAs(todayDay);
        }
      }
    } catch (e) {
      appLogger.e('Error checking if already completed today', error: e);
    }
  }

  // Stop tracking a session
  void stopSession() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    appLogger.d('App session stopped');
  }

  // Called when 15 minutes are reached
  Future<void> _onSessionComplete() async {
    // Only update if we haven't already completed today
    if (_hasCompletedToday) {
      appLogger.d('Already completed today - skipping streak update');
      return;
    }
    
    try {
      await updateStreakFromAppUsage();
      _hasCompletedToday = true;
      appLogger.d('15 minutes reached - streak updated');
    } catch (e) {
      appLogger.e('Error updating streak from app usage', error: e);
    }
  }

  // Update streak based on app usage (15 minutes)
  Future<void> updateStreakFromAppUsage() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final userRef = _db.collection('users').doc(user.uid);
      final userDoc = await userRef.get();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      Map<String, dynamic> currentData = {};
      if (userDoc.exists) {
        currentData = userDoc.data() ?? {};
      }

      int streak = currentData['streak'] ?? 0;
      Timestamp? lastActivityDate = currentData['lastActivityDate'];

      // Update streak based on last activity date
      if (lastActivityDate != null) {
        final lastDate = lastActivityDate.toDate();
        final lastActivityDay = DateTime(
          lastDate.year,
          lastDate.month,
          lastDate.day,
        );
        final daysDifference = today.difference(lastActivityDay).inDays;

        if (daysDifference == 0) {
          // Same day - don't change streak (already counted today)
        } else if (daysDifference == 1) {
          // Consecutive day - increment streak
          streak++;
        } else {
          // Streak broken - reset to 0
          streak = 0;
        }
      } else {
        // First activity ever - start streak at 1
        streak = 1;
      }

      // Update last activity date
      if (!userDoc.exists) {
        await userRef.set({
          'streak': streak,
          'lastActivityDate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        await userRef.update({
          'streak': streak,
          'lastActivityDate': FieldValue.serverTimestamp(),
        });
      }

      appLogger.d('Updated streak from app usage: $streak');
    } catch (e) {
      appLogger.e('Error updating streak from app usage', error: e);
    }
  }

  void dispose() {
    _sessionTimer?.cancel();
  }
}

