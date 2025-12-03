import 'package:aid_iq/models/question_model.dart';

final List<Question> cprQuestions = [
  // Concept-Based Questions
  Question(
    questionText: "When is CPR necessary?",
    options: [
      "When the casualty has a pulse but is not breathing",
      "When the casualty has no pulse and is not breathing",
      "When the casualty is conscious but in pain",
      "When the casualty has a weak pulse and is breathing slowly",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: "What is the correct ratio of chest compressions to rescue breaths in CPR?",
    options: [
      "15 compressions, then 2 breaths",
      "20 compressions, then 1 breath",
      "30 compressions, then 2 breaths",
      "50 compressions, then 5 breaths",
    ],
    correctOptionIndex: 2,
  ),
  Question(
    questionText: "At what rate should chest compressions be performed during CPR?",
    options: [
      "60 compressions per minute",
      "80 compressions per minute",
      "100 compressions per minute",
      "120 compressions per minute",
    ],
    correctOptionIndex: 2,
  ),
  Question(
    questionText: "What should be ensured before starting CPR?",
    options: [
      "The casualty's family has been notified",
      "Professional help has been called for",
      "A defibrillator is available",
      "At least five people are present to help",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: "How can CPR be provided by two people?",
    options: [
      "Both give compressions simultaneously",
      "Both give breaths simultaneously",
      "One gives compressions; the other gives breaths",
      "They alternate every 5 minutes regardless of the cycle",
    ],
    correctOptionIndex: 2,
  ),
  // Scenario-Based Questions
  Question(
    questionText: "You find an unconscious person in a park. After checking, you confirm they have no pulse and are not breathing. What should you do first?",
    options: [
      "Start giving rescue breaths immediately",
      "Try to wake them up by shaking them vigorously",
      "Ensure professional help has been called, then begin CPR with 30 compressions",
      "Wait for professional help to arrive before doing anything",
    ],
    correctOptionIndex: 2,
  ),
  Question(
    questionText: "You are performing CPR alone on an adult victim. After completing 30 chest compressions, what should you do next?",
    options: [
      "Check for a pulse",
      "Give 2 rescue breaths",
      "Wait 10 seconds before continuing",
      "Give 5 more compressions",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: "You are performing chest compressions during CPR and want to maintain the correct rhythm. Which song's tempo matches the recommended compression rate of 100 per minute?",
    options: [
      "\"Happy Birthday\"",
      "\"Stayin' Alive\" by Bee Gees",
      "\"Twinkle Twinkle Little Star\"",
      "\"Silent Night\"",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: "You and a colleague find a person who has collapsed and has no pulse or breathing. How should you divide the CPR tasks between the two of you?",
    options: [
      "Both perform compressions at the same time for maximum effect",
      "Take turns doing complete cycles of 30 compressions and 2 breaths",
      "One person gives compressions while the other gives breaths",
      "One person performs CPR while the other just observes",
    ],
    correctOptionIndex: 2,
  ),
  Question(
    questionText: "During CPR, you have completed several cycles of 30 compressions and 2 breaths. The victim is still unresponsive with no pulse. What should you do?",
    options: [
      "Stop CPR and wait for professional help",
      "Continue CPR cycles until professional help arrives or the victim shows signs of life",
      "Give only compressions and stop giving breaths",
      "Increase the rate to 150 compressions per minute",
    ],
    correctOptionIndex: 1,
  ),
];
