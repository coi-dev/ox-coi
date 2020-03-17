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

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/widgets/superellipse_icon.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/ui/dimensions.dart';

enum SettingsItemName {
  flagged,
  qrShow,
  invite,
  notification,
  chat,
  signature,
  serverSetting,
  darkMode,
  dataProtection,
  blocked,
  encryption,
  about,
  feedback,
  bugReport,
  debug,
  logout,
}

class SettingsItem extends StatelessWidget {
  final IconSource icon;
  final Color iconBackground;
  final String text;
  final Function onTap;
  final bool showSwitch;
  final bool showChevron;
  final Function onSwitchChanged;
  final Color textColor;
  final double itemHeight;

  SettingsItem({
    Key key,
    @required this.icon,
    @required this.iconBackground,
    @required this.text,
    @required this.onTap,
    this.showSwitch = false,
    this.showChevron = true,
    this.onSwitchChanged,
    this.textColor,
    this.itemHeight = dimension48dp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = CustomTheme.of(context).brightness;

    final backgroundSize = itemHeight - settingsItemVerticalPadding * 2;
    final iconBackgroundPadding = 4.0;
    final iconSize = backgroundSize - iconBackgroundPadding * 2;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: CustomTheme.of(context).surface,
        height: itemHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: dimension20dp, vertical: settingsItemVerticalPadding),
          child: Row(
            children: [
              SuperellipseIcon(
                color: iconBackground,
                backgroundSize: backgroundSize,
                iconSize: iconSize,
                iconColor: CustomTheme.of(context).white,
                icon: icon,
              ),
              Padding(
                padding: EdgeInsets.only(right: dimension16dp),
              ),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.body1.apply(color: this.textColor ?? CustomTheme.of(context).onSurface),
                ),
              ),
              Visibility(
                visible: Platform.isIOS && !showSwitch && showChevron,
                child: AdaptiveIcon(
                  icon: IconSource.iosChevron,
                  color: CustomTheme.of(context).onSurface,
                ),
              ),
              Visibility(
                visible: showSwitch,
                child: Switch.adaptive(value: brightness == Brightness.dark ? true : false, onChanged: (value) => onSwitchChanged()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
