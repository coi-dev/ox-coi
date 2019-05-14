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

import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/l10n/localizations.dart';
import 'package:ox_coi/src/message/message_attachment_bloc.dart';
import 'package:ox_coi/src/message/message_attachment_event.dart';
import 'package:ox_coi/src/message/message_item_bloc.dart';
import 'package:ox_coi/src/message/message_item_event.dart';
import 'package:ox_coi/src/message/message_item_state.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/share/share.dart';
import 'package:ox_coi/src/utils/colors.dart';
import 'package:ox_coi/src/utils/conversion.dart';
import 'package:ox_coi/src/utils/date.dart';
import 'package:ox_coi/src/utils/dimensions.dart';
import 'package:ox_coi/src/utils/styles.dart';
import 'package:ox_coi/src/utils/toast.dart';
import 'package:ox_coi/src/widgets/avatar.dart';

const List<MessageAction> messageActions = const <MessageAction>[
  const MessageAction(title: 'Forward', icon: Icons.forward, messageActionTag: MessageActionTag.forward),
  const MessageAction(title: 'Copy', icon: Icons.content_copy, messageActionTag: MessageActionTag.copy),
];

const List<MessageAction> messageAttachmentActions = const <MessageAction>[
  const MessageAction(title: 'Forward', icon: Icons.forward, messageActionTag: MessageActionTag.forward),
];

enum MessageActionTag {
  forward,
  copy,
  delete
}

class ChatMessageItem extends StatefulWidget {
  final int _chatId;
  final int _messageId;
  final bool _isGroupChat;
  final bool _hasDateMarker;

  ChatMessageItem(this._chatId, this._messageId, this._isGroupChat, this._hasDateMarker, key) : super(key: Key(key));

  @override
  _ChatMessageItemState createState() => _ChatMessageItemState();
}

class _ChatMessageItemState extends State<ChatMessageItem> with AutomaticKeepAliveClientMixin<ChatMessageItem> {
  MessageItemBloc _messagesBloc = MessageItemBloc();
  MessageAttachmentBloc _attachmentBloc = MessageAttachmentBloc();
  Navigation _navigation = Navigation();
  String _message = "";
  Offset tapDownPosition;
  bool _hasFile;

  void _selectMessageAction(MessageAction messageAction) {
    List<int> msgIds = List();
    msgIds.add(widget._messageId);
    switch(messageAction.messageActionTag){
      case MessageActionTag.forward:
        _navigation.pop(context);
        _navigation.push(context, MaterialPageRoute(builder: (context) => ShareScreen(msgIds, messageAction.messageActionTag)));
        break;
      case MessageActionTag.copy:
        var clipboardData = ClipboardData(text: _message);
        Clipboard.setData(clipboardData);
        String clipboardToast = AppLocalizations.of(context).copiedToClipboard;
        showToast(clipboardToast);
        _navigation.pop(context);
        break;
      case MessageActionTag.delete:
        _navigation.pop(context);
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _messagesBloc.dispatch(RequestMessage(widget._chatId, widget._messageId, widget._isGroupChat));
  }

  @override
  bool get wantKeepAlive => true;

  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _messagesBloc,
      builder: (context, state) {
        if (state is MessageItemStateSuccess) {
          _hasFile = state.hasFile;
          _message = state.messageText;
          return Column(
            crossAxisAlignment: state.messageIsOutgoing ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: buildMessageAndMarker(state),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  List<Widget> buildMessageAndMarker(MessageItemStateSuccess state) {
    List<Widget> widgets = List();
    if (widget._hasDateMarker) {
      String date = getDateFormTimestamp(state.messageTimestamp, true, true, context);
      widgets.add(
        Center(
          child: Text(
        date,
        style: messageListDateSeparator,
      )));
    }
    widgets.add(
      GestureDetector(
        onTap: !state.hasFile ? _onTap : null,
        onTapDown: _onTapDown,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: messagesVerticalPadding),
          child: state.messageIsOutgoing
            ? buildSentMessage(state)
            : buildReceivedMessage(
            widget._isGroupChat,
            state,
          ),
        ),
    ));
    return widgets;
  }

  void _onTapDown(TapDownDetails details){
    tapDownPosition = details.globalPosition;
  }

  _onTap(){
    _showMenu();
  }

  _onLongPress(){
    _showMenu();
  }

  void _showMenu(){
    List<MessageAction> actions = _hasFile ? messageAttachmentActions : messageActions;
    showMenu(
        context: context,
        position: RelativeRect.fromLTRB(tapDownPosition.dx, tapDownPosition.dy, tapDownPosition.dx, tapDownPosition.dy),
        items: actions.map((MessageAction choice) {
          return PopupMenuItem<MessageAction>(
              value: choice,
              child: InkWell(
                onTap: () => _selectMessageAction(choice),
                child: Row(
                  children: <Widget>[
                    Icon(choice.icon),
                    Padding(padding: EdgeInsets.only(right: iconTextPadding)),
                    Text(choice.title),
                  ],
                ),
              )
          );
        }).toList()
    );
  }

  Widget buildSentMessage(MessageItemStateSuccess state) {
    String text = state.messageText;
    String time = getTimeFormTimestamp(state.messageTimestamp);
    bool hasFile = state.hasFile;
    return FractionallySizedBox(
        alignment: Alignment.topRight,
        widthFactor: 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              decoration: buildSenderBoxDecoration(messageSentBackground),
              child: Padding(
                padding: EdgeInsets.all(messagesInnerPadding),
                child: hasFile ? buildAttachmentMessage(state.attachmentWrapper, text, time) : buildTextMessage(text, time),
              ),
            ),
          ],
        ));
  }

  BoxDecoration buildSenderBoxDecoration(Color color) {
    return BoxDecoration(
        shape: BoxShape.rectangle,
        boxShadow: [
          new BoxShadow(
            color: messageBoxGrey,
            blurRadius: messagesBlurRadius,
          ),
        ],
        color: color,
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(messagesBoxRadius),
            bottomLeft: Radius.circular(messagesBoxRadius),
            topLeft: Radius.circular(messagesBoxRadius)));
  }

  BoxDecoration buildReceiverBoxDecoration(Color color) {
    return BoxDecoration(
        shape: BoxShape.rectangle,
        boxShadow: [
          new BoxShadow(
            color: messageBoxGrey,
            blurRadius: messagesBlurRadius,
          ),
        ],
        color: color,
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(messagesBoxRadius),
            bottomRight: Radius.circular(messagesBoxRadius),
            bottomLeft: Radius.circular(messagesBoxRadius)));
  }

  Widget buildAttachmentMessage(AttachmentWrapper attachment, String text, String time) {
    return GestureDetector(
      onLongPress: () => _onLongPress(),
      onTap: _openAttachment,
      child: attachment.type == ChatMsg.typeImage
          ? buildImageAttachmentMessage(attachment, text, time)
          : buildGenericAttachmentMessage(attachment, time),
    );
  }

  Row buildGenericAttachmentMessage(AttachmentWrapper attachment, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.attach_file,
          size: messagesFileIconSize,
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                attachment.filename,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
              Text(byteToPrintableSize(attachment.size)),
            ],
          ),
        ),
        Padding(padding: EdgeInsets.only(left: messagesContentTimePadding)),
        buildTime(time),
      ],
    );
  }

  Widget buildImageAttachmentMessage(AttachmentWrapper attachment, String text, String time) {
    File file = File(attachment.path);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image.file(file),
        text.isNotEmpty ? Padding(padding: EdgeInsets.only(top: messagesContentTimePadding)) : Container(),
        text.isNotEmpty
            ? Flexible(
                child: Text(text),
              )
            : Container(),
        Padding(padding: EdgeInsets.only(top: messagesContentTimePadding)),
        buildTime(time),
      ],
    );
  }

  Widget buildTextMessage(String text, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: Text(
            text,
            style: defaultText,
          ),
        ),
        Padding(padding: EdgeInsets.only(left: messagesContentTimePadding)),
        buildTime(time),
      ],
    );
  }

  StatelessWidget buildTime(String time) {
    return Text(time, style: messageTimeText);
  }

  Widget buildReceivedMessage(bool isGroupChat, MessageItemStateSuccess state) {
    ContactWrapper contactWrapper = state.contactWrapper;
    String name;
    String email;
    Color color;
    if (contactWrapper != null) {
      name = contactWrapper.contactName;
      email = contactWrapper.contactAddress;
      color = contactWrapper.contactColor;
    }
    String text = state.messageText;
    String time = getTimeFormTimestamp(state.messageTimestamp);
    bool hasFile = state.hasFile;
    return FractionallySizedBox(
      alignment: Alignment.topLeft,
      widthFactor: 0.8,
      child: Row(
        children: <Widget>[
          isGroupChat
              ? Padding(
                  padding: const EdgeInsets.only(right: messagesInnerPadding),
                  child: Avatar(
                    initials: getInitials(name, email),
                    color: color,
                  ),
                )
              : Container(),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(messagesInnerPadding),
              decoration: buildReceiverBoxDecoration(messageReceivedBackground),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  isGroupChat
                      ? Text(
                          name,
                          style: TextStyle(color: color),
                        )
                      : Container(
                          constraints: BoxConstraints(maxWidth: zero),
                        ),
                  hasFile ? buildAttachmentMessage(state.attachmentWrapper, text, time) : buildTextMessage(text, time),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getInitials(String name, String email) {
    if (name != null && name.isNotEmpty) {
      return name.substring(0, 1);
    }
    if (email != null && email.isNotEmpty) {
      return email.substring(0, 1);
    }
    return "";
  }

  void _openAttachment() {
    _attachmentBloc.dispatch(RequestAttachment(widget._chatId, widget._messageId));
  }
}

class MessageAction {
  final String title;
  final IconData icon;
  final MessageActionTag messageActionTag;
  const MessageAction({this.title, this.icon, this.messageActionTag});
}
