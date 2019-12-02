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
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:test/test.dart';
import 'package:test_api/src/backend/invoker.dart';

import 'setup/global_consts.dart';
import 'setup/global_consts.dart' as prefix0;
import 'setup/helper_methods.dart';
import 'setup/main_test_setup.dart';

void main() {
  group('Test block / unblock functionality', () {
    //  Define the driver.
    FlutterDriver driver;
    Setup setup = new Setup(driver);

    final block = 'Block';

    test('Get login and create one contact.', () async {
      //  Check real authentication and get chat.
      await getAuthentication(
        setup.driver,
        signInFinder,
        coiDebugProviderFinder,
        providerEmailFinder,
        realEmail,
        providerPasswordFinder,
        realPassword,
      );

      Invoker.current.heartbeat();
      await setup.driver.waitFor(chatWelcomeFinder);
      Invoker.current.heartbeat();

      //  Get contacts and add new contacts.
      await setup.driver.tap(contactsFinder);
      await setup.driver.tap(cancelFinder);
      await setup.driver.waitFor(find.text(meContact));

      // Add two new contacts in the contact list.
      await addNewContact(
        setup.driver,
        personAddFinder,
        keyContactChangeNameFinder,
        newTestName01,
        keyContactChangeEmailFinder,
        newTestContact04,
        keyContactChangeCheckFinder,
      );
    });

    test(': Test block functionality.\n', () async {
      await setup.driver.scroll(find.text(newTestName01), 75, 0, Duration(milliseconds: 100));
      await setup.driver.tap(find.text(block));
      await catchScreenshot(setup.driver, 'screenshots/contactListAfterBlock.png');
      await setup.driver.waitForAbsent(find.text(newTestName01));
      await navigateTo(setup.driver, chat);
      await navigateTo(setup.driver, contacts);
      await setup.driver.waitForAbsent(find.text(newTestName01));
    });

    test(': Test unblock functionality.\n', () async {
      await setup.driver.tap(find.byValueKey(keyContactListBlockIconButton));
      await setup.driver.waitFor(find.text(newTestName01));
      await catchScreenshot(setup.driver, 'screenshots/blockedList.png');
      await setup.driver.scroll(find.text(newTestName01), 75, 0, Duration(milliseconds: 100));
      await setup.driver.tap(find.text('Unblock'));
      await setup.driver.waitForAbsent(find.text(newTestName01));
      await setup.driver.tap(find.byValueKey(keyContactBlockedListCloseIconButton));
    });

    test(': Test if block and unblock are really been done\n', () async {
      await setup.driver.waitFor(find.text(newTestName01));
      await catchScreenshot(setup.driver, 'screenshots/afterUnblock.png');
      await setup.driver.tap(find.byValueKey(keyContactListBlockIconButton));
      await setup.driver.waitForAbsent(find.text(newTestName01));
    });
  });
}
