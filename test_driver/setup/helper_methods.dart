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

import 'main_test_setup.dart';
import 'test_constants.dart';

final scrollDuration = Duration(milliseconds: 1000);

Future catchScreenshot(FlutterDriver driver, String path) async {
  final List<int> pixels = await driver.screenshot();
  final File file = new File(path);
  await file.writeAsBytes(pixels);
  print(path);
}

/// Navigates to the given UI [pageToNavigate] in the App.
Future navigateTo(FlutterDriver driver, String pageToNavigate) async {
  if (pageToNavigate == L.getPluralKey(L.contactP)) {
    await driver.tap(contactsFinder);
  } else if (pageToNavigate == L.getKey(L.profile)) {
    await driver.tap(profileFinder);
  } else if (pageToNavigate == L.getPluralKey(L.chatP)) {
    await driver.tap(chatsFinder);
  }
}

///Creates one new contact with the given name [newTestName] and email [newContact].
Future addNewContact(FlutterDriver driver, String newTestName, String newTestContact) async {
  await driver.tap(contactAddFinder);
  await driver.tap(contactChangeNameInputFinder);
  await driver.enterText(newTestName);
  await driver.tap(find.byValueKey(keyContactChangeEmailValidatableTextFormField));
  await driver.enterText(newTestContact);
  await driver.tap(contactChangeSubmitFinder);
  expect(await driver.getText(find.text(newTestName)), newTestName);
}

/// Deletes one contact with the given name [netTestName].
Future deleteContact(FlutterDriver driver, String newTestName) async {
  await driver.tap(find.text(newTestName));
  await driver.scroll(find.byValueKey(keyContactDetailOpenChatProfileActionIcon), 0.0, -600, Duration(milliseconds: 500));
  await driver.tap(find.byValueKey(keyContactDetailDeleteContactProfileActionIcon));
  await driver.tap(find.byValueKey(keyConfirmationDialogPositiveButton));
}

/// Search one chat in the chat list with [chatName].
Future chatSearch(FlutterDriver driver, String chatName, String searchString) async {
  final searchBar = find.byValueKey(keySearchBarInput);
  await driver.tap(searchBar);
  await driver.waitFor(find.byValueKey(keySearchBarClearButton));
  await driver.enterText(searchString);
  await driver.tap(find.text(chatName));
  await driver.tap(pageBackFinder);
}

/// Select one chat [chatName], sends one text message that, and check if the message is really sent using [messageId].
Future chatTest(FlutterDriver driver, int messageId, String chatName) async {
  await driver.tap(find.text(chatName));
  await writeChatFromChat(driver, messageId);
}

Future writeChatFromChat(FlutterDriver driver, int messageId) async {
  await writeTextInChat(driver, messageId);
  await composeAudio(driver);
  await driver.tap(find.byValueKey(KeyChatOnSendTextIcon));
}

/// Composes and sends audio message in chat.
Future composeAudio(FlutterDriver driver) async {
  await performLongPress(driver, find.byValueKey(KeyChatComposerMixinVoiceComposeAdaptiveSuperellipse));
  await driver.tap(find.byValueKey(KeyChatComposerPlayComposeAdaptiveSuperellipse));
  sleep(Duration(seconds: 2));
}

/// Types text message in chat.
/// Default [inputHelloWorld] will send if no [text] to send in giving.
Future writeTextInChat(FlutterDriver driver, int messageId, [String text = ""]) async {
  await driver.tap(composeInputFinder);
  if (text.isEmpty) {
    text = inputHelloWorld;
    await driver.enterText(inputHelloWorld);
  } else {
    await driver.enterText(text);
  }
  await driver.tap(find.byValueKey(KeyChatComposerMixinOnSendTextIcon));
  await driver.waitFor(find.byValueKey(messageId));
}

/// Performs long press of given [target]
Future<void> performLongPress(FlutterDriver driver, SerializableFinder target) async {
  await driver.waitFor(target);
  await driver.scroll(target, 0, 0, Duration(seconds: 2));
}


Future unblockOneContactFromBlockedContacts(FlutterDriver driver, String contactNameToUnblock) async {
  const unblock = 'Unblock';
  await driver.tap(find.text(contactNameToUnblock));
  await driver.tap(find.text(unblock));
  var actualUnblockedContact = await driver.getText(find.text(L.getKey(L.contactNoBlocked)));
  expect(actualUnblockedContact, L.getKey(L.contactNoBlocked));
  await driver.tap(find.byValueKey(keyBackOrCloseButton));
}

Future blockOneContactFromContacts(FlutterDriver driver, String contactNameToBlock) async {
  const blockContact = 'Block contact';
  await driver.tap(find.text(contactNameToBlock));
  await driver.tap(find.byValueKey(keyUserProfileBlockIconSource));
  await driver.tap(find.text(blockContact));
}

Future unflagMessage(FlutterDriver driver,String flagUnFlag, int messageIdToUnFlagged) async {
  SerializableFinder messageToUnFlaggedFinder = find.byValueKey(messageIdToUnFlagged);
  await driver.waitFor(messageToUnFlaggedFinder);
  await performLongPress(driver, messageToUnFlaggedFinder);
  await driver.tap(find.text(flagUnFlag));

}

/// Perform long press on message an tap to flag message
Future flaggedMessage(FlutterDriver driver, String flagUnFlag, SerializableFinder messageToFlaggedFinder) async {
  sleep(Duration(seconds: 5));
  await performLongPress(driver, messageToFlaggedFinder);
  await driver.tap(find.text(flagUnFlag));
}

/// Press long and delete message.
Future deleteMessage(SerializableFinder textToDeleteFinder, FlutterDriver driver) async {
  const deleteLocally = 'Delete locally';
  await performLongPress(driver, textToDeleteFinder);
  await driver.tap(find.text(deleteLocally));
}

/// Copies the sent message from a chat, pastes it into the reserved placeholder for typing and sends it again.
Future copyAndPasteMessage(FlutterDriver driver, String copy, String paste) async {
  await performLongPress(driver, finderMessageOne);
  await driver.tap(find.text(copy));
  await performLongPress(driver, composeInputFinder);
  await driver.tap(find.text(paste));
  await driver.tap(find.byValueKey(KeyChatComposerMixinOnSendTextIcon));
}

Future forwardMessageTo(FlutterDriver driver, String contactToForward, String forward) async {
  await performLongPress(driver, finderMessageOne);
  await driver.tap(find.text(forward));
  await driver.tap(find.text(contactToForward));
}

/// Creates new chat from chat list. This operation is almost the same like to create a new contact
/// with the difference that you end up directly in the chat.
/// [chatEmail] is the email where to send the chat.
/// [chatName] is the name of the recipient.
Future createNewChat(FlutterDriver driver, String chatEmail, String chatName) async {
  final finderMe = find.text(nameMe);
  final finderNewContact = find.text(L.getKey(L.contactNew));

  await driver.tap(find.byValueKey(keyChatListCreateChatButton));
  if (chatName == nameMe) {
    await driver.tap(finderMe);
    await driver.tap(pageBackFinder);
    var actualSavedMessages = await driver.getText(chatSavedMessagesFinder);
    expect(actualSavedMessages, textSavedMessages);

    await driver.waitFor(chatSavedMessagesFinder);
  } else {
    await driver.tap(finderNewContact);
    var actualContactName = await driver.getText(find.text(textName));
    expect(actualContactName, textName);
    var actualContactEmail = await driver.getText(find.text(textEmailAddress));
    expect(actualContactEmail, textEmailAddress);
    await driver.tap(find.byValueKey(keyContactChangeNameValidatableTextFormField));
    var actualContactNameHintText = await driver.getText(find.text(L.getKey(L.contactName)));
    expect(actualContactNameHintText, L.getKey(L.contactName));
    await driver.enterText(chatName);
    await driver.tap(find.byValueKey(keyContactChangeEmailValidatableTextFormField));
    expect(actualContactEmail, textEmailAddress);
    await driver.enterText(chatEmail);
    await driver.tap(find.byValueKey(keyContactChangeCheckIconButton));
    var actualNewMessageHintText = await driver.getText(find.text(L.getKey(L.chatNewPlaceholder)));
    expect(actualNewMessageHintText, L.getKey(L.chatNewPlaceholder));
    await driver.tap(pageBackFinder);
  }
}

/// Performs login from the provider interface with given [email] and [password].
Future logIn(FlutterDriver driver, String email, String password) async {
  final providerEmailFieldFinder = find.byValueKey(keyProviderSignInEmailTextField);
  final providerPasswordFieldFinder = find.byValueKey(keyProviderSignInPasswordTextField);
  await driver.tap(providerEmailFieldFinder);
  await driver.enterText(email);
  await driver.tap(providerPasswordFieldFinder);
  await driver.enterText(password);
  await driver.tap(signInFinder);
}

bool isAndroid() => targetPlatform == environmentTargetPlatformAndroid;
