// List of all modules - import and export them here
import 'package:aid_iq/modules/first_aid_intro_module.dart';
import 'package:aid_iq/modules/cpr_module.dart';
import 'package:aid_iq/modules/wound_cleaning_module.dart';
import 'package:aid_iq/modules/rice_module.dart';
import 'package:aid_iq/modules/strains_module.dart';
import 'package:aid_iq/modules/animal_bites_module.dart';
import 'package:aid_iq/modules/choking_module.dart';
import 'package:aid_iq/modules/fainting_module.dart';

// List of all available modules
final List<Map<String, dynamic>> allModules = [
  firstAidIntroModule,
  cprModule,
  woundCleaningModule,
  riceModule,
  strainsModule,
  animalBitesModule,
  chokingModule,
  faintingModule,
];
