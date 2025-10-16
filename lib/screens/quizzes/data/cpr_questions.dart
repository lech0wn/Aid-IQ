import 'package:aid_iq/models/question_model.dart';

final List<Question> cprQuestions = [
  Question(
    questionText: "What is the first step in performing CPR on an adult?",
    options: [
      "Give two rescue breaths",
      "Check for responsiveness and call for help",
      "Start chest compressions",
      "Look for a medical alert bracelet",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: "What is the correct compression rate for CPR?",
    options: [
      "60-80 compressions per minute",
      "80-100 compressions per minute",
      "100-120 compressions per minute",
      "120-140 compressions per minute",
    ],
    correctOptionIndex: 2,
  ),
  Question(
    questionText:
        "What is the correct depth of chest compressions for an adult?",
    options: [
      "At least 1 inch",
      "At least 2 inches",
      "At least 3 inches",
      "At least 4 inches",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: "What is the ratio of compressions to breaths in CPR?",
    options: [
      "15 compressions to 2 breaths",
      "30 compressions to 2 breaths",
      "50 compressions to 1 breath",
      "100 compressions to 5 breaths",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: "When should you stop CPR?",
    options: [
      "When you get tired",
      "When the person starts breathing",
      "When professional help arrives and takes over",
      "Both b and c",
    ],
    correctOptionIndex: 3,
  ),
  Question(
    questionText:
        "Where should you place your hands when giving chest compressions to an adult?",
    options: [
      "On the upper abdomen",
      "On the lower sternum",
      "On the upper sternum",
      "In the center of the chest, between the nipples",
    ],
    correctOptionIndex: 3,
  ),
  Question(
    questionText: "What should you do if the person vomits during CPR?",
    options: [
      "Stop CPR immediately",
      "Turn the person onto their side to prevent choking",
      "Continue CPR as if nothing happened",
      "Give them water to rinse their mouth",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "What should you do if you are unable to give rescue breaths?",
    options: [
      "Stop CPR",
      "Continue chest compressions only",
      "Try harder to give breaths",
      "Call for help",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: "What is the purpose of CPR?",
    options: [
      "To restart the heart",
      "To provide oxygen to the brain and other vital organs",
      "To diagnose the medical condition",
      "To administer medication",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: "What should you do if you are unsure about performing CPR?",
    options: [
      "Do nothing",
      "Attempt it anyway",
      "Call emergency services and follow their instructions",
      "Ask a bystander for help",
    ],
    correctOptionIndex: 2,
  ),
];
