import 'package:aid_iq/models/question_model.dart';

final List<Question> woundCleaningQuestions = [
  // Concept-Based Questions
  Question(
    questionText: "What is the first step when treating an open wound?",
    options: [
      "Apply antibiotic ointment",
      "Washing of hands",
      "Cover the wound with a bandage",
      "Remove all debris with tweezers",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: "What is the best way to clean an open wound to reduce the risk of infection?",
    options: [
      "Pour alcohol directly on the wound",
      "Rinse the wound with water, keeping it under running tap water",
      "Wipe the wound with a dry cloth",
      "Apply soap directly into the wound",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: "Why should you apply a thin layer of antibiotic ointment or petroleum jelly to a wound?",
    options: [
      "To make the wound heal faster",
      "To keep the surface moist and prevent scarring",
      "To stop the bleeding immediately",
      "To remove dirt and debris",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: "How often should you change the dressing on a wound?",
    options: [
      "Once a week",
      "Only when it falls off",
      "At least once a day or when the bandage becomes wet or dirty",
      "Every hour",
    ],
    correctOptionIndex: 2,
  ),
  Question(
    questionText: "What are the primary interventions for a closed wound?",
    options: [
      "Washing with soap and applying antibiotic ointment",
      "Using ice packs, compression, elevation, and immobilization",
      "Covering with a bandage and changing dressing daily",
      "Rinsing under running water and removing debris",
    ],
    correctOptionIndex: 1,
  ),
  // Scenario-Based Questions
  Question(
    questionText: "You accidentally cut your finger while cooking. The cut is bleeding but not heavily. What should be your first action?",
    options: [
      "Immediately apply antibiotic ointment",
      "Wash your hands, then apply gentle pressure with a clean bandage to stop the bleeding",
      "Run to the emergency room",
      "Wrap the finger tightly with any available cloth",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: "After stopping the bleeding from a scrape on your knee, you notice some dirt and small debris in the wound. What is the proper way to clean it?",
    options: [
      "Leave the dirt alone and just cover it with a bandage",
      "Rinse the wound with water, wash around it with soap (not in the wound), and use alcohol-cleaned tweezers to remove debris",
      "Pour hydrogen peroxide directly into the wound",
      "Scrub the wound vigorously with soap",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: "You applied antibiotic ointment to a wound, and the next day you notice a mild rash appearing around the area. What should you do?",
    options: [
      "Apply more ointment to treat the rash",
      "Stop using the ointment since certain ingredients can cause mild rash",
      "Cover the rash with an additional bandage",
      "Ignore it and continue using the ointment",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: "Your friend fell off a bicycle and has a deep bruise on their thigh with no open wound. What is the appropriate first aid intervention?",
    options: [
      "Wash the area with soap and water and apply antibiotic ointment",
      "Use ice packs, compression, elevation, and immobilization",
      "Cover the bruise with a bandage and change it daily",
      "Remove any debris with tweezers",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: "You treated a minor cut on your hand three days ago. Today, you notice the area around the wound is red, warm to touch, swollen, and more painful than before. What should you do?",
    options: [
      "Change the bandage and continue monitoring at home",
      "Apply more antibiotic ointment and wait another week",
      "See a doctor immediately as these are signs of infection",
      "Remove the bandage and leave the wound uncovered",
    ],
    correctOptionIndex: 2,
  ),
];
