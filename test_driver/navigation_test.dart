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
import 'package:test_api/src/backend/invoker.dart';
import 'setup/helper_methods.dart';
import 'setup/main_test_setup.dart';
import 'setup/global_consts.dart';

void main() {
  group('Create chat list integration tests.', () {
    // Setup for the test.
    Setup setup = new Setup(driver);
    setup.main(timeout);

    SerializableFinder searchReturnIconButton =
        find.byValueKey(keySearchReturnIconButton);
    SerializableFinder settingsUserSettingsUsernameLabelFinder =
        find.byValueKey(keyUserSettingsUserSettingsUsernameLabel);

    test('Test Create chat list integration tests.', () async {
      //  Check real authentication and get chat.
      await getAuthentication(
          setup.driver,
          signInFinder,
          coiDebugProviderFinder,
          providerEmailFinder,
          realEmail,
          providerPasswordFinder,
          realPassword);

      await setup.driver.tap(profileFinder);
      await setup.driver.tap(contactsFinder);
      await setup.driver.tap(cancelFinder);
      await setup.driver.tap(chatsFinder);

      //  Test chat navigation.
      await checkChat(setup.driver, createChatFinder, searchReturnIconButton);

      //  Test contact navigation.
      await checkContact(
        setup.driver,
        searchReturnIconButton,
        personAddFinder,
        meContact,
        contactsFinder,
        cancelFinder,
      );

      //  Test profile navigation.
      await checkProfile(
          setup.driver,
          profileFinder,
          userProfileEditRaisedButtonFinder,
          settingsUserSettingsUsernameLabelFinder,
          userSettingsCheckIconButtonFinder,
          contactsFinder,
          cancelFinder);
    });
  });
}

Future checkProfile(
    FlutterDriver driver,
    SerializableFinder profileFinder,
    SerializableFinder finderUserProfileEditRaisedButton,
    SerializableFinder userSettingsUserSettingsUsernameLabel,
    SerializableFinder finderUserSettingsCheckIconButton,
    SerializableFinder contactsFinder,
    SerializableFinder cancelFinder) async {
  await driver.tap(profileFinder);
  await driver.waitFor(find.text(L.getKey(L.profileNoUsername)));
  await driver.tap(finderUserProfileEditRaisedButton);
  Invoker.current.heartbeat();
  await driver.tap(userSettingsUserSettingsUsernameLabel);
  await driver.tap(finderUserSettingsCheckIconButton);
  print("\nUser name, status, email after edited profile is ok.");
  Invoker.current.heartbeat();
  await catchScreenshot(driver, 'screenshots/UserChangeProfile.png');
  await driver.tap(contactsFinder);
  await driver.waitForAbsent(cancelFinder);
}

Future checkChat(
  FlutterDriver driver,
  SerializableFinder finderCreateChat,
  SerializableFinder searchReturnIconButton,
) async {
  final chatCreate = L.getKey(L.chatCreate);

  //  Check flaggedButton.
  await driver.tap(find.byValueKey(keyChatListGetFlaggedActionIconButton));
  await driver.tap(find.pageBack());
  await catchScreenshot(driver, 'screenshots/afterFlaged.png');
  Invoker.current.heartbeat();
  await driver.tap(finderCreateChat);
  await driver.waitFor(find.text(chatCreate));
  //  Check newContact.
  await driver.tap(find.pageBack());
  //  Check searchChat
  Invoker.current.heartbeat();
  await driver.tap(find.byValueKey(keyChatListSearchIconButton));
  await driver.tap(find.byValueKey(keySearchClearIconButton));
  await driver.tap(searchReturnIconButton);
}

Future checkContact(
  FlutterDriver driver,
  SerializableFinder searchReturnIconButton,
  SerializableFinder personAddFinder,
  String newTestName,
  SerializableFinder contactsFinder,
  SerializableFinder cancelFinder,
) async {
  await driver.tap(contactsFinder);
  await driver.waitForAbsent(cancelFinder);
  Invoker.current.heartbeat();
  await driver.tap(personAddFinder);
  await driver.tap(find.byValueKey(keyContactChangeCloseIconButton));
  await driver.waitFor(find.text(newTestName));
  //  Check import contact.
  await driver.tap(find.byValueKey(keyContactListImportContactIconButton));
  await driver.tap(cancelFinder);
  //  Check blocked.
  await driver.tap(find.byValueKey(keyContactListBlockIconButton));
  await driver.waitFor(find.text(L.getKey(L.contactNoBlocked)));
  await driver.tap(find.byValueKey(keyContactBlockedListCloseIconButton));
  //  Check Search.
  await driver.tap(find.byValueKey(keyContactListSearchIconButton));
  await driver.waitFor(find.text(newTestName));
  await driver.tap(searchReturnIconButton);
  print('\nNew contact is added.');
}
