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

class Config {
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
  int mdnsEnabled;
  int rfc724MsgIdPrefix;
  int maxAttachSize;

  factory Config() {
    if (_instance == null) {
      _instance = Config._internal();
    }
    return _instance;
  }

  Config._internal();

  void reset() {
    _instance = null;
    _instance = Config();
  }

  load() async {
    username = await _context.getConfigValue(Context.configDisplayName);
    avatarPath = await _context.getConfigValue(Context.configSelfAvatar);
    status = await _context.getConfigValue(Context.configSelfStatus);
    email = await _context.getConfigValue(Context.configAddress);
    imapLogin = await _context.getConfigValue(Context.configMailUser);
    imapServer = await _context.getConfigValue(Context.configMailServer);
    imapPort = await _context.getConfigValue(Context.configMailPort);
    smtpLogin = await _context.getConfigValue(Context.configSendUser);
    smtpServer = await _context.getConfigValue(Context.configSendServer);
    smtpPort = await _context.getConfigValue(Context.configSendPort);
    imapSecurity = await _context.getConfigValue(Context.configImapSecurity);
    smtpSecurity = await _context.getConfigValue(Context.configSmtpSecurity);
    showEmails = await _context.getConfigValue(Context.configShowEmails, ObjectType.int);
    mdnsEnabled = await _context.getConfigValue(Context.configMdnsEnabled, ObjectType.int);
    rfc724MsgIdPrefix = await _context.getConfigValue(Context.configRfc724MsgIdPrefix, ObjectType.int);
    maxAttachSize = await _context.getConfigValue(Context.configMaxAttachSize, ObjectType.int);
  }

  Future<void> setValue(String key, var value) async {
    ObjectType type = isTypeInt(key) ? ObjectType.int : ObjectType.String;
    if (key != Context.configDisplayName && key != Context.configSelfAvatar && key != Context.configSelfStatus) {
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
      case Context.configMdnsEnabled:
        mdnsEnabled = value;
        break;
      case Context.configRfc724MsgIdPrefix:
        rfc724MsgIdPrefix = value;
        break;
      case Context.configMaxAttachSize:
        maxAttachSize = value;
        break;
    }
    await _context.setConfigValue(key, value, type);
  }

  bool isTypeInt(String key) =>
      key == Context.configShowEmails ||
      key == Context.configMdnsEnabled ||
      key == Context.configRfc724MsgIdPrefix ||
      key == Context.configMaxAttachSize;

  convertEmptyStringToNull(value) {
    if (value == null || (value is String && value.isEmpty)) {
      return null;
    }
    return value;
  }
}
