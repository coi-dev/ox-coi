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

import 'package:delta_chat_core/delta_chat_core.dart' as Core;
import 'package:flutter/material.dart';
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/chat/chat.dart';
import 'package:ox_coi/src/contact/contact_details.dart';
import 'package:ox_coi/src/contact/contact_item_bloc.dart';
import 'package:ox_coi/src/contact/contact_item_builder_mixin.dart';
import 'package:ox_coi/src/contact/contact_item_event_state.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/dimensions.dart';

import 'chat_change_bloc.dart';
import 'chat_change_event_state.dart';
import 'chat_create_mixin.dart';

enum GroupParticipantActions { info, sendMessage, remove }

class ChatProfileGroupContactItem extends StatefulWidget {
  final int chatId;
  final int contactId;
  final bool showMoreButton;

  ChatProfileGroupContactItem({this.chatId, this.contactId, this.showMoreButton = false, key}) : super(key: Key(key));

  @override
  _ChatProfileGroupContactItemState createState() => _ChatProfileGroupContactItemState();
}

class _ChatProfileGroupContactItemState extends State<ChatProfileGroupContactItem> with ContactItemBuilder, ChatCreateMixin {
  ContactItemBloc _contactBloc = ContactItemBloc();
  ChatChangeBloc _chatChangeBloc = ChatChangeBloc();
  Navigation _navigation = Navigation();
  List<GroupParticipantMenu> choices;

  void _select(GroupParticipantMenu choice) {
    switch (choice.action) {
      case GroupParticipantActions.info:
        goToProfile("", "");
        break;
      case GroupParticipantActions.sendMessage:
        createChat();
        break;
      case GroupParticipantActions.remove:
        _removeParticipant();
    }
  }

  @override
  void initState() {
    super.initState();
    _contactBloc.add(RequestContact(contactId: widget.contactId, typeOrChatId: validContacts));
    if (widget.contactId != Core.Contact.idSelf) {
      choices = participantChoices;
    } else {
      choices = meChoices;
    }
  }

  @override
  void dispose() {
    _contactBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return getAvatarItemBlocBuilder(
        bloc: _contactBloc, onContactTapped: goToProfile, moreButton: widget.showMoreButton ? getMoreButton() : null, showHeaderText: false);
  }

  goToProfile(String title, String subtitle) {
    _navigation.push(
      context,
      MaterialPageRoute(builder: (context) => ContactDetails(contactId: widget.contactId)),
    );
  }

  createChat() {
    createChatFromContact(context, widget.contactId, _handleCreateChatStateChange);
  }

  getMoreButton() {
    return PopupMenuButton<GroupParticipantMenu>(
      key: Key("keyMoreButton_${widget.contactId}"),
      elevation: 3.2,
      onSelected: _select,
      itemBuilder: (BuildContext context) {
        return choices.map((GroupParticipantMenu choice) {
          return PopupMenuItem<GroupParticipantMenu>(
            value: choice,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: iconTextPadding),
                  child: AdaptiveIcon(
                    icon: choice.iconSource,
                    color: choice.color,
                  ),
                ),
                Text(
                  choice.title,
                  style: TextStyle(color: choice.color),
                )
              ],
            ),
          );
        }).toList();
      },
    );
  }

  void _removeParticipant() {
    if (widget.contactId != Core.Contact.idSelf) {
      _chatChangeBloc.add(ChatRemoveParticipant(chatId: widget.chatId, contactId: widget.contactId));
    }
  }

  _handleCreateChatStateChange(int chatId) {
    _navigation.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Chat(chatId: chatId)),
      ModalRoute.withName(Navigation.root),
      Navigatable(Type.rootChildren),
    );
  }
}

List<GroupParticipantMenu> participantChoices = <GroupParticipantMenu>[
  GroupParticipantMenu(
    title: L10n.get(L.groupParticipantActionInfo),
    iconSource: IconSource.info,
    action: GroupParticipantActions.info,
  ),
  GroupParticipantMenu(
    title: L10n.get(L.groupParticipantActionSendMessage),
    iconSource: IconSource.chat,
    action: GroupParticipantActions.sendMessage,
  ),
  GroupParticipantMenu(
    title: L10n.get(L.groupParticipantActionRemove),
    iconSource: IconSource.delete,
    color: Colors.red,
    action: GroupParticipantActions.remove,
  ),
];

List<GroupParticipantMenu> meChoices = <GroupParticipantMenu>[
  GroupParticipantMenu(
    title: L10n.get(L.groupParticipantActionInfo),
    iconSource: IconSource.info,
    action: GroupParticipantActions.info,
  ),
  GroupParticipantMenu(
    title: L10n.get(L.groupParticipantActionSendMessage),
    iconSource: IconSource.chat,
    action: GroupParticipantActions.sendMessage,
  ),
];

class GroupParticipantMenu {
  final String title;
  final IconSource iconSource;
  final Color color;
  final GroupParticipantActions action;

  GroupParticipantMenu({@required this.title, @required this.action, this.iconSource, this.color});
}
