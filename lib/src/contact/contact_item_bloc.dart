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
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/material.dart';
import 'package:ox_coi/src/contact/contact_item_event_state.dart';
import 'package:ox_coi/src/data/contact_extension.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/extensions/color_apis.dart';
import 'package:ox_coi/src/extensions/string_apis.dart';
import 'package:ox_coi/src/invite/invite_mixin.dart';
import 'package:ox_coi/src/utils/constants.dart';

import 'contact_change.dart';

enum ContactChangeType {
  add,
  edit,
  delete,
  block,
  unblock,
}

class ContactItemBloc extends Bloc<ContactItemEvent, ContactItemState> with InviteMixin {
  final Repository<Chat> _chatRepository = RepositoryManager.get(RepositoryType.chat);
  Repository<Contact> _contactRepository = RepositoryManager.get(RepositoryType.contact);

  ContactItemBloc();

  @override
  ContactItemState get initialState => ContactItemStateInitial();

  @override
  Stream<ContactItemState> mapEventToState(ContactItemEvent event) async* {
    try {
      if (event is RequestContact) {
        yield ContactItemStateLoading();
        yield* _setupContactAsync(contactId: event.id, previousContactId: event.previousContactId);
      } else if (event is ChangeContact) {
        yield* _changeContactAsync(event.name, event.email, event.contactAction);
      } else if (event is AddGoogleContact) {
        if(event.email.isNullOrEmpty()){
          yield* _addGoogleContactAsync(event.name, event.email, event.changeEmail);
        } else {

        }
      } else if (event is DeleteContact) {
        yield* _deleteContactAsync(event.id);
      } else if (event is BlockContact) {
        yield* _blockContactAsync(event.id, event.chatId, event.messageId);
      } else if (event is UnblockContact) {
        yield* _unblockContactAsync(event.id);
      }
    } catch (error) {
      yield ContactItemStateFailure(error: error.toString());
    }
  }

  Stream<ContactItemState> _setupContactAsync({@required int contactId, @required int previousContactId}) async* {
    final Contact contact = _contactRepository.get(contactId);
    final String name = await contact.getNameAsync();
    final String email = await contact.getAddressAsync();
    final int colorValue = await contact.getColorAsync();
    final bool isVerified = await contact.isVerifiedAsync();
    final String phoneNumbers = contact.get(ContactExtension.contactPhoneNumber);
    final Color color = colorFromArgb(colorValue);

    String imagePath;
    if (Contact.idSelf == contact.id) {
      imagePath = await contact.getProfileImageAsync();
    } else {
      imagePath = contact.get(ContactExtension.contactAvatar);
    }

    final contactStateData = ContactStateData(
        id: contactId,
        name: name,
        email: email,
        color: color,
        isVerified: isVerified,
        imagePath: imagePath,
        phoneNumbers: phoneNumbers);

    yield ContactItemStateSuccess(contactStateData: contactStateData);
  }

  Stream<ContactItemState> _changeContactAsync(String name, String email, ContactAction contactAction) async* {
    Context context = Context();
    if (contactAction == ContactAction.add) {
      var contactIdByAddress = await context.getContactIdByAddressAsync(email);
      if (contactIdByAddress != 0) {
        yield ContactItemStateFailure(error: contactAddGeneric, id: contactIdByAddress);
        return;
      }
    }
    if (email.contains(googlemailDomain)) {
      yield GoogleContactDetected(name: name, email: email);
    } else {
      if (contactAction == ContactAction.add) {
        int id = await context.createContactAsync(name, email);
        final contactStateData = ContactStateData(id: id, name: name, email: email);
        yield ContactItemStateSuccess(contactStateData: contactStateData, type: ContactChangeType.add, contactHasChanged: true);
      } else {
        int contactId = await context.getContactIdByAddressAsync(email);
        int chatId = await context.getChatByContactIdAsync(contactId);
        if (chatId != 0) {
          _renameChat(chatId, name);
        }
        await context.createContactAsync(name, email);
        Contact contact = _contactRepository.get(contactId);
        contact.set(Contact.methodContactGetName, name);
        final contactStateData = (state as ContactItemStateSuccess).contactStateData.copyWith(name: name);
        yield ContactItemStateSuccess(contactStateData: contactStateData, type: ContactChangeType.edit, contactHasChanged: true);
      }
    }
  }

  void _renameChat(int chatId, String name) {
    Chat chat = _chatRepository.get(chatId);
    chat.set(Chat.methodChatGetName, name);
  }

  Stream<ContactItemState> _deleteContactAsync(int id) async* {
    final context = Context();
    final chatId = await context.getChatByContactIdAsync(id);
    final wasDeleted = await context.deleteContactAsync(id);
    if (wasDeleted) {
      _contactRepository.remove(id: id);
      await _deleteEmptyChatAsync(chatId);
      yield ContactItemStateSuccess(contactStateData: null, type: ContactChangeType.delete, contactHasChanged: true);
    } else {
      String error = chatId != 0 ? contactDeleteChatExists : contactDeleteGeneric;
      yield ContactItemStateFailure(id: id, error: error);
    }
  }

  Future<void> _deleteEmptyChatAsync(int chatId) async {
    if (chatId != 0) {
      _chatRepository.remove(id: chatId);
      final context = Context();
      await context.deleteChatAsync(chatId);
    }
  }

  Stream<ContactItemState> _blockContactAsync(int contactId, int chatId, int messageId) async* {
    if (contactId == null && messageId != null) {
      contactId = await getContactIdFromMessageAsync(messageId);
    }
    Context context = Context();
    if (chatId == null) {
      chatId = await context.getChatByContactIdAsync(contactId);
    }
    await context.blockContactAsync(contactId);
    if (isInviteChat(chatId)) {
      Repository<ChatMsg> messageListRepository = RepositoryManager.get(RepositoryType.chatMessage, Chat.typeInvite);
      messageListRepository.clear();
    }
    adjustChatListOnBlockUnblock(chatId, block: true);
    yield ContactItemStateSuccess(contactStateData: ContactStateData(id: contactId), type: ContactChangeType.block, contactHasChanged: true);
  }

  void adjustChatListOnBlockUnblock(int chatId, {bool block}) {
    if (block) {
      if (chatId != null && chatId != Chat.typeInvite) {
        _chatRepository.remove(id: chatId);
      }
    } else {
      if (chatId != 0) {
        _chatRepository.putIfAbsent(id: chatId);
      }
    }
  }

  Stream<ContactItemState> _unblockContactAsync(int id) async* {
    var contact = _contactRepository.get(id);
    Context context = Context();
    await context.unblockContactAsync(id);
    var email = await contact.getAddressAsync();
    var contactId = await context.getContactIdByAddressAsync(email);
    if (contactId == 0) {
      var name = await contact.getNameAsync();
      await context.createContactAsync(name, email);
    }
    var chatId = await context.getChatByContactIdAsync(id);
    adjustChatListOnBlockUnblock(chatId, block: false);
    yield ContactItemStateSuccess(contactStateData: ContactStateData(id: contactId), type: ContactChangeType.unblock, contactHasChanged: true);
  }

  Stream<ContactItemState> _addGoogleContactAsync(String name, String email, bool changeEmail) async* {
    Context context = Context();
    if (changeEmail) {
      email = email.replaceAll(googlemailDomain, gmailDomain);
    }

    int id = await context.createContactAsync(name, email);
    final contactStateData = ContactStateData(id: id, name: name, email: email);
    yield ContactItemStateSuccess(contactStateData: contactStateData, type: ContactChangeType.add, contactHasChanged: true);
  }
}
