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
import 'package:ox_coi/src/message/message_attachment_bloc.dart';
import 'package:ox_coi/src/message/message_attachment_event_state.dart';
import 'package:ox_coi/src/message/message_builder.dart';
import 'package:ox_coi/src/message/message_item_bloc.dart';
import 'package:ox_coi/src/message/message_item_event_state.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/settings/settings_autocrypt_import.dart';
import 'package:ox_coi/src/share/share.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/clipboard.dart';

import 'message_action.dart';
import 'message_change_bloc.dart';
import 'message_change_event_state.dart';
import 'message_received.dart';
import 'message_sent.dart';
import 'message_special.dart';

class ChatMessageItem extends StatefulWidget {
  final int chatId;
  final int messageId;
  final int nextMessageId;
  final bool isGroupChat;
  final bool hasDateMarker;
  final bool flaggedView;

  ChatMessageItem(
      {@required this.chatId,
      @required this.messageId,
      @required this.nextMessageId,
      @required this.isGroupChat,
      @required this.hasDateMarker,
      this.flaggedView = false,
      key})
      : super(key: key);

  @override
  _ChatMessageItemState createState() => _ChatMessageItemState();
}

class _ChatMessageItemState extends State<ChatMessageItem> with AutomaticKeepAliveClientMixin<ChatMessageItem> {
  final List<MessageAction> _messageActions = const <MessageAction>[
    const MessageAction(title: 'Forward', icon: Icons.forward, messageActionTag: MessageActionTag.forward),
    const MessageAction(title: 'Copy', icon: Icons.content_copy, messageActionTag: MessageActionTag.copy),
    const MessageAction(title: 'Delete locally', icon: Icons.delete, messageActionTag: MessageActionTag.delete),
    const MessageAction(title: 'Flag/Unflag', icon: Icons.star, messageActionTag: MessageActionTag.flag),
    const MessageAction(title: 'Share', icon: Icons.share, messageActionTag: MessageActionTag.share),
  ];

  final List<MessageAction> _messageAttachmentActions = const <MessageAction>[
    const MessageAction(title: 'Forward', icon: Icons.forward, messageActionTag: MessageActionTag.forward),
    const MessageAction(title: 'Delete locally', icon: Icons.delete, messageActionTag: MessageActionTag.delete),
    const MessageAction(title: 'Flag/Unflag', icon: Icons.star, messageActionTag: MessageActionTag.flag),
    const MessageAction(title: 'Share', icon: Icons.share, messageActionTag: MessageActionTag.share),
  ];

  MessageItemBloc _messageBloc = MessageItemBloc();
  MessageAttachmentBloc _attachmentBloc = MessageAttachmentBloc();
  MessageChangeBloc _messageChangeBloc = MessageChangeBloc();
  Navigation _navigation = Navigation();
  String _message = "";
  Offset tapDownPosition;
  bool _hasFile;
  bool _isStarred = false;

  void _selectMessageAction(MessageAction messageAction) {
    if (messageAction == null) {
      return;
    }
    List<int> msgIds = List();
    msgIds.add(widget.messageId);
    switch (messageAction.messageActionTag) {
      case MessageActionTag.forward:
        _navigation.push(context, MaterialPageRoute(builder: (context) => Share(msgIds: msgIds, messageActionTag: messageAction.messageActionTag)));
        break;
      case MessageActionTag.copy:
        copyToClipboardWithToast(text: _message, toastText: getDefaultCopyToastText(context));
        break;
      case MessageActionTag.delete:
        List<int> messageList = List();
        messageList.add(widget.messageId);
        _messageBloc.dispatch(DeleteMessages(messageIds: messageList));
        break;
      case MessageActionTag.flag:
        _messageChangeBloc.dispatch(FlagMessages(chatId: widget.chatId, messageIds: msgIds, star: _isStarred));
        break;
      case MessageActionTag.share:
        _attachmentBloc.dispatch(ShareAttachment(chatId: widget.chatId, messageId: widget.messageId));
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _messageBloc.dispatch(
        RequestMessage(chatId: widget.chatId, messageId: widget.messageId, nextMessageId: widget.nextMessageId, isGroupChat: widget.isGroupChat));
  }

  @override
  bool get wantKeepAlive => true;

  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder(
      bloc: _messageBloc,
      builder: (context, state) {
        if (state is MessageItemStateSuccess) {
          _hasFile = state.hasFile;
          _message = state.messageText;
          _isStarred = state.isStarred;
          String name = state.contactWrapper?.contactName;
          String email = state.contactWrapper?.contactAddress;
          Color color = state.contactWrapper?.contactColor;
          return Column(
            crossAxisAlignment: state.messageIsOutgoing ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (widget.hasDateMarker || state.showTime)
                Padding(
                  padding: EdgeInsets.only(bottom: messagesVerticalPadding),
                  child: MessageDateTime(
                    timestamp: state.messageTimestamp,
                    hasDateMarker: widget.hasDateMarker,
                    showTime: state.showTime,
                  ),
                ),
              if (!widget.flaggedView && state.encryptionStatusChanged)
                Padding(
                  padding: EdgeInsets.only(bottom: messagesVerticalOuterPadding),
                  child: MessageSpecial(type: MessageSpecialType.encryptionStatusChanged),
                ),
              GestureDetector(
                onTap: () => _onTap(state.hasFile, state.isSetupMessage),
                onTapDown: _onTapDown,
                onLongPress: () => _onLongPress(state.hasFile, state.isSetupMessage),
                child: Container(
                  padding: EdgeInsets.only(bottom: messagesVerticalOuterPadding),
                  child: buildMessage(state, name, email, color),
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

  Widget buildMessage(MessageItemStateSuccess state, String name, String email, Color color) {
    Widget message;
    bool isFlagged = state.isStarred;
    if (state.isInfo) {
      message = MessageSpecial(
        type: MessageSpecialType.info,
        messageText: state.messageText,
        timestamp: state.messageTimestamp,
      );
    } else if (state.isSetupMessage) {
      message = MessageSpecial(
        type: MessageSpecialType.setup,
        timestamp: state.messageTimestamp,
      );
    } else if (state.messageIsOutgoing) {
      message = MessageSent(
        text: state.messageText,
        timestamp: state.messageTimestamp,
        hasFile: state.hasFile,
        msgState: state.state,
        attachmentWrapper: state.attachmentWrapper,
        isFlagged: isFlagged,
      );
    } else {
      message = MessageReceived(
        text: state.messageText,
        timestamp: state.messageTimestamp,
        hasFile: state.hasFile,
        attachmentWrapper: state.attachmentWrapper,
        name: name,
        email: email,
        color: color,
        isGroupChat: widget.isGroupChat,
        isFlagged: isFlagged,
      );
    }
    return message;
  }

  _onTap(bool hasFile, bool isSetupMessage) {
    if (isSetupMessage) {
      _showAutocryptSetup();
    } else if (hasFile) {
      _openTapAttachment();
    }
  }

  void _onTapDown(TapDownDetails details) {
    tapDownPosition = details.globalPosition;
  }

  void _openTapAttachment() {
    _attachmentBloc.dispatch(RequestAttachment(chatId: widget.chatId, messageId: widget.messageId));
  }

  _onLongPress(bool hasFile, bool isSetupMessage) {
    if (!isSetupMessage) {
      _showMenu();
    }
  }

  void _showMenu() {
    List<MessageAction> actions = _hasFile ? _messageAttachmentActions : _messageActions;
    showMenu(
            context: context,
            position: RelativeRect.fromLTRB(tapDownPosition.dx, tapDownPosition.dy, tapDownPosition.dx, tapDownPosition.dy),
            items: actions.map((MessageAction choice) {
              return PopupMenuItem<MessageAction>(
                value: choice,
                child: Row(
                  children: <Widget>[
                    Icon(choice.icon),
                    Padding(padding: EdgeInsets.only(right: iconTextPadding)),
                    Text(choice.title),
                  ],
                ),
              );
            }).toList())
        .then((action) {
      _selectMessageAction(action);
    });
  }

  void _showAutocryptSetup() {
    _navigation.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsAutocryptImport(
          chatId: widget.chatId,
          messageId: widget.messageId,
        ),
      ),
    );
  }
}
