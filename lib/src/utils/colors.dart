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

import 'dart:ui';

import 'package:flutter/material.dart';

// Global
const Color textDisabled = Colors.black26;
const Color testLessImportant = Colors.black45;
const Color appBarIcon = Colors.white;
const Color textColorInverted = Colors.white;
const Color transparent = Colors.transparent;

Color rgbColorFromInt(int color, [int alpha]) {
  if (alpha == null) {
    alpha = 255;
  }
  return Color.fromARGB(alpha, _red(color), _green(color), _blue(color));
}

int _red(int color) {
  return (color >> 16) & 0xFF;
}

int _green(int color) {
  return (color >> 8) & 0xFF;
}

int _blue(int color) {
  return color & 0xFF;
}

// Progress
final Color progressBackground = Colors.black45;

// Login
const Color loginHintBackground = Colors.blueGrey;

// List
const Color listAvatarForegroundColor = Colors.white;
final Color listAvatarDefaultBackgroundColor = Colors.blue[700];

// Chat
const Color chatMain = Colors.blue;
final Color chatComposeBorder = Colors.black12;

// Messages
const Color messageBoxGrey = Colors.grey;
final Color messageSentBackground = Colors.blue[50];
const Color messageReceivedBackground = Colors.white;
final Color messageTimeForeground = Colors.grey[700];

// Mail
const Color mailMain = Colors.indigo;

// Contact
const Color contactMain = Colors.blueGrey;
const Color avatarDefaultBackground = Colors.blue;

// Profile
const Color profileMain = contactMain;
final Color editUserAvatarPlaceholderIconColor = Colors.white54;
const Color editUserAvatarEditIconColor = Colors.white;
