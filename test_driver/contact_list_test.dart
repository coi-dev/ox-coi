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

// Imports the Flutter Driver API.

import 'package:flutter_driver/flutter_driver.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:test/test.dart';

import 'setup/helper_methods.dart';
import 'setup/main_test_setup.dart';
import 'setup/test_constants.dart';

void main() {
  FlutterDriver driver;

  setUpAll(() async {
    driver = await setupAndGetDriver();
  });

  tearDownAll(() async {
    teardownDriver(driver);
  });

  group('Test create profile integration tests.', () {
    test(': Get conatact.', () async {
      await driver.tap(contactsFinder);
      await driver.tap(cancelFinder);
      var actualMeContact = await driver.getText(find.text(nameMe));
      expect(actualMeContact, nameMe);
    });

    test(': Add two new contacts in the contact list.', () async {
      await addContactAsync(driver, name1, email1);
      await addContactAsync(driver, name2, email2);
    });
    test(': Manage one created contact.', () async {
      await manageContact(driver, name1, nameNewMe);
    });

    test(': Delete one contact.', () async {
      await deleteContactAsync(driver, name2);
    });
  });
}

Future manageContact(FlutterDriver driver, String newTestName, String newMe) async {
  await driver.tap(find.text(newTestName));
  var actualContactName = await driver.getText(find.text(newTestName));
  expect(actualContactName, newTestName);
  await driver.tap(find.byValueKey(keyProfileHeaderAdaptiveIconButton));
  await driver.tap(contactChangeNameInputFinder);
  await driver.enterText(newMe);
  await driver.tap(contactChangeSubmitFinder);
  await driver.tap(pageBackFinder);
}
