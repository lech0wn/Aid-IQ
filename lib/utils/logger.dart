import 'package:logger/logger.dart';

/// Global logger instance for the app
/// Use this instead of print() statements
final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 50,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);

/// Simple logger for production (less verbose)
final productionLogger = Logger(
  printer: SimplePrinter(colors: false, printTime: false),
);
