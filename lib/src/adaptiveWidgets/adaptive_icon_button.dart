import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_coi/src/ui/dimensions.dart';

import 'adaptive_widget.dart';

class AdaptiveIconButton extends AdaptiveWidget<CupertinoButton, IconButton> {
  final Widget icon;
  final Function onPressed;
  final Color color;

  AdaptiveIconButton({
    Key key,
    this.icon,
    this.onPressed,
    this.color,
  }) : super(childKey: key);

  @override
  IconButton buildMaterialWidget(BuildContext context) {
    return IconButton(
      key: childKey,
      icon: icon,
      onPressed: onPressed,
    );
  }

  @override
  CupertinoButton buildCupertinoWidget(BuildContext context) {
    return CupertinoButton(
      key: childKey,
      padding: const EdgeInsets.fromLTRB(zero, zero, zero, zero),
      child: icon,
      onPressed: onPressed,
    );
  }
}
