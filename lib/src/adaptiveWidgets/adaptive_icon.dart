import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'adaptive_widget.dart';

class AdaptiveIcon extends AdaptiveWidget<Icon, Icon> {
  final IconData androidIcon;
  final IconData iosIcon;

  AdaptiveIcon({
    Key key,
    this.androidIcon,
    this.iosIcon,
  }) : super(key: key);

  @override
  Icon buildMaterialWidget(BuildContext context) {
    return Icon(
      androidIcon,
      key: key,
    );
  }

  @override
  Icon buildCupertinoWidget(BuildContext context) {
    return Icon(
      iosIcon,
      key: key,
    );
  }
}
