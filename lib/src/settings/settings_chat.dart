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

import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_app_bar.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/settings/settings_chat_bloc.dart';
import 'package:ox_coi/src/settings/settings_chat_event_state.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/widgets/state_info.dart';

class SettingsChat extends StatefulWidget {
  @override
  _SettingsChatState createState() => _SettingsChatState();
}

class _SettingsChatState extends State<SettingsChat> {
  SettingsChatBloc _settingsChatBloc = SettingsChatBloc();
  final Navigation _navigation = Navigation();

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.settingsChat);
    _settingsChatBloc.add(RequestValues());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AdaptiveAppBar(
          title: Text(L10n.get(L.chatP)),
        ),
        body: _buildPreferenceList(context));
  }

  Widget _buildPreferenceList(BuildContext context) {
    return BlocBuilder(
      bloc: _settingsChatBloc,
      builder: (context, state) {
        if (state is SettingsChatStateSuccess) {
          return ListView(
            children: ListTile.divideTiles(context: context, tiles: [
              ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: listItemPadding, horizontal: listItemPaddingBig),
                title: Text(L10n.get(L.settingReadReceiptP, count: L10n.plural)),
                subtitle: Text(L10n.get(L.settingReadReceiptText)),
                trailing: Switch.adaptive(value: state.readReceiptsEnabled, onChanged: (value) => _changeReadReceipts()),
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: listItemPadding, horizontal: listItemPaddingBig),
                title: Text(
                  L10n.get(L.settingMessageSyncing),
                ),
                subtitle: Text(
                  L10n.get(L.settingChooseMessageSyncingType),
                ),
                onTap: () {
                  _buildMessageSyncChooserDialog(state.inviteSetting);
                },
              ),
            ]).toList(),
          );
        } else {
          return StateInfo(showLoading: true);
        }
      },
    );
  }

  void _changeReadReceipts() {
    _settingsChatBloc.add(ChangeReadReceipts());
  }

  Future<void> _buildMessageSyncChooserDialog(int inviteSetting) async {
    int selectedInviteSetting = await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(L10n.get(L.settingChooseMessageSyncingType)),
            children: <Widget>[
              RadioListTile<int>(
                title: Text(L10n.get(L.settingMessageSyncingTypeChats)),
                value: Context.showEmailsOff,
                groupValue: inviteSetting,
                onChanged: _onMessageSyncChooserTab,
              ),
              RadioListTile<int>(
                title: Text(L10n.get(L.settingMessageSyncingTypeKnown)),
                value: Context.showEmailsAcceptedContacts,
                groupValue: inviteSetting,
                onChanged: _onMessageSyncChooserTab,
              ),
              RadioListTile<int>(
                title: Text(L10n.get(L.settingMessageSyncingTypeAll)),
                value: Context.showEmailsAll,
                groupValue: inviteSetting,
                onChanged: _onMessageSyncChooserTab,
              ),
            ],
          );
        });
    if (selectedInviteSetting != null) {
      _settingsChatBloc.add((ChangeInviteSetting(newInviteSetting: selectedInviteSetting)));
    }
  }

  _onMessageSyncChooserTab(int value) {
    Navigator.pop(context, value);
  }
}
