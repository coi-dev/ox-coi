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

import 'package:shared_preferences/shared_preferences.dart';

const preferenceSystemContactsImportShown = "preferenceSystemContactsImportShown";
const preferenceAppVersion = "preferenceAppVersion";
const preferenceLogFiles = "preferenceLogFiles";
const preferenceAntiMobbing = "preferenceAntiMobbing";
const preferenceNotificationsPull = "preferenceNotificationsPull";
const preferenceNotificationsPush = "preferenceNotificationsPush";
const preferenceNotificationsPushServiceUrl = "preferenceNotificationsPushServiceUrl";
const preferenceNotificationsEndpoint = "preferenceNotificationsEndpoint";
const preferenceNotificationsPushStatus = "preferenceNotificationsPushStatus";
const preferenceAppState = "preferenceAppState";
const preferenceInviteServiceUrl = "preferenceInviteServiceUrl";
const preferenceHasAuthenticationError = "preferenceHasAuthenticationError";
const preferenceApplicationTheme = "preferenceApplicationTheme";
const preferenceNeedsOnboarding = "preferenceNeedsOnboarding";
const preferenceNotificationHistory = "preferenceNotificationHistory";
const preferenceNotificationInviteHistory = "preferenceNotificationInviteHistory";

const preferenceNotificationsAuth = "preferenceNotificationAuth";
const preferenceNotificationKeyPublic = "preferenceNotificationKeyPublic";
const preferenceNotificationKeyPrivate = "preferenceNotificationKeyPrivate";

Future<dynamic> getPreference(String key) async {
  SharedPreferences sharedPreferences = await getSharedPreferences();
  var preference = sharedPreferences.get(key);
  if (preference is List) {
    return List<String>.from(preference);
  }
  return preference;
}

Future<SharedPreferences> getSharedPreferences() async {
  return await SharedPreferences.getInstance();
}

Future<void> setPreference(String key, value) async {
  SharedPreferences sharedPreferences = await getSharedPreferences();
  if (value is bool) {
    sharedPreferences.setBool(key, value);
  } else if (value is int) {
    sharedPreferences.setInt(key, value);
  } else if (value is double) {
    sharedPreferences.setDouble(key, value);
  } else if (value is String) {
    sharedPreferences.setString(key, value);
  } else if (value is List) {
    sharedPreferences.setStringList(key, value);
  }
}

Future<void> removePreference(String key) async {
  SharedPreferences sharedPreferences = await getSharedPreferences();
  sharedPreferences.remove(key);
}

Future<void> clearPreferences() async {
  SharedPreferences sharedPreferences = await getSharedPreferences();
  await sharedPreferences.clear();
}
