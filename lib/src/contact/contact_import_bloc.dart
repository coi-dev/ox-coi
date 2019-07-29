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
import 'package:contacts_service/contacts_service.dart' as SystemContacts;
import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:ox_coi/src/contact/contact_import_event_state.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/platform/preferences.dart';
import 'package:ox_coi/src/utils/security.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactImportBloc extends Bloc<ContactImportEvent, ContactImportState> {
  final Repository<Contact> contactRepository = RepositoryManager.get(RepositoryType.contact, ContactRepository.validContacts);

  @override
  ContactImportState get initialState => ContactsImportInitial();

  @override
  Stream<ContactImportState> mapEventToState(ContactImportEvent event) async* {
    if (event is MarkContactsAsInitiallyLoaded) {
      markContactsAsInitiallyLoaded();
    } else if (event is PerformImport) {
      loadSystemContacts();
    } else if (event is ImportPerformed) {
      yield ContactsImportSuccess(changedCount: event.changedCount);
    } else if (event is ImportAborted) {
      yield ContactsImportFailure();
    }
  }

  Future<bool> isInitialContactsOpening() async {
    bool systemContactImportShown = await getPreference(preferenceSystemContactsImportShown);
    return systemContactImportShown == null || !systemContactImportShown;
  }

  void markContactsAsInitiallyLoaded() async {
    await setPreference(preferenceSystemContactsImportShown, true);
  }

  void loadSystemContacts() async {
    bool hasContactPermission = await hasPermission(PermissionGroup.contacts);
    if (hasContactPermission) {
      Iterable<SystemContacts.Contact> contacts = await SystemContacts.ContactsService.getContacts();
      String addressBook = "";
      contacts.forEach((contact) {
        if (contact.emails.length != 0) {
          contact.emails.forEach((email) {
            addressBook += "${contact.displayName}\n${email.value}\n";
          });
        }
      });
      contactRepository.clear();
      Context context = Context();
      int changedCount = await context.addAddressBook(addressBook);
      dispatch(ImportPerformed(changedCount: changedCount));
    } else {
      dispatch(ImportAborted());
    }
  }

}
