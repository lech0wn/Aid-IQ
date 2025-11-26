import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aid_iq/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ModuleService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Cache key for modules
  static const String _modulesCacheKey = 'cached_modules';
  static const String _modulesCacheTimestampKey = 'cached_modules_timestamp';

  // Save modules to local cache
  Future<void> _cacheModules(List<Map<String, dynamic>> modules) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(modules);
      await prefs.setString(_modulesCacheKey, jsonString);
      await prefs.setInt(_modulesCacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
      appLogger.d('Cached ${modules.length} modules locally');
    } catch (e) {
      appLogger.e('Error caching modules', error: e);
    }
  }

  // Load modules from local cache
  Future<List<Map<String, dynamic>>> _loadCachedModules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_modulesCacheKey);
      if (jsonString == null) return [];

      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      appLogger.e('Error loading cached modules', error: e);
      return [];
    }
  }

  // Get all modules from Firestore with offline caching support
  Future<List<Map<String, dynamic>>> getAllModules() async {
    // Try to load from Firestore first
    try {
      final snapshot = await _db.collection('modules').orderBy('order').get();
      final modules = snapshot.docs.map((doc) {
        final data = doc.data();
        // Convert Firestore Timestamps to ISO strings for JSON serialization
        final module = {'id': doc.id, ...data};
        // Handle Timestamp fields
        if (module['createdAt'] is Timestamp) {
          module['createdAt'] = (module['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        if (module['updatedAt'] is Timestamp) {
          module['updatedAt'] = (module['updatedAt'] as Timestamp).toDate().toIso8601String();
        }
        return module;
      }).toList();

      // Cache the modules for offline use
      await _cacheModules(modules);
      appLogger.d('Loaded ${modules.length} modules from Firestore and cached');
      return modules;
    } catch (e) {
      appLogger.w('Error loading modules from Firestore, trying cache', error: e);
      
      // Fallback to cached modules if Firestore fails
      final cachedModules = await _loadCachedModules();
      if (cachedModules.isNotEmpty) {
        appLogger.i('Loaded ${cachedModules.length} modules from cache (offline mode)');
        return cachedModules;
      }
      
      appLogger.e('No cached modules available', error: e);
      return [];
    }
  }

  // Get a specific module by ID with offline caching support
  Future<Map<String, dynamic>?> getModuleById(String moduleId) async {
    // Try Firestore first
    try {
      final doc = await _db.collection('modules').doc(moduleId).get();
      if (!doc.exists) {
        // Try cache as fallback
        final cachedModules = await _loadCachedModules();
        final cachedModule = cachedModules.firstWhere(
          (m) => m['id'] == moduleId,
          orElse: () => {},
        );
        if (cachedModule.isNotEmpty) {
          appLogger.d('Loaded module from cache (offline mode)');
          return cachedModule;
        }
        return null;
      }

      final data = doc.data()!;
      final module = {'id': doc.id, ...data};
      // Handle Timestamp fields
      if (module['createdAt'] is Timestamp) {
        module['createdAt'] = (module['createdAt'] as Timestamp).toDate().toIso8601String();
      }
      if (module['updatedAt'] is Timestamp) {
        module['updatedAt'] = (module['updatedAt'] as Timestamp).toDate().toIso8601String();
      }

      // Update cache with this module
      final cachedModules = await _loadCachedModules();
      final index = cachedModules.indexWhere((m) => m['id'] == moduleId);
      if (index >= 0) {
        cachedModules[index] = module;
      } else {
        cachedModules.add(module);
      }
      await _cacheModules(cachedModules);

      return module;
    } catch (e) {
      appLogger.w('Error loading module from Firestore, trying cache', error: e);
      
      // Fallback to cache
      final cachedModules = await _loadCachedModules();
      try {
        final cachedModule = cachedModules.firstWhere(
          (m) => m['id'] == moduleId,
          orElse: () => <String, dynamic>{},
        );
        if (cachedModule.isNotEmpty) {
          appLogger.d('Loaded module from cache (offline mode)');
          return cachedModule;
        }
        appLogger.e('Module not found in cache', error: e);
        return null;
      } catch (_) {
        appLogger.e('Module not found in cache', error: e);
        return null;
      }
    }
  }

  // Upload a module to Firestore
  Future<void> uploadModule({
    required String title,
    required String content,
    required List<String> pictures,
    int? order,
    String? description,
  }) async {
    try {
      await _db.collection('modules').add({
        'title': title,
        'content': content,
        'pictures': pictures,
        'description': description ?? '',
        'order': order ?? 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      appLogger.e('Error uploading module', error: e);
      rethrow;
    }
  }

  // Get user's module progress
  Future<Map<String, dynamic>> getUserModuleProgress() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) return {};

      final data = doc.data() ?? {};
      // Safely convert Firestore data to proper types
      final moduleProgressData = data['moduleProgress'];
      Map<String, dynamic> moduleProgress = {};
      if (moduleProgressData != null && moduleProgressData is Map) {
        moduleProgress = Map<String, dynamic>.from(moduleProgressData);
      }
      
      final bookmarksData = data['moduleBookmarks'];
      List<dynamic> moduleBookmarks = [];
      if (bookmarksData != null && bookmarksData is List) {
        moduleBookmarks = List.from(bookmarksData);
      }
      
      return {
        'modulesCompleted': data['modulesCompleted'] ?? 0,
        'moduleProgress': moduleProgress,
        'moduleBookmarks': moduleBookmarks,
        'totalReadingTime': data['totalReadingTime'] ?? 0, // in minutes
      };
    } catch (e) {
      appLogger.e('Error loading user module progress', error: e);
      return {};
    }
  }

  // Mark module as completed
  Future<void> markModuleCompleted(
    String moduleId,
    String moduleTitle,
    int readingTimeMinutes,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw 'No user is currently signed in.';

    try {
      final userRef = _db.collection('users').doc(user.uid);
      final userDoc = await userRef.get();

      Map<String, dynamic> currentData = {};
      if (userDoc.exists) {
        currentData = userDoc.data() ?? {};
      }

      // Get current progress
      Map<String, dynamic> moduleProgress = Map<String, dynamic>.from(
        currentData['moduleProgress'] ?? {},
      );

      int modulesCompleted = currentData['modulesCompleted'] ?? 0;
      int totalReadingTime = currentData['totalReadingTime'] ?? 0;

      // Check if this is a new completion
      bool isNewCompletion = true;
      if (moduleProgress.containsKey(moduleId)) {
        final existingProgress =
            moduleProgress[moduleId] as Map<String, dynamic>?;
        if (existingProgress != null && existingProgress['completed'] == true) {
          isNewCompletion = false;
        }
      }

      // Update module progress
      moduleProgress[moduleId] = {
        'completed': true,
        'completedAt': FieldValue.serverTimestamp(),
        'readingTime': readingTimeMinutes,
        'title': moduleTitle,
        'lastAccessed': FieldValue.serverTimestamp(),
      };

      if (isNewCompletion) {
        modulesCompleted++;
        totalReadingTime += readingTimeMinutes;
      } else {
        // Update reading time if user read it again
        final existingTime =
            (moduleProgress[moduleId] as Map)['readingTime'] as int? ?? 0;
        totalReadingTime = totalReadingTime - existingTime + readingTimeMinutes;
      }

      // Update user document
      await userRef.set({
        'modulesCompleted': modulesCompleted,
        'moduleProgress': moduleProgress,
        'totalReadingTime': totalReadingTime,
      }, SetOptions(merge: true));
    } catch (e) {
      appLogger.e('Error updating module progress', error: e);
      rethrow;
    }
  }

  // Update module reading progress (for tracking scroll position)
  Future<void> updateModuleReadingProgress(
    String moduleId,
    double scrollPosition,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final userRef = _db.collection('users').doc(user.uid);
      final userDoc = await userRef.get();

      Map<String, dynamic> currentData = {};
      if (userDoc.exists) {
        currentData = userDoc.data() ?? {};
      }

      Map<String, dynamic> moduleProgress = Map<String, dynamic>.from(
        currentData['moduleProgress'] ?? {},
      );

      if (!moduleProgress.containsKey(moduleId)) {
        moduleProgress[moduleId] = {};
      }

      (moduleProgress[moduleId] as Map<String, dynamic>)['scrollPosition'] =
          scrollPosition;
      (moduleProgress[moduleId] as Map<String, dynamic>)['lastAccessed'] =
          FieldValue.serverTimestamp();

      await userRef.set({
        'moduleProgress': moduleProgress,
      }, SetOptions(merge: true));
    } catch (e) {
      appLogger.e('Error updating reading progress', error: e);
    }
  }

  // Toggle bookmark
  Future<void> toggleBookmark(String moduleId) async {
    final user = _auth.currentUser;
    if (user == null) throw 'No user is currently signed in.';

    try {
      final userRef = _db.collection('users').doc(user.uid);
      final userDoc = await userRef.get();

      List<dynamic> bookmarks = [];
      if (userDoc.exists) {
        bookmarks = List.from(userDoc.data()?['moduleBookmarks'] ?? []);
      }

      if (bookmarks.contains(moduleId)) {
        bookmarks.remove(moduleId);
      } else {
        bookmarks.add(moduleId);
      }

      await userRef.set({
        'moduleBookmarks': bookmarks,
      }, SetOptions(merge: true));
    } catch (e) {
      appLogger.e('Error toggling bookmark', error: e);
      rethrow;
    }
  }

  // Check if module is bookmarked
  Future<bool> isModuleBookmarked(String moduleId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final progress = await getUserModuleProgress();
      final bookmarks = progress['moduleBookmarks'] as List? ?? [];
      return bookmarks.contains(moduleId);
    } catch (e) {
      return false;
    }
  }
}
