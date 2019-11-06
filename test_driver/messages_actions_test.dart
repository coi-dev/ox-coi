/*
 *
 *  * OPEN-XCHANGE legal information
 *  *
 *  * All intellectual property rights in the Software are protected by
 *  * international copyright laws.
 *  *
 *  *
 *  * In some countries OX, OX Open-Xchange and open xchange
 *  * as well as the corresponding Logos OX Open-Xchange and OX are registered
 *  * trademarks of the OX Software GmbH group of companies.
 *  * The use of the Logos is not covered by the Mozilla Public License 2.0 (MPL 2.0).
 *  * Instead, you are allowed to use these Logos according to the terms and
 *  * conditions of the Creative Commons License, Version 2.5, Attribution,
 *  * Non-commercial, ShareAlike, and the interpretation of the term
 *  * Non-commercial applicable to the aforementioned license is published
 *  * on the web site https://www.open-xchange.com/terms-and-conditions/.
 *  *
 *  * Please make sure that third-party modules and libraries are used
 *  * according to their respective licenses.
 *  *
 *  * Any modifications to this package must retain all copyright notices
 *  * of the original copyright holder(s) for the original code used.
 *  *
 *  * After any such modifications, the original and derivative code shall remain
 *  * under the copyright of the copyright holder(s) and/or original author(s) as stated here:
 *  * https://www.open-xchange.com/legal/. The contributing author shall be
 *  * given Attribution for the derivative code and a license granting use.
 *  *
 *  * Copyright (C) 2016-2020 OX Software GmbH
 *  * Mail: info@open-xchange.com
 *  *
 *  *
 *  * This Source Code Form is subject to the terms of the Mozilla Public
 *  * License, v. 2.0. If a copy of the MPL was not distributed with this
 *  * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *  *
 *  * This program is distributed in the hope that it will be useful, but
 *  * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  * or FITNESS FOR A PARTICULAR PURPOSE. See the Mozilla Public License 2.0
 *  * for more details.
 *  
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
import 'package:test/test.dart';
import 'package:test_api/src/backend/invoker.dart';

import 'setup/global_consts.dart';
import 'setup/helper_methods.dart';
import 'setup/main_test_setup.dart';

void main() {
  group('Test block / unblock functionality', () {
    //  Define the driver.
    FlutterDriver driver;
    Setup setup = new Setup(driver);
    setup.main(timeout);

    final openChat = 'Open chat';
    final flagUnFlag = 'Flag/Unflag';
    final forward = 'Forward';
    final textToDelete = 'Text to dellete';
    final paste = 'PASTE';
    final copy = 'Copy';

    final meContactFinder = find.text(meContact);
    final textToDeleteFinder = find.text(textToDelete);

    test('Test block / unblock functionality.', () async {
      //  Check real authentication and get chat.
      await getAuthentication(
        setup.driver,
        signInFinder,
        coiDebugProviderFinder,
        providerEmailFinder,
        realEmail,
        providerPasswordFinder,
        realPassword,
      );

      Invoker.current.heartbeat();
      await setup.driver.waitFor(chatWelcomeFinder);
      Invoker.current.heartbeat();

      //  Get contacts and add new contacts.
      await setup.driver.tap(contactsFinder);
      await setup.driver.tap(cancelFinder);
      await setup.driver.waitFor(meContactFinder);

      //  Add two new contacts in the contact list.
      await addNewContact(
        setup.driver,
        personAddFinder,
        keyContactChangeNameFinder,
        newTestName01,
        keyContactChangeEmailFinder,
        newTestContact04,
        keyContactChangeCheckFinder,
      );

      //  Create chat and write something.
      await setup.driver.tap(meContactFinder);
      await setup.driver.tap(find.text(openChat));
      await writeChatFromChat(setup.driver, helloWorld);

      //  First test action: Flagged messages from  meChat.
      await flaggedMessage(setup.driver, flagUnFlag, helloWorldFinder);

      await setup.driver.tap(pageBack);
      await navigateTo(setup.driver, chat);

      //  Second test action: UnFlagged messages.
      await unFlaggedMessage(setup.driver, flagUnFlag, helloWorldFinder);
      await setup.driver.waitForAbsent(helloWorldFinder);

      //  Return to chatList.
      await setup.driver.tap(pageBack);
      await setup.driver.tap(meContactFinder);

      //  Third test action: Forward message.
      await forwardMessageTo(setup.driver, newTestName01, forward);
      await setup.driver.waitFor(helloWorldFinder);

      //  Return to chatList.
      await setup.driver.tap(pageBack);
      await setup.driver.tap(meContactFinder);

      //  Forth test action: Copy message from meContact and it paste in meContact.
      await copyAndPasteMessage(setup.driver, copy, paste);

      //  Enter new text to delete.
      await writeTextInChat(setup.driver, textToDelete);
      await setup.driver.waitFor(textToDeleteFinder);
      await catchScreenshot(setup.driver, 'screenshots/addTextToDelete.png');

      //  Fifth test action: Delete message.
      await deleteMessage(textToDeleteFinder, setup.driver);
      await setup.driver.waitForAbsent(textToDeleteFinder);
    });
  });
}
