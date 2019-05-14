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
import 'package:flutter/widgets.dart';
import 'package:ox_coi/src/l10n/localizations.dart';

const formatterTime = [HH, ':', nn];
const formatterDate = [dd, '.', mm];
const formatterDateLong = [dd, '. ', MM];
const formatterTimer = [nn, ':', ss, ':', SSS];
const formatterDateTimeFile = [yy, '-', mm, '-', dd, '_', HH, '-', nn, '-', ss];

String getTimeFormTimestamp(int timestamp) {
  return formatDate(DateTime.fromMillisecondsSinceEpoch(timestamp), formatterTime);
}

String getDateFormTimestamp(int timestamp, bool longMonth, [bool useWordsWhereApplicable, BuildContext context]) {
  var date = formatDate(DateTime.fromMillisecondsSinceEpoch(timestamp), longMonth ? formatterDateLong : formatterDate);
  if (useWordsWhereApplicable != null && useWordsWhereApplicable && context != null) {
    if (_hasSameDate(DateTime.now().millisecondsSinceEpoch, timestamp)) {
      return "${AppLocalizations.of(context).today} - $date";
    } else if (_hasSameDate(DateTime.now().subtract(Duration(days: 1)).millisecondsSinceEpoch, timestamp)) {
      return "${AppLocalizations.of(context).yesterday} - $date";
    }
  }
  return date;
}

bool _hasSameDate(int timestampOne, int timestampTwo) {
  var dateOne = DateTime.fromMillisecondsSinceEpoch(timestampOne);
  var dateTwo = DateTime.fromMillisecondsSinceEpoch(timestampTwo);
  return formatDate(dateOne, formatterDate) == formatDate(dateTwo, formatterDate);
}

int getNowTimestamp() {
  return DateTime.now().millisecondsSinceEpoch;
}

String getTimerFormTimestamp(int timestamp) {
  return formatDate(DateTime.fromMillisecondsSinceEpoch(timestamp), formatterTimer);
}

String getChatListTime(BuildContext context, int timestamp) {
  DateTime chatTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  DateTime comparingChatDateTime = DateTime(chatTime.year, chatTime.month, chatTime.day);
  DateTime now = DateTime.now();
  DateTime nowDate = DateTime(now.year, now.month, now.day);

  int result = comparingChatDateTime.compareTo(nowDate);
  if (result == 0) {
    return getTimeFormTimestamp(timestamp);
  } else if (result == -1) {
    Duration difference = comparingChatDateTime.difference(nowDate);
    if (difference.inDays == -1) {
      return AppLocalizations.of(context).yesterday;
    } else {
      return formatDate(chatTime, formatterDate);
    }
  }
  return getTimeFormTimestamp(timestamp);
}

String getDateTimeFileFormTimestamp([int timestamp]) {
  if (timestamp == null) {
    timestamp = getNowTimestamp();
  }
  return formatDate(DateTime.fromMillisecondsSinceEpoch(timestamp), formatterDateTimeFile);
}