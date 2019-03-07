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
import 'package:ox_talk/main.dart';
import 'package:ox_talk/src/base/base_root_child.dart';
import 'package:ox_talk/src/chatlist/chat_list_bloc.dart';
import 'package:ox_talk/src/chatlist/chat_list_event.dart';
import 'package:ox_talk/src/chatlist/chat_list_invite_item.dart';
import 'package:ox_talk/src/chatlist/chat_list_item.dart';
import 'package:ox_talk/src/chatlist/chat_list_state.dart';
import 'package:ox_talk/src/l10n/localizations.dart';
import 'package:ox_talk/src/utils/colors.dart';
import 'package:ox_talk/src/utils/dimensions.dart';
import 'package:ox_talk/src/navigation/navigation.dart';

class ChatListView extends BaseRootChild {
  _ChatListState createState() => _ChatListState();
  final Navigation navigation = Navigation();

  @override
  Color getColor() {
    return chatMain;
  }

  @override
  FloatingActionButton getFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      child: new Icon(Icons.create),
      onPressed: () {
        _showCreateChatView(context);
      },
    );
  }

  _showCreateChatView(BuildContext context) {
    navigation.pushNamed(context, Navigation.ROUTES_CHAT_CREATE);
  }

  @override
  String getTitle(BuildContext context) {
    return AppLocalizations.of(context).chatTitle;
  }

  @override
  String getNavigationText(BuildContext context) {
    return AppLocalizations.of(context).chatTitle;
  }

  @override
  IconData getNavigationIcon() {
    return Icons.chat;
  }
}

class _ChatListState extends State<ChatListView> {
  ChatListBloc _chatListBloc = ChatListBloc();

  @override
  void initState() {
    super.initState();
    _chatListBloc.dispatch(RequestChatList());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _chatListBloc,
      builder: (context, state) {
        if (state is ChatListStateSuccess) {
          return buildListViewItems(state.chatIds, state.chatLastUpdateValues, state.messageIds, state.messagesLastUpdateValues);
        } else if (state is! ChatListStateFailure) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Icon(Icons.error);
        }
      },
    );
  }

  Widget buildListViewItems(List<int> chatIds, List<int> chatLastUpdateValues, List<int> messageIds, List<int> messagesLastUpdateValues) {
    return ListView.builder(
      padding: EdgeInsets.all(listItemPadding),
      itemCount: messageIds != null ? chatIds.length + messageIds.length : chatIds.length,
      itemBuilder: (BuildContext context, int index) {
        if (messageIds != null) {
          if (index < messageIds.length) {
            var messageId = messageIds[index];
            var key = "$messageId-${messagesLastUpdateValues[index]}";
            return buildInviteItem(index, messageId, key);
          } else {
            return buildChatListItem(messageIds, index, chatIds, chatLastUpdateValues);
          }
        } else {
          var chatId = chatIds[index];
          var key = "$chatId-${chatLastUpdateValues[index]}";
          return ChatListItem(chatId, key);
        }
      },
    );
  }

  Widget buildInviteItem(int index, int messageId, String key) {
    if (index == 0) {
      return Column(
        children: <Widget>[
          createHeader(invite: true),
          ChatListInviteItem(1, messageId, key),
        ],
      );
    } else {
      return ChatListInviteItem(1, messageId, key);
    }
  }

  Widget createHeader({bool invite = false, bool chats = false}) {
    if (invite) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: listItemHeaderPadding),
        child: Text(AppLocalizations.of(context).chatListInviteHeader),
      );
    } else if (chats) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: listItemHeaderPadding),
        child: Text(AppLocalizations.of(context).chatListChatsHeader),
      );
    } else {
      return Container();
    }
  }

  Widget buildChatListItem(List<int> messageIds, int index, List<int> chatIds, List<int> chatLastUpdateValues) {
    var newIndex = messageIds != null ? index - messageIds.length : index;
    var chatId = chatIds[newIndex];
    var key = "$chatId-${chatLastUpdateValues[newIndex]}";
    if (index == messageIds.length && index != 0) {
      return Column(
        children: <Widget>[
          createHeader(chats: true),
          ChatListItem(chatId, key),
        ],
      );
    } else {
      return ChatListItem(chatId, key);
    }
  }
}
