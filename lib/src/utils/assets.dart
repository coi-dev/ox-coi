import 'package:flutter/services.dart';

Future<bool> assetExists(String path) async {
  try {
    await rootBundle.load(path);
    return true;
  } catch (_) {
    return false;
  }
}
