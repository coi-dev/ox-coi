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
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/message/message_item_event_state.dart';
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/utils/date.dart';

class MessageItemBloc extends Bloc<MessageItemEvent, MessageItemState> {
  Repository<Contact> _contactRepository = RepositoryManager.get(RepositoryType.contact);
  Repository<ChatMsg> _messageListRepository;
  int _messageId;
  int _nextMessageId;
  int _contactId;
  bool _showContact;

  @override
  MessageItemState get initialState => MessageItemStateInitial();

  @override
  Stream<MessageItemState> mapEventToState(MessageItemEvent event) async* {
    if (event is RequestMessage) {
      try {
        var chatId = event.chatId;
        _messageListRepository = RepositoryManager.get(RepositoryType.chatMessage, chatId);
        _messageId = event.messageId;
        _nextMessageId = event.nextMessageId;
        _showContact = event.isGroupChat || isInvite(chatId);
        if (_showContact) {
          await _setupContact();
        }
        if (_hasNextMessage()) {
          await _setupNextMessage();
        }
        await _setupMessage();
        dispatch(MessageLoaded());
      } catch (error) {
        yield MessageItemStateFailure(error: error.toString());
      }
    } else if (event is MessageLoaded) {
      bool showTime = await _getShowTime();
      bool encryptionStatusChanged = await _getEncryptionStatusChanged();
      ChatMsg message = _getMessage();
      bool isOutgoing = await message.isOutgoing();
      String text = await message.getText();
      bool hasFile = await message.hasFile();
      bool isSetupMessage = await message.isSetupMessage();
      bool isInfo = await message.isInfo();
      int timestamp = await message.getTimestamp();
      int state = await message.getState();
      int showPadlock = await message.showPadlock();
      bool isStarred = await message.isStarred();
      String teaser = await message.getSummaryText(200);
      AttachmentWrapper attachmentWrapper;
      if (hasFile) {
        attachmentWrapper = AttachmentWrapper(
          filename: await message.getFileName(),
          path: await message.getFile(),
          mimeType: await message.getFileMime(),
          size: await message.getFileBytes(),
          type: await message.getType(),
        );
      }

      ContactWrapper contactWrapper;
      if (_showContact) {
        Contact contact = _getContact();
        int contactId = contact.id;
        String contactName = await contact.getName();
        String contactAddress = await contact.getAddress();
        Color contactColor = rgbColorFromInt(await contact.getColor());
        contactWrapper = ContactWrapper(
          contactId: contactId,
          contactName: contactName,
          contactAddress: contactAddress,
          contactColor: contactColor,
        );
      }
      yield MessageItemStateSuccess(
        messageIsOutgoing: isOutgoing,
        messageText: text,
        hasFile: hasFile,
        isSetupMessage: isSetupMessage,
        isInfo: isInfo,
        messageTimestamp: timestamp,
        state: state,
        showPadlock: showPadlock,
        attachmentWrapper: attachmentWrapper,
        contactWrapper: contactWrapper,
        preview: teaser,
        isStarred: isStarred,
        showTime: showTime,
        encryptionStatusChanged: encryptionStatusChanged,
      );
    } else if (event is DeleteMessages) {
      _deleteMessages(event.messageIds);
    }
  }

  bool isInvite(int chatId) => chatId == Chat.typeInvite;

  Future<void> _setupContact() async {
    ChatMsg message = _getMessage();
    _contactId = await message.getFromId();
    _contactRepository.putIfAbsent(id: _contactId);
    await _getContact().loadValues(keys: [
      Contact.methodContactGetName,
      Contact.methodContactGetAddress,
      Contact.methodContactGetColor,
    ]);
  }

  Future<void> _setupMessage() async {
    await _getMessage().loadValues(keys: [
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

  Future<void> _setupNextMessage() async {
    await _getNextMessage().loadValue(ChatMsg.methodMessageGetTimestamp);
  }

  Contact _getContact() {
    return _contactRepository.get(_contactId);
  }

  ChatMsg _getMessage() {
    return _messageListRepository.get(_messageId);
  }

  ChatMsg _getNextMessage() {
    return _messageListRepository.get(_nextMessageId);
  }

  void _deleteMessages(List<int> messageIds) async {
    Context context = Context();
    _messageListRepository.remove(ids: messageIds);
    await context.deleteMessages(messageIds);
  }

  bool _hasNextMessage() {
    return _nextMessageId != null;
  }

  Future<bool> _getShowTime() async {
    if (!_hasNextMessage()) {
      return true;
    }
    ChatMsg _nextChatMsg = _getNextMessage();
    int nextTimestamp = await _nextChatMsg.getTimestamp();
    ChatMsg _chatMsg = _getMessage();
    int timestamp = await _chatMsg.getTimestamp();
    return getDateAndTimeFromTimestamp(nextTimestamp) != getDateAndTimeFromTimestamp(timestamp);
  }

  Future<bool> _getEncryptionStatusChanged() async {
    ChatMsg _chatMsg = _getMessage();
    if (!_hasNextMessage()) {
      return await _chatMsg.showPadlock() == 1;
    }
    ChatMsg _nextChatMsg = _getNextMessage();
    int nextPadlock = await _nextChatMsg.showPadlock();
    int padlock = await _chatMsg.showPadlock();
    return nextPadlock != padlock;
  }
}
