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
import 'package:ox_coi/src/data/config_extension.dart';
import 'package:ox_coi/src/extensions/numbers_apis.dart';
import 'package:ox_coi/src/extensions/string_apis.dart';

class InvalidConfigKeyException implements Exception {
  final String key;

  InvalidConfigKeyException(this.key);

  @override
  String toString() {
    return 'Key must be valid, unknown key "$key" found.';
  }
}

class ReadOnlyConfigValueException implements Exception {
  final String key;

  ReadOnlyConfigValueException(this.key);

  @override
  String toString() {
    return 'Value for key is read only, could not write value for key "$key".';
  }
}

class Config {
  final _logger = Logger("config");

  static Config _instance;

  Context _context = Context();
  String username;
  String status;
  String avatarPath;
  String email;
  String imapLogin;
  String imapServer;
  String imapPort;
  String imapSecurity;
  String smtpLogin;
  String smtpServer;
  String smtpPort;
  String smtpSecurity;
  int showEmails;
  int rfc724MsgIdPrefix;
  int maxAttachSize;
  bool mdnsEnabled;
  bool coiSupported;
  bool coiEnabled;
  bool coiMessageFilterEnabled;

  factory Config() {
    if (_instance == null) {
      _instance = Config._internal();
    }
    return _instance;
  }

  Config._internal();

  void reset() {
    _instance = Config._internal();
  }

  loadAsync() async {
    _logger.info('Loading config');
    username = await _context.getConfigValueAsync(Context.configDisplayName);
    avatarPath = await _context.getConfigValueAsync(Context.configSelfAvatar);
    status = await _context.getConfigValueAsync(Context.configSelfStatus);
    email = await _context.getConfigValueAsync(Context.configAddress);
    imapLogin = await _context.getConfigValueAsync(Context.configMailUser);
    imapServer = await _context.getConfigValueAsync(Context.configMailServer);
    imapPort = await _context.getConfigValueAsync(Context.configMailPort);
    smtpLogin = await _context.getConfigValueAsync(Context.configSendUser);
    smtpServer = await _context.getConfigValueAsync(Context.configSendServer);
    smtpPort = await _context.getConfigValueAsync(Context.configSendPort);
    imapSecurity = await _context.getConfigValueAsync(Context.configImapSecurity);
    smtpSecurity = await _context.getConfigValueAsync(Context.configSmtpSecurity);
    showEmails = await _context.getConfigValueAsync(Context.configShowEmails, ObjectType.int);
    rfc724MsgIdPrefix = await _context.getConfigValueAsync(Context.configRfc724MsgIdPrefix, ObjectType.int);
    maxAttachSize = await _context.getConfigValueAsync(Context.configMaxAttachSize, ObjectType.int);
    mdnsEnabled = await _context.getConfigValueAsync(Context.configMdnsEnabled, ObjectType.int) == 1;

    coiSupported = (await _context.isCoiSupportedAsync()) == 1;
    coiEnabled = (await _context.isCoiEnabledAsync()) == 1;
    coiMessageFilterEnabled = (await _context.isCoiMessageFilterEnabledAsync()) == 1;
  }

  Future<void> setValueAsync(String key, var value) async {
    ObjectType type = isTypeInt(key) ? ObjectType.int : ObjectType.String;
    if (type == ObjectType.String && !isEmptyStringValid(key)) {
      value = convertEmptyStringToNull(value);
    }

    switch (key) {
      case Context.configDisplayName:
        username = value;
        break;
      case Context.configSelfAvatar:
        avatarPath = value;
        break;
      case Context.configSelfStatus:
        status = value;
        break;
      case Context.configAddress:
        email = value;
        break;
      case Context.configMailUser:
        imapLogin = value;
        break;
      case Context.configMailServer:
        imapServer = value;
        break;
      case Context.configMailPort:
        imapPort = value;
        break;
      case Context.configSendUser:
        smtpLogin = value;
        break;
      case Context.configSendServer:
        smtpServer = value;
        break;
      case Context.configSendPort:
        smtpPort = value;
        break;
      case Context.configShowEmails:
        showEmails = value;
        break;
      case Context.configRfc724MsgIdPrefix:
        rfc724MsgIdPrefix = value;
        break;
      case Context.configMaxAttachSize:
        maxAttachSize = value;
        break;
      case Context.configMdnsEnabled:
        mdnsEnabled = (value as int).toBool();
        break;
      case ConfigExtension.coiSupported:
        throw ReadOnlyConfigValueException(key);
      case ConfigExtension.coiEnabled:
        coiEnabled = (value as int).toBool();
        await _context.setCoiEnabledAsync(value, 1);
        break;
      case ConfigExtension.coiMessageFilterEnabled:
        coiMessageFilterEnabled = (value as int).toBool();
        await _context.setCoiMessageFilterAsync(value, 1);
        break;
      case Context.configMailPassword:
      case Context.configSendPassword:
      case Context.configImapSecurity:
      case Context.configSmtpSecurity:
        // No actions required
        break;
      default:
        throw InvalidConfigKeyException(key);
    }
    if (shouldPersistsViaContextSetConfig(key)) {
      await _context.setConfigValueAsync(key, value, type);
    }
    _logConfigChange(value, key);
  }

  void _logConfigChange(value, String key) {
    if (key == Context.configMailPassword || key == Context.configSendPassword) {
      value = "*****";
    }
    _logger.info('Value "$value" for key "$key" successfully set and persisted');
  }

  bool isTypeInt(String key) =>
      key == Context.configShowEmails ||
      key == Context.configMdnsEnabled ||
      key == Context.configRfc724MsgIdPrefix ||
      key == Context.configMaxAttachSize ||
      key == ConfigExtension.coiEnabled ||
      key == ConfigExtension.coiMessageFilterEnabled;

  bool isEmptyStringValid(String key) => key == Context.configDisplayName || key == Context.configSelfAvatar || key == Context.configSelfStatus;

  String convertEmptyStringToNull(String value) => value.isNullOrEmpty() ? null : value;

  bool shouldPersistsViaContextSetConfig(String key) => !ConfigExtension.getAll.contains(key);
}
