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
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:test/test.dart';
import 'package:test_api/src/backend/invoker.dart';

void main() {
  group('Ox coi test', () {
// Define the driver.
    FlutterDriver driver;
    final timeout = Duration(seconds: 120);

    final testUserNameUserProfile = 'EDN tester';
    final realEmail = 'enyakam3@ox.com';
    final realPassword = 'secret';
    final profileUserStatus = "Sent with OX Coi - https://github.com/open-xchange/ox-coi";
    final singIn = 'SIGN IN';
    final coiDebug = 'Coi debug';
    final mailCom = 'Mail.com';
    final chatWelcomeMessage = 'Welcome to OX Coi!\nPlease start a new chat by tapping the chat bubble icon.';

//  SerializableFinder for the Ox coi welcome and provider page.
    final finderCoiDebugProvider = find.text(coiDebug);
    final finderMailComProvider = find.text(mailCom);

//  SerializableFinder for Coi Debug dialog Windows.
    final finderProviderEmail = find.byValueKey(keyProviderSignInEmailTextField);
    final finderProviderPassword = find.byValueKey(keyProviderSignInPasswordTextField);
    final finderSIGNIN = find.text(singIn);
    final finderChatWelcome = find.text(chatWelcomeMessage);

//  SerializableFinder for profile and edit profile windows.
    final finderRootIconProfileTextTitle = find.byValueKey(keyRootIconProfileTitleText);

    final finderUserProfileEditRaisedButton = find.byValueKey(keyUserProfileEditProfileRaisedButton);
    final finderUserSettingsCheckIconButton = find.byValueKey(keyUserSettingsCheckIconButton);
    final userSettingsUserSettingsUsernameLabel = find.byValueKey(keyUserSettingsUserSettingsUsernameLabel);
    final finderUserProfileUserNameText = find.text(testUserNameUserProfile);
    final finderUserProfileEmailText = find.byValueKey(keyUserProfileEmailText);
    final finderUserProfileStatusText = find.text(profileUserStatus);

// Connect to a running Flutter application instance.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
      driver.setSemantics(true, timeout: timeout);
    });

//  Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

//  Take screenshot
    catchScreenshot(FlutterDriver driver, String path) async {
      final List<int> pixels = await driver.screenshot();
      final File file = new File(path);
      await file.writeAsBytes(pixels);
      print(path);
    }

    test('Test create profile integration tests', () async {
      //  Get and print driver status.
      Health health = await driver.checkHealth();
      print(health.status);

      await driver.waitFor(finderSIGNIN);
      await driver.tap(finderSIGNIN);
      await catchScreenshot(driver, 'screenshots/providerList1.png');
      await driver.scroll(finderMailComProvider, 0, -300, Duration(milliseconds: 300));
      await catchScreenshot(driver, 'screenshots/providerList2.png');
      Invoker.current.heartbeat();
      await catchScreenshot(driver, 'screenshots/CoiDebug.png');

      //  Check real authentication and get chat.
      await driver.tap(finderCoiDebugProvider);
      print('\nReal authentication.');
      await getAuthentication(driver, finderProviderEmail, realEmail, finderProviderPassword, realPassword, finderSIGNIN);
      await catchScreenshot(driver, 'screenshots/entered.png');
      Invoker.current.heartbeat();
      print('\nSIGN IN ist done. Wait for chat.');
      await driver.waitFor(finderChatWelcome);
      Invoker.current.heartbeat();
      await catchScreenshot(driver, 'screenshots/chat.png');
      print('\nGet chat.');
      await driver.tap(finderRootIconProfileTextTitle);
      await driver.waitFor(finderUserProfileEmailText);
      await driver.waitFor(finderUserProfileStatusText);
      print("Check E-Mail and status ok.");
      print('\nGet Profile');
      await driver.tap(finderUserProfileEditRaisedButton);
      Invoker.current.heartbeat();
      print('\nGet user Edit user settings to edit username.');
      await driver.tap(userSettingsUserSettingsUsernameLabel);
      await driver.enterText(testUserNameUserProfile);
      print('\nGet Profile after changes saved and check changes.');
      await driver.tap(finderUserSettingsCheckIconButton);
      await driver.waitFor(finderUserProfileUserNameText);
      await driver.tap(finderRootIconProfileTextTitle);
      await driver.waitFor(finderUserProfileEmailText);
      await driver.waitFor(finderUserProfileStatusText);
      print("\nUser name, status, email after edited profile is ok.");
      Invoker.current.heartbeat();
      await catchScreenshot(driver, 'screenshots/UserChangeProfile.png');
    });
  });
}

Future getAuthentication(FlutterDriver driver, SerializableFinder email, String fakeEmail, SerializableFinder password, String realPassword,
    SerializableFinder signIn) async {
  await driver.tap(email);
  await driver.enterText(fakeEmail);
  await driver.waitFor(email);
  await driver.tap(password);
  await driver.enterText(realPassword);
  Invoker.current.heartbeat();
  await driver.tap(signIn);
  Invoker.current.heartbeat();
}
