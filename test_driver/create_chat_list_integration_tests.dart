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
  group('Create chat list integration tests', () {
// Define the driver.
    FlutterDriver driver;
    final timeout = Duration(seconds: 120);

    final realEmail = 'enyakam3@ox.com';
    final realPassword = 'secret';
    final newTestContact01 = 'enyakam1@ox.com';
    final newTestContact02 = 'enyakam2@ox.com';
    final newTestName01 = 'Douglas001';
    final newTestName02 = 'Douglas02';
    final meContact = "Me";
    final singIn = 'SIGN IN';
    final coiDebug = 'Coi debug';
    final searchString = "Douglas00";
    final chatWelcomeMessage =
        'Welcome to OX COI Messenger!\nPlease start a new chat by tapping the chat bubble icon.';
    final typeSomethingComposePlaceholder = "Type something...";
    final helloWord = "Hello word";

//  SerializableFinder.
    final finderCoiDebugProvider = find.text(coiDebug);
    final finderProviderEmail =
        find.byValueKey(keyProviderSignInEmailTextField);
    final finderProviderPassword =
        find.byValueKey(keyProviderSignInPasswordTextField);
    final finderSIGNIN = find.text(singIn);
    final finderCreateChat =
        find.byValueKey(keyChatListChatFloatingActionButton);
    final finderChatListSearchIconButton =
        find.byValueKey(keyChatListSearchIconButton);
    final finderChatListSearchEmptyIconButton =
        find.byValueKey(keyChatListSearchEmptyIconButton);
    final finderChatWelcome = find.text(chatWelcomeMessage);

    // Connect to a running Flutter application instance.
    setUpAll(() async {
      final String adbPath =
          '/Users/openxchange/Library/Android/sdk/platform-tools/adb';
      await Process.run(adbPath, [
        'shell',
        'pm',
        'grant',
        'com.openxchange.oxcoi.dev',
        'android.permission.WRITE_CONTACTS'
      ]);
      await Process.run(adbPath, [
        'shell',
        'pm',
        'grant',
        'com.openxchange.oxcoi.dev',
        'android.permission.READ_CONTACTS'
      ]);
      await Process.run(adbPath, [
        'shell',
        'pm',
        'grant',
        'com.openxchange.oxcoi.dev',
        'android.permission.RECORD_AUDIO'
      ]);

      await Process.run(adbPath, [
        'shell',
        'pm',
        'grant',
        'com.openxchange.oxcoi.dev',
        'android.permission.READ_EXTERNAL_STORAGE'
      ]);
      await Process.run(adbPath, [
        'shell',
        'pm',
        'grant',
        'com.openxchange.oxcoi.dev',
        'android.permission.WRITE_EXTERNAL_STORAGE'
      ]);
      driver = await FlutterDriver.connect();
      driver.setSemantics(true, timeout: timeout);
    });

//  Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('Test Create chat list integration tests', () async {
      //  Get and print driver status.
      await driver.waitFor(finderSIGNIN);
      await driver.tap(finderSIGNIN);
      await catchScreenshot(driver, 'screenshots/providerList1.png');

      //  Check real authentication and get chat.
      await driver.tap(finderCoiDebugProvider);
      print('\nReal authentication.');
      await getAuthentication(driver, finderProviderEmail, finderChatWelcome, realEmail,
          finderProviderPassword, realPassword, finderSIGNIN);
      //  Create first Me contact.
      await createNewChat(driver, finderCreateChat, realEmail, meContact);
      //  Create second contact.
      await createNewChat(
          driver, finderCreateChat, newTestContact02, newTestName02);
      //  create third contact
      await createNewChat(
          driver, finderCreateChat, newTestContact01, newTestName01);
      //  Type something and get it.
      await chatTest(
          driver, newTestName01, typeSomethingComposePlaceholder, helloWord);
      //  Search contact.
      await chatSearch(driver, newTestName01,searchString, finderChatListSearchIconButton,
          finderChatListSearchEmptyIconButton);
    });
  });
}


//  Take screenshot
Future catchScreenshot(FlutterDriver driver, String path) async {
  final List<int> pixels = await driver.screenshot();
  final File file = new File(path);
  await file.writeAsBytes(pixels);
  print(path);
}

Future getAuthentication(
    FlutterDriver driver,
    SerializableFinder email, SerializableFinder finderChatWelcome,
String fakeEmail,
    SerializableFinder password,
    String realPassword,
    SerializableFinder signInCaps) async {
  await driver.tap(email);
  await driver.enterText(fakeEmail);
  await driver.waitFor(email);
  await driver.tap(password);
  await driver.enterText(realPassword);
  Invoker.current.heartbeat();
  await driver.tap(signInCaps);
  Invoker.current.heartbeat();
  await catchScreenshot(driver, 'screenshots/entered.png');
  Invoker.current.heartbeat();
  print('\nSIGN IN ist done. Wait for chat.');
  await driver.waitFor(finderChatWelcome);
  await catchScreenshot(driver, 'screenshots/chat.png');
  print('\nGet chat.');

}

Future createNewChat(FlutterDriver driver, SerializableFinder finderCreateChat,
    String chatEmail, String chatName) async {
  final meContact = "Me";
  final newContact = "New contact";
  final name = "Name";
  final enterContactName = "Enter the contact name";
  final emailAddress = "Email address";
  final emptyChat = "This is a new chat. Send a message to connect!";

  final finderMe = find.text(meContact);
  final finderNewContact = find.text(newContact);

  Invoker.current.heartbeat();
  await driver.tap(finderCreateChat);
  if (chatName == meContact) {
    await driver.tap(finderMe);
    await driver.tap(find.pageBack());
    await driver.waitFor(finderMe);
  } else {
    Invoker.current.heartbeat();
    await driver.tap(finderNewContact);
    await driver.waitFor(find.text(name));
    await driver.waitFor(find.text(emailAddress));
    await driver
        .tap(find.byValueKey(keyContactChangeNameValidatableTextFormField));
    await driver.waitFor(find.text(enterContactName));
    await driver.enterText(chatName);
    await driver
        .tap(find.byValueKey(keyContactChangeEmailValidatableTextFormField));
    await driver.waitFor(find.text(emailAddress));
    await driver.enterText(chatEmail);
    await driver.tap(find.byValueKey(keyContactChangeCheckIconButton));
    await driver.waitFor(find.text(emptyChat));
    await driver.tap(find.pageBack());
    await catchScreenshot(driver, 'screenshots/chatListeAfterCreated.png');
  }
}

Future chatTest(FlutterDriver driver, String chatName,
    String typeSomethingComposePlaceholder, String helloWord) async {
  Invoker.current.heartbeat();
  await driver.tap(find.text(chatName));
  await driver.tap(find.byValueKey(typeSomethingComposePlaceholder));
  await driver.enterText(helloWord);
  await driver.tap(find.byValueKey(KeyChatComposerMixinOnSendTextIcon));
  await driver.waitFor(find.text(helloWord));
  // Enter audio now.
  await driver
      .tap(find.byValueKey(KeyChatComposerMixinOnRecordAudioPressedIcon));
  sleep(Duration(seconds: 3));
  await driver
      .tap(find.byValueKey(KeyChatComposerMixinOnRecordAudioSendIcon));
  await driver.tap(find.pageBack());
  await catchScreenshot(driver, 'screenshots/chatListe2.png');
}

Future chatSearch(
    FlutterDriver driver,
    String chatName,String searchString
    ,
    SerializableFinder keyChatListSearchIconButton,
    SerializableFinder keyChatListSearchEmptyIconButton) async {
  Invoker.current.heartbeat();
  final searchReturnIconButton = find.byValueKey(keySearchReturnIconButton);
  await driver.tap(find.byValueKey(keyChatListSearchIconButton));
  await catchScreenshot(driver, 'screenshots/searchList1.png');
  await driver.enterText(searchString);
  await catchScreenshot(driver, 'screenshots/searchList.png');
  await driver.tap(find.text(chatName));
  await driver.tap(find.pageBack());
  await driver.tap(searchReturnIconButton);
}
