import 'package:aid_iq/modules/modules_list.dart';
import 'package:aid_iq/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalModuleService {
  // Progress storage keys
  static const String _moduleProgressKey = 'module_progress';
  static const String _modulesCompletedKey = 'modules_completed';
  static const String _totalReadingTimeKey = 'total_reading_time';
  static const String _moduleBookmarksKey = 'module_bookmarks';

  // Get all modules (sorted by order)
  Future<List<Map<String, dynamic>>> getAllModules() async {
    try {
      // Sort modules by order
      final sortedModules = List<Map<String, dynamic>>.from(allModules)
        ..sort((a, b) {
          final orderA = a['order'] as int? ?? 0;
          final orderB = b['order'] as int? ?? 0;
          return orderA.compareTo(orderB);
        });
      
      appLogger.d('Loaded ${sortedModules.length} modules from local files');
      return sortedModules;
    } catch (e) {
      appLogger.e('Error loading modules', error: e);
      return [];
    }
  }

  // Get a specific module by ID
  Future<Map<String, dynamic>?> getModuleById(String moduleId) async {
    try {
      final modules = await getAllModules();
      return modules.firstWhere(
        (m) => m['id'] == moduleId,
        orElse: () => <String, dynamic>{},
      );
    } catch (e) {
      appLogger.e('Error loading module by ID', error: e);
      return null;
    }
  }

  // Get user's module progress from SharedPreferences
  Future<Map<String, dynamic>> getUserModuleProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load module progress
      final progressJson = prefs.getString(_moduleProgressKey);
      Map<String, dynamic> moduleProgress = {};
      if (progressJson != null) {
        try {
          final decoded = json.decode(progressJson);
          if (decoded is Map) {
            moduleProgress = Map<String, dynamic>.from(decoded);
          }
        } catch (e) {
          appLogger.w('Error parsing module progress JSON', error: e);
        }
      }

      // Load bookmarks
      final bookmarksJson = prefs.getString(_moduleBookmarksKey);
      List<dynamic> moduleBookmarks = [];
      if (bookmarksJson != null) {
        try {
          final decoded = json.decode(bookmarksJson);
          if (decoded is List) {
            moduleBookmarks = List.from(decoded);
          }
        } catch (e) {
          appLogger.w('Error parsing bookmarks JSON', error: e);
        }
      }

      return {
        'modulesCompleted': prefs.getInt(_modulesCompletedKey) ?? 0,
        'moduleProgress': moduleProgress,
        'moduleBookmarks': moduleBookmarks,
        'totalReadingTime': prefs.getInt(_totalReadingTimeKey) ?? 0, // in minutes
      };
    } catch (e) {
      appLogger.e('Error loading user module progress', error: e);
      return {
        'modulesCompleted': 0,
        'moduleProgress': <String, dynamic>{},
        'moduleBookmarks': <String>[],
        'totalReadingTime': 0,
      };
    }
  }

  // Mark module as completed
  Future<void> markModuleCompleted(
    String moduleId,
    String moduleTitle,
    int readingTimeMinutes,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load current progress
      final progress = await getUserModuleProgress();
      final moduleProgress = Map<String, dynamic>.from(progress['moduleProgress'] as Map);
      int modulesCompleted = progress['modulesCompleted'] as int;
      int totalReadingTime = progress['totalReadingTime'] as int;

      // Check if this is a new completion
      bool isNewCompletion = true;
      if (moduleProgress.containsKey(moduleId)) {
        final existingProgress = moduleProgress[moduleId] as Map<String, dynamic>?;
        if (existingProgress != null && existingProgress['completed'] == true) {
          isNewCompletion = false;
        }
      }

      // Update module progress
      moduleProgress[moduleId] = {
        'completed': true,
        'completedAt': DateTime.now().toIso8601String(),
        'readingTime': readingTimeMinutes,
        'title': moduleTitle,
        'lastAccessed': DateTime.now().toIso8601String(),
      };

      if (isNewCompletion) {
        modulesCompleted++;
        totalReadingTime += readingTimeMinutes;
      } else {
        // Update reading time if user read it again
        final existingTime = (moduleProgress[moduleId] as Map)['readingTime'] as int? ?? 0;
        totalReadingTime = totalReadingTime - existingTime + readingTimeMinutes;
      }

      // Save to SharedPreferences
      await prefs.setString(_moduleProgressKey, json.encode(moduleProgress));
      await prefs.setInt(_modulesCompletedKey, modulesCompleted);
      await prefs.setInt(_totalReadingTimeKey, totalReadingTime);
      
      appLogger.d('Module $moduleId marked as completed');
    } catch (e) {
      appLogger.e('Error marking module as completed', error: e);
      rethrow;
    }
  }

  // Update module reading progress (for tracking scroll position)
  Future<void> updateModuleReadingProgress(
    String moduleId,
    double scrollPosition,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load current progress
      final progress = await getUserModuleProgress();
      final moduleProgress = Map<String, dynamic>.from(progress['moduleProgress'] as Map);

      // Get or create the module's progress entry
      Map<String, dynamic> moduleEntry = {};
      if (moduleProgress.containsKey(moduleId)) {
        final entryData = moduleProgress[moduleId];
        if (entryData != null && entryData is Map) {
          moduleEntry = Map<String, dynamic>.from(entryData);
        }
      }

      // Update the module entry
      moduleEntry['scrollPosition'] = scrollPosition;
      moduleEntry['lastAccessed'] = DateTime.now().toIso8601String();

      // Update the moduleProgress map
      moduleProgress[moduleId] = moduleEntry;

      // Save to SharedPreferences
      await prefs.setString(_moduleProgressKey, json.encode(moduleProgress));
    } catch (e) {
      appLogger.e('Error updating reading progress', error: e);
    }
  }

  // Toggle bookmark
  Future<void> toggleBookmark(String moduleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load current bookmarks
      final progress = await getUserModuleProgress();
      List<dynamic> bookmarks = List.from(progress['moduleBookmarks'] as List);

      if (bookmarks.contains(moduleId)) {
        bookmarks.remove(moduleId);
      } else {
        bookmarks.add(moduleId);
      }

      // Save to SharedPreferences
      await prefs.setString(_moduleBookmarksKey, json.encode(bookmarks));
    } catch (e) {
      appLogger.e('Error toggling bookmark', error: e);
      rethrow;
    }
  }

  // Check if module is bookmarked
  Future<bool> isModuleBookmarked(String moduleId) async {
    try {
      final progress = await getUserModuleProgress();
      final bookmarks = progress['moduleBookmarks'] as List? ?? [];
      return bookmarks.contains(moduleId);
    } catch (e) {
      return false;
    }
  }
}

