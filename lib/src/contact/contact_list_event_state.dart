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
import 'package:ox_coi/src/contact/contact_list_bloc.dart';

abstract class ContactListEvent {}

class RequestContacts extends ContactListEvent {
  final int typeOrChatId;
  final int chatId;

  RequestContacts({@required this.typeOrChatId, this.chatId});
}

class RequestContactsForGroup extends ContactListEvent {
  final int typeOrChatId;
  final int chatId;

  RequestContactsForGroup({@required this.typeOrChatId, @required this.chatId});
}

class ContactsChanged extends ContactListEvent {
  final List<dynamic> ids;

  ContactsChanged({@required this.ids});
}

class ContactsSelectionChanged extends ContactListEvent {
  final int id;
  final int chatId;

  ContactsSelectionChanged({@required this.id, this.chatId});
}

class BlockedContactsChanged extends ContactListEvent {}

class SearchContacts extends ContactListEvent {
  final String query;
  final int chatId;

  SearchContacts({@required this.query, this.chatId});
}

class ContactsSearched extends ContactListEvent {
  final List<dynamic> ids;

  ContactsSearched({@required this.ids});
}

class AddGoogleContacts extends ContactListEvent {
  final bool changeEmail;

  AddGoogleContacts({@required this.changeEmail});
}

class MarkContactsAsInitiallyLoaded extends ContactListEvent {}

class PerformImport extends ContactListEvent {
  final bool shouldUpdateUi;

  PerformImport({this.shouldUpdateUi = true});
}

abstract class ContactListState {}

class ContactListStateInitial extends ContactListState {}

class ContactListStateLoading extends ContactListState {}

class ContactListStateSuccess extends ContactListState {
  final List<dynamic> contactElements;
  final List<int> contactsSelected;
  final ContactImportState importState;

  ContactListStateSuccess({@required this.contactElements, @required this.contactsSelected, this.importState});
}

class ContactListStateFailure extends ContactListState {
  final String error;

  ContactListStateFailure({@required this.error});
}

class GooglemailContactsDetected extends ContactListState {}