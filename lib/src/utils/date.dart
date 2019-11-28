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

import 'package:date_format/date_format.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';

const formatterDateAndTime = [dd, '.', mm, '.', yyyy, ' - ', HH, ':', nn];
const formatterTime = [HH, ':', nn];
const formatterDate = [dd, '.', mm];
const formatterDateLong = [dd, '. ', MM];
const formatterTimer = [nn, ':', ss, ':', SSS];
const formatterVideoTime = [n, ':', ss];
const formatterDateTimeFile = [yy, '-', mm, '-', dd, '_', HH, '-', nn, '-', ss];

String getTimeFormTimestamp(int timestamp) {
  return formatDate(_getDateTimeFromTimestamp(timestamp), formatterTime);
}

DateTime _getDateTimeFromTimestamp(int timestamp) => DateTime.fromMillisecondsSinceEpoch(timestamp);

String getDateFromTimestamp(int timestamp, bool longMonth, [bool prependWordsWhereApplicable]) {
  var date = formatDate(_getDateTimeFromTimestamp(timestamp), longMonth ? formatterDateLong : formatterDate);
  if (prependWordsWhereApplicable != null && prependWordsWhereApplicable) {
    if (_compareDate(getNowTimestamp(), timestamp) == 0) {
      return "${L10n.get(L.today)} - $date";
    } else if (_compareDate(getYesterdayTimestamp(), timestamp) == 0) {
      return "${L10n.get(L.yesterday)} - $date";
    }
  }
  return date;
}

int _compareDate(int timestampOne, int timestampTwo) {
  var dateOne = _getDateTimeFromTimestamp(timestampOne);
  var dateOneCompare = DateTime(dateOne.year, dateOne.month, dateOne.day);
  var dateTwo = _getDateTimeFromTimestamp(timestampTwo);
  var dateTwoCompare = DateTime(dateTwo.year, dateTwo.month, dateTwo.day);
  return dateOneCompare.compareTo(dateTwoCompare);
}

int getNowTimestamp() {
  return DateTime.now().millisecondsSinceEpoch;
}

int getYesterdayTimestamp() {
  return DateTime.now().subtract(Duration(days: 1)).millisecondsSinceEpoch;
}

String getTimerFromTimestamp(int timestamp) {
  return formatDate(_getDateTimeFromTimestamp(timestamp), formatterTimer);
}

String getChatListTime(int timestamp) {
  if (_compareDate(timestamp, getNowTimestamp()) == 0) {
    return getTimeFormTimestamp(timestamp);
  } else if (_compareDate(getYesterdayTimestamp(), timestamp) == 0) {
    return L10n.get(L.yesterday);
  } else {
    return formatDate(_getDateTimeFromTimestamp(timestamp), formatterDate);
  }
}

String getDateTimeFileFormTimestamp([int timestamp]) {
  if (timestamp == null) {
    timestamp = getNowTimestamp();
  }
  return formatDate(_getDateTimeFromTimestamp(timestamp), formatterDateTimeFile);
}

String getDateAndTimeFromTimestamp(int timestamp) {
  return formatDate(_getDateTimeFromTimestamp(timestamp), formatterDateAndTime);
}

String getVideoTimeFromTimestamp(int timestamp) {
  return formatDate(_getDateTimeFromTimestamp(timestamp), formatterVideoTime);
}
