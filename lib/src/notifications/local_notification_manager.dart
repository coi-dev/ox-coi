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

import 'dart:collection';
import 'dart:convert';

import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:logging/logging.dart';
import 'package:ox_coi/src/data/chat_message_repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/notifications/notification_manager.dart';
import 'package:ox_coi/src/platform/preferences.dart';
import 'package:rxdart/rxdart.dart';

class LocalNotificationManager {
  static LocalNotificationManager _instance;

  final Logger _logger = Logger("local_notification_manager");
  final _messageSubject = PublishSubject<Event>();
  final _chatRepository = RepositoryManager.get<Chat>(RepositoryType.chat);
  final _contactRepository = RepositoryManager.get<Contact>(RepositoryType.contact);
  final _temporaryMessageRepository = ChatMessageRepository(ChatMsg.getCreator());
  final _core = DeltaChatCore();
  final _context = Context();

  NotificationManager _notificationManager;
  bool _listenersRegistered = false;

  factory LocalNotificationManager() => _instance ??= LocalNotificationManager._internal();

  LocalNotificationManager._internal();

  void setup() {
    _registerListeners();
  }

  void tearDown() {
    _unregisterListeners();
  }

  void _registerListeners() {
    if (!_listenersRegistered) {
      _listenersRegistered = true;
      _notificationManager = NotificationManager();
      _messageSubject.listen(_messagesUpdated);
      _core.addListener(eventIdList: [Event.incomingMsg, Event.msgsChanged], streamController: _messageSubject);
    }
  }

  void _unregisterListeners() {
    if (_listenersRegistered) {
      _core.removeListener(_messageSubject);
      _listenersRegistered = false;
    }
  }

  void _messagesUpdated(Event event) {
    _logger.info("Callback event for local notification received");
    triggerNotificationAsync();
  }

  Future<void> triggerNotificationAsync() async {
    _logger.info("Local notification triggered");
    await createChatNotificationsAsync();
    await createInviteNotificationsAsync();
  }

  Future createChatNotificationsAsync() async {
    final HashMap<String, int> notificationHistory = await _getNotificationHistoryAsync();
    final List<int> freshMessages = await _context.getFreshMessages();
    _temporaryMessageRepository.putIfAbsent(ids: freshMessages);
    _logger.info("Handling ${freshMessages.length} fresh messages");

    await Future.forEach(freshMessages, (int messageId) async {
      final message = _temporaryMessageRepository.get(messageId);
      final chatId = await message.getChatId();
      if (isMessageNew(notificationHistory, chatId, messageId)) {
        notificationHistory.update(chatId.toString(), (value) => messageId, ifAbsent: () => messageId);
        _chatRepository.putIfAbsent(id: chatId);
        final chat = _chatRepository.get(chatId);
        String title = await chat.getName();
        final count = (await _context.getFreshMessageCount(chatId)) - 1;
        if (count > 1) {
          title = "$title (+ ${L10n.getFormatted(L.moreMessagesX, [count])})";
        }
        final teaser = await message.getSummaryText(200);
        final payload = chatId?.toString();
        _logger.info("Creating chat notification for chat id $chatId with message id $messageId");
        _notificationManager.showNotificationFromLocal(chatId, title, teaser, payload: payload);
      }
    });

    await _setNotificationHistoryAsync(notificationHistory);
  }

  bool isMessageNew(HashMap<String, int> notificationHistory, int keyId, int messageId, {bool isInvite = false}) {
    final isNormalMessage = isInvite ? keyId > Contact.idLastSpecial : keyId > Chat.typeLastSpecial;
    if (isNormalMessage) {
      final chatIdString = keyId.toString();
      if (notificationHistory.keys.contains(chatIdString)) {
        return notificationHistory[chatIdString] < messageId;
      }
      return true;
    }
    return false;
  }

  Future<HashMap<String, int>> _getNotificationHistoryAsync({bool isInvite = false}) async {
    final preferenceTarget = isInvite ? preferenceNotificationInviteHistory : preferenceNotificationHistory;
    final notificationHistoryString = await getPreference(preferenceTarget);
    return notificationHistoryString != null ? HashMap<String, int>.from(json.decode(notificationHistoryString)) : HashMap<String, int>();
  }

  Future<void> _setNotificationHistoryAsync(HashMap<String, int> notificationHistory, {bool isInvite = false}) async {
    final preferenceTarget = isInvite ? preferenceNotificationInviteHistory : preferenceNotificationHistory;
    final notificationHistoryString = json.encode(notificationHistory);
    await setPreference(preferenceTarget, notificationHistoryString);
  }

  Future<void> createInviteNotificationsAsync() async {
    final HashMap<String, int> notificationInviteHistory = await _getNotificationHistoryAsync(isInvite: true);
    final List<int> openInvites = await _context.getChatMessages(Chat.typeInvite);
    _temporaryMessageRepository.putIfAbsent(ids: openInvites);
    _logger.info("Handling ${openInvites.length} open invites");

    await Future.forEach(openInvites.reversed, (int messageId) async {
      final message = _temporaryMessageRepository.get(messageId);
      final senderId = await message.getFromId();
      if (isMessageNew(notificationInviteHistory, senderId, messageId)) {
        notificationInviteHistory.update(senderId.toString(), (value) => messageId, ifAbsent: () => messageId);
        _contactRepository.putIfAbsent(id: senderId);
        final contact = _contactRepository.get(senderId);
        final contactName = await contact.getName();
        final contactMail = await contact.getAddress();
        String title;
        if (contactName.isNotEmpty) {
          title = L10n.getFormatted(L.chatListInviteDialogXY, [contactName, contactMail]);
        } else {
          title = L10n.getFormatted(L.chatListInviteDialogX, [contactMail]);
        }
        final teaser = await message.getSummaryText(200);
        final payload = "${Chat.typeInvite.toString()}_$messageId";
        _logger.info("Creating invite notification for sender id $senderId with message id $messageId");
        _notificationManager.showNotificationFromLocal(Chat.typeInvite, title, teaser, payload: payload);
      }
    });

    await _setNotificationHistoryAsync(notificationInviteHistory, isInvite: true);
  }
}
