import 'package:aid_iq/models/question_model.dart';

final List<Question> chokingQuestions = [
  // Concept-Based Questions
  Question(
    questionText:
        "What is the difference between partial and complete airway obstruction?",
    options: [
      "Partial obstruction is more dangerous than complete obstruction",
      "In partial obstruction, the person can speak, cry, cough, or breathe; in complete obstruction, they cannot",
      "Partial obstruction requires immediate abdominal thrusts; complete obstruction does not",
      "There is no difference between the two",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "What should you do first if someone is experiencing partial airway obstruction?",
    options: [
      "Immediately perform abdominal thrusts",
      "Call emergency services and wait",
      "Encourage them to keep coughing to clear the blockage",
      "Put your fingers in their mouth to remove the object",
    ],
    correctOptionIndex: 2,
  ),
  Question(
    questionText:
        "How many back blows should you give before checking the mouth and switching to abdominal thrusts?",
    options: [
      "3 back blows",
      "5 back blows",
      "10 back blows",
      "Continue back blows until the object is dislodged",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "Where should you position your fist when performing abdominal thrusts (Heimlich maneuver)?",
    options: [
      "On the chest, over the heart",
      "Slightly above the navel, below the ribcage",
      "On the back, between the shoulder blades",
      "On the throat, near the obstruction",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: "What should you do if a choking person becomes unconscious?",
    options: [
      "Continue giving back blows and abdominal thrusts",
      "Lower them to the ground, call emergency services, and begin CPR if trained",
      "Wait for them to wake up on their own",
      "Give them water to help clear the obstruction",
    ],
    correctOptionIndex: 1,
  ),
  // Scenario-Based Questions
  Question(
    questionText:
        "You are at a restaurant and notice someone clutching their throat. They are coughing weakly and can barely speak. What should you do?",
    options: [
      "Tell them to drink water immediately",
      "Encourage them to keep coughing, but be ready to perform back blows if coughing becomes ineffective",
      "Immediately perform abdominal thrusts",
      "Call emergency services and do nothing else",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "A child is choking on a piece of candy and cannot speak, cough, or breathe. You have positioned yourself behind them and supported their chest. What should you do next?",
    options: [
      "Give 5 abdominal thrusts immediately",
      "Lean them forward and give up to 5 back blows between the shoulder blades using the heel of your hand",
      "Put your fingers in their mouth to remove the candy",
      "Wait for emergency services to arrive",
    ],
    correctOptionIndex: 1,
  ),
  Question(
    questionText:
        "You have given 5 back blows to a choking adult, but they are still unable to breathe or speak. What should you do next?",
    options: [
      "Give 5 more back blows",
      "Call emergency services and wait",
      "Give up to 5 abdominal thrusts (Heimlich maneuver)",
      "Lay them down and begin CPR",
    ],
    correctOptionIndex: 2,
  ),
  Question(
    questionText:
        "After performing back blows and abdominal thrusts, the obstruction is cleared and the person can breathe normally. What should you do?",
    options: [
      "Nothing further is needed; they are fine now",
      "Give them water and food immediately",
      "Encourage them to seek medical attention, as abdominal thrusts can cause internal injuries",
      "Perform one more cycle of back blows to be safe",
    ],
    correctOptionIndex: 2,
  ),
  Question(
    questionText:
        "You are helping a choking victim and have alternated between back blows and abdominal thrusts several times, but the obstruction is not clearing. The person suddenly becomes unconscious. What should you do?",
    options: [
      "Continue giving back blows and abdominal thrusts",
      "Lower them to the ground carefully, call emergency services immediately, and begin CPR if trained",
      "Shake them vigorously to wake them up",
      "Wait for them to regain consciousness before doing anything",
    ],
    correctOptionIndex: 1,
  ),
];
