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

import 'package:delta_chat_core/delta_chat_core.dart' as dcc;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ox_coi/src/chat/chat.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/extensions/string_apis.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/lifecycle/lifecycle_bloc.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/utils/constants.dart';

class DisplayNotificationManager {
  static const _androidIconPath = '@mipmap/ic_notification';
  static const _payloadIdSeparator = "_";
  static const _payloadChatIdPosition = 0;
  static const _payloadMessageIdPosition = 1;

  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final platformChannelSpecifics = NotificationDetails(
    AndroidNotificationDetails(
      kNotificationChannelMainId,
      L10n.get(L.notificationChannelTitle),
      L10n.get(L.notificationChannelDescription),
      importance: Importance.Max,
      priority: Priority.High,
    ),
    IOSNotificationDetails(),
  );

  static DisplayNotificationManager _instance;

  BuildContext _buildContext;

  factory DisplayNotificationManager() => _instance ??= new DisplayNotificationManager._internal();

  DisplayNotificationManager._internal();

  Future<void> setupAsync(BuildContext buildContext) async {
    this._buildContext = buildContext;
    final initializationSettingsAndroid = AndroidInitializationSettings(_androidIconPath);
    final initializationSettingsIOS = IOSInitializationSettings();
    final initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) {
    Navigation navigation = Navigation();
    if (!payload.isNullOrEmpty()) {
      int chatId = getIdFromPayload(payload, _payloadChatIdPosition);
      int messageId = getIdFromPayload(payload, _payloadMessageIdPosition);
      var isChatOpened = navigation.current?.equal(Navigatable(Type.chat, params: [chatId, messageId]));
      if (isChatOpened == null || !isChatOpened) {
        navigation.pushAndRemoveUntil(
          _buildContext,
          MaterialPageRoute(
            builder: (context) {
              return Chat(
                chatId: chatId,
                messageId: messageId,
                headlessStart: true,
              );
            },
          ),
          ModalRoute.withName(Navigation.root),
          Navigatable(Type.rootChildren),
        );
      } else {
        navigation.popUntilRoot(_buildContext);
      }
    } else {
      navigation.popUntilRoot(_buildContext);
    }
    return Future.value(true);
  }

  int getIdFromPayload(String payload, int idPosition) {
    var hasSeparator = payload.contains(_payloadIdSeparator);
    if (!hasSeparator && idPosition > _payloadChatIdPosition) {
      return null;
    }
    String idString = hasSeparator ? payload.split(_payloadIdSeparator)[idPosition] : payload;
    return idString != null ? int.parse(idString) : null;
  }

  Future<void> showNotificationFromPushAsync(String fromEmail, dcc.DecryptedChatMessage decryptedChatMessage) async {
    if (_buildContext != null && _isAppResumed()) {
      return;
    }
    final contactRepository = RepositoryManager.get<dcc.Contact>(RepositoryType.contact);
    String name = fromEmail;
    int chatId = decryptedChatMessage.chatId;
    await Future.forEach(contactRepository.getAll(), (dcc.Contact contact) async {
      final address = await contact.getAddress();
      if (address == fromEmail) {
        final contactName = await contact.getName();
        name = contactName.isNotEmpty ? contactName : fromEmail;
      }
    });
    await _flutterLocalNotificationsPlugin.show(chatId, name, decryptedChatMessage.content, platformChannelSpecifics, payload: chatId != 0 ? chatId.toString() : null);
  }

  Future<void> showNotificationFromLocalAsync(int chatId, String title, String body, {String payload}) async {
    if (_buildContext != null) {
      final navigation = Navigation();
      if (_isAppInForeground(navigation)) {
        final isChatOpened = navigation.current.equal(Navigatable(Type.chat, params: [chatId]));
        final isChatListOpened = navigation.current.equal(Navigatable(Type.chatList));
        if (isChatOpened || isChatListOpened) {
          return;
        }
      }
    }
    await _flutterLocalNotificationsPlugin.show(chatId, title, body, platformChannelSpecifics, payload: payload);
  }

  bool _isAppInForeground(Navigation navigation) => navigation.hasElements() && _isAppResumed();

  bool _isAppResumed() => BlocProvider.of<LifecycleBloc>(_buildContext).currentBackgroundState == AppLifecycleState.resumed.toString();

  Future<bool> isAppLaunchedFromNotificationAsync() async {
    final notificationAppLaunchDetails = await _flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    return notificationAppLaunchDetails.didNotificationLaunchApp;
  }

  Future<void> cancelNotificationAsync(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<dynamic> cancelAllNotificationsAsync() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
