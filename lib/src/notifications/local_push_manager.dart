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

class LocalPushManager {
  static LocalPushManager _instance;
  final Logger _logger = Logger("local_push_manager");

  Repository<Chat> _chatRepository = RepositoryManager.get(RepositoryType.chat);
  Repository<ChatMsg> _temporaryMessageRepository = ChatMessageRepository(ChatMsg.getCreator());
  PublishSubject<Event> _messageSubject = new PublishSubject();
  DeltaChatCore _core = DeltaChatCore();
  Context _context = Context();
  NotificationManager _notificationManager;
  bool _listenersRegistered = false;

  factory LocalPushManager() => _instance ??= LocalPushManager._internal();

  LocalPushManager._internal();

  Future<void> setup() async {
    if (!_listenersRegistered) {
      _listenersRegistered = true;
      _notificationManager = NotificationManager();
      _messageSubject.listen(_successCallback);
      await _core.listen(Event.incomingMsg, _messageSubject);
    }
  }

  Future<void> tearDown() async {
    if (_listenersRegistered) {
      _core.removeListener(Event.incomingMsg, _messageSubject);
      _listenersRegistered = false;
    }
  }

  void _successCallback(Event event) {
    _logger.info("Callback event for local push received");
    triggerLocalPush();
  }

  Future<void> triggerLocalPush() async {
    _logger.info("Local push triggered");
    List<int> createdNotifications = List();
    List<int> freshMessages = await getAndFilterFreshMessages();
    Future.forEach(freshMessages, (int messageId) async {
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
        _notificationManager.showNotificationFromLocal(chatId, title, teaser, payload: chatId.toString());
      }
    });
  }

  Future<List<int>> getAndFilterFreshMessages() async {
    var freshMessages = List<int>.from(await _context.getFreshMessages());
    freshMessages.removeWhere((int messageId) => _temporaryMessageRepository.contains(messageId));
    _temporaryMessageRepository.putIfAbsent(ids: freshMessages);
    _logger.info("Temporary push repository contains ${_temporaryMessageRepository.length()} messages");
    return freshMessages;
  }
}
