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
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/foundation.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/data/repository_stream_handler.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/message/message_item_event_state.dart';
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/utils/date.dart';

class MessageItemBloc extends Bloc<MessageItemEvent, MessageItemState> {
  Repository<Contact> _contactRepository = RepositoryManager.get(RepositoryType.contact);
  RepositoryMultiEventStreamHandler _repositoryStreamHandler;
  Repository<ChatMsg> _messageListRepository;
  int _messageId;
  int _contactId;
  bool _listenersRegistered = false;

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
  void close() {
    unregisterListeners();
    super.close();
  }

  Stream<MessageItemState> _loadMessage(LoadMessage event) async* {
    try {
      var chatId = event.chatId;
      _messageListRepository = RepositoryManager.get(RepositoryType.chatMessage, chatId);
      _messageId = event.messageId;
      var nextMessageId = event.nextMessageId;
      var isGroup = event.isGroupChat;
      var showContact = isGroup || chatId == Chat.typeInvite;
      if (showContact) {
        await _setupContact();
      }
      if (nextMessageId != null) {
        await _setupNextMessage(nextMessageId);
      }
      await _setupMessage();
      ChatMsg message = _getMessage(messageId: _messageId);
      var isOutgoing = await message.isOutgoing();
      var state = await message.getState();
      if (isOutgoing && state != ChatMsg.messageStateReceived) {
        _registerListeners();
      }
      bool showTime = await _showTime(nextMessageId);
      bool encryptionStatusChanged = await _hasEncryptionStatusChanged(nextMessageId);
      bool hasFile = await message.hasFile();
      bool isSetupMessage = await message.isSetupMessage();
      String text = await message.getText();
      String informationText;
      if (isSetupMessage) {
        informationText = L10n.get(L.autocryptChatMessagePlaceholder);
      } else if (encryptionStatusChanged) {
        informationText = L10n.get(L.chatEncryptionStatusChanged);
      }
      bool isInfo = await message.isInfo();
      int timestamp = await message.getTimestamp();
      int showPadlock = await message.showPadlock();
      bool isFlagged = await message.isStarred();
      String teaser = await message.getSummaryText(200);
      String messageInfo = "";
      if (state == ChatMsg.messageStateFailed) {
        Context context = Context();
        messageInfo = await context.getMessageInfo(_messageId);
      }
      AttachmentStateData attachmentStateData;
      if (hasFile) {
        attachmentStateData = AttachmentStateData(
          duration: await message.getDuration(),
          filename: await message.getFileName(),
          path: await message.getFile(),
          mimeType: await message.getFileMime(),
          size: await message.getFileBytes(),
          type: await message.getType(),
        );
      }
      ContactStateData contactStateData;
      if (showContact) {
        Contact contact = _getContact();
        int contactId = contact.id;
        String contactName = await contact.getName();
        String contactAddress = await contact.getAddress();
        Color contactColor = rgbColorFromInt(await contact.getColor());
        contactStateData = ContactStateData(
          id: contactId,
          name: contactName,
          address: contactAddress,
          color: contactColor,
        );
      }
      var messageStateData = MessageStateData(
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
        preview: teaser,
        isFlagged: isFlagged,
        showTime: showTime,
        encryptionStatusChanged: encryptionStatusChanged,
        isGroup: isGroup,
        messageInfo: messageInfo,
      );
      yield MessageItemStateSuccess(messageStateData: messageStateData);
    } catch (error) {
      yield MessageItemStateFailure(error: error.toString());
    }
  }

  Stream<MessageItemState> _deleteMessages(int id) async* {
    Context context = Context();
    var messageIds = [id];
    _messageListRepository.remove(ids: messageIds);
    await context.deleteMessages(messageIds);
    yield MessageItemStateSuccess(messageStateData: null);
  }

  Stream<MessageItemState> _flagUnflagMessage(int id) async* {
    if (state is MessageItemStateSuccess) {
      var successState = state as MessageItemStateSuccess;
      var flagged = !successState.messageStateData.isFlagged;
      Context context = Context();
      int nonSpecialChatId = await _messageListRepository.get(id).getChatId();
      Repository<ChatMsg> nonSpecialMessageListRepository = RepositoryManager.get(RepositoryType.chatMessage, nonSpecialChatId);
      var message = nonSpecialMessageListRepository.get(id);
      message?.set(ChatMsg.methodMessageIsStarred, flagged);
      Repository<ChatMsg> _flaggedRepository = RepositoryManager.get(RepositoryType.chatMessage, Chat.typeStarred);
      if (flagged) {
        _flaggedRepository.putIfAbsent(id: id);
      } else {
        _flaggedRepository.remove(id: id);
      }
      int flagType = flagged ? Context.starMessage : Context.unstarMessage;
      await context.starMessages([id], flagType);
      var messageStateData = (state as MessageItemStateSuccess).messageStateData.copyWith(isFlagged: flagged);
      yield MessageItemStateSuccess(messageStateData: messageStateData);
    }
  }

  void _registerListeners() {
    if (!_listenersRegistered) {
      _repositoryStreamHandler = RepositoryMultiEventStreamHandler(
        Type.publish,
        [Event.msgDelivered, Event.msgRead, Event.msgFailed],
        _onMessageStateChanged,
      );
      _messageListRepository.addListener(_repositoryStreamHandler);
    }
  }

  void unregisterListeners() {
    _messageListRepository?.removeListener(_repositoryStreamHandler);
    _listenersRegistered = false;
  }

  void _onMessageStateChanged(Event event) async{
    var eventMessageId = event.data2;
    if (_messageId == eventMessageId && (event.hasType(Event.msgDelivered) || event.hasType(Event.msgRead))) {
      if (state is MessageItemStateSuccess) {
        int eventMessageState = event.hasType(Event.msgDelivered) ? ChatMsg.messageStateDelivered : ChatMsg.messageStateReceived;
        var messageStateData = (state as MessageItemStateSuccess).messageStateData.copyWith(state: eventMessageState);
        add(MessageUpdated(messageStateData: messageStateData));
        if (eventMessageState == ChatMsg.messageStateReceived) {
          unregisterListeners();
        }
      }
    }else if (event.hasType(Event.msgFailed) && _messageId == event.data2){
      int eventMessageState = ChatMsg.messageStateFailed;
      Context context = Context();
      String messageInfo = await context.getMessageInfo(_messageId);
      var messageStateData = (state as MessageItemStateSuccess).messageStateData.copyWith(state: eventMessageState, messageInfo: messageInfo);
      unregisterListeners();
      add(MessageUpdated(messageStateData: messageStateData));
    }
  }

  Future<void> _setupMessage() async {
    await _getMessage(messageId: _messageId).loadValues(keys: [
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
    ]);
  }

  Future<void> _setupNextMessage(int nextMessageId) async {
    await _getMessage(messageId: nextMessageId).loadValue(ChatMsg.methodMessageGetTimestamp);
  }

  Future<void> _setupContact() async {
    ChatMsg message = _getMessage(messageId: _messageId);
    _contactId = await message.getFromId();
    _contactRepository.putIfAbsent(id: _contactId);
    await _getContact().loadValues(keys: [
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
    ChatMsg nextChatMsg = _getMessage(messageId: nextMessageId);
    int nextTimestamp = await nextChatMsg.getTimestamp();
    ChatMsg chatMsg = _getMessage(messageId: _messageId);
    int timestamp = await chatMsg.getTimestamp();
    return getDateAndTimeFromTimestamp(nextTimestamp) != getDateAndTimeFromTimestamp(timestamp);
  }

  Future<bool> _hasEncryptionStatusChanged(int nextMessageId) async {
    ChatMsg chatMsg = _getMessage(messageId: _messageId);
    if (nextMessageId == null) {
      return await chatMsg.showPadlock() == 1;
    }
    ChatMsg nextChatMsg = _getMessage(messageId: nextMessageId);
    int nextPadlock = await nextChatMsg.showPadlock();
    int padlock = await chatMsg.showPadlock();
    if (await chatMsg.isSetupMessage() || await nextChatMsg.isSetupMessage()) {
      return false;
    }
    return nextPadlock != padlock;
  }
}
