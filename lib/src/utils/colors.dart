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

// Global
final Color primary = Colors.blue[600];
const Color accent = Colors.blue;
const Color transparent = Colors.transparent;

// Text
const Color text = Colors.white;
const Color textDisabled = Colors.black26;
const Color textLessImportant = Colors.black45;
const Color textInverted = Colors.white;

// Icons / images
const Color appBarIcon = Colors.white;

// Progress
final Color progressBackground = Colors.black45;

// Login
const Color loginHintBackground = Colors.blueGrey;

// Chat
final Color chatComposeBorder = Colors.black12;

// Messages
const Color messageBoxGrey = Colors.grey;
final Color messageSentBackground = Colors.blue[50];
const Color messageReceivedBackground = Colors.white;
final Color messageTimeForeground = Colors.grey[700];
const Color messageInfoBackground = Colors.white70;
final Color messageSetupBackground = Colors.blue[200];
const Color messageListDateSeparatorForeground = Colors.black54;

// Avatar
const Color avatarDefaultBackground = Colors.blue;
const Color avatarForegroundColor = Colors.white;

// Profile
final Color editUserAvatarPlaceholderIconColor = Colors.white54;
const Color editUserAvatarEditIconColor = Colors.white;
