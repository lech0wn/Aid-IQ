// DEPRECATED: This script is no longer used. Modules are now stored in local files.
// Keeping this file commented out for reference only.

/*
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

> First aid is not a substitute for professional medical care. Always seek professional medical attention for serious injuries or illnesses. The goal of first aid is to provide immediate care until professional help arrives.


## Practice Makes Perfect

> The more you know about first aid, the more confident you'll be in an emergency. Consider taking a certified first aid course to learn hands-on techniques and stay updated with the latest guidelines.
''',
        'pictures': ['assets/images/first_aid_module.jpg'],
      },
      {
        'title': 'CPR',
        'description': 'Learn Cardiopulmonary Resuscitation techniques',
        'order': 2,
        'content': '''
# CPR (Cardiopulmonary Resuscitation)


## What is CPR?

CPR (Cardiopulmonary Resuscitation) is a life-saving technique used when someone's breathing or heartbeat has stopped. It combines chest compressions and rescue breaths to maintain blood circulation and provide oxygen to the brain and vital organs until professional medical help arrives.


## When to Perform CPR

Perform CPR immediately if:
- The person is unresponsive and not breathing
- The person has no pulse
- The person is unconscious and not breathing normally
- You witness a cardiac arrest


## The CPR Steps (CAB Sequence)

### C - Compressions
1. Place the person on a firm, flat surface
2. Position yourself at the person's side
3. Place the heel of one hand on the center of the chest (between the nipples)
4. Place your other hand on top and interlock fingers
5. Keep your arms straight and shoulders directly above your hands
6. Push hard and fast: at least 2 inches deep at a rate of 100-120 compressions per minute
7. Allow the chest to fully recoil between compressions

### A - Airway
1. After 30 compressions, open the airway
2. Tilt the head back and lift the chin (head-tilt, chin-lift maneuver)
3. Check for any visible obstructions in the mouth

### B - Breathing
1. Pinch the nose closed
2. Give 2 rescue breaths, each lasting about 1 second
3. Watch for chest rise with each breath
4. If chest doesn't rise, reposition the head and try again


## CPR Ratio and Rate

### For Adults and Children (1 year and older)
- **Ratio**: 30 compressions to 2 breaths
- **Compression Rate**: 100-120 compressions per minute
- **Compression Depth**: At least 2 inches (5 cm) for adults, about 2 inches for children
- **Continue cycles** until help arrives or the person shows signs of life

### For Infants (under 1 year)
- **Ratio**: 30 compressions to 2 breaths
- **Compression Rate**: 100-120 compressions per minute
- **Compression Depth**: About 1.5 inches (4 cm)
- Use 2 fingers in the center of the chest, just below the nipple line


## Hands-Only CPR

If you're untrained or uncomfortable giving rescue breaths:
- Perform **chest compressions only**
- Continue at 100-120 compressions per minute
- Don't stop until help arrives or an AED is available
- Hands-only CPR is better than doing nothing


## Important CPR Guidelines

### Hand Placement
- **Adults/Children**: Center of chest, between the nipples
- **Infants**: Just below the nipple line, use 2 fingers
- Keep hands/fingers in the correct position throughout

### Compression Technique
- Push hard and fast
- Allow full chest recoil between compressions
- Minimize interruptions (less than 10 seconds)
- Switch rescuers every 2 minutes if possible to avoid fatigue

### Rescue Breaths
- Each breath should last about 1 second
- Watch for chest rise
- If you can't give breaths, continue compressions only
- Use a barrier device if available (face shield or mask)


## When to Stop CPR

Stop CPR only when:
- The person shows signs of life (breathing, movement, pulse)
- Professional medical help arrives and takes over
- An AED is ready to use (pause briefly to attach it)
- You are too exhausted to continue (try to find someone to take over)
- The scene becomes unsafe


## Special Situations

### If the Person Vomits
- Turn the person onto their side
- Clear the mouth of vomit
- Return to back and continue CPR

### If You're Unsure
- Call emergency services (911) immediately
- Follow the dispatcher's instructions
- They can guide you through CPR over the phone

### If You're Alone
- Call 911 first (put on speakerphone)
- Begin CPR immediately
- Continue until help arrives


## Using an AED (Automated External Defibrillator)

1. Turn on the AED and follow voice prompts
2. Attach pads to bare chest (one upper right, one lower left)
3. Ensure no one is touching the person
4. Let the AED analyze the heart rhythm
5. If shock is advised, ensure everyone is clear and press the shock button
6. Immediately resume CPR after the shock
7. Continue following AED prompts


## CPR for Different Age Groups

### Adults (Puberty and older)
- Use both hands for compressions
- Depth: At least 2 inches
- Rate: 100-120 per minute

### Children (1 year to puberty)
- Use one or two hands depending on child's size
- Depth: About 2 inches
- Rate: 100-120 per minute

### Infants (Under 1 year)
- Use 2 fingers for compressions
- Depth: About 1.5 inches
- Rate: 100-120 per minute
- Cover both mouth and nose when giving rescue breaths


## Common Mistakes to Avoid

- **Don't** stop compressions for too long
- **Don't** compress too shallow or too deep
- **Don't** give breaths too forcefully (can cause stomach inflation)
- **Don't** forget to call 911 first
- **Don't** move the person unless absolutely necessary
- **Don't** give up too early


## Remember

> CPR is a critical life-saving skill that can double or triple a person's chance of survival after cardiac arrest. Even if you're not certified, performing hands-only CPR is better than doing nothing. The most important thing is to act quickly and call for professional help immediately.


## Practice Makes Perfect

> Proper CPR technique requires practice. Consider taking a certified CPR course from organizations like the American Heart Association or Red Cross. Regular training and recertification help ensure you're using the most current techniques and can perform CPR effectively in an emergency situation.
''',
        'pictures': ['assets/images/cpr_module.jpg'],
      },
    ];

    appLogger.i('Starting to upload ${modules.length} modules to Firestore...');
    appLogger.i(
      'Modules to upload: ${modules.map((m) => m['title']).join(', ')}',
    );

    for (final module in modules) {
      try {
        appLogger.d('Processing module: ${module['title']}');

        // Check if module already exists
        final existingModules = await moduleService.getAllModules();
        final existingModule = existingModules.firstWhere(
          (m) => m['title'] == module['title'],
          orElse: () => <String, dynamic>{},
        );

        if (existingModule.isNotEmpty) {
          // Update existing module
          appLogger.i(
            'Module "${module['title']}" already exists (ID: ${existingModule['id']}), updating...',
          );
          await moduleService.updateModule(
            moduleId: existingModule['id'] as String,
            title: module['title'] as String,
            content: module['content'] as String,
            pictures: module['pictures'] as List<String>,
            order: module['order'] as int?,
            description: module['description'] as String?,
          );
          appLogger.i('✓ Successfully updated: ${module['title']}');
        } else {
          // Upload new module
          appLogger.i('Module "${module['title']}" is new, uploading...');
          await moduleService.uploadModule(
            title: module['title'] as String,
            content: module['content'] as String,
            pictures: module['pictures'] as List<String>,
            order: module['order'] as int?,
            description: module['description'] as String?,
          );
          appLogger.i('✓ Successfully uploaded: ${module['title']}');
        }
      } catch (e, stackTrace) {
        appLogger.e(
          '✗ Error uploading/updating ${module['title']}',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }

    appLogger.i(
      'Finished uploading modules! Total processed: ${modules.length}',
    );
  }
}
*/
