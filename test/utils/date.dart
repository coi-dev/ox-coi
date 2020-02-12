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
import 'package:mockito/mockito.dart';
import 'package:ox_coi/src/utils/date.dart';
import 'package:test/test.dart';

const date20190520_120000 = 1558346400000;
const today = "Today";
const yesterday = "Yesterday";

class MockAppLocalizations extends Mock {}

void main() {
  test('Should get time from timestamp', () {
    var nowDateTime = DateTime.now();
    int nowTimestamp = nowDateTime.millisecondsSinceEpoch;
    String hour = formatDate(nowDateTime, [HH]);
    String minute = formatDate(nowDateTime, [nn]);

    var timeFormTimestamp = getTimeFormTimestamp(nowTimestamp);

    expect(timeFormTimestamp, "$hour:$minute");
  });

  test('Get date from timestamp', () {
    var dateFormTimestamp = getDateFromTimestamp(date20190520_120000, false);

    expect(dateFormTimestamp, "20.05");
  });

  test('Get date for today from timestamp', () {
    var nowDateTime = DateTime.now();
    String todayDate = formatDate(nowDateTime, [dd, '.', mm]);
    var todayTimestamp = nowDateTime.millisecondsSinceEpoch;

    var dateFormTimestamp = getDateFromTimestamp(todayTimestamp, false, true);

    expect(dateFormTimestamp, "$today - $todayDate");
  });

  test('Get date for yesterday from timestamp', () {
    var yesterdayDateTime = DateTime.now().subtract(Duration(days: 1));
    String yesterdayDate = formatDate(yesterdayDateTime, [dd, '.', mm]);
    var yesterdayTimestamp = yesterdayDateTime.millisecondsSinceEpoch;

    var dateFormTimestamp = getDateFromTimestamp(yesterdayTimestamp, false, true);

    expect(dateFormTimestamp, "$yesterday - $yesterdayDate");
  });

  test('Get long date from timestamp', () {
    var dateFormTimestamp = getDateFromTimestamp(date20190520_120000, true);

    expect(dateFormTimestamp, "20. May");
  });

  test('Should get timer from timestamp', () {
    var timerFormTimestamp = getTimerFromTimestamp(date20190520_120000);

    expect(timerFormTimestamp, "00:00:000");
  });

  test('Get chat list date from timestamp', () {

    var dateFormTimestamp = getChatListTime(date20190520_120000);

    expect(dateFormTimestamp, "20.05");
  });

  test('Get chat list date for today from timestamp', () {
    var nowDateTime = DateTime.now();
    int nowTimestamp = nowDateTime.millisecondsSinceEpoch;
    String hour = formatDate(nowDateTime, [HH]);
    String minute = formatDate(nowDateTime, [nn]);

    var dateFormTimestamp = getChatListTime(nowTimestamp);

    expect(dateFormTimestamp, "$hour:$minute");
  });

  test('Get chat list date for yesterday from timestamp', () {
    var yesterdayTimestamp = DateTime.now().subtract(Duration(days: 1)).millisecondsSinceEpoch;

    var dateFormTimestamp = getChatListTime(yesterdayTimestamp);

    expect(dateFormTimestamp, yesterday);
  });
}
