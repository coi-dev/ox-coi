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
import 'package:ox_coi/src/chat/chat.dart';
import 'package:ox_coi/src/chatlist/chat_list_item.dart';
import 'package:ox_coi/src/contact/contact_item.dart';
import 'package:ox_coi/src/l10n/localizations.dart';
import 'package:ox_coi/src/message/message_action.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/share/share_bloc.dart';
import 'package:ox_coi/src/share/share_event_state.dart';
import 'package:ox_coi/src/utils/dimensions.dart';
import 'package:ox_coi/src/widgets/state_info.dart';

class ShareScreen extends StatefulWidget {
  final List<int> _msgIds;
  final MessageActionTag _messageActionTag;

  ShareScreen(this._msgIds, this._messageActionTag);

  @override
  _ShareScreenState createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  ShareBloc _shareBloc = ShareBloc();

  @override
  void initState() {
    super.initState();
    _shareBloc.dispatch(RequestChatsAndContacts());
  }

  @override
  void dispose() {
    _shareBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget._messageActionTag == MessageActionTag.forward
            ? Text(AppLocalizations.of(context).forward)
            : Text(AppLocalizations.of(context).share),
      ),
      body: _buildShareList(),
    );
  }

  Widget _buildShareList() {
    return BlocBuilder(
      bloc: _shareBloc,
      builder: (context, state) {
        if (state is ShareStateSuccess) {
          if (state.chatAndContactIds.length > 0) {
            return buildListView(state);
          }
        } else if (state is ShareStateLoading) {
          return StateInfo(showLoading: true);
        } else {
          return Icon(Icons.error);
        }
      },
    );
  }

  Widget buildListView(ShareStateSuccess state) {
    return ListView.builder(
      padding: EdgeInsets.only(top: listItemPadding),
      itemCount: state.chatAndContactIds.length,
      itemBuilder: (BuildContext context, int index) {
        if (state.chatIdCount > 0 && index < state.chatIdCount) {
          var chatId = state.chatAndContactIds[index];
          if (index == 0) {
            return createChatItemWithHeader(chatId);
          } else {
            return ChatListItem(chatId, chatItemTapped, null, false, true, chatId.toString());
          }
        } else if (state.contactIdCount > 0 && index >= state.chatIdCount) {
          var contactId = state.chatAndContactIds[index];
          if (index == state.chatIdCount) {
            return createContactItemWithHeader(contactId);
          } else {
            return ContactItem(contactId, contactId.toString(), ContactItemType.forward, chatItemTapped);
          }
        }
      },
    );
  }

  chatItemTapped(int chatId) {
    Navigation navigation = Navigation();
    _shareBloc.dispatch(ForwardMessages(chatId, widget._msgIds));
    navigation.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Chat(chatId)),
      ModalRoute.withName(Navigation.root),
      Navigatable(Type.chat, params: [chatId]),
    );
  }

  Widget createChatItemWithHeader(int chatId) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            AppLocalizations.of(context).chats,
            style: Theme.of(context).textTheme.headline,
          ),
          ChatListItem(chatId, chatItemTapped, null, false, true, chatId.toString()),
        ],
      ),
    );
  }

  Widget createContactItemWithHeader(int contactId) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            AppLocalizations.of(context).contacts,
            style: Theme.of(context).textTheme.headline,
          ),
          ContactItem(contactId, contactId.toString(), ContactItemType.forward, chatItemTapped),
        ],
      ),
    );
  }
}
