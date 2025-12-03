import 'package:aid_iq/models/question_model.dart';

final List<Question> animalBitesQuestions = [
  // Concept-Based Questions
  Question(
    questionText: "What is the first step in treating a dog or cat bite?",
    options: [
      "Apply antibiotic cream immediately",
      "Cover the wound with a bandage",
      "Wash the wound thoroughly with soap and water",
      "Go to the hospital",
    ],
    correctOptionIndex: 2,
  ),
  Question(
    questionText: "Why should you NOT wash the skin after a snake bite?",
    options: [
      "Water can spread the venom faster",
      "Traces of venom left on the skin can help medical personnel identify the type of snake",
      "Washing makes the bite more painful",
      "It is not necessary to clean snake bites",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: "When is a tetanus shot needed after an animal bite?",
    options: [
      "Always, regardless of vaccination history",
      "Only for snake bites",
      "If you have not received one in the last 5 years",
      "Tetanus shots are never needed for animal bites",
    ],
    correctOptionIndex: 2,
  ),
  Question(
    questionText:
        "What should you do if prescribed antibiotics for an animal bite?",
    options: [
      "Stop taking them once you feel better",
      "Take them at the given time and complete the full course",
      "Only take them if the wound looks infected",
      "Share them with others who have similar bites",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: "What is the proper first aid for a snake bite on a limb?",
    options: [
      "Wash the area thoroughly and apply ice",
      "Cut the wound to remove venom",
      "Use a pressure immobilization bandage and splint the limb, then seek medical help immediately",
      "Apply a tourniquet above the bite",
    ],
    correctOptionIndex: 2,
  ),
  // Scenario-Based Questions
  Question(
    questionText:
        "You are bitten by a neighbor's dog on your hand. The skin is broken and bleeding slightly. What should you do first?",
    options: [
      "Apply antibiotic cream immediately",
      "Wash the bitten area thoroughly with soap and water",
      "Cover it with a bandage without cleaning",
      "Wait to see if it gets infected",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "A stray dog bites your friend, and you're concerned about rabies. The doctor recommends a series of rabies shots. Your friend wants to skip some appointments. What should you tell them?",
    options: [
      "It's okay to skip a few shots if they feel fine",
      "They must complete the full cycle of shots as instructed by the doctor",
      "One shot is enough for protection",
      "Rabies shots are optional",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "While hiking, your companion is bitten on the leg by a snake. What is the most appropriate immediate action?",
    options: [
      "Wash the bite thoroughly with soap and water",
      "Seek medical help immediately, do not wash the skin, use a pressure immobilization bandage and splint the limb",
      "Apply ice to reduce swelling",
      "Cut the wound to suck out the venom",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "A person is bitten by a snake on the torso. You need to apply bandaging. What important consideration must you keep in mind?",
    options: [
      "Wrap as tightly as possible",
      "Do not bandage torso bites at all",
      "Make sure the bandaging does not restrict their breathing",
      "Only bandage if the person is unconscious",
    ],
    correctOptionIndex: 2,
  ),
  Question(
    questionText:
        "You were bitten by a cat three days ago. The doctor prescribes antibiotics and you start feeling better after two days of taking them. What should you do?",
    options: [
      "Stop taking the antibiotics since you feel better",
      "Continue taking them at the given time until you complete the full course",
      "Save the remaining antibiotics for future use",
      "Take them only when the wound hurts",
    ],
    correctOptionIndex: 1,
  ),
];
