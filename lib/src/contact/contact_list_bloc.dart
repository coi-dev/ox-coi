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
import 'package:flutter/material.dart';
import 'package:ox_coi/src/contact/contact_list_event_state.dart';
import 'package:ox_coi/src/contact/contacts_updater_mixin.dart';
import 'package:ox_coi/src/data/contact_extension.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/data/repository_stream_handler.dart';
import 'package:ox_coi/src/extensions/string_apis.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/platform/preferences.dart';
import 'package:ox_coi/src/utils/constants.dart';
import 'package:ox_coi/src/utils/key_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

enum ContactImportState { success, fail }

class ContactListBloc extends Bloc<ContactListEvent, ContactListState> with ContactsUpdaterMixin {
  Repository<Contact> _contactRepository = RepositoryManager.get(RepositoryType.contact);
  final Repository<Chat> _chatRepository = RepositoryManager.get(RepositoryType.chat);
  RepositoryMultiEventStreamHandler _repositoryStreamHandler;
  int _typeOrChatId;
  List<int> _contactsSelected = List();
  String _currentSearch;
  bool _listenersRegistered = false;
  Iterable<SystemContacts.Contact> _systemContacts;
  String _coreContacts = "";
  Map<String, String> _phoneNumbers = Map();

  int get contactsSelectedCount => _contactsSelected.length;

  List<int> get contactsSelected => _contactsSelected;

  @override
  ContactListState get initialState => ContactListStateInitial();

  @override
  Stream<ContactListState> mapEventToState(ContactListEvent event) async* {
    if (event is RequestContacts) {
      yield ContactListStateLoading();
      try {
        _currentSearch = null;
        _typeOrChatId = event.typeOrChatId;
        _registerListeners();
        yield* _setupContactsAsync(chatId: event.chatId);
      } catch (error) {
        yield ContactListStateFailure(error: error.toString());
      }
    } else if (event is SearchContacts) {
      try {
        _currentSearch = event.query;
        yield* _searchContactsAsync(chatId: event.chatId);
      } catch (error) {
        yield ContactListStateFailure(error: error.toString());
      }
    } else if (event is ContactsChanged) {
      yield ContactListStateSuccess(
        contactElements: event.ids,
        contactsSelected: _contactsSelected,
      );
    } else if (event is ContactsSearched) {
      yield ContactListStateSuccess(
        contactElements: event.ids,
        contactsSelected: _contactsSelected,
      );
    } else if (event is AddGoogleContacts) {
      yield* _addUpdateContactsAsync(changeEmails: event.changeEmail);
    } else if (event is ContactsSelectionChanged) {
      yield* _selectionChangedAsync(event.id, event.chatId);
    } else if (event is MarkContactsAsInitiallyLoaded) {
      await _markContactsAsInitiallyLoadedAsync();
    } else if (event is PerformImport) {
      _systemContacts = await _loadSystemContactsAsync();
      if (_systemContacts == null && event.shouldUpdateUi) {
        yield* _setupContactsAsync(importState: ContactImportState.fail);
      } else {
        yield ContactListStateLoading();
        yield* _importSystemContactsAsync(event.shouldUpdateUi);
      }
    }
  }

  @override
  Future<void> close() {
    _unregisterListeners();
    return super.close();
  }

  void _registerListeners() {
    if (!_listenersRegistered) {
      _listenersRegistered = true;
      _repositoryStreamHandler = RepositoryMultiEventStreamHandler(Type.publish, [Event.contactsChanged, Event.chatModified], _onContactsChanged);
      _contactRepository.addListener(_repositoryStreamHandler);
    }
  }

  void _unregisterListeners() {
    if (_listenersRegistered) {
      _listenersRegistered = false;
      _contactRepository.removeListener(_repositoryStreamHandler);
    }
  }

  void _onContactsChanged([event]) async {
    List<int> ids = await getIdsAsync(_typeOrChatId);
    final contactHeaderList = await _mergeHeaderAndContactsAsync(contactIds: ids);
    add(ContactsChanged(ids: contactHeaderList));
  }

  void _onContactSelected(int chatId) async {
    List<int> ids = await getIdsAsync(_typeOrChatId);
    final contactHeaderList = await _mergeHeaderAndContactsAsync(contactIds: ids, chatId: chatId);
    add(ContactsChanged(ids: contactHeaderList));
  }

  Stream<ContactListStateSuccess> _setupContactsAsync({int chatId, ContactImportState importState}) async* {
    List<int> contactIds = await getIdsAsync(_typeOrChatId);
    _contactRepository.update(ids: contactIds);
    var contactExtensionProvider = ContactExtensionProvider();
    await Future.forEach(contactIds, (contactId) async {
      var contactExtension = await contactExtensionProvider.get(contactId: contactId);
      if (contactExtension != null) {
        _contactRepository.get(contactId).set(ContactExtension.contactPhoneNumber, contactExtension.phoneNumbers);
        _contactRepository.get(contactId).set(ContactExtension.contactAvatar, contactExtension.avatar);
      }
    });

    final contactHeaderList = await _mergeHeaderAndContactsAsync(contactIds: contactIds, chatId: chatId);

    yield ContactListStateSuccess(
      contactElements: contactHeaderList,
      contactsSelected: _contactsSelected,
      importState: importState,
    );
  }

  Future<List<dynamic>> _mergeHeaderAndContactsAsync({List<int> contactIds, int chatId}) async {
    final headerList = List();
    final context = Context();
    List<int> chatParticipants;
    var meHeader = L10n.get(L.contactOwnCardGroupHeaderText);
    var meContactDetails;

    if (chatId != null) {
      chatParticipants = await context.getChatContactsAsync(chatId);
    }

    await Future.forEach(contactIds, (id) async {
      if (chatParticipants != null && chatParticipants.contains(id)) {
        return;
      }
      final Contact contact = _contactRepository.get(id);
      final String name = await contact.getNameAsync();
      final String email = await contact.getAddressAsync();
      final int lastUpdate = contact.lastUpdate;
      final index = contactIds.indexOf(id);
      final previousContactId = (index > 0) ? contactIds[index - 1] : null;

      if (Contact.idSelf == id) {
        meContactDetails = createKeyFromId(id, [lastUpdate]);
        return;
      }
      String headerText = name.isNullOrEmpty() ? email.getFirstCharacter()?.toUpperCase() : name.getFirstCharacter()?.toUpperCase();

      if (previousContactId != null) {
        String previousName = await _contactRepository.get(previousContactId).getNameAsync();
        if (previousName.isNullOrEmpty()) {
          previousName = await _contactRepository.get(previousContactId).getAddressAsync();
        }

        if (headerText == previousName.getFirstCharacter()?.toUpperCase()) {
          headerList.add(createKeyFromId(id, [lastUpdate]));
        } else {
          headerList.add(headerText);
          headerList.add(createKeyFromId(id, [lastUpdate]));
        }
      } else {
        headerList.add(headerText);
        headerList.add(createKeyFromId(id, [lastUpdate]));
      }
    });
    if (showMe(contactIds, chatParticipants)) {
      headerList.add(meHeader);
      headerList.add(meContactDetails);
    }
    return headerList;
  }

  bool showMe(List<int> contactIds, List<int> chatParticipants) {
    return contactIds.contains(Contact.idSelf) && (chatParticipants == null || !chatParticipants.contains(Contact.idSelf));
  }

  Stream<ContactListStateSuccess> _searchContactsAsync({@required int chatId}) async* {
    Context context = Context();
    List<int> contactIds = List.from(await context.getContactsAsync(2, _currentSearch));
    final contactHeaderList = await _mergeHeaderAndContactsAsync(contactIds: contactIds, chatId: chatId);

    yield ContactListStateSuccess(
      contactElements: contactHeaderList,
      contactsSelected: _contactsSelected,
    );
  }

  Stream<ContactListStateSuccess> _selectionChangedAsync(int id, chatId) async* {
    if (_contactsSelected.contains(id)) {
      _contactsSelected.remove(id);
    } else {
      _contactsSelected.add(id);
    }
    if (_currentSearch.isNullOrEmpty()) {
      _onContactSelected(chatId);
    } else {
      yield* _searchContactsAsync(chatId: chatId);
    }
  }

  Future<bool> isInitialContactsOpeningAsync() async {
    bool systemContactImportShown = await getPreference(preferenceSystemContactsImportShown);
    return systemContactImportShown == null || !systemContactImportShown;
  }

  Future<void> _markContactsAsInitiallyLoadedAsync() async {
    await setPreference(preferenceSystemContactsImportShown, true);
  }

  Future<Iterable<SystemContacts.Contact>> _loadSystemContactsAsync() async {
    bool hasContactPermission = await Permission.contacts.request().isGranted;
    if (hasContactPermission) {
      return await SystemContacts.ContactsService.getContacts();
    } else {
      return null;
    }
  }

  Stream<ContactListState> _importSystemContactsAsync(bool shouldUpdateUi) async* {
    bool googlemailDetected = false;

    _systemContacts.forEach((contact) {
      if (contact.emails.length != 0) {
        contact.emails.forEach((email) {
          if (email.value.isEmail) {
            if (shouldUpdateUi && !googlemailDetected) {
              googlemailDetected = email.value.contains(googlemailDomain);
            }
            _coreContacts += getFormattedContactData(contact, email);
            updatePhoneNumbers(_phoneNumbers, contact, email);
          }
        });
      }
    });

    if (googlemailDetected) {
      yield GooglemailContactsDetected();
    } else {
      yield* _addUpdateContactsAsync(changeEmails: false, shouldUpdateUi: shouldUpdateUi);
    }
  }

  Stream<ContactListState> _addUpdateContactsAsync({@required bool changeEmails, bool shouldUpdateUi = true}) async* {
    final context = Context();
    if (changeEmails) {
      _coreContacts = _coreContacts.replaceAll(googlemailDomain, gmailDomain);
    }
    await _updateContactsAsync(_coreContacts, context);

    if (_phoneNumbers.isNotEmpty) {
      List<int> ids = List.from(await context.getContactsAsync(2, null));
      await _updateContactExtensionsAsync(ids, _phoneNumbers);
    }

    await Future.forEach(_contactRepository.getAll(), (contact) async {
      await _updateAvatarAsync(_systemContacts, contact);
      if (shouldUpdateUi) {
        await _reloadChatNameAsync(context, contact.id);
      }
    });
    _systemContacts = null;
    _phoneNumbers.clear();

    if (shouldUpdateUi) {
      yield* _setupContactsAsync(importState: ContactImportState.success);
    }
  }

  Future<void> _reloadChatNameAsync(Context context, int contactId) async {
    int chatId = await context.getChatByContactIdAsync(contactId);
    if (chatId != 0) {
      Chat chat = _chatRepository.get(chatId);
      chat.reloadValueAsync(Chat.methodChatGetName);
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

  Future<void> _updateAvatarAsync(Iterable<SystemContacts.Contact> systemContacts, Contact contact) async {
    final avatarPath = await _avatarPathAsync();
    final contactEmail = await contact.getAddressAsync();
    final contactExtensionProvider = ContactExtensionProvider();
    final contactId = contact.id;

    systemContacts.forEach((systemContact) {
      systemContact.emails.forEach((email) async {
        if (email.value.isEmail && contactEmail == email.value) {
          String filePath = "";
          // ignore: null_aware_before_operator
          if (systemContact.avatar != null && systemContact.avatar.length > 0) {
            _contactRepository.update(id: contactId);
            filePath = "$avatarPath/${email.value}_avatar.png";
            File file = File(filePath);
            FileImage image = FileImage(file);
            image.evict();
            await file.writeAsBytes(systemContact.avatar);
          }
          var contactExtension = await contactExtensionProvider.get(contactId: contactId);
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

  Future<int> _updateContactsAsync(String coreContacts, Context context) async {
    int changedCount = 0;
    if (coreContacts != null && coreContacts.isNotEmpty) {
      changedCount = await context.addAddressBookAsync(coreContacts);
    }
    return changedCount;
  }

  Future _updateContactExtensionsAsync(List<int> contactIds, Map<String, String> phoneNumbers) async {
    var contactExtensionProvider = ContactExtensionProvider();
    _contactRepository.update(ids: contactIds);
    contactIds.forEach((contactId) async {
      var contact = _contactRepository.get(contactId);
      var mail = await contact.getAddressAsync();
      var contactPhoneNumbers = phoneNumbers[mail];
      var contactExtension = await contactExtensionProvider.get(contactId: contactId);
      if (contactPhoneNumbers != null && contactPhoneNumbers.isNotEmpty) {
        if (contactExtension == null) {
          contactExtension = ContactExtension(contactId, phoneNumbers: contactPhoneNumbers);
          contactExtensionProvider.insert(contactExtension);
        } else {
          contactExtension.phoneNumbers = contactPhoneNumbers;
          contactExtensionProvider.update(contactExtension);
        }
      } else {
        if (contactExtension != null) {
          contactExtension.phoneNumbers = "";
          contactExtensionProvider.update(contactExtension);
        }
      }
    });
  }

  Future<String> _avatarPathAsync() async {
    final applicationSupportDirectory = await getApplicationSupportDirectory();
    final avatarPath = "${applicationSupportDirectory.path}/avatars";
    final avatarDir = Directory(avatarPath);
    if (await avatarDir.exists() == false) {
      avatarDir.createSync(recursive: true);
    }
    return avatarPath;
  }
}
