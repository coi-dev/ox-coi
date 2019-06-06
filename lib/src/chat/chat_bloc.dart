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
import 'package:flutter/material.dart';
import 'package:ox_coi/src/chat/chat_event_state.dart';
import 'package:ox_coi/src/data/chat_extension.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/utils/colors.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  bool _isGroup = false;
  bool get isGroup => _isGroup;

  @override
  ChatState get initialState => ChatStateInitial();

  @override
  Stream<ChatState> mapEventToState(ChatState currentState, ChatEvent event) async* {
    if (event is RequestChat) {
      yield ChatStateLoading();
      try {
        int chatId = event.chatId;
        if (chatId == Chat.typeInvite) {
          _setupInviteChat(event.messageId);
        } else {
          _setupChat(chatId);
        }
      } catch (error) {
        yield ChatStateFailure(error: error.toString());
      }
    } else if (event is ChatLoaded) {
      yield ChatStateSuccess(
        name: event.name,
        subTitle: event.subTitle,
        color: event.color,
        freshMessageCount: event.freshMessageCount,
        isSelfTalk: event.isSelfTalk,
        isGroupChat: event.isGroupChat,
        preview: event.preview,
        timestamp: event.timestamp,
        isVerified: event.isVerified,
      );
    }
  }

  void _setupInviteChat(int messageId) async {
    Repository<ChatMsg> messageListRepository = RepositoryManager.get(RepositoryType.chatMessage, Chat.typeInvite);
    ChatMsg message = messageListRepository.get(messageId);
    int contactId = await message.getFromId();
    Repository<Contact> inviteContactRepository = RepositoryManager.get(RepositoryType.contact, ContactRepository.inviteContacts);
    Contact contact = inviteContactRepository.get(contactId);
    String name = await contact.getName();
    String email = await contact.getAddress();
    int colorValue = await contact.getColor();
    Color color = rgbColorFromInt(colorValue);
    dispatch(ChatLoaded(name, email, color, 0, false, false, null, null, false));
  }

  void _setupChat(int chatId) async {
    Repository<Chat> _chatRepository = RepositoryManager.get(RepositoryType.chat);
    Context context = Context();
    Chat chat = _chatRepository.get(chatId);
    String name = await chat.getName();
    String subTitle = await chat.getSubtitle();
    int colorValue = await chat.getColor();
    int freshMessageCount = await context.getFreshMessageCount(chatId);
    bool isSelfTalk = await chat.isSelfTalk();
    _isGroup = await chat.isGroup();
    bool isVerified = await chat.isVerified();
    Color color = rgbColorFromInt(colorValue);
    var chatSummary = chat.get(ChatExtension.chatSummary);
    dispatch(ChatLoaded(name, subTitle, color, freshMessageCount, isSelfTalk, _isGroup, chatSummary?.preview, chatSummary?.timestamp, isVerified));
  }
}
