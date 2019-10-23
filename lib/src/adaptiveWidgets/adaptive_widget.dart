import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class AdaptiveWidget<C extends Widget, M extends Widget> extends StatelessWidget {
  final Key key;

  AdaptiveWidget({this.key});

  C buildCupertinoWidget(BuildContext context);

  M buildMaterialWidget(BuildContext context);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return buildCupertinoWidget(context);
    }
    return buildMaterialWidget(context);
  }
}
