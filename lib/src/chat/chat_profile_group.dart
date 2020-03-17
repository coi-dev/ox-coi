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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/chat/chat_change_bloc.dart';
import 'package:ox_coi/src/chat/chat_change_event_state.dart';
import 'package:ox_coi/src/chat/chat_profile_group_contact_item.dart';
import 'package:ox_coi/src/contact/contact_list_bloc.dart';
import 'package:ox_coi/src/contact/contact_list_event_state.dart';
import 'package:ox_coi/src/flagged/flagged.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/extensions/color_apis.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/widgets/list_group_header.dart';
import 'package:ox_coi/src/widgets/profile_body.dart';
import 'package:ox_coi/src/widgets/profile_header.dart';
import 'package:ox_coi/src/widgets/settings_item.dart';

import 'chat_add_group_participants.dart';
import 'chat_bloc.dart';
import 'chat_event_state.dart';
import 'edit_group_profile.dart';

class ChatProfileGroup extends StatefulWidget {
  final int chatId;
  final Color chatColor;
  final bool isVerified;

  ChatProfileGroup({@required this.chatId, this.chatColor, this.isVerified});

  @override
  _ChatProfileGroupState createState() => _ChatProfileGroupState();
}

class _ChatProfileGroupState extends State<ChatProfileGroup> {
  ContactListBloc _contactListBloc = ContactListBloc();
  ChatChangeBloc _chatChangeBloc = ChatChangeBloc();

  // Ignoring false positive https://github.com/felangel/bloc/issues/587
  // ignore: close_sinks
  ChatBloc _chatBloc;
  Navigation _navigation = Navigation();

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.chatGroupProfile);
    _contactListBloc.add(RequestContacts(typeOrChatId: widget.chatId));
  }

  @override
  void dispose() {
    _contactListBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _chatBloc = BlocProvider.of<ChatBloc>(context);
    return BlocBuilder(
      bloc: _chatBloc,
      builder: (context, chatState) {
        if (chatState is ChatStateSuccess) {
          return BlocBuilder(
              bloc: _contactListBloc,
              builder: (context, state) {
                if (state is ContactListStateSuccess) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      buildProfileImageAndTitle(chatState),
                      SettingsItem(
                        icon: IconSource.flag,
                        text: L10n.get(L.settingItemFlaggedTitle),
                        iconBackground: CustomTheme.of(context).flagIcon,
                        onTap: () => _settingsItemTapped(context, SettingsItemName.flagged),
                      ),
                      ListGroupHeader(
                        text: L10n.get(L.settingP),
                      ),
                      SettingsItem(
                        icon: IconSource.notifications,
                        text: L10n.get(L.settingItemNotificationsTitle),
                        iconBackground: CustomTheme.of(context).notificationIcon,
                        onTap: () => _settingsItemTapped(context, SettingsItemName.notification),
                      ),
                      ListGroupHeader(
                        text: L10n.getFormatted(L.participantXP, [state.contactIds.length], count: state.contactIds.length),
                      ),
                      Visibility(
                        visible: !chatState.isRemoved,
                        child: SettingsItem(
                          icon: IconSource.groupAdd,
                          text: L10n.get(L.participantAdd),
                          key: Key(keyChatProfileGroupAddParticipant),
                          iconBackground: CustomTheme.of(context).accent,
                          onTap: () => _navigation.push(context,
                              MaterialPageRoute(builder: (context) => ChatAddGroupParticipants(chatId: widget.chatId, contactIds: state.contactIds))),
                        ),
                      ),
                      _buildGroupMemberList(state, chatState.isRemoved),
                      SettingsItem(
                        icon: IconSource.delete,
                        text: L10n.get(L.groupLeave),
                        iconBackground: CustomTheme.of(context).error,
                        textColor: CustomTheme.of(context).error,
                        onTap: () => showActionDialog(context, ProfileActionType.leave, _leaveGroup),
                        key: Key(keyChatProfileGroupDelete),
                      ),
                    ],
                  );
                } else {
                  return Container();
                }
              });
        } else {
          return Container();
        }
      },
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

  ProfileData buildProfileImageAndTitle(ChatStateSuccess state) {
    return ProfileData(
      imageBackgroundColor: widget.chatColor,
      text: state.name,
      textStyle: Theme.of(context).textTheme.title,
      iconData: state.isVerified ? IconSource.verifiedUser : null,
      imageActionCallback: state.isRemoved ? null : _editPhotoCallback,
      avatarPath: state.avatarPath,
      showWhiteImageIcon: true,
      editActionCallback: state.isRemoved ? null : _openEditGroupProfile,
      child: ProfileHeader(),
    );
  }

  _editPhotoCallback(String avatarPath) {
    _chatChangeBloc.add(SetImagePath(chatId: widget.chatId, newPath: avatarPath));
  }

  ListView _buildGroupMemberList(ContactListStateSuccess state, bool isRemoved) {
    return ListView.separated(
        separatorBuilder: (context, index) => Divider(
              height: zero,
              color: CustomTheme.of(context).onBackground.barely(),
            ),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: state.contactIds.length,
        itemBuilder: (BuildContext context, int index) {
          var contactId = state.contactIds[index];
          var key = "$contactId-${state.contactLastUpdateValues[index]}";
          return ChatProfileGroupContactItem(chatId: widget.chatId, contactId: contactId, showMoreButton: !isRemoved, key: key);
        });
  }

  _leaveGroup() async {
    _chatChangeBloc.add(LeaveGroupChat(chatId: widget.chatId));
    _chatChangeBloc.add(DeleteChat(chatId: widget.chatId));
    _navigation.popUntilRoot(context);
  }

  void _openEditGroupProfile() {
    _navigation.push(
      context,
      MaterialPageRoute<EditGroupProfile>(
        builder: (context) {
          return BlocProvider.value(
            value: _chatBloc,
            key: Key(keyChatProfileGroupEditIcon),
            child: EditGroupProfile(
              chatId: widget.chatId,
            ),
          );
        },
      ),
    );
  }
}
