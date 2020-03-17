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
  }) : super(childKey: key);

  @override
  FlatButton buildMaterialWidget(BuildContext context) {
    return FlatButton(
      key: childKey,
      child: child,
      onPressed: onPressed,
    );
  }

  @override
  CupertinoDialogAction buildCupertinoWidget(BuildContext context) {
    return CupertinoDialogAction(
      key: childKey,
      child: child,
      onPressed: onPressed,
    );
  }
}
