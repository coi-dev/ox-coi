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
import 'package:flutter/material.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';

enum ProtocolType { imap, smtp }

String convertProtocolStringToDccString(String value) {
  String newValue = "";
  if (value == plain)
    newValue = "plain_socket";
  else if (value == sslTls)
    newValue = "ssl";
  else if (value == startTLS)
    newValue = "starttls";
  return newValue;
}

String convertProtocolDccStringToString(String value) {
  String newValue = L10n.get(L.automatic);
  if (value == "plain_socket")
    newValue = plain;
  else if (value == "ssl")
    newValue = sslTls;
  else if (value == "starttls")
    newValue = startTLS;
  return newValue;
}

int getSavedImapSecurityOption(int serverFlags) {
  int sel = 0;
  if ((serverFlags & Context.serverFlagsImapSsl) != 0) sel = 1;
  if ((serverFlags & Context.serverFlagsImapStartTls) != 0) sel = 2;
  if ((serverFlags & Context.serverFlagsImapPlain) != 0) sel = 3;
  return sel;
}

int getSavedSmtpSecurityOption(int serverFlags) {
  int sel = 0;
  if ((serverFlags & Context.serverFlagsSmtpSsl) != 0) sel = 1;
  if ((serverFlags & Context.serverFlagsSmtpStartTls) != 0) sel = 2;
  if ((serverFlags & Context.serverFlagsSmtpPlain) != 0) sel = 3;
  return sel;
}

int createServerFlagInteger(int imapOption, int smtpOption) {
  int serverFlags = 0;
  if (imapOption == 1) serverFlags |= Context.serverFlagsImapSsl;
  if (imapOption == 2) serverFlags |= Context.serverFlagsImapStartTls;
  if (imapOption == 3) serverFlags |= Context.serverFlagsImapPlain;
  if (smtpOption == 1) serverFlags |= Context.serverFlagsSmtpSsl;
  if (smtpOption == 2) serverFlags |= Context.serverFlagsSmtpStartTls;
  if (smtpOption == 3) serverFlags |= Context.serverFlagsSmtpPlain;
  return serverFlags;
}

int getErrorType(Event event) {
  if (_isErrorEvent(event)) {
    return event.data1;
  }
  return -1;
}

bool _isErrorEvent(Event event) => event?.eventId == Event.error || event?.eventId == Event.errorNoNetwork || event?.eventId == Event.errorNotInGroup;

String getErrorMessage(Event event) {
  if (_isErrorEvent(event)) {
    return event.data2;
  }
  return "";
}
