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

import 'global_consts.dart';

final scrollDuration = Duration(milliseconds: 1000);

//  Take screenshot
Future catchScreenshot(FlutterDriver driver, String path) async {
  final List<int> pixels = await driver.screenshot();
  final File file = new File(path);
  await file.writeAsBytes(pixels);
  print(path);
}

Future navigateTo(FlutterDriver driver, String pageToNavigate) async {
  if (pageToNavigate == L.getPluralKey(L.contactP)) {
    await driver.tap(contactsFinder);
  } else if (pageToNavigate == L.getKey(L.profile)) {
    await driver.tap(profileFinder);
  } else if (pageToNavigate == L.getPluralKey(L.chatP)) {
    await driver.tap(chatsFinder);
  }
}

Future addNewContact(
  FlutterDriver driver,
  String newTestName,
  String newTestContact,
) async {
  await driver.tap(personAddFinder);
  await driver.tap(keyContactChangeNameFinder);
  await driver.enterText(newTestName);
  await driver.tap(keyContactChangeEmailFinder);
  await driver.enterText(newTestContact);
  await driver.tap(keyContactChangeCheckFinder);
  var actualNewContact = await driver.getText(find.text(newTestName));
  expect(actualNewContact, newTestName);
}

Future deleteContact(
  FlutterDriver driver,
  String newTestName,
) async {
  await driver.tap(find.text(newTestName));
  await driver.tap(find.byValueKey(keyContactDetailDeleteContactProfileActionIcon));
  await driver.tap(positiveFinder);
}

Future chatSearch(FlutterDriver driver, String chatName, String searchString) async {
  final searchReturnIconButton = find.byValueKey(keySearchReturnIconButton);

  await driver.tap(find.byValueKey(keyChatListSearchIconButton));
  await driver.waitFor(find.byValueKey(keySearchClearIconButton));
  await driver.enterText(searchString);
  await driver.tap(find.text(chatName));
  await driver.tap(pageBack);
  await driver.tap(searchReturnIconButton);
}

Future chatTest(
  FlutterDriver driver,
  String chatName,
) async {
  await driver.tap(find.text(chatName));
  await writeChatFromChat(driver);
}

Future writeChatFromChat(FlutterDriver driver) async {
  await writeTextInChat(driver);
  // Enter audio now.
  await driver.tap(find.byValueKey(KeyChatComposerMixinOnRecordAudioPressedIcon));
  sleep(Duration(seconds: 1));
  await driver.tap(find.byValueKey(KeyChatComposerMixinOnRecordAudioSendIcon));
}

Future writeTextInChat(FlutterDriver driver, [String text = ""]) async {
  await driver.tap(typeSomethingComposePlaceholderFinder);
  if (text.isEmpty) {
    text = helloWorld;
    await driver.enterText(helloWorld);
  } else {
    await driver.enterText(text);
  }
  await driver.tap(find.byValueKey(KeyChatComposerMixinOnSendTextIcon));
  var actualNewMessage = await driver.getText(find.text(text));
  expect(actualNewMessage, text);
}

Future callTest(FlutterDriver driver) async {
  await driver.tap(find.byValueKey(keyChatIconButtonIconPhone));
  await driver.tap(keyDialogBuilderAlertDialogOkFlatButtonFinder);
}

Future unblockOneContactFromBlockedContacts(
  FlutterDriver driver,
  String contactNameToUnblock,
) async {
  const unblock = 'Unblock';
  await driver.tap(find.text(contactNameToUnblock));
  await driver.tap(find.text(unblock));
  var actualUnblockedContact = await driver.getText(find.text(L.getKey(L.contactNoBlocked)));
  expect(actualUnblockedContact, L.getKey(L.contactNoBlocked));
  await driver.tap(find.byValueKey(keyContactBlockedListCloseIconButton));
}

Future blockOneContactFromContacts(FlutterDriver driver, String contactNameToBlock) async {
  const blockContact = 'Block contact';
  await driver.tap(find.text(contactNameToBlock));
  await driver.tap(find.byValueKey(keyContactDetailBlockContactProfileActionIcon));
  await driver.tap(find.text(blockContact));
}

Future unFlaggedMessage(FlutterDriver driver, String flagUnFlag, String messageToUnFlagged) async {
  SerializableFinder messageToUnFlaggedFinder = find.text(messageToUnFlagged);
  await driver.tap(find.byValueKey(keyChatListGetFlaggedActionIconButton));
  var actualUnflaggedMessage = await driver.getText(messageToUnFlaggedFinder);
  expect(actualUnflaggedMessage, messageToUnFlagged);
  await driver.scroll(messageToUnFlaggedFinder, 0, 0, scrollDuration);
  await driver.tap(find.text(flagUnFlag));
}

Future flaggedMessage(FlutterDriver driver, String flagUnFlag, SerializableFinder messageToFlaggedFinder) async {
  await driver.scroll(messageToFlaggedFinder, 0, 0, scrollDuration);
  await driver.tap(find.text(flagUnFlag));
}

Future deleteMessage(SerializableFinder textToDeleteFinder, FlutterDriver driver) async {
  const deleteLocally = 'Delete locally';
  await driver.scroll(textToDeleteFinder, 0, 0, scrollDuration);
  await driver.tap(find.text(deleteLocally));
}

Future copyAndPasteMessage(FlutterDriver driver, String copy, String paste) async {
  await driver.scroll(helloWorldFinder, 0, 0, scrollDuration);
  await driver.tap(find.text(copy));
  await driver.scroll(typeSomethingComposePlaceholderFinder, 0, 0, scrollDuration);
  await driver.tap(find.text(paste));
  await driver.tap(find.byValueKey(KeyChatComposerMixinOnSendTextIcon));
  if (helloWorldFinder.serialize().length <= 2) {
    print('Copy paste succeed');
  }
}

Future forwardMessageTo(FlutterDriver driver, String contactToForward, String forward) async {
  await driver.scroll(helloWorldFinder, 0, 0, scrollDuration);
  await driver.tap(find.text(forward));
  await driver.tap(find.text(contactToForward));
}

Future createNewChat(
  FlutterDriver driver,
  String chatEmail,
  String chatName,
) async {
  final finderMe = find.text(meContact);
  final finderNewContact = find.text(L.getKey(L.contactNew));

  await driver.tap(find.byValueKey(keyChatListChatFloatingActionButton));
  if (chatName == meContact) {
    await driver.tap(finderMe);
    await driver.tap(pageBack);
    var actualMeContact = await driver.getText(finderMe);
    expect(actualMeContact, meContact);

    await driver.waitFor(finderMe);
  } else {
    await driver.tap(finderNewContact);
    var actualContactName = await driver.getText(find.text(name));
    expect(actualContactName, name);
    var actualContactEmail = await driver.getText(find.text(emailAddress));
    expect(actualContactEmail, emailAddress);
    await driver.tap(find.byValueKey(keyContactChangeNameValidatableTextFormField));
    var actualContactNameHintText = await driver.getText(find.text(L.getKey(L.contactName)));
    expect(actualContactNameHintText, L.getKey(L.contactName));
    await driver.enterText(chatName);
    await driver.tap(find.byValueKey(keyContactChangeEmailValidatableTextFormField));
    expect(actualContactEmail, emailAddress);
    await driver.enterText(chatEmail);
    await driver.tap(find.byValueKey(keyContactChangeCheckIconButton));
    var actualNewMessageHintText = await driver.getText(find.text(L.getKey(L.chatNewPlaceholder)));
    expect(actualNewMessageHintText, L.getKey(L.chatNewPlaceholder));
    await driver.tap(pageBack);
  }
}

Future logIn(FlutterDriver driver, String email, String password) async {
  final providerEmailFieldFinder = find.byValueKey(keyProviderSignInEmailTextField);
  final providerPasswordFieldFinder = find.byValueKey(keyProviderSignInPasswordTextField);

  await driver.tap(providerEmailFieldFinder);
  await driver.enterText(email);
  await driver.tap(providerPasswordFieldFinder);
  await driver.enterText(password);
  await driver.tap(signInFinder);
}
