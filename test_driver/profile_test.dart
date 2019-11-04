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
import 'package:test_api/src/backend/invoker.dart';

import 'setup/global_consts.dart';
import 'setup/helper_methods.dart';
import 'setup/main_test_setup.dart';

void main() {
  group('Ox coi test.', () {
    // Setup for the test.
    Setup setup = new Setup(driver);
    setup.main(timeout);

    SerializableFinder userSettingsUsernameLabelFinder = find.byValueKey(keyUserSettingsUserSettingsUsernameLabel);
    SerializableFinder userProfileUserNameTextFinder = find.text(testUserNameUserProfile);

    test('Test create profile integration tests.', () async {
      await getAuthentication(
        setup.driver,
        signInFinder,
        coiDebugProviderFinder,
        providerEmailFinder,
        realEmail,
        providerPasswordFinder,
        realPassword,
      );

      await catchScreenshot(setup.driver, 'screenshots/signInDone.png');
      await setup.driver.waitFor(chatWelcomeFinder);
      await setup.driver.tap(profileFinder);
      await setup.driver.waitFor(userProfileEmailTextFinder);
      await setup.driver.waitFor(userProfileStatusTextFinder);
      print("Check E-Mail and status ok.");
      print('\nGet Profile');
      await setup.driver.tap(userProfileEditRaisedButtonFinder);
      Invoker.current.heartbeat();
      print('\nGet user Edit user settings to edit username.');
      await setup.driver.tap(userSettingsUsernameLabelFinder);
      await setup.driver.enterText(testUserNameUserProfile);
      print('\nGet Profile after changes saved and check changes.');
      await setup.driver.tap(userSettingsCheckIconButtonFinder);
      await setup.driver.waitFor(userProfileUserNameTextFinder);
      await setup.driver.waitFor(userProfileEmailTextFinder);
      await setup.driver.waitFor(userProfileStatusTextFinder);
      print("\nUser name, status, email after edited profile is ok.");
      Invoker.current.heartbeat();
      await catchScreenshot(setup.driver, 'screenshots/UserChangeProfile.png');
      await navigateTo(setup.driver, chat);
    });
  });
}
