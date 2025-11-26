// This is a one-time script to upload all modules to Firestore

import 'package:aid_iq/services/module_service.dart';
import 'package:aid_iq/utils/logger.dart';

class UploadModulesToFirestore {
  static Future<void> uploadAllModules() async {
    final moduleService = ModuleService();

    final modules = [
      {
        'title': 'First Aid Introduction',
        'description': 'Learn the fundamentals of first aid',
        'order': 1,
        'content': '''
# First Aid Introduction

## What is First Aid?

First aid is the immediate care given to a person who has been injured or suddenly taken ill. It includes self-help and home care if medical assistance is not available or delayed.

## The Goals of First Aid

1. **Preserve Life**: The primary goal is to save lives
2. **Prevent Further Harm**: Prevent the condition from worsening
3. **Promote Recovery**: Help the person recover as quickly as possible

## The Three C's of First Aid

### Check
- Check the scene for safety
- Check the person for consciousness
- Check for breathing and pulse

### Call
- Call for emergency medical services (911 or local emergency number)
- Provide clear information about the situation

### Care
- Provide care until professional help arrives
- Follow basic first aid principles

## Basic First Aid Principles

### 1. Stay Calm
- Panic can make the situation worse
- Take deep breaths and assess the situation calmly

### 2. Ensure Safety
- Make sure the scene is safe for you and the victim
- Do not put yourself in danger

### 3. Assess the Situation
- Check if the person is conscious
- Look for signs of breathing
- Check for severe bleeding

### 4. Provide Appropriate Care
- Follow basic first aid procedures
- Use available resources and materials

### 5. Get Professional Help
- Call emergency services when needed
- Stay with the person until help arrives

## Common First Aid Situations

### Minor Cuts and Scrapes
- Clean the wound with water
- Apply pressure to stop bleeding
- Cover with a clean bandage

### Burns
- Cool the burn with running water
- Cover with a clean, dry cloth
- Do not apply ice or butter

### Choking
- Encourage coughing if possible
- Perform the Heimlich maneuver if needed
- Call emergency services if severe

### Unconsciousness
- Check for breathing and pulse
- Place in recovery position if breathing
- Begin CPR if not breathing

## First Aid Kit Essentials

Every home and workplace should have a basic first aid kit containing:
- Adhesive bandages (various sizes)
- Sterile gauze pads
- Medical tape
- Antiseptic wipes
- Scissors
- Tweezers
- Disposable gloves
- Pain relievers
- Emergency contact information

## When to Call Emergency Services

Call emergency services (911) immediately if:
- The person is unconscious
- There is severe bleeding
- The person is not breathing
- There are signs of a heart attack or stroke
- There is a suspected spinal injury
- The person has been poisoned
- There is a severe burn

## Remember

First aid is not a substitute for professional medical care. Always seek professional medical attention for serious injuries or illnesses. The goal of first aid is to provide immediate care until professional help arrives.

## Practice Makes Perfect

The more you know about first aid, the more confident you'll be in an emergency. Consider taking a certified first aid course to learn hands-on techniques and stay updated with the latest guidelines.
''',
        'pictures': [
          'assets/images/first_aid_intro_1.png', // Placeholder
        ],
      },
    ];

    appLogger.i('Starting to upload ${modules.length} modules to Firestore...');

    for (final module in modules) {
      try {
        // Check if module already exists
        final existingModules = await moduleService.getAllModules();
        final exists = existingModules.any(
          (m) => m['title'] == module['title'],
        );

        if (exists) {
          appLogger.d(
            'Module "${module['title']}" already exists, skipping...',
          );
          continue;
        }

        await moduleService.uploadModule(
          title: module['title'] as String,
          content: module['content'] as String,
          pictures: module['pictures'] as List<String>,
          order: module['order'] as int?,
          description: module['description'] as String?,
        );
        appLogger.i('✓ Uploaded: ${module['title']}');
      } catch (e) {
        appLogger.e('✗ Error uploading ${module['title']}', error: e);
      }
    }

    appLogger.i('Finished uploading modules!');
  }
}
