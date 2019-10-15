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
import 'package:flutter_driver/flutter_driver.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'setup/global_consts.dart';
import 'setup/helper_methods.dart';
import 'setup/main_test_setup.dart';
import 'package:test/test.dart';
import 'package:test_api/src/backend/invoker.dart';

void main() {
  group('Create chat list integration tests.', () {
    // Setup for the test.
    Setup setup = new Setup(driver);
    setup.main(timeout);

    test('Test Create chat list integration tests.', () async {
      await getAuthentication(
          setup.driver,
          signInFinder,
          coiDebugProviderFinder,
          providerEmailFinder,
          realEmail,
          providerPasswordFinder,
          realPassword);

      //  Create first Me contact.
      await createNewChat(setup.driver, createChatFinder, realEmail, meContact,
          newContact, name, enterContactName, emptyChat);
      //  Create second contact.
      await createNewChat(setup.driver, createChatFinder, newTestContact02,
          newTestName02, newContact, name, enterContactName, emptyChat);
      //  create third contact
      await createNewChat(setup.driver, createChatFinder, newTestContact01,
          newTestName01, newContact, name, enterContactName, emptyChat);
      //  Type something and get it.
      await chatTest(setup.driver, newTestName01,
          typeSomethingComposePlaceholderFinder, helloWord);
      await callTest(setup.driver);
      //  Search contact.
      await chatSearch(
          setup.driver,
          newTestName01,
          searchString,
          find.byValueKey(keyChatListSearchIconButton),
          keySearchReturnIconButton);
    });
  });
}

Future createNewChat(
    FlutterDriver driver,
    SerializableFinder finderCreateChat,
    String chatEmail,
    String chatName,
    String newContact,
    String name,
    String enterContactName,
    String emptyChat) async {
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

