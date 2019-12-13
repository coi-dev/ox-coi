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
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/message/message_attachment_bloc.dart';
import 'package:ox_coi/src/message/message_attachment_event_state.dart';
import 'package:ox_coi/src/message/message_builder.dart';
import 'package:ox_coi/src/message/message_item_bloc.dart';
import 'package:ox_coi/src/message/message_item_event_state.dart';
import 'package:ox_coi/src/message/message_list_event_state.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/settings/settings_autocrypt_import.dart';
import 'package:ox_coi/src/share/share.dart';
import 'package:ox_coi/src/ui/custom_theme.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/clipboard.dart';
import 'package:ox_coi/src/utils/dialog_builder.dart';

import 'message_action.dart';
import 'message_list_bloc.dart';
import 'message_received.dart';
import 'message_sent.dart';
import 'message_special.dart';

class ChatMessageItem extends StatefulWidget {
  final int chatId;
  final int messageId;
  final int nextMessageId;
  final bool isGroupChat;
  final bool hasDateMarker;
  final bool isFlaggedView;

  ChatMessageItem(
      {@required this.chatId,
      @required this.messageId,
      @required this.nextMessageId,
      @required this.isGroupChat,
      @required this.hasDateMarker,
      this.isFlaggedView = false,
      key})
      : super(key: key);

  @override
  _ChatMessageItemState createState() => _ChatMessageItemState();
}

class _ChatMessageItemState extends State<ChatMessageItem> with AutomaticKeepAliveClientMixin<ChatMessageItem> {
  final List<MessageAction> _messageActions = <MessageAction>[
    MessageAction(title: L10n.get(L.messageActionForward), icon: IconSource.forward, messageActionTag: MessageActionTag.forward),
    MessageAction(title: L10n.get(L.messageActionCopy), icon: IconSource.contentCopy, messageActionTag: MessageActionTag.copy),
    MessageAction(title: L10n.get(L.messageActionDelete), icon: IconSource.delete, messageActionTag: MessageActionTag.delete),
    MessageAction(title: L10n.get(L.messageActionFlagUnflag), icon: IconSource.flag, messageActionTag: MessageActionTag.flag),
    MessageAction(title: L10n.get(L.messageActionShare), icon: IconSource.share, messageActionTag: MessageActionTag.share),
  ];

  final List<MessageAction> _messageAttachmentActions = <MessageAction>[
    MessageAction(title: L10n.get(L.messageActionForward), icon: IconSource.forward, messageActionTag: MessageActionTag.forward),
    MessageAction(title: L10n.get(L.messageActionDelete), icon: IconSource.delete, messageActionTag: MessageActionTag.delete),
    MessageAction(title: L10n.get(L.messageActionFlagUnflag), icon: IconSource.flag, messageActionTag: MessageActionTag.flag),
    MessageAction(title: L10n.get(L.messageActionShare), icon: IconSource.share, messageActionTag: MessageActionTag.share),
  ];

  final List<MessageAction> _messageErrorActions = <MessageAction>[
    MessageAction(title: L10n.get(L.messageActionInfo), icon: IconSource.info, messageActionTag: MessageActionTag.info),
    MessageAction(title: L10n.get(L.messageActionDeleteFailedMessage), icon: IconSource.delete, messageActionTag: MessageActionTag.delete),
  ];

  final List<MessageAction> _messagePendingActions = <MessageAction>[
    MessageAction(title: L10n.get(L.messageActionRetry), icon: IconSource.retry, messageActionTag: MessageActionTag.retry),
    MessageAction(title: L10n.get(L.messageActionDeleteFailedMessage), icon: IconSource.delete, messageActionTag: MessageActionTag.delete),
  ];

  MessageItemBloc _messageItemBloc = MessageItemBloc();
  // ignore: close_sinks
  MessageListBloc _messageListBloc = MessageListBloc();
  MessageAttachmentBloc _attachmentBloc = MessageAttachmentBloc();
  Navigation _navigation = Navigation();
  Offset tapDownPosition;

  @override
  void initState() {
    super.initState();
    _messageItemBloc
        .add(LoadMessage(chatId: widget.chatId, messageId: widget.messageId, nextMessageId: widget.nextMessageId, isGroupChat: widget.isGroupChat));
  }

  @override
  bool get wantKeepAlive => true;

  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider.value(
      value: _messageItemBloc,
      child: BlocBuilder<MessageItemBloc, MessageItemState>(
        bloc: _messageItemBloc,
        builder: (context, state) {
          if (state is MessageItemStateSuccess) {
            var messageStateData = state.messageStateData;
            Widget message;
            if (messageStateData.isInfo) {
              message = MessageInfo(messageStateData: messageStateData, useInformationText: false);
            } else if (messageStateData.isSetupMessage) {
              message = MessageSetup(messageStateData: messageStateData);
            } else if (messageStateData.isOutgoing) {
              message = MessageSent(messageStateData: messageStateData);
            } else {
              message = MessageReceived(messageStateData: messageStateData);
            }
            return Column(
              crossAxisAlignment: messageStateData.isOutgoing ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (widget.hasDateMarker || messageStateData.showTime)
                  Padding(
                    padding: EdgeInsets.only(bottom: messagesVerticalPadding),
                    child: MessageDateTime(
                      timestamp: messageStateData.timestamp,
                      hasDateMarker: widget.hasDateMarker,
                      showTime: messageStateData.showTime,
                    ),
                  ),
                if (!widget.isFlaggedView && messageStateData.encryptionStatusChanged)
                  Padding(
                    padding: EdgeInsets.only(bottom: messagesVerticalOuterPadding),
                    child: MessageInfo(
                        messageStateData: messageStateData,
                        useInformationText: true,
                        icon: AdaptiveIcon(
                          icon: IconSource.lock,
                          color: CustomTheme.of(context).onInfo,
                        )),
                  ),
                GestureDetector(
                  onTap: () => messageStateData.hasFile ? _onTap(messageStateData.isSetupMessage) : null,
                  onTapDown: _onTapDown,
                  onLongPress: () => _onLongPress(
                    hasFile: messageStateData.hasFile,
                    showLongPressMenu: !messageStateData.isSetupMessage,
                    text: messageStateData.text,
                    messageInfo: messageStateData.messageInfo,
                    isPending: messageStateData.state == ChatMsg.messageStatePending
                  ),
                  child: Container(
                    padding: EdgeInsets.only(bottom: messagesVerticalOuterPadding),
                    child: message,
                  ),
                ),
              ],
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  _onTap(bool isSetupMessage) {
    if (isSetupMessage) {
      _showAutocryptSetup();
    } else {
      _openTapAttachment();
    }
  }

  void _onTapDown(TapDownDetails details) {
    tapDownPosition = details.globalPosition;
  }

  void _openTapAttachment() {
    _attachmentBloc.add(RequestAttachment(chatId: widget.chatId, messageId: widget.messageId));
  }

  _onLongPress({bool hasFile, bool showLongPressMenu, String text, String messageInfo, bool isPending}) {
    if (!showLongPressMenu) {
      return;
    }
    _showMenu(hasFile, text, messageInfo, isPending);
  }

  void _showMenu(bool hasFile, String text, String messageInfo, bool isPending) {
    List<MessageAction> actions;
    if(hasFile && !isPending){
      actions = _messageAttachmentActions;
    }else if(messageInfo.isNotEmpty){
      actions = _messageErrorActions;
    }else if(isPending){
      actions = _messagePendingActions;
    }else{
      actions  = _messageActions;
    }
    showMenu(
            context: context,
            position: RelativeRect.fromLTRB(tapDownPosition.dx, tapDownPosition.dy, tapDownPosition.dx, tapDownPosition.dy),
            items: actions.map((MessageAction choice) {
              return PopupMenuItem<MessageAction>(
                value: choice,
                child: Row(
                  children: <Widget>[
                    AdaptiveIcon(icon: choice.icon),
                    Padding(padding: EdgeInsets.only(right: iconTextPadding)),
                    Text(choice.title),
                  ],
                ),
              );
            }).toList())
        .then((action) {
      if (action == null) {
        return;
      }
      switch (action.messageActionTag) {
        case MessageActionTag.forward:
          _navigation.push(
              context,
              MaterialPageRoute(
                builder: (context) => Share(msgIds: [widget.messageId], messageActionTag: action.messageActionTag),
              ));
          break;
        case MessageActionTag.copy:
          copyToClipboardWithToast(text: text, toastText: getDefaultCopyToastText(context));
          break;
        case MessageActionTag.delete:
          List<int> messageList = List();
          messageList.add(widget.messageId);
          _messageItemBloc.add(DeleteMessage(id: widget.messageId));
          break;
        case MessageActionTag.flag:
          _messageItemBloc.add(FlagUnflagMessage(id: widget.messageId));
          break;
        case MessageActionTag.share:
          _attachmentBloc.add(ShareAttachment(chatId: widget.chatId, messageId: widget.messageId));
          break;
        case MessageActionTag.retry:
            _messageListBloc.add(RetrySendingPendingMessages());
          break;
        case MessageActionTag.info:
          _showErrorDialog(messageInfo);
          break;
      }
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

  void _showErrorDialog(String messageInfo) {
    showInformationDialog(
      context: context,
      title: L10n.get(L.error),
      content: messageInfo,
      navigatable: Navigatable(Type.messageInfoDialog),
    );
  }
}
