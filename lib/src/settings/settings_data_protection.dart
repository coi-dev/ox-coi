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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/settings/settings_data_protection_bloc.dart';
import 'package:ox_coi/src/settings/settings_data_protection_event_state.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/widgets/dynamic_appbar.dart';
import 'package:ox_coi/src/widgets/state_info.dart';

class SettingsDataProtection extends StatefulWidget {
  static get viewTitle => L10n.get(L.settingAntiMobbing);

  @override
  _DataProtectionState createState() => _DataProtectionState();
}

class _DataProtectionState extends State<SettingsDataProtection> {
  SettingsDataProtectionBloc _settingsDataProtectionBloc = SettingsDataProtectionBloc();
  Navigation navigation = Navigation();

  @override
  void initState() {
    super.initState();
    navigation.current = Navigatable(Type.settingsDataProtection);
    _settingsDataProtectionBloc.add(RequestSettings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: SettingsDataProtection.viewTitle,
        leading: AppBarBackButton(context: context),
      ),
      body: BlocBuilder(
        bloc: _settingsDataProtectionBloc,
        builder: (context, state) {
          if (state is SettingsDataProtectionStateInitial) {
            return StateInfo(showLoading: true);
          } else if (state is SettingsDataProtectionStateSuccess) {
            return ListView(
              children: ListTile.divideTiles(context: context, tiles: [
                ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: listItemPadding, horizontal: listItemPadding),
                  title: Text(L10n.get(L.settingAntiMobbing)),
                  subtitle: Text(L10n.get(L.settingAntiMobbingText)),
                  trailing: Switch.adaptive(
                    value: state.antiMobbingActive,
                    onChanged: (value) => _changeAntiMobbingSetting(),
                    activeColor: CustomTheme.of(context).accent,
                  ),
                ),
                Visibility(
                    visible: state.antiMobbingActive,
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: listItemPadding),
                      title: Text(L10n.get(L.settingChatMessagesUnknownShow)),
                      onTap: () {
                        _showAntiMobbingList();
                      },
                      trailing: Platform.isIOS ? AdaptiveIcon(icon: IconSource.iosChevron) : null,
                    )),
              ]).toList(),
            );
          } else {
            return Center(
              child: AdaptiveIcon(icon: IconSource.error),
            );
          }
        },
      ),
    );
  }

  _changeAntiMobbingSetting() {
    _settingsDataProtectionBloc.add(ChangeSettings());
  }

  void _showAntiMobbingList() {
    navigation.pushNamed(context, Navigation.settingsAntiMobbingList);
  }
}
