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
  group(
      'Create contact list integration tests: After login, Me contact is checked first, '
          'then two contacts are created. The contacts made can then be found in the contact list.'
          'After that one of the contacts will be delete from the contact list',
      () {
    //  Define the driver.
    FlutterDriver driver;
    final timeout = Duration(seconds: 120);


    final realEmail = 'enyakam3@ox.com';
    final newTestContact01 = 'enyakam1@ox.com';
    final newTestContact02 = 'enyakam2@ox.com';
    final newTestName01 = 'Douglas01';
    final newTestName02 = 'Douglas02';
    final newMe = "newMe";
    final meContact ="Me";
    final realPassword = 'secret';
    final contacts = "Contacts";

    final singIn = 'SIGN IN';
    final coiDebug = 'Coi debug';
    final mailCom = 'Mail.com';
    final chatWelcomeMessage =
        'Welcome to OX Coi!\nPlease start a new chat by tapping the chat bubble icon.';

    //  SerializableFinder for the Ox coi welcome and provider page.
    final finderCoiDebugProvider = find.text(coiDebug);
    final finderMailComProvider = find.text(mailCom);

    //  SerializableFinder for Coi Debug dialog Windows.
    final finderProviderEmail =
        find.byValueKey(keyProviderSignInEmailTextField);
    final finderProviderPassword =
        find.byValueKey(keyProviderSignInPasswordTextField);
    final finderSIGNIN = find.text(singIn);
    final finderChatWelcome = find.text(chatWelcomeMessage);

    //  SerializableFinder for Contacts and edit profile windows.
    final contactsFinder = find.text(contacts);
    final positiveFinder = find.byValueKey(keyDialog_builderPositiveFlatButton);
    final cancelFinder = find.byValueKey(keyDialog_builderCancelFlatButton);
    final personAddFinder =
        find.byValueKey(keyContact_listPerson_addFloatingActionButton);
    final keyContactChangeNameFinder =
        find.byValueKey(keyContact_changeNameValidatableTextFormField);
    final keyContactChangeEmailFinder =
        find.byValueKey(keyContact_changeEmailValidatableTextFormField);
    final keyContactChangeCheckFinder =
        find.byValueKey(keyContact_changeCheckIconButton);

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
        'com.openxchange.oxcoi.dev ',
        'android.permission.READ_CONTACTS'
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

    test('Test create profile integration tests', () async {
      //  Get and print driver status.
      Health health = await driver.checkHealth();
      print(health.status);

      await driver.tap(finderSIGNIN);
      await catchScreenshot(driver, 'screenshots/providerList1.png');
      await driver.scroll(
          finderMailComProvider, 0, -300, Duration(milliseconds: 300));
      await catchScreenshot(driver, 'screenshots/providerList2.png');
      Invoker.current.heartbeat();
      await catchScreenshot(driver, 'screenshots/CoiDebug.png');

      //  Check real authentication and get chat.
      await driver.tap(finderCoiDebugProvider);
      print('\nReal authentication.');
      await getAuthentication(driver, finderProviderEmail, realEmail,
          finderProviderPassword, realPassword, finderSIGNIN);
      await catchScreenshot(driver, 'screenshots/entered.png');
      Invoker.current.heartbeat();
      print('\nSIGN IN ist done. Wait for chat.');
      await driver.waitFor(finderChatWelcome);
      Invoker.current.heartbeat();
      await catchScreenshot(driver, 'screenshots/chat.png');
      print('\nGet chat.');

      //  Get contacts and add new contacts.
      await driver.tap(contactsFinder);
      await driver.tap(cancelFinder);
      await driver.waitFor(find.text(meContact));

      // Add two new contacts in the contact list.
      await addNewContact(
          driver,
          personAddFinder,
          keyContactChangeNameFinder,
          newTestName01,
          keyContactChangeEmailFinder,
          newTestContact01,
          keyContactChangeCheckFinder);
      await addNewContact(
          driver,
          personAddFinder,
          keyContactChangeNameFinder,
          newTestName02,
          keyContactChangeEmailFinder,
          newTestContact02,
          keyContactChangeCheckFinder);

      // Manage new contact
      await manageContact(driver, newTestName01, keyContactChangeNameFinder,
          newMe, keyContactChangeCheckFinder);
      await catchScreenshot(driver, 'screenshots/persone_add02.png');
      print('\nContacts');

      // Delete one contact
      await deleteContact(driver, positiveFinder, newTestName02);
      Invoker.current.heartbeat();
      await catchScreenshot(driver, 'screenshots/contactList.png');
    });
  });
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

Future manageContact(
    FlutterDriver driver,
    String newTestName,
    SerializableFinder keyContactChangeNameFinder,
    String newMe,
    SerializableFinder keyContactChangeCheckFinder) async {
  await driver.tap(find.text(newTestName));
  Invoker.current.heartbeat();
  await driver.waitFor(find.text(newTestName));
  await driver
      .tap(find.byValueKey(keyContact_detailEdit_contactProfileActionIcon));
  await driver.tap(keyContactChangeNameFinder);
  await driver.enterText(newMe);
  await driver.tap(keyContactChangeCheckFinder);
  await driver.tap(find.pageBack());
}

Future deleteContact(
  FlutterDriver driver,
  SerializableFinder positiveFinder,
  String newTestName,
) async {
  await driver.tap(find.text(newTestName));
  Invoker.current.heartbeat();
  await driver
      .tap(find.byValueKey(keyContact_detailDelete_contactProfileActionIcon));
  await driver.tap(positiveFinder);
}

//  Take screenshot
catchScreenshot(FlutterDriver driver, String path) async {
  final List<int> pixels = await driver.screenshot();
  final File file = new File(path);
  await file.writeAsBytes(pixels);
  print(path);
}

Future getAuthentication(
    FlutterDriver driver,
    SerializableFinder email,
    String fakeEmail,
    SerializableFinder password,
    String realPassword,
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
