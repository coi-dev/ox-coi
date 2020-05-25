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

abstract class MessageListEvent {}

class RequestMessageList extends MessageListEvent {
  final int chatId;
  final int messageId;

  RequestMessageList({@required this.chatId, this.messageId});
}

class RequestFlaggedMessageList extends MessageListEvent {
  final int chatId;

  RequestFlaggedMessageList({@required this.chatId});
}

class UpdateMessageList extends MessageListEvent {}

class SendMessage extends MessageListEvent {
  final String text;
  final String path;
  final int fileType;
  final bool isShared;

  SendMessage({this.text, this.path, this.fileType, this.isShared});
}

class DeleteCacheFile extends MessageListEvent {
  final String path;

  DeleteCacheFile({this.path});
}

class RetrySendPendingMessages extends MessageListEvent {}

abstract class MessageListState {}

class MessageListStateInitial extends MessageListState {}

class MessageListStateLoading extends MessageListState {}

class MessageListStateSuccess extends MessageListState {
  final List<int> messageIds;
  final List<int> messageLastUpdateValues;
  final Stream messageChangedStream;
  final bool handlesFlaggedMessages;
  final List<int> dateMarkerIds;

  MessageListStateSuccess({
    @required this.messageIds,
    @required this.messageLastUpdateValues,
    @required this.messageChangedStream,
    @required this.handlesFlaggedMessages,
    this.dateMarkerIds,
  });
}

class MessageListStateFailure extends MessageListState {
  final String error;

  MessageListStateFailure({@required this.error});
}
