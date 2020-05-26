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

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/data/notification.dart';
import 'package:ox_coi/src/data/push_chat_message.dart';
import 'package:ox_coi/src/data/push_validation.dart';
import 'package:ox_coi/src/extensions/string_apis.dart';
import 'package:ox_coi/src/notifications/notification_manager.dart';
import 'package:ox_coi/src/platform/preferences.dart';
import 'package:ox_coi/src/push/push_bloc.dart';
import 'package:ox_coi/src/push/push_event_state.dart';

class PushManager {
  static const securityChannelName = const MethodChannel("oxcoi.security");
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  var _notificationManager = NotificationManager();
  PushBloc _pushBloc;

  static PushManager _instance;

  factory PushManager() => _instance ??= PushManager._internal();

  PushManager._internal();

  Future<void> setup(PushBloc pushBloc) async {
    this._pushBloc = pushBloc;
    //firebase setup
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        var notificationData = NotificationData.fromJson(message);
        if (notificationData.valid) {
          String decryptedContent = await decrypt(notificationData.content);
          if (_isValidationPush(decryptedContent)) {
            var validation = _getPushValidation(decryptedContent).validation;
            _pushBloc.add(ValidateMetadata(validation: validation));
          } else {
            var pushChatMessage = _getPushChatMessage(decryptedContent);
            String fromEmail = pushChatMessage.fromEmail;
            String body = "I sent you a new chat message";
            await _notificationManager.showNotificationFromPush(fromEmail, body);
          }
        }
        return Future(null);
      },
      onResume: (Map<String, dynamic> message) {
        //TODO: Add functionality
        print('on resume $message');
        return Future(null);
      },
      onLaunch: (Map<String, dynamic> message) {
        //TODO: Add functionality
        print('on launch $message');
        return Future(null);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((token) {
      //TODO Use in production
      //_pushBloc.add(PatchPushResource(pushToken: token));
    });
  }

  Future<String> getPushToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<String> getPushResource() async {
    return await getPreference(preferenceNotificationsPush);
  }

  Future<String> decrypt(String base64content) async {
    return await securityChannelName.invokeMethod('decrypt', {"input": base64content});
  }

  bool _isValidationPush(String decryptedContent) {
    var pushValidationMap = jsonDecode(decryptedContent);
    var pushValidation = PushValidation.fromJson(pushValidationMap);
    return !pushValidation.validation.isNullOrEmpty();
  }

  PushValidation _getPushValidation(String decryptedContent) {
    var pushValidationMap = jsonDecode(decryptedContent);
    return PushValidation.fromJson(pushValidationMap);
  }

  PushChatMessage _getPushChatMessage(String decryptedContent) {
    var pushValidationMap = jsonDecode(decryptedContent);
    return PushChatMessage.fromJson(pushValidationMap);
  }
}
