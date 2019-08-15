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

// Light theme

const background = Colors.white;
const surface = Colors.white;
const primary = const Color(0xFF0E7BCC);
const secondary = const Color(0xFF0E7BCC);
const accent = const Color(0xFF0E7BCC);
const onBackground = const Color(0xFF1F1F1F);
const onSurface = const Color(0xFF1F1F1F);
const onPrimary = Colors.white;
const onSecondary = Colors.white;
const onAccent = Colors.white;
final info = Colors.grey[300];
final onInfo = Colors.black;
const warning = Colors.yellow;
const onWarning = Colors.white;
const error = Colors.red;
const onError = Colors.white;

// Dark theme

const darkBackground = Colors.black;
const darkSurface = const Color(0xFF1F1F1F);
const darkPrimary = const Color(0xFF052D4B);
const darkSecondary = const Color(0xFF052D4B);
const darkAccent = const Color(0xFF052D4B);
const darkOnBackground = const Color(0xFFF3F3F3);
const darkOnSurface = const Color(0xFFF3F3F3);
const darkOnPrimary = const Color(0xFFF3F3F3);
const darkOnSecondary = const Color(0xFFF3F3F3);
const darkOnAccent = const Color(0xFFF3F3F3);

// Calculated values

final semiTransparent = Colors.black.withOpacity(half);

// Constants for reusable access

const fade = 0.7;
const half = 0.5;
const disabled = 0.3;
const slightly = 0.3;
const barely = 0.1;

// Helper methods to generate colors

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
