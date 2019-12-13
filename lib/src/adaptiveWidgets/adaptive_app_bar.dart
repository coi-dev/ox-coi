import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_coi/src/ui/custom_theme.dart';

import 'adaptive_widget.dart';

class AdaptiveAppBar extends AdaptiveWidget<CupertinoTheme, AppBar> with PreferredSizeWidget {
  final Function onPressed;
  final Color color;
  final Widget title;
  final List<Widget> actions;
  final double elevation;
  final Widget leadingIcon;

  AdaptiveAppBar({
    Key key,
    this.onPressed,
    this.color,
    this.title,
    this.actions,
    this.elevation = 1.0,
    this.leadingIcon,
  }) : super(childKey: key);

  @override
  AppBar buildMaterialWidget(BuildContext context) {
    return AppBar(
      key: childKey,
      leading: leadingIcon,
      title: title,
      actions: actions,
      elevation: elevation,
      backgroundColor: CustomTheme.of(context).surface,
      iconTheme: IconThemeData(color: CustomTheme.of(context).onSurface),
    );
  }

  @override
  CupertinoTheme buildCupertinoWidget(BuildContext context) {
    return CupertinoTheme(
        data: CupertinoThemeData(
          brightness: CustomTheme.of(context).brightness,
        ),
        child: CupertinoNavigationBar(
          key: childKey,
          leading: leadingIcon,
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
          middle: title,
          backgroundColor: color,
          actionsForegroundColor: CustomTheme.of(context).onSurface,
          trailing: actions != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions,
                )
              : null,
        ));
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
