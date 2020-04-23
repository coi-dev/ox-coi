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
import 'package:ox_coi/src/chat/chat_event_state.dart';
import 'package:ox_coi/src/data/chat_extension.dart';
import 'package:ox_coi/src/data/contact_extension.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/data/repository_stream_handler.dart';
import 'package:ox_coi/src/extensions/color_apis.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/notifications/notification_manager.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final _chatRepository = RepositoryManager.get(RepositoryType.chat);
  final _contactRepository = RepositoryManager.get(RepositoryType.contact);
  RepositoryEventStreamHandler _repositoryStreamHandler;
  bool _listenersRegistered = false;
  bool _isGroupChat;
  int _chatId;

  @override
  ChatState get initialState => ChatStateInitial();

  @override
  Stream<ChatState> mapEventToState(ChatEvent event) async* {
    if (event is RequestChat) {
      yield ChatStateLoading();
      try {
        _chatId = event.chatId;

       await _registerListeners();
        if (_chatId == Chat.typeInvite) {
          yield* _setupInviteChat(event.messageId);
        } else {
          yield* _setupChat(event.isHeadless);
        }
      } catch (error, stackTrace) {
        yield ChatStateFailure(error: error, stackTrace: stackTrace);
      }
    } else if (event is ClearNotifications) {
      _removeNotifications();
    }
  }

  @override
  Future<void> close() {
    _unregisterListeners();
    return super.close();
  }

  Future<void> _registerListeners() async {
    if (!_listenersRegistered) {
      _listenersRegistered = true;
      _repositoryStreamHandler = RepositoryEventStreamHandler(
        Type.publish,
        Event.chatModified,
        _onChatChanged,
      );
      _chatRepository.addListener(_repositoryStreamHandler);
    }
  }

  void _unregisterListeners() {
    if (_listenersRegistered) {
      _listenersRegistered = false;
      _chatRepository.removeListener(_repositoryStreamHandler);
    }
  }

  void _onChatChanged([Event event]) async {
    int eventChatId = event.data1;
    if (_chatId == eventChatId) {
      _setupChat(false);
    }
  }

  Stream<ChatState> _setupInviteChat(int messageId) async* {
    final messageListRepository = RepositoryManager.get(RepositoryType.chatMessage, Chat.typeInvite);
    final ChatMsg message = messageListRepository.get(messageId);
    if (message != null) {
      final contactId = await message.getFromId();
      final Contact contact = _contactRepository.get(contactId);
      final name = await contact.getName();
      final email = await contact.getAddress();
      final colorValue = await contact.getColor();
      final color = colorFromArgb(colorValue);
      yield ChatStateSuccess(
        name: name,
        subTitle: email,
        color: color,
        freshMessageCount: 0,
        isSelfTalk: false,
        isGroupChat: false,
        preview: null,
        timestamp: null,
        isVerified: false,
        isRemoved: false,
        avatarPath: null,
      );
    }
  }

  Stream<ChatState> _setupChat(bool isHeadless) async* {
    final context = Context();
    Chat chat = _chatRepository.get(_chatId);
    if (chat == null && isHeadless) {
      _chatRepository.putIfAbsent(id: _chatId);
      chat = _chatRepository.get(_chatId);
    }
    if (chat == null) {
      return;
    }
    _isGroupChat = await chat.isGroup();
    final name = await chat.getName();
    final colorValue = await chat.getColor();
    final freshMessageCount = await context.getFreshMessageCount(_chatId);
    final isSelfTalk = await chat.isSelfTalk();
    final isVerified = await chat.isVerified();
    final color = colorFromArgb(colorValue);
    final chatSummary = chat.get(ChatExtension.chatSummary);
    final chatSummaryState = chatSummary?.state;
    final chatContacts = await context.getChatContacts(_chatId);
    String avatarPath = await chat.getProfileImage();
    var phoneNumbers;
    var isRemoved = false;
    String subTitle;
    if (_isGroupChat) {
      final chatContactsCount = chatContacts.length;
      subTitle = L10n.getFormatted(L.memberXP, [chatContactsCount], count: chatContactsCount);
      isRemoved = !chatContacts.contains(Contact.idSelf);
    } else {
      final chatContactId = chatContacts.first;
      Contact contact = _contactRepository.get(chatContactId);
      phoneNumbers = contact?.get(ContactExtension.contactPhoneNumber);
      avatarPath = contact?.get(ContactExtension.contactAvatar);
      final isSelfTalk = await chat.isSelfTalk();
      if (isSelfTalk) {
        subTitle = L10n.get(L.chatMessagesSelf);
      } else {
        final Contact contact = _contactRepository.get(chatContactId);
        subTitle = await contact.getAddress();
      }
    }
    yield ChatStateSuccess(
      name: name,
      subTitle: subTitle,
      color: color,
      freshMessageCount: freshMessageCount,
      isSelfTalk: isSelfTalk,
      isGroupChat: _isGroupChat,
      preview: chatSummaryState != ChatMsg.messageStateDraft && chatSummaryState != ChatMsg.messageNone
          ? chatSummary?.preview
          : L10n.get(L.chatNoMessages),
      timestamp: chatSummary?.timestamp,
      isVerified: isVerified,
      avatarPath: avatarPath,
      isRemoved: isRemoved,
      phoneNumbers: phoneNumbers,
    );
  }

  void _removeNotifications() {
    final notificationManager = NotificationManager();
    notificationManager.cancelNotification(_chatId);
  }
}
