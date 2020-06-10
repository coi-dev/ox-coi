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

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:ox_coi/src/contact/contact_item_event_state.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/extensions/color_apis.dart';
import 'package:ox_coi/src/extensions/numbers_apis.dart';
import 'package:ox_coi/src/extensions/string_linkpreview.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/message/message_item_event_state.dart';
import 'package:ox_coi/src/message_list/message_list_event_state.dart';
import 'package:ox_coi/src/utils/url_preview_cache.dart';

import '../message_list/message_list_bloc.dart';

class MessageItemBloc extends Bloc<MessageItemEvent, MessageItemState> {
  final _logger = Logger("message_item_bloc");

  final Repository<Contact> _contactRepository = RepositoryManager.get(RepositoryType.contact);
  final Repository<Chat> _chatRepository = RepositoryManager.get(RepositoryType.chat);
  final MessageListBloc messageListBloc;

  Stream _messageChangedStream;
  StreamSubscription _messageChangedSubscription;
  StreamSubscription _messageListBlocSubscription;
  Repository<ChatMsg> _messageListRepository;
  int _messageId;
  int _contactId;
  bool _listenersRegistered = false;

  MessageItemBloc({this.messageListBloc}) {
    final listensToMessageChanges = messageListBloc != null;
    if (listensToMessageChanges) {
      _messageListBlocSubscription = messageListBloc.listen((state) {
        if (state is MessageListStateSuccess) {
          _messageChangedStream ??= state.messageChangedStream;
        }
      });
    }
  }

  @override
  MessageItemState get initialState => MessageItemStateInitial();

  @override
  Stream<MessageItemState> mapEventToState(MessageItemEvent event) async* {
    if (event is LoadMessage) {
      yield* _loadMessage(event);
    } else if (event is DeleteMessage) {
      yield* _deleteMessages(event.id);
    } else if (event is FlagUnflagMessage) {
      yield* _flagUnflagMessage(event.id);
    } else if (event is MessageUpdated) {
      yield MessageItemStateSuccess(messageStateData: event.messageStateData);
    }
  }

  @override
  Future<void> close() {
    _unregisterListeners();
    return super.close();
  }

  Stream<MessageItemState> _loadMessage(LoadMessage event) async* {
    try {
      final chatId = event.chatId;
      _messageListRepository = RepositoryManager.get(RepositoryType.chatMessage, chatId);
      _messageId = event.messageId;
      final nextMessageId = event.nextMessageId;
      bool isGroup;
      if (Chat.typeInvite == chatId) {
        isGroup = false;
      } else if (Chat.typeStarred == chatId) {
        isGroup = true;
      } else {
        final chatRepository = RepositoryManager.get(RepositoryType.chat);
        Chat chat = chatRepository.get(chatId);
        isGroup = await chat.isGroupAsync();
      }

      final showContact = isGroup || Chat.typeInvite == chatId;
      if (showContact) {
        await _setupContact();
      }
      if (nextMessageId != null) {
        await _setupNextMessage(nextMessageId);
      }
      await _setupMessage();

      ChatMsg message = _getMessage(messageId: _messageId);
      final isOutgoing = await message.isOutgoingAsync();
      final state = await message.getStateAsync();
      bool showTime = await _showTime(nextMessageId);
      bool encryptionStatusChanged = await _hasEncryptionStatusChanged(nextMessageId);
      bool hasFile = await message.hasFileAsync();
      bool isSetupMessage = await message.isSetupMessageAsync();
      String text = await message.getTextAsync();
      bool isForwarded = await message.isForwardedAsync();
      String informationText;
      if (isSetupMessage) {
        informationText = L10n.get(L.autocryptChatMessagePlaceholder);
      } else if (encryptionStatusChanged) {
        informationText = L10n.get(L.chatEncryptionStatusChanged);
      }

      final isInfo = await message.isInfoAsync();
      final timestamp = await message.getTimestampAsync();
      final showPadlock = await message.showPadlockAsync();
      final isFlagged = await message.isStarredAsync();
      final teaser = await message.getSummaryTextAsync(200);

      String messageInfo = "";
      ChatStateData chatStateData;
      if (state == ChatMsg.messageStateFailed) {
        final context = Context();
        messageInfo = await context.getMessageInfoAsync(_messageId);
        chatStateData = await _getChatDataAsync();
      }

      AttachmentStateData attachmentStateData;
      if (hasFile) {
        attachmentStateData = AttachmentStateData(
          duration: await message.getDurationAsync(),
          filename: await message.getFileNameAsync(),
          path: await message.getFileAsync(),
          mimeType: await message.getFileMimeAsync(),
          size: await message.getFileBytesAsync(),
          type: await message.getTypeAsync(),
        );
      }

      ContactStateData contactStateData;
      if (showContact) {
        contactStateData = await _getContactDataAsync();
      }

      // Load possible URL preview data
      Metadata urlPreviewData = await UrlPreviewCache().getMetadataFor(uri: text.previewUri);

      final messageStateData = MessageStateData(
        isOutgoing: isOutgoing,
        text: text,
        informationText: informationText,
        hasFile: hasFile,
        isSetupMessage: isSetupMessage,
        isInfo: isInfo,
        timestamp: timestamp,
        state: state,
        showPadlock: showPadlock,
        attachmentStateData: attachmentStateData,
        contactStateData: contactStateData,
        chatStateData: chatStateData,
        preview: teaser,
        isFlagged: isFlagged,
        showTime: showTime,
        encryptionStatusChanged: encryptionStatusChanged,
        isGroup: isGroup,
        isForwarded: isForwarded,
        messageInfo: messageInfo,
        urlPreviewData: urlPreviewData,
      );
      yield MessageItemStateSuccess(messageStateData: messageStateData);
      _registerListeners();
    } catch (error) {
      _logger.warning(error.toString());
      yield MessageItemStateFailure(error: error.toString());
    }
  }

  Future<ContactStateData> _getContactDataAsync() async {
    final contact = _getContact();
    final contactId = contact.id;
    final contactName = await contact.getNameAsync();
    final contactAddress = await contact.getAddressAsync();
    final contactColor = colorFromArgb(await contact.getColorAsync());

    ContactStateData contactStateData = ContactStateData(
      id: contactId,
      name: contactName,
      email: contactAddress,
      color: contactColor,
    );
    return contactStateData;
  }

  Future<ChatStateData> _getChatDataAsync() async {
    final ChatMsg message = _getMessage(messageId: _messageId);
    final chatId = await message.getChatIdAsync();
    final chat = _chatRepository.get(chatId);
    final chatName = await chat.getNameAsync();
    return ChatStateData(
      id: chatId,
      name: chatName,
    );
  }

  Stream<MessageItemState> _deleteMessages(int id) async* {
    final context = Context();
    final messageIds = [id];

    _messageListRepository.remove(ids: messageIds);
    await context.deleteMessagesAsync(messageIds);
    yield MessageItemStateSuccess(messageStateData: null);
  }

  Stream<MessageItemState> _flagUnflagMessage(int messageId) async* {
    if (state is MessageItemStateSuccess) {
      final successState = state as MessageItemStateSuccess;
      final isFlagged = !successState.messageStateData.isFlagged;
      final context = Context();
      final int nonSpecialChatId = await _messageListRepository.get(messageId).getChatIdAsync();
      final Repository<ChatMsg> nonSpecialMessageListRepository = RepositoryManager.get(RepositoryType.chatMessage, nonSpecialChatId);
      final message = nonSpecialMessageListRepository.get(messageId);

      message?.set(ChatMsg.methodMessageIsStarred, isFlagged);
      Repository<ChatMsg> _flaggedRepository = RepositoryManager.get(RepositoryType.chatMessage, Chat.typeStarred);

      if (isFlagged) {
        _flaggedRepository.putIfAbsent(id: messageId);
      } else {
        _flaggedRepository.remove(id: messageId);
      }

      await context.starMessagesAsync([messageId], (isFlagged ? Context.starMessage : Context.unstarMessage));
      final messageStateData = (state as MessageItemStateSuccess).messageStateData.copyWith(isFlagged: isFlagged);
      yield MessageItemStateSuccess(messageStateData: messageStateData);
    }
  }

  void _registerListeners() {
    if (!_listenersRegistered) {
      _listenersRegistered = true;
      _messageChangedSubscription ??= _messageChangedStream?.listen(_onMessageStateChanged);
    }
  }

  void _unregisterListeners() {
    if (_listenersRegistered) {
      _listenersRegistered = false;
      _messageListBlocSubscription?.cancel();
      _messageChangedSubscription?.cancel();
    }
  }

  void _onMessageStateChanged(event) async {
    final eventMessageId = event.data2;
    if (_messageId == eventMessageId) {
      if (event.hasType(Event.msgDelivered) || event.hasType(Event.msgRead)) {
        if (state is MessageItemStateSuccess) {
          final eventMessageState = event.hasType(Event.msgDelivered) ? ChatMsg.messageStateDelivered : ChatMsg.messageStateReceived;
          final messageStateData = (state as MessageItemStateSuccess).messageStateData.copyWith(state: eventMessageState);
          add(MessageUpdated(messageStateData: messageStateData));
        }
      } else if (event.hasType(Event.msgFailed)) {
        final eventMessageState = ChatMsg.messageStateFailed;
        final context = Context();
        final String messageInfo = await context.getMessageInfoAsync(_messageId);
        await _setupContact();
        final chatStateData = await _getChatDataAsync();
        final messageStateData = (state as MessageItemStateSuccess).messageStateData.copyWith(
              state: eventMessageState,
              messageInfo: messageInfo,
              chatStateData: chatStateData,
            );
        add(MessageUpdated(messageStateData: messageStateData));
      } else if (event.hasType(Event.msgsChanged) && state is MessageItemStateSuccess) {
        var flagged = await _messageListRepository.get(eventMessageId)?.isStarredAsync();
        add((MessageUpdated(messageStateData: (state as MessageItemStateSuccess).messageStateData.copyWith(isFlagged: flagged))));
      }
    }
  }

  Future<void> _setupMessage() async {
    await _getMessage(messageId: _messageId).loadValuesAsync(keys: [
      ChatMsg.methodMessageGetText,
      ChatMsg.methodMessageGetTimestamp,
      ChatMsg.methodMessageIsOutgoing,
      ChatMsg.methodMessageHasFile,
      ChatMsg.methodMessageGetFile,
      ChatMsg.methodMessageGetFileMime,
      ChatMsg.methodMessageGetType,
      ChatMsg.methodMessageGetFileBytes,
      ChatMsg.methodMessageGetFilename,
      ChatMsg.methodMessageGetState,
      ChatMsg.methodMessageShowPadlock,
      ChatMsg.methodMessageIsForwarded,
    ]);
  }

  Future<void> _setupNextMessage(int nextMessageId) async {
    await _getMessage(messageId: nextMessageId).loadValueAsync(ChatMsg.methodMessageGetTimestamp);
  }

  Future<void> _setupContact() async {
    final ChatMsg message = _getMessage(messageId: _messageId);
    _contactId = await message.getFromIdAsync();
    _contactRepository.putIfAbsent(id: _contactId);

    await _getContact().loadValuesAsync(keys: [
      Contact.methodContactGetName,
      Contact.methodContactGetAddress,
      Contact.methodContactGetColor,
    ]);
  }

  ChatMsg _getMessage({@required int messageId}) {
    return _messageListRepository.get(messageId);
  }

  Contact _getContact() {
    return _contactRepository.get(_contactId);
  }

  Future<bool> _showTime(int nextMessageId) async {
    if (nextMessageId == null) {
      return true;
    }

    final ChatMsg nextChatMsg = _getMessage(messageId: nextMessageId);
    final nextTimestamp = await nextChatMsg.getTimestampAsync();
    final ChatMsg chatMsg = _getMessage(messageId: _messageId);
    final timestamp = await chatMsg.getTimestampAsync();

    return nextTimestamp.getDateAndTimeFromTimestamp() != timestamp.getDateAndTimeFromTimestamp();
  }

  Future<bool> _hasEncryptionStatusChanged(int nextMessageId) async {
    final ChatMsg chatMsg = _getMessage(messageId: _messageId);
    if (nextMessageId == null) {
      return await chatMsg.showPadlockAsync() == 1;
    }

    final ChatMsg nextChatMsg = _getMessage(messageId: nextMessageId);
    final nextPadlock = await nextChatMsg.showPadlockAsync();
    final padlock = await chatMsg.showPadlockAsync();

    if (await chatMsg.isSetupMessageAsync() || await nextChatMsg.isSetupMessageAsync() || await chatMsg.isInfoAsync()) {
      return false;
    }

    return nextPadlock != padlock;
  }
}
