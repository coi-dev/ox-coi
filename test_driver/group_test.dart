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

import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:ox_coi/src/l10n/l.dart';
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
    await teardownDriver(driver);
  });

  const testNameGroup = "TestGroup";
  const newNameTestGroup = "NewNameTestGroup";
  const keyMoreButton11 = "keyMoreButton_11";
  const keyMoreButton12 = "keyMoreButton_12";
  const popupItemInfo = "Info";
  const popupItemRemove = "Remove from group";
  const popupItemSendMessage = "Send message";
  const searchNew = "new";
  const groupParticipants = "4 participants";
  const newTestContact03 = 'enyakam3@ox.com';

  group('Add Contacts.', () {
    test(': Create three cantacts in the conctact list and navigate back to chat.', () async {
      await navigateTo(driver, L.getPluralKey(L.contactP));
      await driver.tap(cancelFinder);
      await addNewContact(driver, name3, email3);
      await addNewContact(driver, name2, email2);
      await addNewContact(driver, nameNewMe, newTestContact03);
      navigateTo(driver, L.getPluralKey(L.chatP));
    });
  });

  group('Create group', () {
    test(': Create group.', () async {
      await driver.tap(createChatFinder);
      await driver.tap(find.byValueKey(keyChatCreateGroupAddIcon));
      await driver.tap(find.text(name3));
      await driver.tap(find.text(name2));
      await driver.tap(find.byValueKey(keyChatCreateGroupParticipantsSummitIconButton));
      expect(await driver.getText(find.text(name3)), name3);
      expect(await driver.getText(find.text(name2)), name2);
    });

    test(': Edit group name', () async {
      await driver.tap(find.byValueKey(keyChatCreateGroupSettingsGroupNameField));
      await driver.enterText(testNameGroup);
      await driver.tap(find.byValueKey(keyChatCreateGroupSettingCheckIconButton));
      expect(await driver.getText(find.text(testNameGroup)), testNameGroup);
      await driver.tap(pageBackFinder);
    });
  });

  group('Test group chat functionality.', () {
    test(': Change group name and come back to Chat.', () async {
      await driver.tap(find.text(testNameGroup));
      await driver.tap(find.byValueKey(keyChatNameText));
      await driver.tap(find.byValueKey(keyProfileHeaderAdaptiveIconButton));
      await driver.tap(find.byValueKey(keyUserSettingsUsernameLabel));
      await driver.tap(find.byValueKey(keyUserSettingsUsernameLabel));
      await driver.enterText(newNameTestGroup);
      await driver.tap(find.byValueKey(keyEditGroupProfileAdaptiveIconIconSource));
      expect(await driver.getText(find.text(newNameTestGroup)), newNameTestGroup);
      await driver.tap(pageBackFinder);
      await driver.tap(pageBackFinder);
    });

    test(': Test chat in group', () async {
      await chatTest(driver, messageIdTwo, newNameTestGroup);
      await driver.tap(pageBackFinder);
    });

    test(': Add new Participants in the group and test.', () async {
      await driver.tap(find.text(newNameTestGroup));
      await driver.tap(find.byValueKey(keyChatNameText));
      await driver.tap(find.byValueKey(keyChatProfileGroupAddParticipant));
      await driver.tap(find.byValueKey(keySearchBarInput));
      sleep(Duration(seconds: 4));
      await driver.enterText(searchNew);
      await driver.tap(find.text(nameNewMe));
      await driver.tap(find.byValueKey(keyChatAddGroupParticipantsCheckIcon));
      expect(await driver.getText(find.text(groupParticipants)), groupParticipants);
    });

    test(': Check popupMenu: Test info menu.', () async {
      await driver.tap(find.byValueKey(keyMoreButton11));
      await driver.tap(find.text(popupItemInfo));
      await driver.tap(pageBackFinder);
    });

    test(': Check popupMenu: Test remove menu.', () async {
      await driver.tap(find.byValueKey(keyMoreButton11));
      await driver.tap(find.text(popupItemRemove));
      await driver.waitForAbsent(find.text(name3));
      expect(await driver.getText(find.text(nameNewMe)), nameNewMe);
    });

    test(': Check popupMenu: Test send menu.', () async {
      await driver.tap(find.byValueKey(keyMoreButton12));
      await driver.tap(find.text(popupItemSendMessage));
      await driver.tap(pageBackFinder);
    });

    test(': Leave group.', () async {
      await driver.tap(find.text(newNameTestGroup));
      await driver.tap(find.byValueKey(keyChatNameText));
      await driver.scroll(find.byValueKey(keyChatProfileGroupAddParticipant), 0.0, -600, Duration(milliseconds: 500));
      await driver.tap(find.byValueKey(keyChatProfileGroupLeaveOrDelete));
      await driver.tap(find.byValueKey(keyConfirmationDialogPositiveButton));
      await driver.waitFor(find.text(newNameTestGroup));
    });

    test(': Delete group.', () async {
      await driver.tap(find.text(newNameTestGroup));
      await driver.tap(find.byValueKey(keyChatNameText));
      await driver.tap(find.byValueKey(keyChatProfileGroupLeaveOrDelete));
      await driver.tap(find.byValueKey(keyConfirmationDialogPositiveButton));
      await driver.waitForAbsent(find.text(newNameTestGroup));
    });
  });
}
