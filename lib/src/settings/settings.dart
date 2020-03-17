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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/platform/app_information.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/widgets/dynamic_appbar.dart';

enum SettingsType {
  account,
  security,
  about,
  chat,
  antiMobbing,
  debug,
  notifications,
}

class Settings extends StatelessWidget {
  final Navigation _navigation = Navigation();

  Settings() {
    _navigation.current = Navigatable(Type.settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new DynamicAppBar(
          title: L10n.get(L.settingP, count: L10n.plural),
          leading: AppBarBackButton(context: context),
        ),
        body: buildPreferenceList(context));
  }

  ListView buildPreferenceList(BuildContext context) {
    return ListView(
      children: ListTile.divideTiles(context: context, tiles: [
        ListTile(
          leading: AdaptiveIcon(
            icon: IconSource.accountCircle,
            color: CustomTheme.of(context).accent,
          ),
          title: Text(L10n.get(L.settingAccount)),
          onTap: () => _onPressed(context, SettingsType.account),
        ),
        ListTile(
          leading: AdaptiveIcon(
            icon: IconSource.chat,
            color: CustomTheme.of(context).accent,
          ),
          title: Text(L10n.get(L.chatP)),
          onTap: () => _onPressed(context, SettingsType.chat),
        ),
        ListTile(
          leading: AdaptiveIcon(
            icon: IconSource.notifications,
            color: CustomTheme.of(context).accent,
          ),
          title: Text(L10n.get(L.settingNotificationP, count: L10n.plural)),
          onTap: () => _onPressed(context, SettingsType.notifications),
        ),
        ListTile(
          leading: AdaptiveIcon(
            icon: IconSource.https,
            color: CustomTheme.of(context).accent,
          ),
          title: Text(L10n.get(L.settingAntiMobbing)),
          onTap: () => _onPressed(context, SettingsType.antiMobbing),
        ),
        ListTile(
          leading: AdaptiveIcon(
            icon: IconSource.security,
            color: CustomTheme.of(context).accent,
          ),
          title: Text(L10n.get(L.security)),
          onTap: () => _onPressed(context, SettingsType.security),
        ),
        ListTile(
          leading: AdaptiveIcon(
            icon: IconSource.info,
            color: CustomTheme.of(context).accent,
          ),
          title: Text(L10n.get(L.about)),
          onTap: () => _onPressed(context, SettingsType.about),
        ),
        if (!isRelease())
          ListTile(
            leading: AdaptiveIcon(
              icon: IconSource.bugReport,
              color: CustomTheme.of(context).accent,
            ),
            title: Text(L10n.get(L.debug)),
            onTap: () => _onPressed(context, SettingsType.debug),
          ),
      ]).toList(),
    );
  }

  void _onPressed(BuildContext context, SettingsType type) {
    switch (type) {
      case SettingsType.account:
        _navigation.pushNamed(context, Navigation.settingsAccount);
        break;
      case SettingsType.security:
        _navigation.pushNamed(context, Navigation.settingsSecurity);
        break;
      case SettingsType.about:
        _navigation.pushNamed(context, Navigation.settingsAbout);
        break;
      case SettingsType.chat:
        _navigation.pushNamed(context, Navigation.settingsChat);
        break;
      case SettingsType.antiMobbing:
        _navigation.pushNamed(context, Navigation.settingsAntiMobbing);
        break;
      case SettingsType.notifications:
        _navigation.pushNamed(context, Navigation.settingsNotifications);
        break;
      case SettingsType.debug:
        _navigation.pushNamed(context, Navigation.settingsDebug);
        break;
    }
  }
}
