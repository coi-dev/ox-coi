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

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class MessageItemEvent extends Equatable {}

class LoadMessage extends MessageItemEvent {
  final int chatId;
  final int messageId;
  final int nextMessageId;
  final bool isGroupChat;

  LoadMessage({@required this.chatId, @required this.messageId, this.nextMessageId, @required this.isGroupChat});

  @override
  List<Object> get props => [chatId, messageId, nextMessageId, isGroupChat];
}

class DeleteMessage extends MessageItemEvent {
  final int id;

  DeleteMessage({@required this.id});

  @override
  List<Object> get props => [id];
}

class FlagUnflagMessage extends MessageItemEvent {
  final int id;

  FlagUnflagMessage({@required this.id});

  @override
  List<Object> get props => [id];
}

class MessageUpdated extends MessageItemEvent {
  final MessageStateData messageStateData;

  MessageUpdated({@required this.messageStateData});

  @override
  List<Object> get props => [messageStateData];
}

abstract class MessageItemState extends Equatable {}

class MessageItemStateInitial extends MessageItemState {
  @override
  List<Object> get props => null;
}

class MessageItemStateLoading extends MessageItemState {
  @override
  List<Object> get props => null;
}

class MessageItemStateSuccess extends MessageItemState {
  final MessageStateData messageStateData;

  MessageItemStateSuccess({@required this.messageStateData});

  @override
  List<Object> get props => [messageStateData];
}

class MessageItemStateFailure extends MessageItemState {
  final String error;

  MessageItemStateFailure({@required this.error});

  @override
  List<Object> get props => [error];
}

class MessageStateData extends Equatable {
  final String text;
  final String informationText;
  final int timestamp;
  final bool isOutgoing;
  final bool hasFile;
  final int state;
  final bool isSetupMessage;
  final bool isInfo;
  final int showPadlock;
  final ContactStateData contactStateData;
  final AttachmentStateData attachmentStateData;
  final String preview;
  final bool isFlagged;
  final bool showTime;
  final bool encryptionStatusChanged;
  final bool isGroup;

  MessageStateData({
    @required this.text,
    @required this.informationText,
    @required this.isOutgoing,
    @required this.timestamp,
    @required this.hasFile,
    @required this.state,
    @required this.isSetupMessage,
    @required this.isInfo,
    @required this.showPadlock,
    @required this.attachmentStateData,
    @required this.contactStateData,
    @required this.preview,
    @required this.isFlagged,
    @required this.showTime,
    @required this.encryptionStatusChanged,
    @required this.isGroup,
  });

  MessageStateData copyWith(
      {text,
      informationText,
      isOutgoing,
      timestamp,
      hasFile,
      state,
      isSetupMessage,
      isInfo,
      showPadlock,
      attachmentStateData,
      contactStateData,
      preview,
      isFlagged,
      showTime,
      encryptionStatusChanged,
      isGroup}) {
    return MessageStateData(
      text: text ?? this.text,
      informationText: informationText ?? this.informationText,
      isOutgoing: isOutgoing ?? this.isOutgoing,
      timestamp: timestamp ?? this.timestamp,
      hasFile: hasFile ?? this.hasFile,
      state: state ?? this.state,
      isSetupMessage: isSetupMessage ?? this.isSetupMessage,
      isInfo: isInfo ?? this.isInfo,
      showPadlock: showPadlock ?? this.showPadlock,
      attachmentStateData: attachmentStateData ?? this.attachmentStateData,
      contactStateData: contactStateData ?? this.contactStateData,
      preview: preview ?? this.preview,
      isFlagged: isFlagged ?? this.isFlagged,
      showTime: showTime ?? this.showTime,
      encryptionStatusChanged: encryptionStatusChanged ?? this.encryptionStatusChanged,
      isGroup: isGroup ?? this.isGroup,
    );
  }

  @override
  List<Object> get props => [
        text,
        informationText,
        isOutgoing,
        timestamp,
        hasFile,
        state,
        isSetupMessage,
        isInfo,
        showPadlock,
        attachmentStateData,
        contactStateData,
        preview,
        isFlagged,
        showTime,
        encryptionStatusChanged,
        isGroup,
      ];
}

class ContactStateData extends Equatable {
  final int id;
  final String name;
  final String address;
  final Color color;

  ContactStateData({
    @required this.id,
    @required this.name,
    @required this.address,
    @required this.color,
  });

  ContactStateData copyWith({id, name, address, color}) {
    return ContactStateData(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      color: color ?? this.color,
    );
  }

  @override
  List<Object> get props => [id, name, address, color];
}

class AttachmentStateData extends Equatable {
  final int duration;
  final String filename;
  final String path;
  final String mimeType;
  final int size;
  final int type;

  AttachmentStateData({
    @required this.duration,
    @required this.filename,
    @required this.path,
    @required this.mimeType,
    @required this.size,
    @required this.type,
  });

  AttachmentStateData copyWith({duration, filename, path, mimeType, size, type}) {
    return AttachmentStateData(
      duration: duration ?? this.duration,
      filename: filename ?? this.filename,
      path: path ?? this.path,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      type: type ?? this.type,
    );
  }

  @override
  List<Object> get props => [duration, filename, path, mimeType, size, type];
}
