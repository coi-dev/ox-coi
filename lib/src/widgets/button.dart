/*
 * OPEN-XCHANGE legal information
 *
 * All intellectual property rights in the Software are protected by
 * international copyright laws.
 *
 *
 * In some countries OX, OX Open-Xchange and open xchange
 * as well as the corresponding Logos OX Open-Xchange and OX are registered
 * trademarks of the OX Software GmbH group of companies.
 * The use of the Logos is not covered by the Mozilla Public License 2.0 (MPL 2.0).
 * Instead, you are allowed to use these Logos according to the terms and
 * conditions of the Creative Commons License, Version 2.5, Attribution,
 * Non-commercial, ShareAlike, and the interpretation of the term
 * Non-commercial applicable to the aforementioned license is published
 * on the web site https://www.open-xchange.com/terms-and-conditions/.
 *
 * Please make sure that third-party modules and libraries are used
 * according to their respective licenses.
 *
 * Any modifications to this package must retain all copyright notices
 * of the original copyright holder(s) for the original code used.
 *
 * After any such modifications, the original and derivative code shall remain
 * under the copyright of the copyright holder(s) and/or original author(s) as stated here:
 * https://www.open-xchange.com/legal/. The contributing author shall be
 * given Attribution for the derivative code and a license granting use.
 *
 * Copyright (C) 2016-2020 OX Software GmbH
 * Mail: info@open-xchange.com
 *
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the Mozilla Public License 2.0
 * for more details.
 */

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/extensions/color_apis.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:tinycolor/tinycolor.dart';

final _circularBorder = RoundedRectangleBorder(borderRadius: BorderRadius.circular(loginOtherProviderButtonRadius));

abstract class BaseButton extends StatelessWidget {
  static final darkenFactor = 10;
  static final lightenFactor = 10;
  final double minimumWidth;
  final Widget child;
  final Function onPressed;
  final bool isDestructive;

  const BaseButton({Key key, @required this.onPressed, @required this.child, this.minimumWidth, this.isDestructive}) : super(key: key);
}

class ButtonImportanceHigh extends BaseButton {
  const ButtonImportanceHigh({Key key, @required onPressed, @required child, minimumWidth = buttonMinWidth, isDestructive = false})
      : super(
          key: key,
          onPressed: onPressed,
          child: child,
          minimumWidth: minimumWidth,
          isDestructive: isDestructive,
        );

  @override
  Widget build(BuildContext context) {
    final baseColor = isDestructive ? CustomTheme.of(context).error : CustomTheme.of(context).accent;
    final highlightColor = (CustomTheme.of(context).brightness == Brightness.light)
        ? TinyColor(baseColor).darken(BaseButton.darkenFactor).color
        : TinyColor(baseColor).lighten(BaseButton.lightenFactor).color;
    return ButtonTheme(
      minWidth: minimumWidth,
      height: buttonHeight,
      child: RaisedButton(
        highlightElevation: zero,
        color: baseColor,
        textColor: CustomTheme.of(context).onAccent,
        disabledColor: baseColor.disabled(),
        disabledTextColor: baseColor.disabled(),
        highlightColor: highlightColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: buttonVerticalContentPadding),
          child: child,
        ),
        shape: _circularBorder,
        onPressed: onPressed,
      ),
    );
  }
}

class ButtonImportanceMedium extends BaseButton {
  const ButtonImportanceMedium({Key key, @required onPressed, @required child, minimumWidth = buttonMinWidth, isDestructive = false})
      : super(
          key: key,
          onPressed: onPressed,
          child: child,
          minimumWidth: minimumWidth,
          isDestructive: isDestructive,
        );

  @override
  Widget build(BuildContext context) {
    final baseColor = isDestructive ? CustomTheme.of(context).error : CustomTheme.of(context).accent;
    return ButtonTheme(
      minWidth: minimumWidth,
      height: buttonHeight,
      splashColor: Colors.transparent,
      child: OutlineButton(
        textColor: baseColor,
        borderSide: BorderSide(color: baseColor),
        disabledTextColor: baseColor.disabled(),
        disabledBorderColor: baseColor.disabled(),
        highlightColor: baseColor.slightly(),
        highlightedBorderColor: baseColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: buttonVerticalContentPadding),
          child: child,
        ),
        shape: _circularBorder,
        onPressed: onPressed,
      ),
    );
  }
}

class ButtonImportanceLow extends BaseButton {
  const ButtonImportanceLow({Key key, @required onPressed, @required child, minimumWidth = buttonMinWidth, isDestructive = false})
      : super(
          key: key,
          onPressed: onPressed,
          child: child,
          minimumWidth: minimumWidth,
          isDestructive: isDestructive,
        );

  @override
  Widget build(BuildContext context) {
    final baseColor = isDestructive ? CustomTheme.of(context).error : CustomTheme.of(context).accent;
    return ButtonTheme(
      minWidth: minimumWidth,
      height: buttonHeight,
      splashColor: Colors.transparent,
      child: FlatButton(
        textColor: baseColor,
        disabledTextColor: baseColor.disabled(),
        highlightColor: baseColor.slightly(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: buttonVerticalContentPadding),
          child: child,
        ),
        shape: _circularBorder,
        onPressed: onPressed,
      ),
    );
  }
}
