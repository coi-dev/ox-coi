import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'adaptive_widget.dart';

class AdaptiveDialogAction extends AdaptiveWidget<CupertinoDialogAction, FlatButton> {
  final Widget child;
  final Function onPressed;

  AdaptiveDialogAction({
    Key key,
    this.child,
    this.onPressed,
  }) : super(key: key);

  @override
  FlatButton buildMaterialWidget(BuildContext context) {
    return FlatButton(
      key: key,
      child: child,
      onPressed: onPressed,
    );
  }

  @override
  CupertinoDialogAction buildCupertinoWidget(BuildContext context) {
    // TODO : Parameter 'key' is missing: https://github.com/flutter/flutter/issues/42729
    return CupertinoDialogAction(
      child: child,
      onPressed: onPressed,
    );
  }
}
