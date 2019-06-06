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
import 'package:ox_coi/src/contact/contact_list_event_state.dart';
import 'package:ox_coi/src/data/contact_repository_updater.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/data/repository_stream_handler.dart';
import 'package:ox_coi/src/utils/text.dart';

class ContactListBloc extends Bloc<ContactListEvent, ContactListState> with ContactRepositoryUpdater {
  Repository<Contact> contactRepository;
  RepositoryEventStreamHandler repositoryStreamHandler;
  int _listTypeOrChatId;
  List<int> _contactsSelected = List();
  String _currentSearch;

  int get contactsSelectedCount => _contactsSelected.length;

  List<int> get contactsSelected => _contactsSelected;

  @override
  ContactListState get initialState => ContactListStateInitial();

  @override
  Stream<ContactListState> mapEventToState(ContactListState currentState, ContactListEvent event) async* {
    if (event is RequestContacts) {
      yield ContactListStateLoading();
      try {
        _currentSearch = null;
        _listTypeOrChatId = event.listTypeOrChatId;
        contactRepository = RepositoryManager.get(RepositoryType.contact, _listTypeOrChatId);
        _setupContactListener();
        _setupContacts();
      } catch (error) {
        yield ContactListStateFailure(error: error.toString());
      }
    } else if (event is SearchContacts) {
      try {
        _currentSearch = event.query;
        _searchContacts();
      } catch (error) {
        yield ContactListStateFailure(error: error.toString());
      }
    } else if (event is ContactsChanged) {
      yield ContactListStateSuccess(
        contactIds: contactRepository.getAllIds(),
        contactLastUpdateValues: contactRepository.getAllLastUpdateValues(),
        contactsSelected: _contactsSelected,
      );
    } else if (event is ContactsSearched) {
      yield ContactListStateSuccess(
        contactIds: event.ids,
        contactLastUpdateValues: event.lastUpdates,
        contactsSelected: _contactsSelected,
      );
    } else if (event is ContactsSelectionChanged) {
      _selectionChanged(event.id);
    }
  }

  @override
  void dispose() {
    contactRepository.removeListener(repositoryStreamHandler);
    super.dispose();
  }

  void _setupContactListener() async {
    repositoryStreamHandler = RepositoryEventStreamHandler(Type.publish, Event.contactsChanged, _dispatchContactsChanged);
    contactRepository.addListener(repositoryStreamHandler);
  }

  void _dispatchContactsChanged() {
    dispatch(ContactsChanged());
  }

  Future _setupContacts() async {
    List<int> contactIds = await getContactIdsAfterUpdate(_listTypeOrChatId);
    contactRepository.update(ids: contactIds);
    _dispatchContactsChanged();
  }

  void _searchContacts() async {
    Context context = Context();
    List<int> contactIds = List.from(await context.getContacts(2, _currentSearch));
    List<int> lastUpdates = List();
    contactIds.forEach((contactId) {
      lastUpdates.add(contactRepository.get(contactId).lastUpdate);
    });
    dispatch(ContactsSearched(ids: contactIds, lastUpdates: lastUpdates));
  }

  void _selectionChanged(int id) {
    if (_contactsSelected.contains(id)) {
      _contactsSelected.remove(id);
    } else {
      _contactsSelected.add(id);
    }
    if (isNullOrEmpty(_currentSearch)) {
      _dispatchContactsChanged();
    } else {
      _searchContacts();
    }
  }
}
