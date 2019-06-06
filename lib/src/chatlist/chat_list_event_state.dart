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

import 'package:meta/meta.dart';

import 'chat_list_bloc.dart';

abstract class ChatListEvent {}

class RequestChatList extends ChatListEvent {
  final bool showInvites;

  RequestChatList({@required this.showInvites});
}

class SearchChatList extends ChatListEvent {
  final String query;
  final bool showInvites;

  SearchChatList({@required this.query, @required this.showInvites});
}

class InvitesPrepared extends ChatListEvent {
  final String query;
  final List<int> messageIds;

  InvitesPrepared({this.query, @required this.messageIds});
}

class ChatsPrepared extends ChatListEvent {
  final List<int> chatIds;

  ChatsPrepared({@required this.chatIds});
}

class ChatListModified extends ChatListEvent {
  final ChatListItemWrapper chatListItemWrapper;

  ChatListModified({@required this.chatListItemWrapper});
}

abstract class ChatListState {}

class ChatListStateInitial extends ChatListState {}

class ChatListStateLoading extends ChatListState {}

class ChatListStateSuccess extends ChatListState {
  final ChatListItemWrapper chatListItemWrapper;

  ChatListStateSuccess({
    @required this.chatListItemWrapper,
  });
}

class ChatListStateFailure extends ChatListState {
  final String error;

  ChatListStateFailure({@required this.error});
}

class ChatListItemWrapper {
  final List<int> ids;
  final List<ChatListItemType> types;
  final List<int> lastUpdateValues;

  ChatListItemWrapper({@required this.ids, @required this.types, @required this.lastUpdateValues});
}
