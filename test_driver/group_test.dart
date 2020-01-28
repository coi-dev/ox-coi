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
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:test/test.dart';
import 'package:ox_coi/src/l10n/l.dart';

import 'setup/global_consts.dart';
import 'setup/helper_methods.dart';
import 'setup/main_test_setup.dart';

void main() {
  final setup = Setup();
  setup.perform();
  final driver = setup.driver;

  const testNameGroup = "TestGroup";
  const newNameTestGroup = "NewNameTestGroup";
  const keyMoreButton11 = "keyMoreButton_11";
  const keyMoreButton10 = "keyMoreButton_10";
  const popupItemInfo = "Info";
  const popupItemRemove = "Remove from group";
  const popupItemSendMessage = "Send message";
  const searchNew = "new";
  const groupParticipants = "3 participants";
  const newTestContact03 = 'enyakam3@ox.com';

  group('Add Contacts.', () {
    test(': Create three cantacts in the conctact list and navigate back to chat.', () async {
      await navigateTo(driver, L.getPluralKey(L.contactP));
      await driver.tap(cancelFinder);
      await addNewContact(
        driver,
        newTestName01,
        newTestEmail04,
      );
      await addNewContact(
        driver,
        newTestName02,
        newTestEmail02,
      );
      await addNewContact(
        driver,
        newMe,
        newTestContact03,
      );
      navigateTo(driver, L.getPluralKey(L.chatP));
    });
  });

  group('Create group', () {
    test(': Create group.', () async {
      await driver.tap(createChatFinder);
      await driver.tap(find.byValueKey(keyChatCreateGroupAddIcon));
      await driver.tap(find.text(newTestName01));
      await driver.tap(find.text(newTestName02));
      await driver.tap(find.byValueKey(keyChatCreateGroupParticipantsSummitIconButton));
      var actualFirstGroupName = await driver.getText(find.text(newTestName01));
      expect(actualFirstGroupName, newTestName01);
      var actualSecondGroupName = await driver.getText(find.text(newTestName02));
      expect(actualSecondGroupName, newTestName02);
    });

    test(': Edit group name', () async {
      await driver.tap(find.byValueKey(keyChatCreateGroupSettingsGroupNameField));
      await driver.enterText(testNameGroup);
      await driver.tap(find.byValueKey(keyChatCreateGroupSettingCheckIconButton));
      var actualNewGroupName = await driver.getText(find.text(testNameGroup));
      expect(actualNewGroupName, testNameGroup);
      await driver.tap(pageBack);
    });
  });

  group('Test group chat functionality.', () {
    test(': Change group name and come back to Chat.', () async {
      driver.tap(find.text(testNameGroup));
      await driver.tap(find.byValueKey(keyChatNameText));
      await driver.tap(find.byValueKey(keyChatProfileGroupEditIcon));
      await driver.tap(find.byValueKey(keyEditNameValidatableTextFormField));
      await driver.enterText(newNameTestGroup);
      await driver.tap(find.byValueKey(keyEditNameCheckIcon));
      var actualNewGroupName = await driver.getText(find.text(newNameTestGroup));
      expect(actualNewGroupName, newNameTestGroup);
      await driver.tap(pageBack);
      await driver.tap(pageBack);
    });

    test(': Test chat in group', () async {
      await chatTest(
        driver,
        newNameTestGroup,
      );
      await driver.tap(pageBack);
    });

    test(': Add new Participants in the group and test.', () async {
      await driver.tap(find.text(newNameTestGroup));
      await driver.tap(find.byValueKey(keyChatNameText));
      await driver.tap(find.byValueKey(keyChatProfileGroupAddParticipant));
      await driver.tap(find.byValueKey(keyChatAddGroupParticipantsSearchIcon));
      sleep(Duration(seconds: 4));
      await driver.enterText(searchNew);
      await driver.tap(find.text(newMe));
      await driver.tap(find.byValueKey(keySearchReturnIconButton));
      await driver.tap(find.byValueKey(keyChatAddGroupParticipantsCheckIcon));
      var actualGroupParticipants = await driver.getText(find.text(groupParticipants));
      expect(actualGroupParticipants, groupParticipants);
    });

    test(': Check popupMenu: Test info menu.', () async {
      await driver.tap(find.byValueKey(keyMoreButton11));
      await driver.tap(find.text(popupItemInfo));
      await driver.tap(pageBack);
    });

    test(': Check popupMenu: Test remove menu.', () async {
      await driver.tap(find.byValueKey(keyMoreButton11));
      await driver.tap(find.text(popupItemRemove));
      var actualFirstRemainingContact = await driver.getText(find.text(newTestName01));
      expect(actualFirstRemainingContact, newTestName01);
      var actualMeContact = await driver.getText(find.text(newMe));
      expect(actualMeContact, newMe);
    });

    test(': Check popupMenu: Test send menu.', () async {
      await driver.tap(find.byValueKey(keyMoreButton10));
      await driver.tap(find.text(popupItemSendMessage));
      await writeChatFromChat(driver);
      await driver.tap(pageBack);
    });

    test(': Check popupMenu: Leave group.', () async {
      await driver.tap(find.text(newNameTestGroup));
      await driver.tap(find.byValueKey(keyChatNameText));
      await driver.tap(find.byValueKey(keyChatProfileGroupDelete));
      await driver.tap(find.byValueKey(keyConfirmationDialogPositiveButton));
      await driver.waitForAbsent(find.text(newNameTestGroup));
    });
  });
}
