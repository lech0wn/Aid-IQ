import 'package:aid_iq/models/question_model.dart';

final List<Question> faintingQuestions = [
  // Concept-Based Questions
  Question(
    questionText: "What is the first priority when someone faints?",
    options: [
      "Position them on their back immediately",
      "Check if the person is breathing",
      "Loosen their clothing",
      "Elevate their legs",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "What should you do if a person who has fainted is NOT breathing?",
    options: [
      "Wait for them to start breathing on their own",
      "Splash water on their face",
      "Begin CPR immediately and call the local emergency number",
      "Position them on their side",
    ],
    correctOptionIndex: 2,
  ),
  Question(
    questionText:
        "How high should you raise a fainting person's legs above heart level?",
    options: [
      "About 6 inches",
      "About 12 inches",
      "About 24 inches",
      "Elevation is not necessary",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "What is the most effective way to stop bleeding from a fall-related injury after fainting?",
    options: [
      "Apply ice directly to the wound",
      "Control the bleeding with direct pressure",
      "Elevate the wound only",
      "Apply a tourniquet immediately",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "Why should you loosen belts, collars, and other constrictive clothing after someone faints?",
    options: [
      "To make them more comfortable only",
      "To check for injuries underneath",
      "To improve breathing and circulation",
      "It is not necessary to loosen clothing",
    ],
    correctOptionIndex: 2,
  ),
  // Scenario-Based Questions
  Question(
    questionText:
        "You witness someone collapse at a shopping mall. You rush over and find them unresponsive. What should you do first?",
    options: [
      "Elevate their legs immediately",
      "Check if the person is breathing by looking for chest rise, listening for breath sounds, and feeling for air",
      "Loosen their clothing",
      "Call for help and wait",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "A person has fainted and is breathing normally, but you notice they hit their head on the ground and have a small cut that is bleeding. What should you do?",
    options: [
      "Ignore the cut and focus only on positioning",
      "Treat the cut appropriately and control the bleeding with direct pressure",
      "Pour water on the cut to clean it",
      "Wait for the person to wake up before treating the cut",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "You have confirmed that a fainting person is breathing and has no serious injuries. How should you position them?",
    options: [
      "Keep them sitting upright",
      "Position them on their side",
      "Position them on their back with legs raised about 12 inches above heart level",
      "Leave them in the position they fell",
    ],
    correctOptionIndex: 2,
  ),
  Question(
    questionText:
        "A person has fainted and recovered. They are now alert and want to stand up immediately. What should you do?",
    options: [
      "Let them stand up quickly since they feel fine",
      "Do not let them get up too quickly; help them sit up slowly first, wait, then stand gradually",
      "Have them run in place to test if they're okay",
      "Give them coffee to boost their energy",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "You are helping someone who fainted. After positioning them on their back with legs elevated, they start to regain consciousness but suddenly feel dizzy again. What should you do?",
    options: [
      "Help them stand up immediately to walk it off",
      "Have the person lie back down immediately and elevate the legs again",
      "Give them water to drink right away",
      "Ignore the dizziness; it's normal",
    ],
    correctOptionIndex: 1,
  ),
];
