import 'package:aid_iq/models/question_model.dart';

final List<Question> riceQuestions = [
  // Concept-Based Questions
  Question(
    questionText:
        "What does the acronym R.I.C.E. stand for in treating sprains and strains?",
    options: [
      "Run, Ice, Compress, Examine",
      "Rest, Ice, Compression, Elevation",
      "Raise, Inspect, Cover, Elevate",
      "Relax, Immobilize, Cool, Exercise",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: "What is the key difference between a sprain and a strain?",
    options: [
      "A sprain affects bones; a strain affects muscles",
      "A sprain affects ligaments; a strain affects muscles or tendons",
      "A sprain is more serious than a strain",
      "A sprain requires surgery; a strain does not",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "How long should ice be applied to a sprain or strain at one time?",
    options: [
      "5-10 minutes",
      "15-20 minutes",
      "30-45 minutes",
      "1 hour continuously",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "What is the purpose of elevating an injured limb above heart level?",
    options: [
      "To increase blood flow to the injury",
      "To make the injury more visible",
      "To help reduce swelling by allowing fluid to drain",
      "To prevent the limb from moving",
    ],
    correctOptionIndex: 2,
  ),
  Question(
    questionText:
        "Which intervention can help sprains and strains heal thoroughly and restore full function?",
    options: [
      "Complete bed rest for several weeks",
      "Physical therapy",
      "Applying heat immediately after injury",
      "Avoiding all movement permanently",
    ],
    correctOptionIndex: 1,
  ),
  // Scenario-Based Questions
  Question(
    questionText:
        "You twist your ankle while playing basketball. It immediately starts to swell and hurt. What should be your first action using the R.I.C.E. method?",
    options: [
      "Continue playing to \"walk it off\"",
      "Rest the ankle and stop playing immediately",
      "Apply heat to the ankle",
      "Start doing stretching exercises",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "After applying ice to a sprained wrist for 20 minutes, what is the next step in the R.I.C.E. method?",
    options: [
      "Apply heat immediately",
      "Start running to test the wrist",
      "Apply compression using an elastic bandage",
      "Massage the wrist vigorously",
    ],
    correctOptionIndex: 2,
  ),
  Question(
    questionText:
        "You have wrapped a sprained ankle with an elastic bandage for compression. You notice the toes are turning blue and feel numb. What should you do?",
    options: [
      "Leave it as is; this is normal",
      "Wrap it even tighter",
      "Remove or loosen the bandage immediately as it's too tight",
      "Apply more ice",
    ],
    correctOptionIndex: 2,
  ),
  Question(
    questionText:
        "Your friend strained their back while lifting a heavy box two weeks ago. They have been using the R.I.C.E. method, but still have limited mobility and some pain. What should they do next?",
    options: [
      "Continue resting indefinitely and avoid all movement",
      "Seek physical therapy to help heal the strain thoroughly",
      "Start running immediately to test the back",
      "Apply heat constantly throughout the day",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "You sprained your knee and have applied ice, compression, and are resting. How should you position your leg for proper elevation?",
    options: [
      "Below heart level",
      "At the same level as the heart",
      "Above heart level on pillows, approximately 12 inches",
      "Elevation is not necessary for knee injuries",
    ],
    correctOptionIndex: 2,
  ),
];
