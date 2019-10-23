import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'adaptive_icon.dart';
import 'adaptive_widget.dart';

class AdaptiveIconButton extends AdaptiveWidget<CupertinoButton, IconButton> {
  final AdaptiveIcon icon;
  final Function onPressed;
  final Color color;

  AdaptiveIconButton({
    Key key,
    this.icon,
    this.onPressed,
    this.color,
  }) : super(key: key);

  @override
  IconButton buildMaterialWidget(BuildContext context) {
    return IconButton(
      key: key,
      icon: icon,
      onPressed: onPressed,
    );
  }

  @override
  CupertinoButton buildCupertinoWidget(BuildContext context) {
    return CupertinoButton(
      key: key,
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: icon,
      onPressed: onPressed,
    );
  }
}
