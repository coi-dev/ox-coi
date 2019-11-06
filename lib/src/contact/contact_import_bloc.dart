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
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:contacts_service/contacts_service.dart' as SystemContacts;
import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:ox_coi/src/contact/contact_import_event_state.dart';
import 'package:ox_coi/src/data/contact_extension.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/platform/preferences.dart';
import 'package:ox_coi/src/utils/security.dart';
import 'package:ox_coi/src/utils/text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactImportBloc extends Bloc<ContactImportEvent, ContactImportState> {
  final Repository<Contact> _contactRepository = RepositoryManager.get(RepositoryType.contact);

  @override
  ContactImportState get initialState => ContactsImportInitial();

  @override
  Stream<ContactImportState> mapEventToState(ContactImportEvent event) async* {
    if (event is MarkContactsAsInitiallyLoaded) {
      markContactsAsInitiallyLoaded();
    } else if (event is PerformImport) {
      Iterable<SystemContacts.Contact> contacts = await loadSystemContacts();
      importSystemContacts(contacts);
    } else if (event is ImportPerformed) {
      yield ContactsImportSuccess();
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

  Future<Iterable<SystemContacts.Contact>> loadSystemContacts() async {
    bool hasContactPermission = await hasPermission(PermissionGroup.contacts);
    if (hasContactPermission) {
      return await SystemContacts.ContactsService.getContacts();
    } else {
      add(ImportAborted());
      return null;
    }
  }

  void importSystemContacts(Iterable<SystemContacts.Contact> systemContacts) async {
    String coreContacts = "";
    Map<String, String> phoneNumbers = Map();
    systemContacts.forEach((contact) {
      if (contact.emails.length != 0) {
        contact.emails.forEach((email) {
          if (isEmail(email.value)) {
            coreContacts += getFormattedContactData(contact, email);
            updatePhoneNumbers(phoneNumbers, contact, email);
          }
        });
      }
    });
    var context = Context();
    await updateContacts(coreContacts, context);

    if (phoneNumbers.isNotEmpty) {
      List<int> ids = List.from(await context.getContacts(2, null));
      await updateContactExtensions(ids, phoneNumbers);
    }

    final Repository<Chat> chatRepository = RepositoryManager.get(RepositoryType.chat);
    await Future.forEach(_contactRepository.getAll(), (contact) async {
      await updateAvatar(systemContacts, contact);
      await reloadChatName(context, chatRepository, contact.id);
    });
    _contactRepository.clear();
    add(ImportPerformed());
  }

  Future<void> reloadChatName(Context context, Repository<Chat> chatRepository, int contactId) async {
    int chatId = await context.getChatByContactId(contactId);
    if (chatId != 0) {
      Chat chat = chatRepository.get(chatId);
      chat.reloadValue(Chat.methodChatGetName);
    }
  }

  String getFormattedContactData(SystemContacts.Contact contact, SystemContacts.Item email) {
    return "${contact.displayName}\n${email.value}\n";
  }

  void updatePhoneNumbers(Map<String, String> phoneNumbers, SystemContacts.Contact contact, SystemContacts.Item email) {
    if (contact.phones.isNotEmpty) {
      contact.phones.forEach((phoneNumber) {
        var currentPhoneNumber = phoneNumbers[email.value];
        if (currentPhoneNumber == null) {
          phoneNumbers[email.value] = "";
        }
        phoneNumbers[email.value] += "${phoneNumber.value}\n";
      });
    }
  }

  Future<void> updateAvatar(Iterable<SystemContacts.Contact> systemContacts, Contact contact) async {
    String contactEmail = await contact.getAddress();
    var directory = await getApplicationDocumentsDirectory();
    var contactExtensionProvider = ContactExtensionProvider();
    int contactId = contact.id;

    systemContacts.forEach((systemContact) {
      systemContact.emails.forEach((email) async {
        if (isEmail(email.value) && contactEmail == email.value) {
          String filePath = "";
          if (systemContact.avatar.length > 0) {
            _contactRepository.update(id: contactId);
            filePath = "${directory.path}/${email.value}_avatar.png";
            File file = File(filePath);
            FileImage image = FileImage(file);
            image.evict();
            await file.writeAsBytes(systemContact.avatar);
          }
          var contactExtension = await contactExtensionProvider.getContactExtension(contactId: contactId);
          if (contactExtension == null) {
            contactExtension = ContactExtension(contactId, avatar: filePath);
            contactExtensionProvider.insert(contactExtension);
          } else {
            contactExtension.avatar = filePath;
            contactExtensionProvider.update(contactExtension);
          }
        }
      });
    });
  }

  Future<int> updateContacts(String coreContacts, Context context) async {
    int changedCount = 0;
    if (coreContacts != null && coreContacts.isNotEmpty) {
      changedCount = await context.addAddressBook(coreContacts);
    }
    return changedCount;
  }

  Future updateContactExtensions(List<int> contactIds, Map<String, String> phoneNumbers) async {
    var contactExtensionProvider = ContactExtensionProvider();
    _contactRepository.update(ids: contactIds);
    contactIds.forEach((contactId) async {
      var contact = _contactRepository.get(contactId);
      var mail = await contact.getAddress();
      var contactPhoneNumbers = phoneNumbers[mail];
      if (contactPhoneNumbers != null && contactPhoneNumbers.isNotEmpty) {
        var contactExtension = await contactExtensionProvider.getContactExtension(contactId: contactId);
        if (contactExtension == null) {
          contactExtension = ContactExtension(contactId, phoneNumbers: contactPhoneNumbers);
          contactExtensionProvider.insert(contactExtension);
        } else {
          contactExtension.phoneNumbers = contactPhoneNumbers;
          contactExtensionProvider.update(contactExtension);
        }
      }
    });
  }
}
