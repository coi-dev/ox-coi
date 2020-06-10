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

Future<void> catchScreenshotAsync(FlutterDriver driver, String path) async {
  final List<int> pixels = await driver.screenshot();
  final File file = new File(path);
  await file.writeAsBytes(pixels);
  print(path);
}

/// Navigates to the given screen [pageToNavigate] in the app.
Future<void> navigateToAsync(FlutterDriver driver, String pageToNavigate) async {
  if (pageToNavigate == L.getPluralKey(L.contactP)) {
    await driver.tap(contactsFinder);
  } else if (pageToNavigate == L.getKey(L.profile)) {
    await driver.tap(profileFinder);
  } else if (pageToNavigate == L.getPluralKey(L.chatP)) {
    await driver.tap(chatsFinder);
  }
}

/// Creates one new contact with the given name [name] and email [email].
Future<void> addContactAsync(FlutterDriver driver, String name, String email) async {
  await driver.tap(contactAddFinder);
  await driver.tap(contactChangeNameInputFinder);
  await driver.enterText(name);
  await driver.tap(find.byValueKey(keyContactChangeEmailValidatableTextFormField));
  await driver.enterText(email);
  await driver.tap(contactChangeSubmitFinder);
  expect(await driver.getText(find.text(name)), name);
}

/// Deletes one contact with the given name [name].
Future<void> deleteContactAsync(FlutterDriver driver, String name) async {
  await driver.tap(find.text(name));
  await driver.scroll(find.byValueKey(keyContactDetailOpenChatProfileActionIcon), 0.0, -600, Duration(milliseconds: 500));
  await driver.tap(find.byValueKey(keyContactDetailDeleteContactProfileActionIcon));
  await driver.tap(find.byValueKey(keyConfirmationDialogPositiveButton));
}

/// Search for the chat [chatName] via [searchString] in the chat list.
Future<void> searchChatAsync(FlutterDriver driver, String chatName, String searchString) async {
  final searchBar = find.byValueKey(keySearchBarInput);
  await driver.tap(searchBar);
  await driver.waitFor(find.byValueKey(keySearchBarClearButton));
  await driver.enterText(searchString);
  await driver.tap(find.text(chatName));
  await driver.tap(pageBackFinder);
}

/// Sends a text and audio message and checks if the message is sent using [messageId].
Future<void> composeChatMessagesAsync(FlutterDriver driver, int messageId) async {
  await composeTextAsync(driver, messageId);
  await composeAudioAsync(driver);
  await driver.tap(find.byValueKey(KeyChatOnSendTextIcon));
}
/// Composes and sends a text message in chat.
/// Default [inputHelloWorld] will be send if no [text] to send is given.
Future<void> composeTextAsync(FlutterDriver driver, int messageId, [String text = ""]) async {
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

/// Composes and sends an audio message in chat.
Future<void> composeAudioAsync(FlutterDriver driver) async {
  await performLongPress(driver, find.byValueKey(KeyChatComposerMixinVoiceComposeAdaptiveSuperellipse));
  await driver.tap(find.byValueKey(KeyChatComposerPlayComposeAdaptiveSuperellipse));
  sleep(Duration(seconds: 2));
}

/// Performs long press on given [target]
Future<void> performLongPress(FlutterDriver driver, SerializableFinder target) async {
  await driver.waitFor(target);
  await driver.scroll(target, 0, 0, Duration(seconds: 2));
}

Future<void> unblockContactAsync(FlutterDriver driver, String contactName) async {
  const unblock = 'Unblock';
  await driver.tap(find.text(contactName));
  await driver.tap(find.text(unblock));
  var actualUnblockedContact = await driver.getText(find.text(L.getKey(L.contactNoBlocked)));
  expect(actualUnblockedContact, L.getKey(L.contactNoBlocked));
  await driver.tap(find.byValueKey(keyBackOrCloseButton));
}

Future<void> blockContactAsync(FlutterDriver driver, String contactName) async {
  const blockContact = 'Block contact';
  await driver.tap(find.text(contactName));
  await driver.tap(find.byValueKey(keyUserProfileBlockIconSource));
  await driver.tap(find.text(blockContact));
}

/// Perform long press on message an tap to flag [message]
Future<void> flagMessageAsync(FlutterDriver driver, String flagUnFlag, SerializableFinder message) async {
  sleep(Duration(seconds: 5));
  await performLongPress(driver, message);
  await driver.tap(find.text(flagUnFlag));
}

Future<void> unflagMessageAsync(FlutterDriver driver,String flagUnFlag, int messageIdToUnFlagged) async {
  SerializableFinder messageToUnFlaggedFinder = find.byValueKey(messageIdToUnFlagged);
  await driver.waitFor(messageToUnFlaggedFinder);
  await performLongPress(driver, messageToUnFlaggedFinder);
  await driver.tap(find.text(flagUnFlag));

}

/// Perform long press and delete message.
Future<void> deleteMessageAsync(FlutterDriver driver, SerializableFinder message) async {
  const deleteLocally = 'Delete locally';
  await performLongPress(driver, message);
  await driver.tap(find.text(deleteLocally));
}

/// Copies a sent message from a chat, pastes it into the compose view and sends it again.
Future<void> copyAndPasteMessageAsync(FlutterDriver driver, String copy, String paste) async {
  await performLongPress(driver, finderMessageOne);
  await driver.tap(find.text(copy));
  await performLongPress(driver, composeInputFinder);
  await driver.tap(find.text(paste));
  await driver.tap(find.byValueKey(KeyChatComposerMixinOnSendTextIcon));
}

Future<void> forwardMessageAsync(FlutterDriver driver, String contactToForward, String forward) async {
  await performLongPress(driver, finderMessageOne);
  await driver.tap(find.text(forward));
  await driver.tap(find.text(contactToForward));
}

/// Creates a new chat from the chat list. [email] is the receivers email address and [name] is the name of the recipient.
Future<void> createNewChatAsync(FlutterDriver driver, String email, String name) async {
  final finderMe = find.text(nameMe);
  final finderNewContact = find.text(L.getKey(L.contactNew));

  await driver.tap(find.byValueKey(keyChatListCreateChatButton));
  if (name == nameMe) {
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
    await driver.enterText(name);
    await driver.tap(find.byValueKey(keyContactChangeEmailValidatableTextFormField));
    expect(actualContactEmail, textEmailAddress);
    await driver.enterText(email);
    await driver.tap(find.byValueKey(keyContactChangeCheckIconButton));
    var actualNewMessageHintText = await driver.getText(find.text(L.getKey(L.chatNewPlaceholder)));
    expect(actualNewMessageHintText, L.getKey(L.chatNewPlaceholder));
    await driver.tap(pageBackFinder);
  }
}

/// Performs login from the provider view with given [email] and [password].
Future<void> performLoginAsync(FlutterDriver driver, String email, String password) async {
  final providerEmailFieldFinder = find.byValueKey(keyProviderSignInEmailTextField);
  final providerPasswordFieldFinder = find.byValueKey(keyProviderSignInPasswordTextField);
  await driver.tap(providerEmailFieldFinder);
  await driver.enterText(email);
  await driver.tap(providerPasswordFieldFinder);
  await driver.enterText(password);
  await driver.tap(signInFinder);
}

bool isAndroid() => targetPlatform == environmentTargetPlatformAndroid;
