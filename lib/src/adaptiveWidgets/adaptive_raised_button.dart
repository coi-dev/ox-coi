import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_coi/src/ui/dimensions.dart';

import 'adaptive_widget.dart';

class AdaptiveRaisedButton extends AdaptiveWidget<CupertinoButton, ButtonTheme> {
  final Function onPressed;
  final double buttonWidth;
  final Color color;
  final Color textColor;
  final RoundedRectangleBorder shape;
  final Widget child;

  AdaptiveRaisedButton({
    Key key,
    @required this.onPressed,
    this.buttonWidth,
    this.color,
    this.textColor,
    this.shape,
    this.child,
  }) : super(childKey: key);

  @override
  ButtonTheme buildMaterialWidget(BuildContext context) {
    return ButtonTheme(
      minWidth: buttonWidth ?? buttonThemeMinWidth,
      child: RaisedButton(
        key: childKey,
        color: color,
        textColor: textColor,
        child: child,
        shape: shape,
        onPressed: onPressed,
      ),
    );
  }

  @override
  CupertinoButton buildCupertinoWidget(BuildContext context) {
    return CupertinoButton(
      key: childKey,
      padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
      color: color,
      child: child,
      onPressed: onPressed,
    );
  }
}
