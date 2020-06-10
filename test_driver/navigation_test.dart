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
//import 'dart:io';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:test/test.dart';

import 'setup/test_constants.dart';
import 'setup/main_test_setup.dart';

void main() {
  FlutterDriver driver;
  setUpAll(() async {
    driver = await setupAndGetDriver();
  });

  tearDownAll(() async {
    teardownDriver(driver);
  });

  group('Test navigation tests.', () {
    test(': Test chat navigation.', () async {
      await driver.tap(profileFinder);
      await driver.tap(contactsFinder);
      await driver.tap(cancelFinder);
      await driver.tap(chatsFinder);
      await checkChat(driver);
    });

    test(': Test contact navigation.', () async {
      await checkContact(
        driver,
        nameMe,
      );
    });
    test(': Test profile navigation.', () async {
      await checkProfile(
        driver,
      );
    });
  });
}

Future checkProfile(FlutterDriver driver) async {
  SerializableFinder settingsUserSettingsUsernameLabelFinder = find.byValueKey(keyUserSettingsUsernameLabel);
  SerializableFinder finderUserProfileEditRaisedButton = find.byValueKey(keyProfileHeaderAdaptiveIconButton);
  await driver.tap(profileFinder);
  await driver.tap(finderUserProfileEditRaisedButton);
  await driver.tap(settingsUserSettingsUsernameLabelFinder);
  await driver.tap(userSettingsSubmitFinder);
  await driver.tap(contactsFinder);
  await driver.waitForAbsent(cancelFinder);
}

Future checkChat(FlutterDriver driver) async {
  final chatCreate = L.getKey(L.chatCreate);
  await driver.tap(createChatFinder);
  expect(await driver.getText(find.text(chatCreate)), chatCreate);
  //  Check newContact.
  await driver.tap(pageBackFinder);
  //  Check searchChat
  await driver.tap(find.byValueKey(keySearchBarInput));
  await driver.tap(find.byValueKey(keySearchBarClearButton));
}

Future checkContact(FlutterDriver driver, String newTestName) async {
  await driver.tap(contactsFinder);
  //  await driver.waitForAbsent(cancelFinder);
  await driver.tap(contactAddFinder);
  await driver.tap(find.byValueKey(keyBackOrCloseButton));
  var actualNewContactName = await driver.getText(find.text(newTestName));
  expect(actualNewContactName, newTestName);

  //  Check import contact.
  await driver.tap(find.byValueKey(keyContactListImportButton));
  await driver.tap(cancelFinder);

  //  Check Search.
  await driver.tap(find.byValueKey(keySearchBarInput));
  expect(actualNewContactName, newTestName);
}
