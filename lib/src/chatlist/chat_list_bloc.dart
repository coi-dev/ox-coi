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
import 'package:ox_talk/src/chatlist/chat_list_event.dart';
import 'package:ox_talk/src/chatlist/chat_list_state.dart';
import 'package:ox_talk/src/data/repository.dart';
import 'package:ox_talk/src/data/repository_manager.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final Repository<ChatList> chatListRepository = RepositoryManager.get(RepositoryType.chatList);
  final Repository<Chat> chatRepository = RepositoryManager.get(RepositoryType.chat);
  StreamSubscription streamSubscription;

  @override
  ChatListState get initialState => ChatListStateInitial();

  @override
  Stream<ChatListState> mapEventToState(ChatListState currentState, ChatListEvent event) async* {
    if (event is RequestChatList) {
      yield ChatListStateLoading();
      try {
        setupChatListListener();
        setupChatList();
      } catch (error) {
        yield ChatListStateFailure(error: error.toString());
      }
    } else if (event is ChatListModified) {
      yield ChatListStateSuccess(
          chatIds: chatRepository.getAllIds(),
          chatLastUpdateValues: chatRepository.getAllLastUpdateValues());
    }
  }

  @override
  void dispose() {
    super.dispose();
    chatListRepository.removeListener(hashCode, Event.msgsChanged);
    chatListRepository.removeListener(hashCode, Event.contactsChanged);
    streamSubscription.cancel();
  }

  void setupChatList() async {
    ChatList chatList = ChatList();
    int chatCount = await chatList.getChatCnt();
    List<int> chatIds = List();
    for (int i = 0; i < chatCount; i++) {
      int chatId = await chatList.getChat(i);
      chatIds.add(chatId);
    }
    chatRepository.putIfAbsent(ids: chatIds);
    dispatch(ChatListModified());
  }

  void setupChatListListener() {
    if (streamSubscription == null) {
      chatListRepository.addListener(hashCode, Event.msgsChanged);
      chatListRepository.addListener(hashCode, Event.contactsChanged);
      streamSubscription = chatListRepository.observable.listen((event) => dispatch(RequestChatList()));
    }
  }
}
