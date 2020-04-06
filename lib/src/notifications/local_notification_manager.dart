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

import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:logging/logging.dart';
import 'package:ox_coi/src/data/chat_message_repository.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/notifications/notification_manager.dart';
import 'package:rxdart/rxdart.dart';

class LocalNotificationManager {
  static LocalNotificationManager _instance;
  final Logger _logger = Logger("local_notification_manager");

  Repository<Chat> _chatRepository = RepositoryManager.get(RepositoryType.chat);
  Repository<ChatMsg> _temporaryMessageRepository = ChatMessageRepository(ChatMsg.getCreator());
  Repository<ChatMsg> _inviteMessageListRepository = RepositoryManager.get(RepositoryType.chatMessage, Chat.typeInvite);
  PublishSubject<Event> _messageSubject = new PublishSubject();
  DeltaChatCore _core = DeltaChatCore();
  Context _context = Context();
  NotificationManager _notificationManager;
  bool _listenersRegistered = false;

  factory LocalNotificationManager() => _instance ??= LocalNotificationManager._internal();

  LocalNotificationManager._internal();

  void setup() {
    if (!_listenersRegistered) {
      _listenersRegistered = true;
      _notificationManager = NotificationManager();
      _messageSubject.listen(_successCallback);
      _core.addListener(eventIdList: [Event.incomingMsg, Event.msgsChanged], streamController: _messageSubject);
    }
  }

  Future<void> tearDown() async {
    if (_listenersRegistered) {
      _core.removeListener(_messageSubject);
      _listenersRegistered = false;
    }
  }

  void _successCallback(Event event) {
    _logger.info("Callback event for local notification received");
    triggerNotification();
  }

  Future<void> triggerNotification() async {
    _logger.info("Local notification triggered");
    await createFreshMessagesNotifications();
    await createInviteNotifications();
  }

  Future createFreshMessagesNotifications() async {
    var createdNotifications = List<int>();
    List<int> notNotifiedMessages = await getNotNotifiedMessages();
    _temporaryMessageRepository.putIfAbsent(ids: notNotifiedMessages);
    Future.forEach(notNotifiedMessages, (int messageId) async {
      ChatMsg message = _temporaryMessageRepository.get(messageId);
      int chatId = await message.getChatId();
      if (!createdNotifications.contains(chatId) && chatId > Chat.typeLastSpecial) {
        Chat chat = _chatRepository.get(chatId);
        if (chat == null) {
          _chatRepository.putIfAbsent(id: chatId);
          chat = _chatRepository.get(chatId);
        }
        createdNotifications.add(chatId);
        String title = await chat.getName();
        int count = (await _context.getFreshMessageCount(chatId)) - 1;
        if (count > 1) {
          title = "$title (+ $count ${L10n.get(L.moreMessages)})";
        }
        String teaser = await message.getSummaryText(200);
        var payload = chatId?.toString();
        _notificationManager.showNotificationFromLocal(chatId, title, teaser, payload: payload);
      }
    });
  }

  Future<List<int>> getNotNotifiedMessages() async {
    var freshMessages = List<int>.from(await _context.getFreshMessages());
    freshMessages.removeWhere((int messageId) => _temporaryMessageRepository.contains(messageId));
    _logger.info("Temporary notification repository (messages) contains ${_temporaryMessageRepository.length()} messages");
    return freshMessages;
  }

  Future createInviteNotifications() async {
    var createdNotifications = List<int>();
    List<int> notNotifiedInvites = await getNotNotifiedInvites();
    _inviteMessageListRepository.putIfAbsent(ids: notNotifiedInvites);
    Repository<Contact> contactRepository = RepositoryManager.get(RepositoryType.contact);
    Future.forEach(notNotifiedInvites.reversed, (int messageId) async {
      ChatMsg invite = _inviteMessageListRepository.get(messageId);
      int senderId = await invite.getFromId();
      if (!createdNotifications.contains(senderId)) {
        createdNotifications.add(senderId);
        contactRepository.putIfAbsent(id: senderId);
        Contact contact = contactRepository.get(senderId);
        var contactName = await contact.getName();
        var contactMail = await contact.getAddress();
        String title;
        if (contactName.isNotEmpty) {
          title = L10n.getFormatted(L.chatListInviteDialogXY, [contactName, contactMail]);
        } else {
          title = L10n.getFormatted(L.chatListInviteDialogX, [contactMail]);
        }
        String teaser = await invite.getSummaryText(200);
        String payload = "${Chat.typeInvite.toString()}_$messageId";
        _notificationManager.showNotificationFromLocal(Chat.typeInvite, title, teaser, payload: payload);
      }
    });
  }

  Future<List<int>> getNotNotifiedInvites() async {
    var invites = List<int>.from(await _context.getChatMessages(Chat.typeInvite));
    invites.removeWhere((int messageId) => _inviteMessageListRepository.contains(messageId));
    _logger.info("Temporary notification repository (invites) contains ${_inviteMessageListRepository.length()} messages");
    return invites;
  }
}
