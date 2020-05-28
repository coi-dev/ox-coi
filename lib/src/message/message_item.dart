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
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/extensions/numbers_apis.dart';
import 'package:ox_coi/src/extensions/string_ui.dart';
import 'package:ox_coi/src/gallery/gallery.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/message/message_attachment_bloc.dart';
import 'package:ox_coi/src/message/message_attachment_event_state.dart';
import 'package:ox_coi/src/message/message_builder.dart';
import 'package:ox_coi/src/message/message_item_bloc.dart';
import 'package:ox_coi/src/message/message_item_event_state.dart';
import 'package:ox_coi/src/message_list/message_list_event_state.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/settings/settings_autocrypt_import.dart';
import 'package:ox_coi/src/share/share.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/text_field_handling.dart';
import 'package:ox_coi/src/widgets/modal_builder.dart';

import '../message_list/message_list_bloc.dart';
import 'message_action.dart';
import 'message_received.dart';
import 'message_sent.dart';
import 'message_special.dart';

class MessageItem extends StatefulWidget {
  final int chatId;
  final int messageId;
  final int nextMessageId;
  final bool hasDateMarker;
  final bool isFlaggedView;

  MessageItem({
    @required this.chatId,
    @required this.messageId,
    @required this.nextMessageId,
    @required this.hasDateMarker,
    this.isFlaggedView = false,
    key,
  }) : super(key: key);

  @override
  _MessageItemState createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> with AutomaticKeepAliveClientMixin<MessageItem> {
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

  MessageItemBloc _messageItemBloc;
  final MessageAttachmentBloc _attachmentBloc = MessageAttachmentBloc();
  final Navigation _navigation = Navigation();
  Offset tapDownPosition;

  @override
  void initState() {
    super.initState();
    _messageItemBloc = MessageItemBloc(messageListBloc: BlocProvider.of<MessageListBloc>(context));
    _messageItemBloc.add(LoadMessage(
      chatId: widget.chatId,
      messageId: widget.messageId,
      nextMessageId: widget.nextMessageId,
    ));
  }

  @override
  void dispose() {
    _messageItemBloc.close();
    _attachmentBloc.close();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider.value(
      value: _messageItemBloc,
      child: BlocConsumer(
        bloc: _messageItemBloc,
        listener: (context, state) {
          if (state is MessageItemStateSuccess) {
            final messageStateData = state.messageStateData;
            if (messageStateData.state == ChatMsg.messageStateFailed) {
              final chatData = messageStateData.chatStateData;
              final messageDate = messageStateData.timestamp.getDateAndTimeFromTimestamp();
              showConfirmationDialog(
                  context: context,
                  title: L10n.get(L.error),
                  contentText: L10n.getFormatted(L.messageFailedDialogContentXY, [chatData.name, messageDate]),
                  positiveButton: L10n.get(L.messageActionDeleteMessage),
                  positiveAction: _deleteMessage,
                  negativeButton: L10n.get(L.cancel),
                  navigatable: Navigatable(Type.messageFailedDialog));
            }
          }
        },
        builder: (context, state) {
          if (state is MessageItemStateSuccess) {
            final messageStateData = state.messageStateData;

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
                    padding: const EdgeInsets.only(bottom: messagesVerticalPadding),
                    child: MessageDateTime(
                      timestamp: messageStateData.timestamp,
                      hasDateMarker: widget.hasDateMarker,
                      showTime: messageStateData.showTime,
                    ),
                  ),
                if (!widget.isFlaggedView && messageStateData.encryptionStatusChanged)
                  Padding(
                    padding: const EdgeInsets.only(bottom: messagesVerticalOuterPadding),
                    child: MessageInfo(
                        messageStateData: messageStateData,
                        useInformationText: true,
                        icon: AdaptiveIcon(
                          icon: IconSource.lock,
                          color: CustomTheme.of(context).onInfo,
                        )),
                  ),
                GestureDetector(
                  onTap: () => messageStateData.hasFile ? _onTap(messageStateData.isSetupMessage, messageStateData.attachmentStateData.type) : null,
                  onTapDown: _onTapDown,
                  onLongPress: () => _onLongPress(messageStateData),
                  child: Container(
                    padding: const EdgeInsets.only(bottom: messagesVerticalOuterPadding),
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

  _deleteMessage() => _messageItemBloc.add(DeleteMessage(id: widget.messageId));

  _onTap(bool isSetupMessage, int attachmentType) {
    if (isSetupMessage) {
      _showAutocryptSetup();
    } else {
      _openTapAttachment(attachmentType: attachmentType);
    }
  }

  void _onTapDown(TapDownDetails details) {
    tapDownPosition = details.globalPosition;
  }

  void _openTapAttachment({int attachmentType}) {
    if (attachmentType == ChatMsg.typeImage || attachmentType == ChatMsg.typeVideo || attachmentType == ChatMsg.typeGif) {
      _navigation.push(context, MaterialPageRoute(builder: (context) => Gallery(chatId: widget.chatId, messageId: widget.messageId)));
    } else {
      _attachmentBloc.add(RequestAttachment(chatId: widget.chatId, messageId: widget.messageId));
    }
  }

  _onLongPress(MessageStateData messageStateData) {
    final showLongPressMenu = !messageStateData.isSetupMessage && !messageStateData.isInfo;
    if (!showLongPressMenu) {
      return;
    }

    final hasFile = messageStateData.hasFile;
    final hasError = messageStateData.state == ChatMsg.messageStateFailed;
    final text = messageStateData.text;
    final messageInfo = messageStateData.messageInfo;
    final isPending = messageStateData.state == ChatMsg.messageStatePending;
    List<MessageAction> actions;
    if (hasError) {
      actions = _messageErrorActions;
    } else if (isPending) {
      actions = _messagePendingActions;
    } else if (hasFile) {
      actions = _messageAttachmentActions;
    } else {
      actions = _messageActions;
    }
    resetGlobalFocus(context);
    showMenu(
            context: context,
            position: RelativeRect.fromLTRB(tapDownPosition.dx, tapDownPosition.dy, tapDownPosition.dx, tapDownPosition.dy),
            items: actions.map((MessageAction choice) {
              return PopupMenuItem<MessageAction>(
                value: choice,
                child: Row(
                  children: <Widget>[
                    AdaptiveIcon(icon: choice.icon),
                    Padding(padding: const EdgeInsets.only(right: iconTextPadding)),
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
          text.copyToClipboardWithToast(toastText: getDefaultCopyToastText(context));
          break;
        case MessageActionTag.delete:
          _deleteMessage();
          break;
        case MessageActionTag.flag:
          _messageItemBloc.add(FlagUnflagMessage(id: widget.messageId));
          break;
        case MessageActionTag.share:
          _attachmentBloc.add(ShareAttachment(chatId: widget.chatId, messageId: widget.messageId));
          break;
        case MessageActionTag.retry:
          BlocProvider.of<MessageListBloc>(context).add(RetrySendPendingMessages());
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
      contentText: messageInfo ?? "",
      navigatable: Navigatable(Type.messageInfoDialog),
    );
  }
}
