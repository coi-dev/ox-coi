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

import 'package:flutter/material.dart';

abstract class ChatChangeEvent {}

class CreateChat extends ChatChangeEvent {
  final int contactId;
  final int messageId;
  final int chatId;
  final bool verified;
  final String name;
  final List<int> contacts;
  final String imagePath;

  CreateChat({
    this.contactId,
    this.messageId,
    this.chatId,
    this.verified,
    this.name,
    this.contacts,
    this.imagePath,
  });
}

class ChatCreated extends ChatChangeEvent {
  final int chatId;

  ChatCreated({this.chatId});
}

class DeleteChat extends ChatChangeEvent{
  final int chatId;

  DeleteChat({@required this.chatId});
}

class LeaveGroupChat extends ChatChangeEvent{
  final int chatId;

  LeaveGroupChat({@required this.chatId});
}

class DeleteChats extends ChatChangeEvent{
  final List<int> chatIds;

  DeleteChats({@required this.chatIds});
}

class ChatMarkNoticed extends ChatChangeEvent {
  final int chatId;

  ChatMarkNoticed({this.chatId});
}

class ChatMarkMessagesSeen extends ChatChangeEvent {
  final List<int> messageIds;

  ChatMarkMessagesSeen({@required this.messageIds});
}

class ChatAddParticipants extends ChatChangeEvent{
  final int chatId;
  final List<int> contactIds;

  ChatAddParticipants({@required this.chatId, @required this.contactIds});
}

class ChatRemoveParticipant extends ChatChangeEvent{
  final int chatId;
  final int contactId;

  ChatRemoveParticipant({@required this.chatId, @required this.contactId});
}

class SetName extends ChatChangeEvent{
  final int chatId;
  final String newName;

  SetName({@required this.chatId, @required this.newName});
}

class SetImagePath extends ChatChangeEvent{
  final int chatId;
  final String newPath;

  SetImagePath({@required this.chatId, @required this.newPath});
}

class SetNameCompleted extends ChatChangeEvent{}

abstract class ChatChangeState {}

class CreateChatStateInitial extends ChatChangeState {}

class CreateChatStateLoading extends ChatChangeState {}

class CreateChatStateSuccess extends ChatChangeState {
  final int chatId;

  CreateChatStateSuccess({@required this.chatId});
}

class CreateChatStateFailure extends ChatChangeState {
  final String error;

  CreateChatStateFailure({@required this.error});
}

class ChangeNameSuccess extends ChatChangeState {}