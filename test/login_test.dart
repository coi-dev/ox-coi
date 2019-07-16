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

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ox_coi/src/l10n/localizations.dart';
import 'package:ox_coi/src/login/login.dart';
import 'package:ox_coi/src/login/login_provider_list.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('Ox coi', () {
    final mockObserver = MockNavigatorObserver();

    // All constants we need for the test
    final welcomeMessage = 'Welcome to OX Coi';
    final welcomeMessageOxCoi =
        'OX Coi works with any email account. If you have one, please sign in, otherwise register a new account first.';
    final enterEmailMessage = 'Please enter a valid e-mail address';
    final signInMessage = 'Sign in';
    final signInButton = 'SIGN IN';
    final selectProviderMethod = 'Please select your email provider to sign in';
    final emailAddress = 'Email address';
    final registerButton = 'REGISTER';
    final password = 'Password';
    final validEmailAddress = 'enyakam3@ox.com';
    final fakeEmailAddress = 'fake2@ox.com';
    final validPassword = 'secret';
    final fakePassword = 'fakepasst';
    final errorMessageForCredential = 'Please check your username and password';
    final errorLoginFail = 'Login failed';
    final finderSINGIN = find.text(signInButton);
    final loginButton = find.byType(RaisedButton);
    final yahoo = 'Yahoo';
    final outlook = 'Outlook';
    final gmx = 'GMX';
    final mailboxOrg = 'Mailbox.org';
    final mailCom = 'Mail.com';
    final otherMail = 'Other mail account';
    final coiDebug = 'Coi debug';
    final manualSetting = 'Manual Settings';

    final providerList = [
      yahoo,
      outlook,
      gmx,
      mailboxOrg,
      mailCom,
      otherMail,
      coiDebug
    ];

    // Run thought all provider list and get provider.
    for (int i = 0; i < providerList.length; i++) {
      var provider = providerList[i];

      testWidgets('Login test for $provider', (WidgetTester tester) async {
        await tester.pumpWidget(TestWrapper(
          child: Login(_onSuccess),
          mockObserver: mockObserver,
        ));
        await tester.runAsync(() async {
          await tester.pumpAndSettle();

          // Test the full welcome page.
          expectWelcomePage(welcomeMessage, welcomeMessageOxCoi, signInButton,
              registerButton);

          // Get loginButton and tap it to get the provider page, then test the providers welcome message.
          await getProviderPage(
              tester, signInMessage, loginButton, selectProviderMethod);

          if (provider != otherMail) {
            if (provider == coiDebug) {
              // We navigate in the screen to get other Provider
              await tester.drag(find.text(mailCom), Offset(0.0, -600.0));
              await tester.pumpAndSettle();
            }
            // Get provider.
            expect(find.text(provider), findsOneWidget);
            final finder = find.text(provider);
            await tester.tap(finder);
            await tester.pumpAndSettle();
            expect(find.text(emailAddress), findsWidgets);
            expect(find.text(password), findsWidgets);
            expect(find.text('Sign in with $provider?'), findsOneWidget);
            expect(find.text(signInButton), findsOneWidget);

            //Try to sign in with provider.
            // Without credential.
            await signInWithoutCredential(signInButton, tester,
                enterEmailMessage, emailAddress, finderSINGIN);

            // Test now with all credential possibilities.
            // Make credential test after selecting the provider.
            await completeCredentialTest(
                tester,
                validEmailAddress,
                finderSINGIN,
                emailAddress,
                fakeEmailAddress,
                fakePassword,
                signInButton,
                errorMessageForCredential,
                validPassword,
                errorLoginFail);
          } else {
            // We navigate in the screen to get other Provider
            await tester.drag(find.text(mailCom), Offset(0.0, -600.0));
            await tester.pumpAndSettle();

            // Get other provider.
            expect(find.text(provider), findsOneWidget);
            final finder = find.text(provider);
            await tester.tap(finder);
            await tester.pumpAndSettle();
            expect(find.text(emailAddress), findsWidgets);
            expect(find.text(password), findsWidgets);
            expect(find.text('Sign in with other?'), findsOneWidget);
            expect(find.text(signInButton), findsOneWidget);
            await testManualSettingOtherMail(
                emailAddress,
                password,
                signInButton,
                tester,
                fakeEmailAddress,
                fakePassword,
                finderSINGIN,
                manualSetting);
          }
        });
      });
    }
  });
}

Future testManualSettingOtherMail(
    String emailAddress,
    String password,
    String signInButton,
    WidgetTester tester,
    String fakeEmailAddress,
    String fakePassword,
    Finder finderSINGIN,
    String manualSetting) async {
  // Scroll in Other mail to tap or test  Manual settings
  final settingHelpMessage =
      "Often you only need to provide your email address, password and server addresses. The remaining values are determined automatically. Sometimes IMAP needs to be enabled in your email website. Consult your email provider or friends for help.";
  final serverSettings = "Please specify your email server settings.";
  final baseSettings = "Base Settings";
  final serverAddresses = "Server addresses";
  final serverEGImapCoiMe = "IMAP server (e.g. imap.coi.me)";
  final serverEGSmtpCoiMe = "SMTP server (e.g. smtp.coi.me)";
  final advancedIMAPSettings = "Advanced IMAP Settings";
  final iMAPPort = "IMAP port";
  final iMAPSecurity = "IMAP Security";
  final automatic = "Automatic";
  final sMTPSecurity = "SMTP Security";
  final sMTPPort = "SMTP port";
  final advancedSMTPSettings = "Advanced SMTP Settings";
  final off = "Off";
  final sSLTLS = "SSL/TLS";
  final startTLS = "StartTLS";

  // Try to sign in with Other mail.
  expect(find.text(manualSetting), findsOneWidget);
  expect(find.text(emailAddress), findsWidgets);
  expect(find.text(password), findsWidgets);
  expect(find.text("Sign in with other?"), findsOneWidget);
  expect(find.text(signInButton), findsOneWidget);

  // Scroll in Other mail to tap or test  Manual settings
  await tester.drag(find.text(signInButton), Offset(0.0, -300.0));
  await tester.pumpAndSettle();

  // Test Manual Settings first after enter fake Email Address and password.
  await tester.enterText(find.byType(TextField).at(0), fakeEmailAddress);
  await tester.enterText(find.byType(TextField).at(1), fakePassword);
  await tester.tap(finderSINGIN);
  await tester.pumpAndSettle();
  expect(find.text(signInButton), findsOneWidget);
  expect(find.text(manualSetting), findsOneWidget);
  expect(find.text(serverSettings), findsOneWidget);
  expect(find.text(settingHelpMessage), findsOneWidget);
  expect(find.text(baseSettings), findsOneWidget);
  expect(find.text(emailAddress), findsOneWidget);
  expect(find.text(password), findsOneWidget);
  expect(find.text(serverAddresses), findsOneWidget);
  expect(find.text(serverEGImapCoiMe), findsOneWidget);
  expect(find.text(serverEGSmtpCoiMe), findsOneWidget);
  expect(find.text(advancedIMAPSettings), findsOneWidget);
  expect(find.text(iMAPPort), findsOneWidget);
  expect(find.text(iMAPSecurity), findsOneWidget);
  expect(find.text(automatic), findsWidgets);
  expect(find.text(sMTPSecurity), findsOneWidget);
  expect(find.text(sMTPPort), findsOneWidget);
  expect(find.text(advancedSMTPSettings), findsOneWidget);
  expect(find.text(off), findsWidgets);
  expect(find.text(sSLTLS), findsWidgets);
  expect(find.text(startTLS), findsWidgets);

  // Login without credential.
  await tester.tap(finderSINGIN);
  await tester.pumpAndSettle();
}

Future completeCredentialTest(
    WidgetTester tester,
    String validEmailAddress,
    Finder finderSINGIN,
    String emailAddress,
    String fakeEmailAddress,
    String fakePassword,
    String signInButton,
    String errorMessageForCredential,
    String validPassword,
    String errorLoginFail) async {
  await tester.enterText(find.byType(TextField).at(0), validEmailAddress);
  await tester.tap(finderSINGIN);
  await tester.pumpAndSettle();
  expect(find.text(emailAddress), findsWidgets);

  // With fake credential.
  await tester.enterText(find.byType(TextField).at(0), fakeEmailAddress);
  await tester.enterText(find.byType(TextField).at(1), fakePassword);
  await tester.tap(finderSINGIN);
  await tester.pumpAndSettle();
  expect(find.text(errorMessageForCredential), findsWidgets);

  // third with real credential.
  await tester.enterText(find.byType(TextField).at(0), validEmailAddress);
  await tester.enterText(find.byType(TextField).at(1), validPassword);
  await tester.tap(finderSINGIN);
  await tester.pumpAndSettle();
  expect(find.text(errorLoginFail), findsWidgets);
}

Future signInWithoutCredential(String signInButton, WidgetTester tester,
    String enterEmailMessage, String emailAddress, Finder finderSINGIN) async {
  await tester.tap(finderSINGIN);
  await tester.pumpAndSettle();
  expect(find.text(enterEmailMessage), findsOneWidget);
  expect(find.text(emailAddress), findsWidgets);
}

Future getProviderPage(WidgetTester tester, String signInMessage,
    Finder loginButton, String selectProviderMethod) async {
  await tester.tap(loginButton);
  await tester.pumpAndSettle();
  final providerList = find.byType(ProviderList);

  expect(find.text(signInMessage), findsOneWidget);
  expect(find.text(selectProviderMethod), findsOneWidget);
  expect(providerList, findsOneWidget);
}

void expectWelcomePage(String welcomeMessage, String welcomeMessageOxCoi,
    String signInButton, String registerButton) {
  expect(find.byType(Text), findsNWidgets(4));
  expect(find.text(welcomeMessage), findsOneWidget);
  expect(find.text(welcomeMessageOxCoi), findsOneWidget);
  expect(find.text(signInButton), findsOneWidget);
  expect(find.text(registerButton), findsOneWidget);
}

// Wrapper class help to get all needed configuration for the Login.
class TestWrapper extends StatelessWidget {
  final Widget child;
  final MockNavigatorObserver mockObserver;

  const TestWrapper({Key key, this.child, this.mockObserver}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
      navigatorObservers: [mockObserver],
    );
  }
}

_onSuccess() {}
