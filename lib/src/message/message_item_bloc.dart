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
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/message/message_item_event.dart';
import 'package:ox_coi/src/message/message_item_state.dart';
import 'package:ox_coi/src/utils/colors.dart';

class MessageItemBloc extends Bloc<MessageItemEvent, MessageItemState> {
  Repository<Contact> _contactRepository;
  Repository<ChatMsg> _messageListRepository;
  int _messageId;
  int _contactId;
  bool _addContact;

  @override
  MessageItemState get initialState => MessageItemStateInitial();

  @override
  Stream<MessageItemState> mapEventToState(MessageItemState currentState, MessageItemEvent event) async* {
    if (event is RequestMessage) {
      yield MessageItemStateLoading();
      try {
        var chatId = event.chatId;
        if (isInvite(chatId)) {
          _contactRepository = RepositoryManager.get(RepositoryType.contact, ContactRepository.inviteContacts);
        } else {
          _contactRepository = RepositoryManager.get(RepositoryType.contact, ContactRepository.validContacts);
        }
        _messageListRepository = RepositoryManager.get(RepositoryType.chatMessage, chatId);
        _messageId = event.messageId;
        _addContact = event.isGroupChat || isInvite(chatId);
        if (_addContact) {
          _setupContact();
        }
        _setupMessage();
        dispatch(MessageLoaded());
      } catch (error) {
        yield MessageItemStateFailure(error: error.toString());
      }
    } else if (event is MessageLoaded) {
      ChatMsg message = _getMessage();
      bool isOutgoing = await message.isOutgoing();
      String text = await message.getText();
      bool hasFile = await message.hasFile();
      bool isSetupMessage = await message.isSetupMessage();
      bool isInfo = await message.isInfo();
      int timestamp = await message.getTimestamp();
      int state = await message.getState();
      AttachmentWrapper attachmentWrapper;
      if (hasFile) {
        attachmentWrapper = AttachmentWrapper(
          filename: await message.getFileName(),
          path: await message.getFile(),
          mimeType: await message.getFileMime(),
          size: await message.getFileBytes(),
          type: await message.getType(),
        );
      }

      ContactWrapper contactWrapper;
      if (_addContact) {
        Contact contact = _getContact();
        int contactId = contact.id;
        String contactName = await contact.getName();
        String contactAddress = await contact.getAddress();
        Color contactColor = rgbColorFromInt(await contact.getColor());
        contactWrapper = ContactWrapper(
          contactId: contactId,
          contactName: contactName,
          contactAddress: contactAddress,
          contactColor: contactColor,
        );
        yield MessageItemStateSuccess(
          messageIsOutgoing: isOutgoing,
          messageText: text,
          hasFile: hasFile,
          isSetupMessage: isSetupMessage,
          isInfo: isInfo,
          messageTimestamp: timestamp,
          state: state,
          attachmentWrapper: attachmentWrapper,
          contactWrapper: contactWrapper,
        );
      } else {
        yield MessageItemStateSuccess(
          messageIsOutgoing: isOutgoing,
          messageText: text,
          hasFile: hasFile,
          isSetupMessage: isSetupMessage,
          isInfo: isInfo,
          messageTimestamp: timestamp,
          state: state,
          attachmentWrapper: attachmentWrapper,
          contactWrapper: contactWrapper,
        );
      }
    }
  }

  bool isInvite(int chatId) => chatId == Chat.typeInvite;

  void _setupContact() async {
    ChatMsg message = _getMessage();
    _contactId = await message.getFromId();
    if (isInvite(await message.getChatId())) {
      _contactRepository.putIfAbsent(id: _contactId);
    }
    await _getContact().loadValues(keys: [
      Contact.methodContactGetName,
      Contact.methodContactGetAddress,
      Contact.methodContactGetColor,
    ]);
  }

  void _setupMessage() async {
    await _getMessage().loadValues(keys: [
      ChatMsg.methodMessageGetText,
      ChatMsg.methodMessageGetTimestamp,
      ChatMsg.methodMessageIsOutgoing,
      ChatMsg.methodMessageHasFile,
      ChatMsg.methodMessageGetFile,
      ChatMsg.methodMessageGetFileMime,
      ChatMsg.methodMessageGetType,
      ChatMsg.methodMessageGetFileBytes,
      ChatMsg.methodMessageGetFilename,
      ChatMsg.methodMessageGetState,
    ]);
  }

  Contact _getContact() {
    return _contactRepository.get(_contactId);
  }

  ChatMsg _getMessage() {
    return _messageListRepository.get(_messageId);
  }
}
