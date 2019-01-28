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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ox_talk/source/l10n/messages_all.dart';

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) {
    final String name =
    locale.countryCode == null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return new AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  //add new translations here
  //call 'flutter pub pub run intl_translation:extract_to_arb --output-dir=lib/source/l10n lib/source/l10n/localizations.dart' in the terminal
  //copy intl_messages.arb and create language specific intl_[language_code].arb files (e.g. intl_en.arb) and translate the file
  //call flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/source/l10n \ --no-use-deferred-loading lib/source/l10n/localizations.dart lib/source/l10n/intl_*.arb
  //translation complete

  String get mailTitle {
    return Intl.message('Mail', name: 'mailTitle');
  }

  String get chatTitle {
    return Intl.message('Chat', name: 'chatTitle');
  }

  String get contactsTitle {
    return Intl.message('Contacts', name: 'contactsTitle');
  }

  String get profileTitle {
    return Intl.message('Profile', name: 'profileTitle');
  }

  String get profileStatusPlaceholder{
    return Intl.message('No status', name: 'profileStatusPlaceholder');
  }

  String get editUserSettingsTitle {
    return Intl.message('Edit user settings', name: 'editUserSettingsTitle');
  }

  String get editUserSettingsUsernameLabel {
    return Intl.message('Username', name: 'editUserSettingsUsernameLabel');
  }

  String get editUserSettingsStatusLabel {
    return Intl.message('Status', name: 'editUserSettingsStatusLabel');
  }

  String get editUserSettingsSaveButton {
    return Intl.message('Save', name: 'editUserSettingsSaveButton');
  }

  String get editAccountSettingsTitle {
    return Intl.message('Edit account settings', name: 'editAccountSettingsTitle');
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    //TODO: add new locales here like: return ['en', 'es', 'de'].contains(locale.languageCode);
    return ['en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}