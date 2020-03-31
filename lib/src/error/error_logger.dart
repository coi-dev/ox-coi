import 'package:logging/logging.dart';

const errorLogger = "error_logger";

void logError(origin, error, stackTrace) {
  final logger = Logger(errorLogger);
  logger.warning("Exception thrown via ${origin.runtimeType}", error, stackTrace);
}