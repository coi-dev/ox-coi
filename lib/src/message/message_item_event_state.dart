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

import 'dart:ui';

import 'package:meta/meta.dart';

abstract class MessageItemEvent {}

class RequestMessage extends MessageItemEvent {
  final int chatId;
  final int messageId;
  final bool isGroupChat;

  RequestMessage(this.chatId, this.messageId, this.isGroupChat);
}

class MessageLoaded extends MessageItemEvent {}

class DeleteMessages extends MessageItemEvent {
  final List<int> messageIds;

  DeleteMessages(this.messageIds);
}

abstract class MessageItemState {}

class MessageItemStateInitial extends MessageItemState {}

class MessageItemStateLoading extends MessageItemState {}

class MessageItemStateSuccess extends MessageItemState {
  final String messageText;
  final int messageTimestamp;
  final bool messageIsOutgoing;
  final bool hasFile;
  final int state;
  final bool isSetupMessage;
  final bool isInfo;
  final int showPadlock;
  final ContactWrapper contactWrapper;
  final AttachmentWrapper attachmentWrapper;
  final String preview;
  final bool isStarred;

  MessageItemStateSuccess({
    @required this.messageText,
    @required this.messageIsOutgoing,
    @required this.messageTimestamp,
    @required this.hasFile,
    @required this.state,
    @required this.isSetupMessage,
    @required this.isInfo,
    @required this.showPadlock,
    @required this.attachmentWrapper,
    @required this.contactWrapper,
    @required this.preview,
    @required this.isStarred,
  });
}

class MessageItemStateFailure extends MessageItemState {
  final String error;

  MessageItemStateFailure({@required this.error});
}

class ContactWrapper {
  final int contactId;
  final String contactName;
  final String contactAddress;
  final Color contactColor;

  ContactWrapper({
    @required this.contactId,
    @required this.contactName,
    @required this.contactAddress,
    @required this.contactColor,
  });
}

class AttachmentWrapper {
  final String filename;
  final String path;
  final String mimeType;
  final int size;
  final int type;

  AttachmentWrapper({
    @required this.filename,
    @required this.path,
    @required this.mimeType,
    @required this.size,
    @required this.type,
  });
}