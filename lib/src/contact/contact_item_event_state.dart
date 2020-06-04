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

import 'contact_change.dart';
import 'contact_item_bloc.dart';

abstract class ContactItemEvent extends Equatable {}

class RequestContact extends ContactItemEvent {
  final int id;
  final int previousContactId;
  final int typeOrChatId;

  RequestContact({@required this.id, this.previousContactId, @required this.typeOrChatId});

  @override
  List<Object> get props => [id, previousContactId, typeOrChatId];
}

class ChangeContact extends ContactItemEvent {
  final String name;
  final String email;
  final ContactAction contactAction;

  ChangeContact({
    @required this.name,
    @required this.email,
    @required this.contactAction,
  });

  @override
  List<Object> get props => [name, email, contactAction];
}

class DeleteContact extends ContactItemEvent {
  final int id;

  DeleteContact({@required this.id});

  @override
  List<Object> get props => [id];
}

class AddGoogleContact extends ContactItemEvent {
  final String name;
  final String email;
  final bool changeEmail;

  AddGoogleContact({@required this.name,  @required this.email, @required this.changeEmail});

  @override
  List<Object> get props => [name, email, changeEmail];
}

class BlockContact extends ContactItemEvent {
  final int id;
  final int chatId;
  final int messageId;

  BlockContact({this.chatId, this.id, this.messageId});

  @override
  List<Object> get props => [id, chatId, messageId];
}

class UnblockContact extends ContactItemEvent {
  final int id;

  UnblockContact({@required this.id});

  @override
  List<Object> get props => [id];
}

abstract class ContactItemState extends Equatable{}

class ContactItemStateInitial extends ContactItemState {
  @override
  List<Object> get props => null;
}

class ContactItemStateLoading extends ContactItemState {
  @override
  List<Object> get props => null;
}

class ContactItemStateSuccess extends ContactItemState {
  final ContactStateData contactStateData;
  final ContactChangeType type;
  final bool contactHasChanged;

  ContactItemStateSuccess({@required this.contactStateData, this.type, this.contactHasChanged = false});

  @override
  List<Object> get props => [contactStateData, type, contactHasChanged];
}

class ContactItemStateFailure extends ContactItemState {
  final int id;
  final String error;


  ContactItemStateFailure({this.id, @required this.error});

  @override
  List<Object> get props => [id, error];
}

class GoogleContactDetected extends ContactItemState {
  final String name;
  final String email;

  GoogleContactDetected({@required this.name, @required this.email});

  @override
  List<Object> get props => [name, email];
}

class ContactStateData extends Equatable {
  final int id;
  final String name;
  final String email;
  final Color color;
  final bool isVerified;
  final String imagePath;
  final String phoneNumbers;

  ContactStateData({
    @required this.id,
    this.name,
    this.email,
    this.color,
    this.isVerified,
    this.imagePath,
    this.phoneNumbers,
  });

  ContactStateData copyWith({id, name, email, color, isVerified, imagePath, phoneNumbers}) {
    return ContactStateData(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      color: color ?? this.color,
      isVerified: isVerified ?? this.isVerified,
      imagePath: imagePath ?? this.imagePath,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
    );
  }

  @override
  List<Object> get props => [id, name, email, color, isVerified, imagePath, phoneNumbers];
}
