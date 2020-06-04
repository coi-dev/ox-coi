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
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/chat/chat_change_bloc.dart';
import 'package:ox_coi/src/chat/chat_change_event_state.dart';
import 'package:ox_coi/src/contact/contact_list_bloc.dart';
import 'package:ox_coi/src/contact/contact_list_content.dart';
import 'package:ox_coi/src/contact/contact_list_event_state.dart';
import 'package:ox_coi/src/extensions/color_apis.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/message_list/message_list_flagged.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
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
  final _contactListBloc = ContactListBloc();
  final _chatChangeBloc = ChatChangeBloc();
  final _navigation = Navigation();

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
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatStateSuccess) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ProfileData(
                imageBackgroundColor: widget.chatColor,
                text: state.name,
                textStyle: Theme.of(context).textTheme.title,
                iconData: state.isVerified ? IconSource.verifiedUser : null,
                imageActionCallback: state.isRemoved ? null : _editPhotoCallback,
                avatarPath: state.avatarPath,
                showWhiteImageIcon: true,
                editActionCallback: state.isRemoved ? null : _openEditGroupProfile,
                child: ProfileHeader(),
              ),
              MultiBlocProvider(
                providers: [
                  BlocProvider<ChatChangeBloc>.value(value: _chatChangeBloc),
                  BlocProvider<ContactListBloc>.value(value: _contactListBloc),
                ],
                child: GroupMemberList(
                  chatId: widget.chatId,
                  isRemoved: state.isRemoved,
                ),
              ),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }

  _editPhotoCallback(String avatarPath) {
    _chatChangeBloc.add(SetImagePath(chatId: widget.chatId, newPath: avatarPath));
  }

  void _openEditGroupProfile() {
    // ignore: close_sinks
    final chatBloc = BlocProvider.of<ChatBloc>(context);
    _navigation.push(
      context,
      MaterialPageRoute<EditGroupProfile>(
        builder: (context) {
          return BlocProvider.value(
            value: chatBloc,
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

class GroupMemberList extends StatelessWidget {
  final _navigation = Navigation();
  final bool isRemoved;
  final int chatId;

  GroupMemberList({Key key, @required this.isRemoved, @required this.chatId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactListBloc, ContactListState>(
      builder: (context, state) {
        if (state is ContactListStateSuccess) {
          state.contactElements.retainWhere((item) => item is ValueKey);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

              SettingsItem(
                pushesNewScreen: true,
                icon: IconSource.flag,
                text: L10n.get(L.settingItemFlaggedTitle),
                iconBackground: CustomTheme.of(context).flagIcon,
                onTap: () => _navigation.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MessageListFlagged(chatId: chatId),
                  ),
                ),
              ),
              ListGroupHeader(
                text: L10n.getFormatted(L.participantXP, [state.contactElements.length], count: state.contactElements.length),
              ),
              Visibility(
                visible: !isRemoved,
                child: SettingsItem(
                  pushesNewScreen: true,
                  icon: IconSource.groupAdd,
                  text: L10n.get(L.participantAdd),
                  key: Key(keyChatProfileGroupAddParticipant),
                  iconBackground: CustomTheme.of(context).accent,
                  onTap: () => _navigation.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatAddGroupParticipants(chatId: chatId, contactIds: state.contactElements),
                    ),
                  ),
                ),
              ),
              ListView.separated(
                separatorBuilder: (context, index) => Divider(
                  height: zero,
                  color: CustomTheme.of(context).onBackground.barely(),
                ),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: state.contactElements.length,
                itemBuilder: (BuildContext context, int index) {
                  final contactElement = state.contactElements[index];

                  return ContactListContent(
            contactElement: contactElement,
            chatId: chatId,
            isGroupMember: true,
            showMoreButton: !isRemoved,
          );
                },
              ),
              SettingsItem(
                key: Key(keyChatProfileGroupLeaveOrDelete),
                pushesNewScreen: false,
                icon: IconSource.delete,
                text: isRemoved ? L10n.get(L.groupDelete) : L10n.get(L.groupLeave),
                iconBackground: CustomTheme.of(context).error,
                textColor: CustomTheme.of(context).error,
                onTap: () => isRemoved
                    ? showActionDialog(context, ProfileActionType.deleteChat, () => _deleteGroup(context))
                    : showActionDialog(context, ProfileActionType.leave, () => _leaveGroup(context)),
              ),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }

  _deleteGroup(BuildContext context) async {
    BlocProvider.of<ChatChangeBloc>(context).add(DeleteChat(chatId: chatId));
    _navigation.popUntilRoot(context);
  }

  _leaveGroup(BuildContext context) async {
    BlocProvider.of<ChatChangeBloc>(context).add(LeaveGroupChat(chatId: chatId));
    _navigation.popUntilRoot(context);
  }
}
