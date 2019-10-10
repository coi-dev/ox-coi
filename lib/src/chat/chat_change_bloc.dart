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
import 'package:ox_coi/src/chat/chat_change_event_state.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/utils/text.dart';

class ChatChangeBloc extends Bloc<ChatChangeEvent, ChatChangeState> {
  Repository<ChatMsg> _messageListRepository;
  Repository<Chat> _chatRepository = RepositoryManager.get(RepositoryType.chat);

  @override
  ChatChangeState get initialState => CreateChatStateInitial();

  @override
  Stream<ChatChangeState> mapEventToState(ChatChangeEvent event) async* {
    if (event is CreateChat) {
      yield CreateChatStateLoading();
      try {
        _messageListRepository = RepositoryManager.get(RepositoryType.chatMessage, event.chatId);
        _createChat(
            contactId: event.contactId,
            messageId: event.messageId,
            verified: event.verified,
            name: event.name,
            contacts: event.contacts,
            imagePath: event.imagePath);
      } catch (error) {
        yield CreateChatStateFailure(error: error.toString());
      }
    } else if (event is ChatCreated) {
      yield CreateChatStateSuccess(chatId: event.chatId);
    } else if (event is DeleteChat) {
      _deleteChat(event.chatId);
    } else if (event is DeleteChats) {
      _deleteChats(event.chatIds);
    } else if (event is LeaveGroupChat) {
      _leaveGroupChat(event.chatId);
    } else if (event is ChatMarkNoticed) {
      _markNoticedChat(event.chatId);
    } else if (event is ChatMarkMessagesSeen) {
      _markMessagesSeen(event.messageIds);
    } else if (event is ChatAddParticipants) {
      _addParticipants(event.chatId, event.contactIds);
    } else if (event is ChatRemoveParticipant) {
      _removeParticipant(event.chatId, event.contactId);
    } else if (event is SetName) {
      _setName(event.chatId, event.newName);
    } else if (event is SetImagePath) {
      _setProfileImage(event.chatId, event.newPath);
    } else if (event is SetNameCompleted) {
      yield ChangeNameSuccess();
    }
  }

  void _createChat({int contactId, int messageId, bool verified, String name, List<int> contacts, String imagePath}) async {
    Context context = Context();
    var chatId;
    if (contactId != null) {
      Repository<ChatMsg> inviteMessageRepository = RepositoryManager.get(RepositoryType.chatMessage, Chat.typeInvite);
      inviteMessageRepository.clear();
      chatId = await context.createChatByContactId(contactId);
    } else if (messageId != null) {
      _messageListRepository.clear();
      chatId = await context.createChatByMessageId(messageId);
    } else if (verified != null && name != null && contacts != null) {
      chatId = await context.createGroupChat(verified, name);
      for (int i = 0; i < contacts.length; i++) {
        context.addContactToChat(chatId, contacts[i]);
      }
      if (!isNullOrEmpty(imagePath)) {
        _setProfileImage(chatId, imagePath);
      }
    }
    _chatRepository.putIfAbsent(id: chatId);
    dispatch(ChatCreated(chatId: chatId));
  }

  void _deleteChat(int chatId) async {
    Context context = Context();
    if(_messageListRepository != null) {
      _messageListRepository.clear();
    }
    _chatRepository.remove(id: chatId);
    await context.deleteChat(chatId);
  }

  void _deleteChats(List<int> chatIds) async {
    Context context = Context();
    for (int chatId in chatIds) {
      _chatRepository.remove(id: chatId);
      _leaveGroupChat(chatId);
      await context.deleteChat(chatId);
    }
  }

  void _leaveGroupChat(int chatId) async {
    Context context = Context();
    await context.removeContactFromChat(chatId, Contact.idSelf);
  }

  void _markNoticedChat(int chatId) async {
    Context context = Context();
    await context.markNoticedChat(chatId);
    if (!_chatRepository.contains(chatId)) {
      return;
    }
    _chatRepository.get(chatId).setLastUpdate();
  }

  void _markMessagesSeen(List<int> messageIds) async {
    Context context = Context();
    await context.markSeenMessages(messageIds);
  }

  void _addParticipants(int chatId, List<int> contactIds) async {
    Context context = Context();
    for (int i = 0; i < contactIds.length; i++) {
      await context.addContactToChat(chatId, contactIds[i]);
    }
  }

  void _removeParticipant(int chatId, int contactId) async {
    Context context = Context();
    await context.removeContactFromChat(chatId, contactId);
  }

  void _setName(int chatId, String newName) async {
    Context context = Context();
    await context.setChatName(chatId, newName);
    RepositoryManager.get(RepositoryType.chat).get(chatId).set(Chat.methodChatGetName, newName);
    dispatch(SetNameCompleted());
  }

  void _setProfileImage(int chatId, String newPath) async {
    Context context = Context();
    await context.setChatProfileImage(chatId, newPath);
    RepositoryManager.get(RepositoryType.chat).get(chatId).set(Chat.methodChatGetProfileImage, newPath);
  }
}
