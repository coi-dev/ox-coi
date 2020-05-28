import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';

import 'adaptive_widget.dart';

class AdaptiveBottomSheet extends AdaptiveWidget<CupertinoActionSheet, Column> {
  final List<Widget> actions;

  AdaptiveBottomSheet({
    Key key,
    @required this.actions,
  }) : super(childKey: key);

  @override
  CupertinoActionSheet buildCupertinoWidget(BuildContext context) {
    return CupertinoActionSheet(
      key: childKey,
      actions: actions,
      cancelButton: CupertinoActionSheetAction(
        key: Key(keyAdaptiveBottomSheetCancel),
        child: Text(L10n.get(L.cancel)),
        isDefaultAction: true,
        onPressed: () => Navigation().pop(context),
      ),
    );
  }

  @override
  Column buildMaterialWidget(BuildContext context) {
    return Column(
      key: childKey,
      mainAxisSize: MainAxisSize.min,
      children: actions,
    );
  }
}
