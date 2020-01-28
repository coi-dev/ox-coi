/*
 *
 *  * OPEN-XCHANGE legal information
 *  *
 *  * All intellectual property rights in the Software are protected by
 *  * international copyright laws.
 *  *
 *  *
 *  * In some countries OX, OX Open-Xchange and open xchange
 *  * as well as the corresponding Logos OX Open-Xchange and OX are registered
 *  * trademarks of the OX Software GmbH group of companies.
 *  * The use of the Logos is not covered by the Mozilla Public License 2.0 (MPL 2.0).
 *  * Instead, you are allowed to use these Logos according to the terms and
 *  * conditions of the Creative Commons License, Version 2.5, Attribution,
 *  * Non-commercial, ShareAlike, and the interpretation of the term
 *  * Non-commercial applicable to the aforementioned license is published
 *  * on the web site https://www.open-xchange.com/terms-and-conditions/.
 *  *
 *  * Please make sure that third-party modules and libraries are used
 *  * according to their respective licenses.
 *  *
 *  * Any modifications to this package must retain all copyright notices
 *  * of the original copyright holder(s) for the original code used.
 *  *
 *  * After any such modifications, the original and derivative code shall remain
 *  * under the copyright of the copyright holder(s) and/or original author(s) as stated here:
 *  * https://www.open-xchange.com/legal/. The contributing author shall be
 *  * given Attribution for the derivative code and a license granting use.
 *  *
 *  * Copyright (C) 2016-2020 OX Software GmbH
 *  * Mail: info@open-xchange.com
 *  *
 *  *
 *  * This Source Code Form is subject to the terms of the Mozilla Public
 *  * License, v. 2.0. If a copy of the MPL was not distributed with this
 *  * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *  *
 *  * This program is distributed in the hope that it will be useful, but
 *  * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  * or FITNESS FOR A PARTICULAR PURPOSE. See the Mozilla Public License 2.0
 *  * for more details.
 *
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

import 'package:flutter_driver/flutter_driver.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:test/test.dart';

import 'setup/global_consts.dart';
import 'setup/helper_methods.dart';
import 'setup/main_test_setup.dart';

void main() {
  group('Test block / unblock functionality', () {
    final setup = Setup();
    setup.perform();
    final driver = setup.driver;

    final block = L.getKey(L.block);
    final unblock = L.getKey(L.unblock);

    test(': Get contacts', () async {
      await driver.tap(contactsFinder);
      await driver.tap(cancelFinder);
      var actualMeContact = await driver.getText(find.text(meContact));
      expect(actualMeContact, meContact);
    });

    test(': Add one contact.', () async {
      await addNewContact(
        driver,
        newTestName01,
        newTestEmail04,
      );
    });

    test(': Test block functionality.\n', () async {
      await driver.scroll(find.text(newTestName01), 75, 0, Duration(milliseconds: 100));
      await driver.tap(find.text(block));
      await driver.waitForAbsent(find.text(newTestName01));
      await navigateTo(driver, L.getPluralKey(L.chatP));
      await navigateTo(driver, L.getPluralKey(L.contactP));
      await driver.waitForAbsent(find.text(newTestName01));
    });

    test(': Test unblock functionality.\n', () async {
      await driver.tap(find.byValueKey(keyContactListBlockIconButton));
      var actualBlockedContact = await driver.getText(find.text(newTestName01));
      expect(actualBlockedContact, newTestName01);
      await driver.scroll(find.text(newTestName01), 75, 0, Duration(milliseconds: 100));
      await driver.tap(find.text(unblock));
      await driver.waitForAbsent(find.text(newTestName01));
      await driver.tap(find.byValueKey(keyContactBlockedListCloseIconButton));
    });

    test(': Test check if block and unblock are really been done\n', () async {
      var actualUnblockedContact = await driver.getText(find.text(newTestName01));
      expect(actualUnblockedContact, newTestName01);
      await driver.tap(find.byValueKey(keyContactListBlockIconButton));
      await driver.waitForAbsent(find.text(newTestName01));
    });
  });
}
