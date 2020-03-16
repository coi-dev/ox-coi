import 'package:flutter/cupertino.dart';

void resetGlobalFocus(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

void safeControllerClear(TextEditingController controller) {
  // Workaround for https://github.com/flutter/flutter/issues/17647
  WidgetsBinding.instance.addPostFrameCallback((_) => controller.clear());
}