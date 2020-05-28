import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'adaptive_widget.dart';

class AdaptiveBottomSheetAction extends AdaptiveWidget<CupertinoActionSheetAction, ListTile> {
  final Widget title;
  final Widget leading;
  final bool isDestructive;
  final Function onPressed;

  AdaptiveBottomSheetAction({
    @required Key key,
    @required this.title,
    @required this.onPressed,
    this.leading,
    this.isDestructive = false,
  }) : super(childKey: key);

  @override
  ListTile buildMaterialWidget(BuildContext context) {
    return ListTile(
      key: childKey,
      leading: leading,
      title: title,
      onTap: onPressed,
    );
  }

  @override
  CupertinoActionSheetAction buildCupertinoWidget(BuildContext context) {
    return CupertinoActionSheetAction(
      key: childKey,
      child: title,
      isDestructiveAction: isDestructive,
      onPressed: onPressed,
    );
  }
}
