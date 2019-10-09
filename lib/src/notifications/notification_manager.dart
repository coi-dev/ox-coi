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

import 'package:delta_chat_core/delta_chat_core.dart' as DeltaChatCore;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ox_coi/src/background/background_bloc.dart';
import 'package:ox_coi/src/chat/chat.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/utils/text.dart';

class NotificationManager {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  //TODO: Add better AndroidNotificationDetails
  final platformChannelSpecifics = NotificationDetails(
    AndroidNotificationDetails(
      'com.android.oxcoi.notification.single',
      'Message notification',
      'Notification for incoming messages',
      importance: Importance.Max,
      priority: Priority.High,
    ),
    IOSNotificationDetails(),
  );

  static NotificationManager _instance;

  BuildContext _buildContext;

  factory NotificationManager() => _instance ??= new NotificationManager._internal();

  NotificationManager._internal();

  void setup(BuildContext buildContext) {
    this._buildContext = buildContext;
    //localNotification setup
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_notification');
    var initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);
  }

  Future onDidReceiveLocalNotification(int id, String title, String body, String payload) {
    //TODO: Use payload to navigate to the right location/chat
    debugPrint("NotificationManager.onDidRecieveLocalNotification() payload = $payload");
  }

  Future onSelectNotification(String payload) {
    Navigation navigation = Navigation();
    if (!isNullOrEmpty(payload)) {
      var chatId = int.parse(payload);
      var isChatNavigatable = navigation.current?.equal(Navigatable(Type.chat, params: [chatId]));
      if (isChatNavigatable == null || !isChatNavigatable) {
        navigation.pushAndRemoveUntil(
          _buildContext,
          MaterialPageRoute(
            builder: (context) {
              return Chat(
                chatId: chatId,
                headlessStart: true,
              );
            },
          ),
          ModalRoute.withName(Navigation.root),
          Navigatable(Type.chatList),
        );
      } else {
        navigation.popUntil(_buildContext, ModalRoute.withName(Navigation.root));
      }
    }
  }

  Future<void> showNotificationFromPush(String fromEmail, String body) async {
    if (_buildContext != null) {
      var backgroundBloc = BlocProvider.of<BackgroundBloc>(_buildContext);
      if (backgroundBloc.currentBackgroundState == AppLifecycleState.resumed.toString()) {
        return;
      }
    }
    Repository<DeltaChatCore.Contact> _contactRepository = RepositoryManager.get(RepositoryType.contact);
    String name = fromEmail;
    int chatId;
    await Future.forEach(_contactRepository.getAll(), (DeltaChatCore.Contact contact) async {
      String address = await contact.getAddress();
      if (address == fromEmail) {
        var contactName = await contact.getName();
        name = contactName.isNotEmpty ? contactName : fromEmail;
        var context = DeltaChatCore.Context();
        chatId = await context.getChatByContactId(contact.id);
      }
    });
    await _flutterLocalNotificationsPlugin.show(chatId, name, body, platformChannelSpecifics, payload: chatId != 0 ? chatId.toString(): null);
  }

  Future<void> showNotificationFromLocal(int chatId, String title, String body, {String payload}) async {
    var backgroundBloc;
    if (_buildContext != null) {
      backgroundBloc = BlocProvider.of<BackgroundBloc>(_buildContext);
      var navigation = Navigation();
      if (navigation.hasElements() && backgroundBloc?.currentBackgroundState == AppLifecycleState.resumed.toString()) {
        var isChatNavigatable = navigation.current.equal(Navigatable(Type.chat, params: [chatId]));
        var isChatListNavigatable = navigation.current.equal(Navigatable(Type.chatList));
        if (isChatNavigatable || isChatListNavigatable) {
          return;
        }
      }
    }
    await _flutterLocalNotificationsPlugin.show(chatId, title, body, platformChannelSpecifics, payload: payload);
  }

  //show group notification (Android only)
  Future<void> showGroupNotification(int chatId, String title, String body, {String payload}) async {
    //TODO: Add better names
    String groupKey = 'com.android.oxcoi.WORK_EMAIL';
    String groupChannelId = 'com.android.oxcoi.notification.group';
    String groupChannelName = 'Group notification';
    String groupChannelDescription = 'Notification for grouped messages';

    AndroidNotificationDetails androidNotificationSpecifics = new AndroidNotificationDetails(
        groupChannelId, groupChannelName, groupChannelDescription,
        importance: Importance.Max, priority: Priority.High, groupKey: groupKey);
    NotificationDetails notificationPlatformSpecifics = new NotificationDetails(androidNotificationSpecifics, null);
    await _flutterLocalNotificationsPlugin.show(chatId, title, body, notificationPlatformSpecifics, payload: payload);

    AndroidNotificationDetails androidSummaryNotificationSpecifics = new AndroidNotificationDetails(
        groupChannelId, groupChannelName, groupChannelDescription,
        importance: Importance.Max, priority: Priority.High, groupKey: groupKey, setAsGroupSummary: true);
    NotificationDetails notificationSummaryPlatformSpecifics = new NotificationDetails(androidSummaryNotificationSpecifics, null);
    await _flutterLocalNotificationsPlugin.show(chatId, "", "", notificationSummaryPlatformSpecifics, payload: payload);
  }

  Future<bool> isAppLaunchedFromNotification() async {
    var notificationAppLaunchDetails = await _flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    return notificationAppLaunchDetails.didNotificationLaunchApp;
  }

  Future cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
