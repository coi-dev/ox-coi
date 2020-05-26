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
import 'package:ox_coi/src/error/error_logger.dart';

abstract class ChatEvent {}

class RequestChat extends ChatEvent {
  final int chatId;
  final int messageId;
  final bool isHeadless;

  RequestChat({@required this.chatId, this.isHeadless = false, this.messageId});
}

class UpdateChat extends ChatEvent {}

class ClearNotifications extends ChatEvent {}

abstract class ChatState {}

class ChatStateInitial extends ChatState {}

class ChatStateLoading extends ChatState {}

class ChatStateSuccess extends ChatState {
  final String name;
  final String subTitle;
  final Color color;
  final int freshMessageCount;
  final bool isSelfTalk;
  final bool isGroupChat;
  final String preview;
  final int timestamp;
  final bool isVerified;
  final String avatarPath;
  final bool isRemoved;
  final String phoneNumbers;

  ChatStateSuccess(
      {@required this.name,
      @required this.subTitle,
      @required this.color,
      @required this.freshMessageCount,
      @required this.isSelfTalk,
      @required this.isGroupChat,
      @required this.preview,
      @required this.timestamp,
      @required this.isVerified,
      @required this.avatarPath,
      @required this.isRemoved,
      this.phoneNumbers});
}

class ChatStateFailure extends ChatState {
  ChatStateFailure({@required error, @required stackTrace}) {
    logError(this, error, stackTrace);
  }
}
