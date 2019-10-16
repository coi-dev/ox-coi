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

import 'package:flutter_driver/flutter_driver.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:test_api/src/backend/invoker.dart';
import 'dart:io';
import 'package:ox_coi/src/l10n/l.dart';
import 'global_consts.dart';

FlutterDriver driver;

//  Take screenshot
Future catchScreenshot(FlutterDriver driver, String path) async {
  final List<int> pixels = await driver.screenshot();
  final File file = new File(path);
  await file.writeAsBytes(pixels);
  print(path);
}

Future getAuthentication(
    FlutterDriver driver,
    SerializableFinder signInFinder,
    SerializableFinder coiDebugProviderFinder,
    SerializableFinder email,
    String fakeEmail,
    SerializableFinder password,
    String realPassword) async {
  print('\nReal authentication.');
  await driver.tap(signInFinder);
  await driver.tap(coiDebugProviderFinder);
  await driver.tap(email);
  await driver.enterText(fakeEmail);
  await driver.waitFor(email);
  await driver.tap(password);
  await driver.enterText(realPassword);
  Invoker.current.heartbeat();
  await driver.tap(signInFinder);
  Invoker.current.heartbeat();
  print('\nSIGN IN ist done. Wait for chat.');
}

Future navigateTo(FlutterDriver driver, String pageToNavigate) async {
  if (pageToNavigate == contacts) {
    await driver.tap(contactsFinder);
  } else if (pageToNavigate == profile) {
    await driver.tap(profileFinder);
  } else if (pageToNavigate == chat) {
    await driver.tap(chatsFinder);
  }
}

Future addNewContact(
    FlutterDriver driver,
    SerializableFinder personAddFinder,
    SerializableFinder keyContactChangeNameFinder,
    String newTestName,
    SerializableFinder keyContactChangeEmailFinder,
    String newTestContact,
    SerializableFinder keyContactChangeCheckFinder) async {
  Invoker.current.heartbeat();
  await driver.tap(personAddFinder);
  await catchScreenshot(driver, 'screenshots/person_add01.png');
  await driver.tap(keyContactChangeNameFinder);
  await driver.enterText(newTestName);
  await driver.tap(keyContactChangeEmailFinder);
  await driver.enterText(newTestContact);
  Invoker.current.heartbeat();
  await driver.tap(keyContactChangeCheckFinder);
  await driver.waitFor(find.text(newTestName));
  await catchScreenshot(driver, 'screenshots/persone_add02.png');
  print('\nNew contact is added');
}

Future deleteContact(
  FlutterDriver driver,
  SerializableFinder positiveFinder,
  String newTestName,
) async {
  await driver.tap(find.text(newTestName));
  Invoker.current.heartbeat();
  await driver
      .tap(find.byValueKey(keyContactDetailDeleteContactProfileActionIcon));
  await driver.tap(positiveFinder);
}

Future chatSearch(
    FlutterDriver driver,
    String chatName,
    String searchString,
    SerializableFinder keyChatListSearchIconButton,
    String keySearchReturnIconButton) async {
  Invoker.current.heartbeat();
  final searchReturnIconButton = find.byValueKey(keySearchReturnIconButton);
  await driver.tap(keyChatListSearchIconButton);
  await catchScreenshot(driver, 'screenshots/searchList1.png');
  await driver.enterText(searchString);
  await catchScreenshot(driver, 'screenshots/searchList.png');
  await driver.tap(find.text(chatName));
  await driver.tap(find.pageBack());
  await driver.tap(searchReturnIconButton);
}

Future chatTest(
    FlutterDriver driver,
    String chatName,
    SerializableFinder typeSomethingComposePlaceholder,
    String helloWord) async {
  Invoker.current.heartbeat();
  await driver.tap(find.text(chatName));
  await writeChatFromChat(driver, helloWord);
  await catchScreenshot(driver, 'screenshots/$chatName.png');
}

Future writeChatFromChat(FlutterDriver driver, String helloWord) async {
  await driver.tap(typeSomethingComposePlaceholderFinder);
  await driver.enterText(helloWord);
  await driver.tap(find.byValueKey(KeyChatComposerMixinOnSendTextIcon));
  await driver.waitFor(find.text(helloWord));
  // Enter audio now.
  await driver
      .tap(find.byValueKey(KeyChatComposerMixinOnRecordAudioPressedIcon));
  sleep(Duration(seconds: 3));
  await driver.tap(find.byValueKey(KeyChatComposerMixinOnRecordAudioSendIcon));
}

Future callTest(FlutterDriver driver) async {
  await driver.tap(find.byValueKey(keyChatIconButtonIconPhone));
  await catchScreenshot(driver, 'screenshots/callTest.png');
  await driver.tap(keyDialogBuilderAlertDialogOkFlatButtonFinder);
  await driver.tap(find.pageBack());
}

Future blockOneContact(FlutterDriver driver, String contactNameToBlock) async {
  await driver.tap(find.text(contactNameToBlock));
  await driver
      .tap(find.byValueKey(keyContactDetailBlockContactProfileActionIcon));
  await driver.tap(find.text(blockContact));
  await catchScreenshot(driver, 'screenshots/contactListAfterBlock.png');
  await driver.waitForAbsent(find.text(contactNameToBlock));
  await driver.tap(find.byValueKey(keyContactListBlockIconButton));
  await driver.waitFor(find.text(contactNameToBlock));
  await catchScreenshot(driver, 'screenshots/blockedList.png');
  await driver.tap(find.text(contactNameToBlock));
  await driver.tap(find.text(unblock));
  await catchScreenshot(driver, 'screenshots/blockedListNew.png');
  await driver.waitFor(find.text(L.getKey(L.contactNoBlocked)));
  await driver.tap(find.byValueKey(keyContactBlockedListCloseIconButton));
  await driver.waitFor(find.text(contactNameToBlock));
}
