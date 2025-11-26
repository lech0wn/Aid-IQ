// This is a one-time script to upload all quizzes to Firestore
// Run this once to populate the database

import 'package:aid_iq/services/quiz_service.dart';
import 'package:aid_iq/utils/logger.dart';
import 'package:aid_iq/screens/quizzes/data/cpr_questions.dart';
import 'package:aid_iq/screens/quizzes/data/first_aid_intro_questions.dart';
import 'package:aid_iq/screens/quizzes/data/proper_bandaging_questions.dart';
import 'package:aid_iq/screens/quizzes/data/wound_cleaning_questions.dart';
import 'package:aid_iq/screens/quizzes/data/rice_questions.dart';
import 'package:aid_iq/screens/quizzes/data/strains_questions.dart';
import 'package:aid_iq/screens/quizzes/data/animal_bites_questions.dart';
import 'package:aid_iq/screens/quizzes/data/choking_questions.dart';
import 'package:aid_iq/screens/quizzes/data/fainting_questions.dart';
import 'package:aid_iq/screens/quizzes/data/seizure_questions.dart';
import 'package:aid_iq/screens/quizzes/data/first_aid_equipment_questions.dart';

class UploadQuizzesToFirestore {
  static Future<void> uploadAllQuizzes() async {
    final quizService = QuizService();

    final quizzes = [
      {
        'title': 'First Aid Introduction',
        'questions':
            firstAidIntroductionQuestions.map((q) => q.toMap()).toList(),
        'description': 'Learn the basics of first aid',
      },
      {
        'title': 'CPR',
        'questions': cprQuestions.map((q) => q.toMap()).toList(),
        'description': 'Cardiopulmonary Resuscitation techniques',
      },
      {
        'title': 'Proper Bandaging',
        'questions': properBandagingQuestions.map((q) => q.toMap()).toList(),
        'description': 'Learn how to properly bandage wounds',
      },
      {
        'title': 'Wound Cleaning',
        'questions': woundCleaningQuestions.map((q) => q.toMap()).toList(),
        'description': 'Proper wound cleaning procedures',
      },
      {
        'title': 'R.I.C.E. (Treating Sprains)',
        'questions': riceQuestions.map((q) => q.toMap()).toList(),
        'description': 'Rest, Ice, Compression, Elevation for sprains',
      },
      {
        'title': 'Strains',
        'questions': strainsQuestions.map((q) => q.toMap()).toList(),
        'description': 'Understanding and treating muscle strains',
      },
      {
        'title': 'Animal Bites',
        'questions': animalBitesQuestions.map((q) => q.toMap()).toList(),
        'description': 'First aid for animal bites',
      },
      {
        'title': 'Choking',
        'questions': chokingQuestions.map((q) => q.toMap()).toList(),
        'description': 'Heimlich maneuver and choking first aid',
      },
      {
        'title': 'Fainting',
        'questions': faintingQuestions.map((q) => q.toMap()).toList(),
        'description': 'First aid for fainting episodes',
      },
      {
        'title': 'Seizure',
        'questions': seizureQuestions.map((q) => q.toMap()).toList(),
        'description': 'First aid for seizures',
      },
      {
        'title': 'First Aid Equipments',
        'questions': firstAidEquipmentQuestions.map((q) => q.toMap()).toList(),
        'description': 'Essential first aid equipment and their uses',
      },
    ];

    appLogger.i('Starting to upload ${quizzes.length} quizzes to Firestore...');

    for (final quiz in quizzes) {
      try {
        // Check if quiz already exists
        final existingQuiz = await quizService.getQuizByTitle(
          quiz['title'] as String,
        );
        if (existingQuiz != null) {
          appLogger.d('Quiz "${quiz['title']}" already exists, skipping...');
          continue;
        }

        await quizService.uploadQuiz(
          title: quiz['title'] as String,
          questions: quiz['questions'] as List<Map<String, dynamic>>,
          description: quiz['description'] as String?,
        );
        appLogger.i('✓ Uploaded: ${quiz['title']}');
      } catch (e) {
        appLogger.e('✗ Error uploading ${quiz['title']}', error: e);
      }
    }

    appLogger.i('Finished uploading quizzes!');
  }
}
