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

class BrandedTheme {
  final Color white = Colors.white;
  final Color black = Colors.black;
  final Color qrIcon = Colors.green.withAlpha(700);
  final Color flagIcon = Colors.amber[600];
  final Color inviteIcon = Colors.teal[400];
  final Color notificationIcon = Colors.cyan[700];
  final Color chatIcon = Colors.lightBlue[800];
  final Color signatureIcon = Colors.blue[600];
  final Color serverSettingsIcon = Colors.indigo[600];
  final Color appearanceIcon = Colors.deepPurple[500];
  final Color dataProtectionIcon = Colors.purple[400];
  final Color blockIcon = Colors.pink[500];
  final Color encryptionIcon = Colors.red[600];
  final Color aboutIcon = Colors.deepOrange[500];
  final Color feedbackIcon = Colors.amber[600];
  final Color bugReportIcon = Colors.red[600];
  final Color logoutIcon = Colors.blueGrey;
  final Color accent;
  final Color onAccent;
  final Color info;
  final Color onInfo;
  final Color warning;
  final Color onWarning;
  final Brightness brightness;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color secondary;
  final Color onSecondary;
  final Color error;
  final Color onError;
  final Color primary;
  final Color onPrimary;

  BrandedTheme({
    this.accent,
    this.onAccent,
    this.info,
    this.onInfo,
    this.warning,
    this.onWarning,
    this.brightness,
    this.background,
    this.onBackground,
    this.surface,
    this.onSurface,
    this.secondary,
    this.onSecondary,
    this.error,
    this.onError,
    this.primary,
    this.onPrimary
  });
}