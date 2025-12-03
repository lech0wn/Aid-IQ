import 'package:aid_iq/models/question_model.dart';

final List<Question> firstAidIntroductionQuestions = [
  // Concept-Based Questions
  Question(
    questionText:
        "What are the three main aims of first aid (the \"Three P's\")?",
    options: [
      "Protect, Provide, Preserve",
      "Prevent, Promote, Perform",
      "Preserve, Prevent, Promote",
      "Prioritize, Protect, Provide",
    ],
    correctOptionIndex: 2,
  ),
  Question(
    questionText:
        "Why is knowledge of first aid important for individuals, even when professional medical help is available?",
    options: [
      "It allows individuals to replace professional medical assistance.",
      "It helps ensure the right methods of administering medical assistance are provided until professionals arrive.",
      "It guarantees a full recovery for the casualty.",
      "It is only useful in situations where no professional help is available.",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "Which of the following is NOT a hindrance to giving effective first aid?",
    options: [
      "Crowded city streets",
      "The presence of a calm and cooperative victim",
      "Lack of necessary materials",
      "Pressure from victims or relatives",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "Which of the following is a primary role and responsibility of a first aider?",
    options: [
      "Diagnosing the patient's long-term medical condition.",
      "Ensuring personal safety and that of the patient/bystander.",
      "Replacing the need for a physician.",
      "Administering advanced medical procedures.",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "Which characteristic of a good first aider involves making the best use of available resources?",
    options: ["Gentle", "Observant", "Resourceful", "Tactful"],
    correctOptionIndex: 2,
  ),
  // Scenario-Based Questions
  Question(
    questionText:
        "You come across a person lying on the sidewalk after a bicycle accident. A crowd starts to gather around, shouting different instructions. As a first aider, what should you do first?",
    options: [
      "Immediately start performing CPR, regardless of the victim's condition.",
      "Shout at the crowd to disperse and leave the area.",
      "Assess the safety of the scene for yourself, the victim, and bystanders, and then gain access to the victim.",
      "Ask the crowd for their opinions on what to do next.",
    ],
    correctOptionIndex: 2,
  ),
  Question(
    questionText:
        "You are in a shopping mall when someone collapses and is unresponsive. The area is noisy and crowded. What is your immediate priority to preserve life?",
    options: [
      "Attempt to move the person to a quieter area by yourself.",
      "Check for responsiveness and breathing, and if necessary, perform emergency procedures like opening an airway.",
      "Ask bystanders if anyone knows the person who collapsed.",
      "Wait for security personnel to arrive before doing anything.",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "It is nighttime and raining heavily. You witness a car accident on a busy highway, and one victim appears to have a broken leg. What is the most appropriate action to prevent further deterioration of the victim's condition?",
    options: [
      "Attempt to move the victim to your car to get them out of the rain.",
      "Immobilize the injured leg to prevent further movement and injury, ensuring the safety of the area if possible.",
      "Leave the victim and call for help from a safe distance.",
      "Try to set the broken bone yourself.",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "A child in your home accidentally touches a hot pan and gets a burn on the hand. What first aid measure should you take to promote recovery?",
    options: [
      "Apply ice directly to the burn.",
      "Cover the burn with a thick blanket.",
      "Properly cool the burn with cool running water to reduce the risk of scarring and encourage early healing.",
      "Apply butter or oil to the burn.",
    ],
    correctOptionIndex: 2,
  ),
  Question(
    questionText:
        "You are giving first aid to a drunk, injured person whose relatives are crying and insisting that you move him quickly to a vehicle. As a good first aider, how should you respond?",
    options: [
      "Comply with the relatives' demands to avoid further distress.",
      "Explain calmly that a thorough examination is necessary before moving the victim, and prioritize the victim's well-being over the relatives' pressure.",
      "Ignore the relatives and continue with your assessment without explanation.",
      "Tell the relatives that you are not a doctor and cannot help.",
    ],
    correctOptionIndex: 1,
  ),
];
