import 'package:aid_iq/models/question_model.dart';

final List<Question> strainsQuestions = [
  // Concept-Based Questions
  Question(
    questionText: "What is a strain?",
    options: [
      "An injury to a ligament that connects bone to bone",
      "An injury to a muscle or tendon that connects muscle to bone",
      "An injury to a bone causing a fracture",
      "An injury to the skin causing a wound",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: "How long should ice be applied to a strain at one time?",
    options: [
      "5-10 minutes",
      "15-20 minutes",
      "30-45 minutes",
      "1 hour continuously",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: "What is the purpose of applying compression to a strain?",
    options: [
      "To increase blood flow to the area",
      "To reduce swelling and provide support",
      "To make the injury more painful",
      "To prevent any movement permanently",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: "Why should you elevate a strained area?",
    options: [
      "To increase swelling",
      "To make it easier to apply ice",
      "To help reduce pain and swelling by allowing fluids to drain",
      "To prevent blood from reaching the injury",
    ],
    correctOptionIndex: 2,
  ),
  Question(
    questionText: "When is physical therapy needed for a strain?",
    options: [
      "Immediately after the injury occurs",
      "When pain remains strong after several days or there is significant weakness",
      "Only if the strain affects the legs",
      "Physical therapy is never needed for strains",
    ],
    correctOptionIndex: 1,
  ),
  // Scenario-Based Questions
  Question(
    questionText:
        "You strain your hamstring while running. It hurts and you have difficulty moving your leg. What should you do first?",
    options: [
      "Continue running to \"work through the pain\"",
      "Rest the strained area and stop the activity immediately",
      "Apply heat to the hamstring",
      "Start doing intense stretching exercises",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "After resting a strained shoulder, you apply ice wrapped in a towel. How long should you keep the ice on?",
    options: [
      "5 minutes",
      "15-20 minutes",
      "45 minutes",
      "Until the area is completely numb",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "You have wrapped your strained calf with an elastic bandage. You notice your toes are tingling and turning pale. What should you do?",
    options: [
      "Leave it as is; this is normal",
      "Wrap it even tighter for better support",
      "Loosen the bandage immediately as it's too tight",
      "Apply more ice to the area",
    ],
    correctOptionIndex: 2,
  ),
  Question(
    questionText:
        "Your coworker strained their back lifting a heavy box. They've been resting, icing, compressing, and elevating for several days, but still have significant weakness and difficulty moving. What should they do?",
    options: [
      "Continue resting and avoid all movement indefinitely",
      "Seek professional help and consider physical therapy",
      "Start lifting heavy objects again to test the back",
      "Ignore the weakness; it will go away on its own",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "You strained your calf muscle during a soccer game. You've applied ice and compression. How should you position your leg for elevation?",
    options: [
      "Below heart level",
      "At the same level as your heart",
      "Above heart level using pillows or cushions",
      "Elevation is not necessary for calf strains",
    ],
    correctOptionIndex: 2,
  ),
];
