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

import 'package:flutter/services.dart';
import "package:gettext/gettext.dart";
import "package:gettext_parser/gettext_parser.dart";
import 'package:ox_coi/src/utils/text.dart';
import 'package:sprintf/sprintf.dart';

class L10n {
  static const plural = 2;

  static final Gettext _getText = Gettext();
  static final _loadedLocales = List<String>();

  static String get locale => _getText.locale;

  static List<String> get loadedLocales => _loadedLocales;

  static Iterable<Locale> get supportedLocales => [
        Locale("cs"),
        Locale("da"),
        Locale("en"),
        Locale("en", "GB"),
        Locale("en", "US"),
        Locale("es"),
        Locale("es", "MX"),
        Locale("fi"),
        Locale("fr"),
        Locale("fr", "CA"),
        Locale("hu"),
        Locale("it"),
        Locale("ja"),
        Locale("lv"),
        Locale("nl"),
        Locale("pl"),
        Locale("pt"),
        Locale("ro"),
        Locale("ru"),
        Locale("sk"),
        Locale("sv"),
        Locale("zh"),
        Locale("zh", "CN"),
        Locale("zh", "TW"),
      ];

  static void loadTranslation(Locale locale) {
    if (locale == null) {
      return;
    }
    String localeString = _getLocaleString(locale);
    if (loadedLocales.contains(localeString)) {
      return;
    }
    rootBundle.loadString('assets/l10n/$localeString.po').then((data) {
      _getText.addLocale(po.parse(data));
      loadedLocales.add(localeString);
    }).catchError((error) {});
  }

  static String _getLocaleString(Locale locale) {
    if (locale == null) {
      return "en_US";
    }
    return "${locale.languageCode}_${locale.countryCode}";
  }

  static void setLanguage(Locale locale) {
    String localeString = _getLocaleString(locale);
    if (!loadedLocales.contains(localeString)) {
      loadTranslation(locale);
    }
    _getText.locale = localeString;
  }

  static String get(List<String> msgIds, {int count}) {
    String msgId = msgIds[0];
    String msgIdPlural;
    if (msgId == null) {
      throw ArgumentError("Missing msgId, could not translate");
    } else {
      msgIdPlural = msgIds[1];
    }
    if (isNullOrEmpty(msgIdPlural) || count == null) {
      return _getText.gettext(msgId);
    } else {
      return _getText.ngettext(msgId, msgIdPlural, count);
    }
  }

  static String getFormatted(List<String> msgIds, List values, {int count}) {
    if (count != null && count == 0) {
      count = plural;
    }
    String unformattedString = get(msgIds, count: count);
    return sprintf(unformattedString, values);
  }
}
