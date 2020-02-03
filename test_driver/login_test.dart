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
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:test/test.dart';

import 'setup/global_consts.dart';
import 'setup/helper_methods.dart';
import 'setup/main_test_setup.dart';

void main() {
  FlutterDriver driver;
  setUpAll(() async {
    driver = await setupAndGetDriver(isLogin: true);
  });

  tearDownAll(() async {
    await teardownDriver(driver);
  });

  //  Const for the Ox coi welcome and provider page.
  const outlook = 'Outlook';
  const yahoo = 'Yahoo';
  const mailbox = 'Mailbox.org';
  const openXChange = "Open-Xchange";

  //  SerializableFinder for Coi Debug dialog Windows.
  final errorMessage = find.text(L.getKey(L.loginCheckMail));

  group('Performing welcome menu and provider list', () {
    test(': Check Ox.coi welcome screen, tap on Sign in to get the provider list, and check if all provider are contained in the list.', () async {
      await checkOxCoiWelcomeAndProviderList(
        driver,
        outlook,
        yahoo,
        find.text(coiDebug),
        mailbox,
      );
    });
  });

  group('Choose provider before starting the whole login check', () {
    test(': Scroll and select the coiDebug provider.', () async {
      await driver.scroll(find.text(mailCom), 0.0, -600.0, Duration(milliseconds: 500));
      await selectAndTapProvider(driver);
    });
  });

  group('Performing login without E-Mail or password', () {
    test(': Sign in without E-Mail and password.', () async {
      await logIn(driver, '', '');
      var actualErrorMessage = await driver.getText(errorMessage);
      expect(actualErrorMessage, L.getKey(L.loginCheckMail));
    });

    test(': Sign in without E-Mail.', () async {
      await logIn(driver, '', fakePassword);
      var actualErrorMessage = await driver.getText(errorMessage);
      expect(actualErrorMessage, L.getKey(L.loginCheckMail));
    });

    test(': Sign in without password.', () async {
      await logIn(driver, fakeInvalidEmail, '');
      var actualErrorMessage = await driver.getText(errorMessage);
      expect(actualErrorMessage, L.getKey(L.loginCheckMail));
    });

    test(': Sign in without password but with fake valid E-Mail.', () async {
      await logIn(driver, fakeValidEmail, '');
      var actualPasswordHint = await driver.getText(find.text(L.getKey(L.loginCheckPassword)));
      expect(actualPasswordHint, L.getKey(L.loginCheckPassword));
    });
  });

  group('Performing login with fake login information', () {
    test(': Sign in with fake invalid E-Mail and fake password.', () async {
      await logIn(driver, fakeInvalidEmail, fakePassword);
      var actualErrorMessage = await driver.getText(errorMessage);
      expect(actualErrorMessage, L.getKey(L.loginCheckMail));
    });

    test(': Sign in with fake valid E-Mail and fake password.', () async {
      await logIn(driver, fakeValidEmail, fakePassword);
      var actualLoginErrorDialogTitle = await driver.getText(find.text(L.getKey(L.loginFailed)));
      expect(actualLoginErrorDialogTitle, L.getKey(L.loginFailed));
      await driver.tap(find.text(L.getKey(L.ok)));
    }, timeout: Timeout(Duration(seconds: 60)));

    test(': Sign in with fake invalid E-Mail and real password.', () async {
      await logIn(driver, fakeInvalidEmail, realPassword);
      var actualErrorMessage = await driver.getText(errorMessage);
      expect(actualErrorMessage, L.getKey(L.loginCheckMail));
    });

    test(': Sign in with fake valid E-Mail and real password.', () async {
      await logIn(driver, fakeValidEmail, realPassword);
      var actualLoginErrorDialogTitle = await driver.getText(find.text(L.getKey(L.loginFailed)));
      expect(actualLoginErrorDialogTitle, L.getKey(L.loginFailed));
      await driver.tap(find.text(L.getKey(L.ok)));
    }, timeout: Timeout(Duration(seconds: 60)));

    test(': Sign in with real E-Mail and fake password.', () async {
      await logIn(driver, realEmail, fakePassword);
      await driver.tap(find.text(L.getKey(L.ok)));
      var actualWrongPasswordHint = await driver.getText(find.text(L.getKey(L.loginCheckUsernamePassword)));
      expect(actualWrongPasswordHint, L.getKey(L.loginCheckUsernamePassword));
    }, timeout: Timeout(Duration(seconds: 60)));
  });

  group('Performing the login with real authentication informations', () {
    test(': Login test: Sign in with realEmail and realPassword.', () async {
      await logIn(driver, realEmail, realPassword);
      expect(await driver.getText(find.text(openXChange)), openXChange);
    }, timeout: Timeout(Duration(seconds: 60)));
  });
}

Future checkOxCoiWelcomeAndProviderList(
  FlutterDriver driver,
  String outlook,
  String yahoo,
  SerializableFinder coiDebugFinder,
  String mailbox,
) async {
  var actualLoginButton = await driver.getText(find.byValueKey(keyLoginLoginSignInText));
  var actualRegisterButton = await driver.getText(find.byValueKey(keyLoginRegisterText));

  expect(actualLoginButton, L.getKey(L.loginSignIn).toUpperCase());
  expect(actualRegisterButton, L.getKey(L.register).toUpperCase());
  await driver.tap(find.text(L.getKey(L.loginSignIn).toUpperCase()));

  //  Check if all providers are found in the list.
  var actualProvideOutlook = await driver.getText(find.text(outlook));
  var actualProviderYahoo = await driver.getText(find.text(yahoo));
  var actualLoginText = await driver.getText(find.text(L.getKey(L.loginSignIn)));
  var actualProviderDebug = await driver.getText(coiDebugFinder);
  var actualProviderOther = await driver.getText(find.text(L.getKey(L.providerOtherMailProvider)));
  var actualProviderMailbox = await driver.getText(find.text(mailbox));
  expect(actualProvideOutlook, outlook);
  expect(actualProviderYahoo, yahoo);
  expect(actualLoginText, L.getKey(L.loginSignIn));
  expect(actualProviderDebug, coiDebug);
  expect(actualProviderOther, L.getKey(L.providerOtherMailProvider));
  expect(actualProviderMailbox, mailbox);
}

Future selectAndTapProvider(FlutterDriver driver) async {
  final loginProviderSignInText = 'Sign in with Debug (mobile-qa)';
  final emailFieldFinder = find.byValueKey(keyProviderSignInEmailTextField);
  final passwordFieldFinder = find.byValueKey(keyProviderSignInPasswordTextField);

  expect(await driver.getText(find.text(coiDebug)), coiDebug);
  await driver.tap(find.text(coiDebug));
  expect(await driver.getText(find.text(loginProviderSignInText)), loginProviderSignInText);
  expect(await driver.getText(find.text(L.getKey(L.loginSignIn).toUpperCase())), L.getKey(L.loginSignIn).toUpperCase());
  await driver.waitFor(emailFieldFinder);
  await driver.waitFor(passwordFieldFinder);
}
