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
import 'package:ox_talk/src/contact/contact_list_event.dart';
import 'package:ox_talk/src/contact/contact_list_state.dart';
import 'package:ox_talk/src/data/contact_repository.dart';
import 'package:ox_talk/src/data/repository.dart';
import 'package:ox_talk/src/data/repository_manager.dart';
import 'package:ox_talk/src/data/repository_stream_handler.dart';

class ContactListBloc extends Bloc<ContactListEvent, ContactListState> {
  Repository<Contact> contactRepository;
  RepositoryStreamHandler repositoryStreamHandler;
  int contactListType;

  @override
  ContactListState get initialState => ContactListStateInitial();

  @override
  Stream<ContactListState> mapEventToState(ContactListState currentState, ContactListEvent event) async* {
    if (event is RequestContacts) {
      yield ContactListStateLoading();
      try {
        contactRepository = RepositoryManager.get(RepositoryType.contact, ContactRepository.validContacts);
        contactListType = ContactRepository.validContacts;
        setupContactListener();
        setupContacts();
      } catch (error) {
        yield ContactListStateFailure(error: error.toString());
      }
    } else if (event is ContactsChanged) {
      yield ContactListStateSuccess(contactIds: contactRepository.getAllIds(), contactLastUpdateValues: contactRepository.getAllLastUpdateValues());
    } else if (event is RequestBlockedContacts) {
      yield ContactListStateLoading();
      try {
        contactRepository = RepositoryManager.get(RepositoryType.contact, ContactRepository.blockedContacts);
        contactListType = ContactRepository.blockedContacts;
        setupContactListener();
        setupBlockedContacts();
      } catch (error) {
        yield ContactListStateFailure(error: error.toString());
      }
    } else if(event is RequestChatContacts){
      yield ContactListStateLoading();
      try {
        contactRepository = RepositoryManager.get(RepositoryType.contact, ContactRepository.validContacts);
        contactListType = ContactRepository.validContacts;
        setupChatContacts(event.chatId);
      } catch (error) {
        yield ContactListStateFailure(error: error.toString());
      }
    }
  }

  @override
  void dispose() {
    contactRepository.removeListener(repositoryStreamHandler);
    super.dispose();
  }

  void setupContactListener() async {
    repositoryStreamHandler = RepositoryStreamHandler(Type.publish, Event.contactsChanged, _dispatchContactsChanged);
    contactRepository.addListener(repositoryStreamHandler);
  }

  void _dispatchContactsChanged() async {
    await _updateValidContactIds();
    dispatch(ContactsChanged());
  }

  Future _updateValidContactIds() async {
    Context _context = Context();
    List<int> contactIds;
    if(contactListType == ContactRepository.validContacts){
      contactIds = List.from(await _context.getContacts(2, null));
    }else if(contactListType == ContactRepository.blockedContacts){
      contactIds = List.from(await _context.getBlockedContacts());
    }else{
      return;
    }
    contactRepository.putIfAbsent(ids: contactIds);
  }

  void setupContacts() async {
    await _updateValidContactIds();
    dispatch(ContactsChanged());
  }

  void setupBlockedContacts() async {
    Context context = Context();
    List<int> contactIds = List.from(await context.getBlockedContacts());
    contactRepository.putIfAbsent(ids: contactIds);
    dispatch(ContactsChanged());
  }

  void setupChatContacts(int chatId) async {
    Context context = Context();
    List<int> contactIds = List.from(await context.getChatContacts(chatId));
    contactRepository.putIfAbsent(ids: contactIds);
    dispatch(ContactsChanged());
  }
}
