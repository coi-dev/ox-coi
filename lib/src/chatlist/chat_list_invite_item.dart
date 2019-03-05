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
import 'package:ox_talk/src/chat/change_chat_bloc.dart';
import 'package:ox_talk/src/chat/change_chat_event.dart';
import 'package:ox_talk/src/chat/change_chat_state.dart';
import 'package:ox_talk/src/chat/chat.dart';
import 'package:ox_talk/src/contact/contact_change_bloc.dart';
import 'package:ox_talk/src/contact/contact_change_event.dart';
import 'package:ox_talk/src/l10n/localizations.dart';
import 'package:ox_talk/src/message/message_change_bloc.dart';
import 'package:ox_talk/src/message/message_change_event.dart';
import 'package:ox_talk/src/message/message_change_state.dart';
import 'package:ox_talk/src/message/message_item_bloc.dart';
import 'package:ox_talk/src/message/message_item_event.dart';
import 'package:ox_talk/src/message/message_item_state.dart';
import 'package:ox_talk/src/utils/colors.dart';
import 'package:ox_talk/src/widgets/avatar_list_item.dart';
import 'package:rxdart/rxdart.dart';

class ChatListInviteItem extends StatefulWidget {
  final int _chatId;
  final int _messageId;

  ChatListInviteItem(this._chatId, this._messageId, key) : super(key: Key(key));

  @override
  _ChatListInviteItemState createState() => _ChatListInviteItemState();
}

class _ChatListInviteItemState extends State<ChatListInviteItem> {
  MessageItemBloc _messageItemBloc = MessageItemBloc();
  int _contactId;

  @override
  void initState() {
    super.initState();
    _messageItemBloc.dispatch(RequestMessage(widget._chatId, widget._messageId, false));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _messageItemBloc,
      builder: (context, state) {
        String name;
        String subTitle;
        Color color;
        if (state is MessageItemStateSuccess) {
          var contactWrapper = state.contactWrapper;
          _contactId = contactWrapper.contactId;
          name = contactWrapper.contactAddress;
          subTitle = state.messageText;
          color = avatarDefaultBackground;
        } else {
          name = "";
          subTitle = "";
        }
        return AvatarListItem(
          title: name,
          subTitle: subTitle,
          color: color,
          onTap: inviteItemTapped,
        );
      },
    );
  }

  inviteItemTapped(String name, String message) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context).createChatWith(name)),
            content: new Text(message),
            actions: <Widget>[
              new FlatButton(
                child: new Text(AppLocalizations.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text(AppLocalizations.of(context).block),
                onPressed: () {
                  blockUser();
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text(AppLocalizations.of(context).yes),
                onPressed: () {
                  createChat();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void createChat() async {
    ChangeChatBloc createChatBloc = ChangeChatBloc();
    final changeChatStatesObservable = new Observable<ChangeChatState>(createChatBloc.state);
    changeChatStatesObservable.listen((state) => _handleChangeChatStateChange(state));
    createChatBloc.dispatch(CreateChat(messageId: widget._messageId, chatId: widget._chatId));
  }

  _handleChangeChatStateChange(ChangeChatState state) {
    if (state is CreateChatStateSuccess) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(state.chatId)));
    }
  }

  void blockUser() {
    MessageChangeBloc messageChangeBloc = MessageChangeBloc();
    messageChangeBloc.dispatch(DeleteMessage(widget._chatId, widget._messageId));
    final messageChangeStatesObservable = new Observable<MessageChangeState>(messageChangeBloc.state);
    messageChangeStatesObservable.listen((state) => _handleMessageChangeStateChange(state));
  }

  _handleMessageChangeStateChange(MessageChangeState state) {
    if (state is MessageChangeStateSuccess) {
      ContactChangeBloc contactChangeBloc = ContactChangeBloc();
      contactChangeBloc.dispatch(BlockContact(_contactId));
    }
  }
}
