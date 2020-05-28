import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'adaptive_widget.dart';

class AdaptiveDialog extends AdaptiveWidget<CupertinoAlertDialog, AlertDialog> {
  final Widget title;
  final Widget content;
  final List<Widget> actions;

  AdaptiveDialog({
    Key key,
    @required this.title,
    @required this.content,
    @required this.actions,
  }) : super(childKey: key);

  @override
  AlertDialog buildMaterialWidget(BuildContext context) {
    return AlertDialog(
      key: childKey,
      title: title,
      content: content,
      actions: actions,
    );
  }

  @override
  CupertinoAlertDialog buildCupertinoWidget(BuildContext context) {
    return CupertinoAlertDialog(
      key: childKey,
      title: title,
      content: content,
      actions: actions,
    );
  }
}
