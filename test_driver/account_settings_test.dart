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

import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:test_api/src/backend/invoker.dart';

import 'setup/global_consts.dart';
import 'setup/helper_methods.dart';
import 'setup/main_test_setup.dart';

void main() {
  group('Add account settings test.', () {
    //  Define the driver.
    FlutterDriver driver;
    Setup setup = new Setup(driver);
    setup.main(timeout);
    final account = 'Account';
    final fakeIMAPCoiServer = 'mobile-coi.open-xchange.comm';
    final fakeSMTPCoiServer = 'mobile-coi.open-xchange.comm';
    final realServer = 'mobile-coi.open-xchange.com';

    test('Test create profile integration tests.', () async {
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
      await setup.driver.tap(profileFinder);
      await setup.driver.tap(userProfileSettingsAdaptiveIconFinder);

      await setup.driver.tap(find.text(account));
      await setup.driver.tap(userAccountAdaptiveIconButtonIconCheckFinder);
      Invoker.current.heartbeat();
      await setup.driver.tap(find.text(ok));

      // Case realPassword and fake IMAP server.
      Invoker.current.heartbeat();
      await setup.driver.tap(settingsManuelFormValidatableTextFormFieldPasswordFieldFinder);
      await setup.driver.enterText(realPassword);
      await setup.driver.tap(settingsManuelFormValidatableTextFormFieldImapServerFieldFinder);
      Invoker.current.heartbeat();
      await setup.driver.enterText(fakeIMAPCoiServer);
      await setup.driver.tap(userAccountAdaptiveIconButtonIconCheckFinder);
      Invoker.current.heartbeat();
      await setup.driver.tap(find.text(ok));

      // Case realPassword and fakeIMAPServer and fakeSMTPServer.
      await setup.driver.tap(settingsManuelFormValidatableTextFormFieldImapServerFieldFinder);
      await setup.driver.enterText(fakeSMTPCoiServer);
      await setup.driver.tap(userAccountAdaptiveIconButtonIconCheckFinder);
      Invoker.current.heartbeat();
      await setup.driver.tap(find.text(ok));

      // Case FakePassword and fakeIMAPServer and fakeSMTPServer.
      Invoker.current.heartbeat();
      await setup.driver.tap(settingsManuelFormValidatableTextFormFieldPasswordFieldFinder);
      await setup.driver.enterText(helloWorld);
      await setup.driver.tap(userAccountAdaptiveIconButtonIconCheckFinder);
      await setup.driver.tap(find.text(ok));

      // Case realPassword and realIMAPServer and realSMTPServer.
      Invoker.current.heartbeat();
      await setup.driver.tap(settingsManuelFormValidatableTextFormFieldPasswordFieldFinder);
      await setup.driver.enterText(realPassword);
      await setup.driver.tap(settingsManuelFormValidatableTextFormFieldImapServerFieldFinder);
      await setup.driver.enterText(realServer);
      await setup.driver.tap(settingsManuelFormValidatableTextFormFieldSMTPServerField);
      await setup.driver.enterText(realServer);
      await setup.driver.tap(userAccountAdaptiveIconButtonIconCheckFinder);
    });
  });
}
