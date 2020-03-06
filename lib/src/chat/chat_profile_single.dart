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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon.dart';
import 'package:ox_coi/src/chat/chat_change_bloc.dart';
import 'package:ox_coi/src/chat/chat_change_event_state.dart';
import 'package:ox_coi/src/contact/contact_change.dart';
import 'package:ox_coi/src/contact/contact_change_bloc.dart';
import 'package:ox_coi/src/contact/contact_change_event_state.dart';
import 'package:ox_coi/src/contact/contact_item_bloc.dart';
import 'package:ox_coi/src/contact/contact_item_event_state.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/flagged/flagged.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/ui/custom_theme.dart';
import 'package:ox_coi/src/widgets/list_group_header.dart';
import 'package:ox_coi/src/widgets/profile_body.dart';
import 'package:ox_coi/src/widgets/profile_header.dart';
import 'package:ox_coi/src/widgets/settings_item.dart';

class ChatProfileOneToOne extends StatefulWidget {
  final int chatId;
  final int contactId;
  final bool isSelfTalk;

  ChatProfileOneToOne(
      {@required this.chatId,
      @required this.isSelfTalk,
      @required this.contactId,
      key})
      : super(key: Key(key));

  @override
  _ChatProfileOneToOneState createState() => _ChatProfileOneToOneState();
}

class _ChatProfileOneToOneState extends State<ChatProfileOneToOne> {
  ContactItemBloc _contactItemBloc = ContactItemBloc();
  Navigation _navigation = Navigation();

  @override
  void initState() {
    super.initState();
    var typeOrChatId;
    if (isInvite()) {
      typeOrChatId = inviteContacts;
    } else {
      typeOrChatId = validContacts;
    }
    _contactItemBloc.add(RequestContact(
        contactId: widget.contactId, typeOrChatId: typeOrChatId));
  }

  bool isInvite() => widget.chatId == Chat.typeInvite;

  @override
  void dispose() {
    _contactItemBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: _contactItemBloc,
        builder: (context, state) {
          if (state is ContactItemStateSuccess) {
            return _buildSingleProfileInfo(state.name, state.email, state.color,
                state.isVerified, state.imagePath, state.phoneNumbers);
          } else {
            return Container();
          }
        });
  }

  Widget _buildSingleProfileInfo(String chatName, String email, Color color,
      bool isVerified, String imagePath, String phoneNumbers) {
    return Container(
      color: CustomTheme.of(context).background,
      child: Column(
        children: <Widget>[
          ProfileData(
            text: chatName,
            secondaryText: email,
            avatarPath: imagePath,
            placeholderText: L10n.get(L.profileNoUsername),
            imageBackgroundColor:
                CustomTheme.of(context).onBackground.barely(),
            withPlaceholder: true,
            editActionCallback: () =>
                _editContact(context, chatName, email, phoneNumbers),
            child: ProfileHeader(),
          ),
          SettingsItem(
            icon: IconSource.flag,
            text: L10n.get(L.settingItemFlaggedTitle),
            iconBackground: CustomTheme.of(context).flagIcon,
            onTap: () =>
                _settingsItemTapped(context, SettingsItemName.flagged),
          ),
          SettingsItem(
            icon: IconSource.block,
            text: L10n.get(L.settingItemBlockedTitle),
            iconBackground: CustomTheme.of(context).blockIcon,
            onTap: () => showActionDialog(
              context,
              ProfileActionType.block,
              _blockContact,
              {
                ProfileActionParams.name: chatName,
                ProfileActionParams.email: email,
              },
            ),
          ),
          if (!widget.isSelfTalk)
            ListGroupHeader(
              text: L10n.get(L.settingP),
            ),
          if (!widget.isSelfTalk)
            SettingsItem(
              icon: IconSource.notifications,
              text: L10n.get(L.settingItemNotificationsTitle),
              iconBackground: CustomTheme.of(context).notificationIcon,
              onTap: () =>
                  _settingsItemTapped(context, SettingsItemName.notification),
            ),
          if (!isInvite())
            ListGroupHeader(
              text: "",
            ),
          if (!isInvite())
            SettingsItem(
              icon: IconSource.delete,
              text: L10n.get(L.chatDeleteP),
              textColor: CustomTheme.of(context).error,
              iconBackground: CustomTheme.of(context).blockIcon,
              onTap: () => _deleteChat(),
            ),
        ],
      ),
    );
  }

  _settingsItemTapped(BuildContext context, SettingsItemName settingsItemName) {
    switch (settingsItemName) {
      case SettingsItemName.flagged:
        _navigation.push(
          context,
          MaterialPageRoute(builder: (context) => Flagged()),
        );
        break;
      case SettingsItemName.notification:
        _navigation.pushNamed(context, Navigation.settingsNotifications);
        break;
      default:
        break;
    }
  }

  _blockContact() {
    // Ignoring false positive https://github.com/felangel/bloc/issues/587
    // ignore: close_sinks
    ContactChangeBloc contactChangeBloc = ContactChangeBloc();
    contactChangeBloc
        .add(BlockContact(contactId: widget.contactId, chatId: widget.chatId));
    _navigation.popUntilRoot(context);
  }

  _deleteChat() {
    // Ignoring false positive https://github.com/felangel/bloc/issues/587
    // ignore: close_sinks
    ChatChangeBloc chatChangeBloc = ChatChangeBloc();
    chatChangeBloc.add(DeleteChat(chatId: widget.chatId));
    _navigation.popUntilRoot(context);
  }

  void _editContact(BuildContext context, String name, String email,
      String phoneNumbers) async {
    return await _navigation
        .push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactChange(
          contactAction: ContactAction.edit,
          id: widget.contactId,
          name: name,
          email: email,
          phoneNumbers: phoneNumbers,
        ),
      ),
    )
        .then((value) {
      _contactItemBloc.add(RequestContact(
          contactId: widget.contactId, typeOrChatId: validContacts));
    });
  }
}
