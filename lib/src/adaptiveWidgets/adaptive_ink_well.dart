import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'adaptive_widget.dart';

class AdaptiveInkWell extends AdaptiveWidget<GestureDetector, InkWell> {
  final Function onTap;
  final Widget child;

  AdaptiveInkWell({
    Key key,
    this.onTap,
    this.child,
  }) : super(childKey: key);

  @override
  InkWell buildMaterialWidget(BuildContext context) {
    return InkWell(
      key: childKey,
      onTap: onTap,
      child: child,
    );
  }

  @override
  GestureDetector buildCupertinoWidget(BuildContext context) {
    return GestureDetector(
      key: childKey,
      onTap: onTap,
      child: child,
    );
  }
}
