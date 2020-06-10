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

import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logging/logging.dart';
import 'package:ox_coi/src/data/push.dart';
import 'package:ox_coi/src/data/push_chat_message.dart';
import 'package:ox_coi/src/data/push_validation.dart';
import 'package:ox_coi/src/extensions/string_apis.dart';
import 'package:ox_coi/src/notifications/display_notification_manager.dart';
import 'package:ox_coi/src/platform/method_channel.dart';
import 'package:ox_coi/src/platform/preferences.dart';
import 'package:ox_coi/src/push/push_bloc.dart';
import 'package:ox_coi/src/push/push_event_state.dart';
import 'package:ox_coi/src/security/security_manager.dart';

const loggerName = "push_manager";

class PushManager {
  final _logger = Logger(loggerName);
  final _firebaseMessaging = FirebaseMessaging();
  final _notificationManager = DisplayNotificationManager();

  PushBloc _pushBloc;

  static PushManager _instance;

  factory PushManager() => _instance ??= PushManager._internal();

  PushManager._internal();

  Future<void> setup(PushBloc pushBloc) async {
    this._pushBloc = pushBloc;

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        _logger.info("Received: $message");
        final pushData = Push.fromJson(message);
        if (pushData.valid) {
          _logger.info("Data is valid");
          _logger.info("Decrypt AES started");
          final decryptedPush = await decryptAesAsync(pushData.content);
          _logger.info("Decrypt AES done");
          if (_isValidationPush(decryptedPush)) {
            _logger.info("Data is validation message");
            final pushValidationMessage = _getPushValidation(decryptedPush).validation;
            _logger.info("Decrypted data: $pushValidationMessage");
            _pushBloc.add(ValidateMetadata(validation: pushValidationMessage));
          } else {
            _logger.info("Data is chat message");
            final pushChatMessage = _getPushChatMessage(decryptedPush);
            final fromEmail = pushChatMessage.fromEmail;
            _logger.info("Decrypted data: $pushChatMessage for $fromEmail");
            var contentType = pushChatMessage.contentType;
            if (contentType.isNullOrEmpty()) {
              contentType = "text/plain; charset=utf-8";
              _logger.info("Manually setting content type to avoid null / empty value");
            }
            _logger.info("Decrypt PGP started");
            final decryptedChatMessage = await decryptPgpAsync(contentType, pushChatMessage, fromEmail);
            _logger.info("Decrypt PGP done");
            _logger.info(
                "Decrypted and mapped data: $fromEmail sent in chat ${decryptedChatMessage.chatId} the message '${decryptedChatMessage.content}'");
            await _notificationManager.showNotificationFromPushAsync(fromEmail, decryptedChatMessage);
          }
        } else {
          _logger.info("Data is *NOT* valid");
        }
        return Future(null);
      },
      onResume: (Map<String, dynamic> message) {
        //TODO: Add functionality
        _logger.info("onResume $message");
        return Future(null);
      },
      onLaunch: (Map<String, dynamic> message) {
        //TODO: Add functionality
        _logger.info("onLaunch $message");
        return Future(null);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  Future<String> getPushTokenAsync() async {
    return await _firebaseMessaging.getToken();
  }

  Future<String> getPushResourceAsync() async {
    return await getPreference(preferenceNotificationsPush);
  }

  Future<String> decryptAesAsync(String encryptedBase64Content) async {
    final privateKey = await getPushPrivateKeyAsync();
    final publicKey = await getPushPublicKeyAsync();
    final auth = await getPushAuthAsync();

    _logger.info("PrivateKey: $privateKey");
    _logger.info("PublicKey: $publicKey");
    _logger.info("Auth: $auth");

    return await SecurityChannel.instance.invokeMethod(SecurityChannel.kMethodDecrypt, {
      SecurityChannel.kArgumentContent: encryptedBase64Content,
      SecurityChannel.kArgumentPrivateKey: privateKey,
      SecurityChannel.kArgumentPublicKey: publicKey,
      SecurityChannel.kArgumentAuth: auth,
    });
  }

  Future<DecryptedChatMessage> decryptPgpAsync(String contentType, PushChatMessage pushChatMessage, String fromEmail) async {
    final context = Context();
    final decrypted = await context.decryptInMemoryAsync(contentType, pushChatMessage.content, fromEmail);
    return DecryptedChatMessage.fromMethodChannel(decrypted);
  }

  bool _isValidationPush(String decryptedContent) {
    final pushValidationMap = jsonDecode(decryptedContent);
    final pushValidation = PushValidation.fromJson(pushValidationMap);
    return !pushValidation.validation.isNullOrEmpty();
  }

  PushValidation _getPushValidation(String decryptedContent) {
    final pushValidationMap = jsonDecode(decryptedContent);
    return PushValidation.fromJson(pushValidationMap);
  }

  PushChatMessage _getPushChatMessage(String decryptedContent) {
    final pushValidationMap = jsonDecode(decryptedContent);
    return PushChatMessage.fromJson(pushValidationMap);
  }
}
