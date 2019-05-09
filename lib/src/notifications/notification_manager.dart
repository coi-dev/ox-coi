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

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

//TODO: Prepare iOS project (https://pub.dev/packages/flutter_local_notifications, https://firebase.google.com/docs/cloud-messaging/ & https://firebase.google.com/docs/cloud-messaging/concept-options)
class NotificationManager{
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  static NotificationManager _instance;

  factory NotificationManager() => _instance ??= new NotificationManager._internal();

  NotificationManager._internal();

  void setupNotificationManager(){
    //localNotification setup
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: onDidRecieveLocalNotification);
    var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);

    //firebase setup
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        //TODO: Add functionality
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) {
        //TODO: Add functionality
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) {
        //TODO: Add functionality
        print('on launch $message');
      },
    );
    _firebaseMessaging.requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((token){
      //Device token for server
    });
  }

  Future onDidRecieveLocalNotification(int id, String title, String body, String payload) {
    //TODO: Use payload to navigate to the right location/chat
    debugPrint("NotificationManager.onDidRecieveLocalNotification() payload = $payload");
  }

  Future onSelectNotification(String payload) {
    //TODO: Use payload to navigate to the right location/chat
    debugPrint("NotificationManager.onSelectNotification() payload = $payload");
  }

  Future<void> showNotification(int chatId, String title, String body, {String payload}) async {
    //TODO: Add better AndroidNotificationDetails
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.android.oxtalk.notification.single', 'Message notification', 'Notification for incoming messages',
      importance: Importance.Max, priority: Priority.High, );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(chatId, title, body, platformChannelSpecifics, payload: payload);
  }

  //show group notification (Android only)
  Future<void> showGroupNotification(int chatId, String title, String body, {String payload}) async{
    //TODO: Add better names
    String groupKey = 'com.android.oxtalk.WORK_EMAIL';
    String groupChannelId = 'com.android.oxtalk.notification.group';
    String groupChannelName = 'Group notification';
    String groupChannelDescription = 'Notification for grouped messages';

    AndroidNotificationDetails androidNotificationSpecifics =
    new AndroidNotificationDetails(
        groupChannelId, groupChannelName, groupChannelDescription,
        importance: Importance.Max,
        priority: Priority.High,
        groupKey: groupKey);
    NotificationDetails notificationPlatformSpecifics = new NotificationDetails(androidNotificationSpecifics, null);
    await _flutterLocalNotificationsPlugin.show(chatId, title, body, notificationPlatformSpecifics, payload: payload);

    AndroidNotificationDetails androidSummaryNotificationSpecifics =
    new AndroidNotificationDetails(
      groupChannelId, groupChannelName, groupChannelDescription,
      importance: Importance.Max,
      priority: Priority.High,
      groupKey: groupKey,
      setAsGroupSummary: true);
    NotificationDetails notificationSummaryPlatformSpecifics = new NotificationDetails(androidSummaryNotificationSpecifics, null);
    await _flutterLocalNotificationsPlugin.show(chatId, "", "", notificationSummaryPlatformSpecifics, payload: payload);
  }

  Future<bool> isAppLaunchedFromNotification() async{
    var notificationAppLaunchDetails = await _flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    return notificationAppLaunchDetails.didNotificationLaunchApp;
  }

  Future cancelNotification(int id) async{
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future cancelAllNotifications() async{
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

}