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


    // Test login Yahoo provider.
    testWidgets('Login Yahoo', (WidgetTester tester) async {
      await tester.pumpWidget(TestWrapper(
        child: Login(_onSuccess),
        mockObserver: mockObserver,
      ));
      await tester.runAsync(() async {
        await tester.pumpAndSettle();

        // Test the full welcome page.
        expect(find.byType(Text), findsNWidgets(4));
        expect(find.text('Welcome to OX Coi'), findsOneWidget);
        expect(
            find.text(
                'OX Coi works with any email account. If you have one, please sign in, otherwise register a new account first.'),
            findsOneWidget);
        expect(find.text('SIGN IN'), findsOneWidget);
        expect(find.text('REGISTER'), findsOneWidget);

        // Get loginButton and tap it to get the provider page.
        final loginButton = find.byType(RaisedButton);
        await tester.tap(loginButton);
        await tester.pumpAndSettle();
        final providerList = find.byType(ProviderList);

        expect(find.text('Sign in'), findsOneWidget);
        expect(find.text('Please select your email provider to sign in'),
            findsOneWidget);
        expect(providerList, findsOneWidget);

        // Get Yahoo provider.
        expect(find.text('Yahoo'), findsOneWidget);
        final finder = find.text('Yahoo');
        await tester.tap(finder);
        await tester.pumpAndSettle();
        expect(find.text("Email address"), findsWidgets);
        expect(find.text("Password"), findsWidgets);
        expect(find.text('Sign in with Yahoo?'), findsOneWidget);
        expect(find.text("SIGN IN"), findsOneWidget);

        //Try to sign in with Yahoo
        // Without credential.
        final finderSINGIN = find.text('SIGN IN');
        await tester.tap(finderSINGIN);
        await tester.pumpAndSettle();
        expect(
            find.text('Please enter a valid e-mail address'), findsOneWidget);
        expect(find.text('Email address'), findsWidgets);

        // Only with Email
        final finderSINGIN1 = find.text('SIGN IN');
        await tester.enterText(find.byType(TextField).at(0), "enyakam3@ox.com");
        await tester.tap(finderSINGIN1);
        await tester.pumpAndSettle();
        expect(find.text('Email address'), findsWidgets);

        // With fake credential.
        await tester.enterText(find.byType(TextField).at(0), "fake2@ox.com");
        await tester.enterText(find.byType(TextField).at(1), "fakepasst");
        final finderSINGIN2 = find.text('SIGN IN');
        await tester.tap(finderSINGIN2);
        await tester.pumpAndSettle();
        expect(
            find.text("Please check your username and password"), findsWidgets);

        // third with real credential.
        await tester.enterText(find.byType(TextField).at(0), 'enyakam3@ox.com');
        await tester.enterText(find.byType(TextField).at(1), 'secret');

        final finderSINGIN3 = find.text('SIGN IN');
        await tester.tap(finderSINGIN3);
        await tester.pumpAndSettle();
        expect(find.text("Login failed"), findsWidgets);
      });
    });

    // Test login Outlook provider.
    testWidgets('Login Outlook', (WidgetTester tester) async {
      await tester.pumpWidget(TestWrapper(
        child: Login(_onSuccess),
        mockObserver: mockObserver,
      ));
      await tester.runAsync(() async {
        await tester.pumpAndSettle();

        // Test the full welcome page.
        expect(find.byType(Text), findsNWidgets(4));
        expect(find.text('Welcome to OX Coi'), findsOneWidget);
        expect(
            find.text(
                'OX Coi works with any email account. If you have one, please sign in, otherwise register a new account first.'),
            findsOneWidget);
        expect(find.text('SIGN IN'), findsOneWidget);
        expect(find.text('REGISTER'), findsOneWidget);

        // Get loginButton and tap it to get the provider page.
        final loginButton = find.byType(RaisedButton);
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        // Get Outlook provider.
        expect(find.text('Outlook'), findsOneWidget);
        final finder = find.text('Outlook');
        await tester.tap(finder);
        await tester.pumpAndSettle();
        expect(find.text("Email address"), findsWidgets);
        expect(find.text("Password"), findsWidgets);
        expect(find.text("SIGN IN"), findsOneWidget);
        expect(find.text('Sign in with Outlook?'), findsOneWidget);

        // Try to sign in with Outlook
        // Without credential.
        final finderSINGIN = find.text('SIGN IN');
        await tester.tap(finderSINGIN);
        await tester.pumpAndSettle();
        expect(
            find.text('Please enter a valid e-mail address'), findsOneWidget);
        expect(find.text('Email address'), findsWidgets);

        // Only with Email
        final finderSINGIN1 = find.text('SIGN IN');
        await tester.enterText(find.byType(TextField).at(0), "enyakam3@ox.com");
        await tester.tap(finderSINGIN1);
        await tester.pumpAndSettle();
        expect(find.text('Email address'), findsWidgets);

        // With fake credential.
        await tester.enterText(find.byType(TextField).at(0), "fake2@ox.com");
        await tester.enterText(find.byType(TextField).at(1), "fakepasst");
        final finderSINGIN2 = find.text('SIGN IN');
        await tester.tap(finderSINGIN2);
        await tester.pumpAndSettle();
        expect(
            find.text("Please check your username and password"), findsWidgets);

        // third with real credential.
        await tester.enterText(find.byType(TextField).at(0), 'enyakam3@ox.com');
        await tester.enterText(find.byType(TextField).at(1), 'secret');

        final finderSINGIN3 = find.text('SIGN IN');
        await tester.tap(finderSINGIN3);
        await tester.pumpAndSettle();
        expect(find.text("Login failed"), findsWidgets);
      });
    });

    // Test login GMX provider.
    testWidgets('Login GMX', (WidgetTester tester) async {
      await tester.pumpWidget(TestWrapper(
        child: Login(_onSuccess),
        mockObserver: mockObserver,
      ));
      await tester.runAsync(() async {
        await tester.pumpAndSettle();

        // Test the full welcome page.
        expect(find.byType(Text), findsNWidgets(4));
        expect(find.text('Welcome to OX Coi'), findsOneWidget);
        expect(
            find.text(
                'OX Coi works with any email account. If you have one, please sign in, otherwise register a new account first.'),
            findsOneWidget);
        expect(find.text('SIGN IN'), findsOneWidget);
        expect(find.text('REGISTER'), findsOneWidget);

        // Get loginButton and tap it to get the provider page.
        final loginButton = find.byType(RaisedButton);
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        // Get GMX provider.
        expect(find.text('GMX'), findsOneWidget);
        final finder = find.text('GMX');
        await tester.tap(finder);
        await tester.pumpAndSettle();
        expect(find.text("Email address"), findsWidgets);
        expect(find.text("Password"), findsWidgets);
        expect(find.text("SIGN IN"), findsOneWidget);
        expect(find.text('Sign in with GMX?'), findsOneWidget);

        // Try to sign in with Login GMX.
        // Without credential.
        final finderSINGIN = find.text('SIGN IN');
        await tester.tap(finderSINGIN);
        await tester.pumpAndSettle();
        expect(
            find.text('Please enter a valid e-mail address'), findsOneWidget);
        expect(find.text('Email address'), findsWidgets);

        // Only with Email
        final finderSINGIN1 = find.text('SIGN IN');
        await tester.enterText(find.byType(TextField).at(0), "enyakam3@ox.com");
        await tester.tap(finderSINGIN1);
        await tester.pumpAndSettle();
        expect(find.text('Email address'), findsWidgets);

        // With fake credential.
        await tester.enterText(find.byType(TextField).at(0), "fake2@ox.com");
        await tester.enterText(find.byType(TextField).at(1), "fakepasst");
        final finderSINGIN2 = find.text('SIGN IN');
        await tester.tap(finderSINGIN2);
        await tester.pumpAndSettle();
        expect(
            find.text("Please check your username and password"), findsWidgets);

        // third with real credential.
        await tester.enterText(find.byType(TextField).at(0), 'enyakam3@ox.com');
        await tester.enterText(find.byType(TextField).at(1), 'secret');

        final finderSINGIN3 = find.text('SIGN IN');
        await tester.tap(finderSINGIN3);
        await tester.pumpAndSettle();
        expect(find.text("Login failed"), findsWidgets);
      });
    });

    // Test login Mailbox.org provider.
    testWidgets('Login Mailbox.org', (WidgetTester tester) async {
      await tester.pumpWidget(TestWrapper(
        child: Login(_onSuccess),
        mockObserver: mockObserver,
      ));
      await tester.runAsync(() async {
        await tester.pumpAndSettle();

        // Test the full welcome page.
        expect(find.byType(Text), findsNWidgets(4));
        expect(find.text('Welcome to OX Coi'), findsOneWidget);
        expect(
            find.text(
                'OX Coi works with any email account. If you have one, please sign in, otherwise register a new account first.'),
            findsOneWidget);
        expect(find.text('SIGN IN'), findsOneWidget);
        expect(find.text('REGISTER'), findsOneWidget);

        // Get loginButton and tap it to get the provider page.
        final loginButton = find.byType(RaisedButton);
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        // Get Mailbox.org provider.
        expect(find.text('Mailbox.org'), findsOneWidget);
        final finder = find.text('Mailbox.org');
        await tester.tap(finder);
        await tester.pumpAndSettle();
        expect(find.text('Sign in with Mailbox.org?'), findsOneWidget);
        expect(find.text("Email address"), findsWidgets);
        expect(find.text("Password"), findsWidgets);
        expect(find.text("SIGN IN"), findsOneWidget);

        // Try to sign in with Login Mailbox.org.
        // Without credential.
        final finderSINGIN = find.text('SIGN IN');
        await tester.tap(finderSINGIN);
        await tester.pumpAndSettle();
        expect(
            find.text('Please enter a valid e-mail address'), findsOneWidget);
        expect(find.text('Email address'), findsWidgets);

        // Only with Email
        final finderSINGIN1 = find.text('SIGN IN');
        await tester.enterText(find.byType(TextField).at(0), "enyakam3@ox.com");
        await tester.tap(finderSINGIN1);
        await tester.pumpAndSettle();
        expect(find.text('Email address'), findsWidgets);

        // With fake credential.
        await tester.enterText(find.byType(TextField).at(0), "fake2@ox.com");
        await tester.enterText(find.byType(TextField).at(1), "fakepasst");
        final finderSINGIN2 = find.text('SIGN IN');
        await tester.tap(finderSINGIN2);
        await tester.pumpAndSettle();
        expect(
            find.text("Please check your username and password"), findsWidgets);

        // third with real credential.
        await tester.enterText(find.byType(TextField).at(0), 'enyakam3@ox.com');
        await tester.enterText(find.byType(TextField).at(1), 'secret');

        final finderSINGIN3 = find.text('SIGN IN');
        await tester.tap(finderSINGIN3);
        await tester.pumpAndSettle();
        expect(find.text("Login failed"), findsWidgets);
      });
    });

    // Test login Mail.com provider.
    testWidgets('Mail.com', (WidgetTester tester) async {
      await tester.pumpWidget(TestWrapper(
        child: Login(_onSuccess),
        mockObserver: mockObserver,
      ));
      await tester.runAsync(() async {
        await tester.pumpAndSettle();

        // Test the full welcome page.
        expect(find.byType(Text), findsNWidgets(4));
        expect(find.text('Welcome to OX Coi'), findsOneWidget);
        expect(
            find.text(
                'OX Coi works with any email account. If you have one, please sign in, otherwise register a new account first.'),
            findsOneWidget);
        expect(find.text('SIGN IN'), findsOneWidget);
        expect(find.text('REGISTER'), findsOneWidget);

        // Get loginButton and tap it to get the provider page.
        final loginButton = find.byType(RaisedButton);
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        // Get Mail.com provider.
        expect(find.text('Mail.com'), findsOneWidget);
        final finder = find.text('Mail.com');
        await tester.tap(finder);
        await tester.pumpAndSettle();
        expect(find.text("Email address"), findsWidgets);
        expect(find.text("Password"), findsWidgets);
        expect(find.text("SIGN IN"), findsOneWidget);
        expect(find.text('Sign in with Mail.com?'), findsOneWidget);

        // Try to sign in with Mail.com.
        // Without credential.
        final finderSINGIN = find.text('SIGN IN');
        await tester.tap(finderSINGIN);
        await tester.pumpAndSettle();
        expect(
            find.text('Please enter a valid e-mail address'), findsOneWidget);
        expect(find.text('Email address'), findsWidgets);

        // Only with Email
        final finderSINGIN1 = find.text('SIGN IN');
        await tester.enterText(find.byType(TextField).at(0), "enyakam3@ox.com");
        await tester.tap(finderSINGIN1);
        await tester.pumpAndSettle();
        expect(find.text('Email address'), findsWidgets);

        // With fake credential.
        await tester.enterText(find.byType(TextField).at(0), "fake2@ox.com");
        await tester.enterText(find.byType(TextField).at(1), "fakepasst");
        final finderSINGIN2 = find.text('SIGN IN');
        await tester.tap(finderSINGIN2);
        await tester.pumpAndSettle();
        expect(
            find.text("Please check your username and password"), findsWidgets);

        // third with real credential.
        await tester.enterText(find.byType(TextField).at(0), 'enyakam3@ox.com');
        await tester.enterText(find.byType(TextField).at(1), 'secret');

        final finderSINGIN3 = find.text('SIGN IN');
        await tester.tap(finderSINGIN3);
        await tester.pumpAndSettle();
        expect(find.text("Login failed"), findsWidgets);
      });
    });

    // Test login Other Mail provider.
    testWidgets('Other Mail', (WidgetTester tester) async {
      await tester.pumpWidget(TestWrapper(
        child: Login(_onSuccess),
        mockObserver: mockObserver,
      ));

      await tester.runAsync(() async {
        await tester.pumpAndSettle();

        // Test the full welcome page.
        expect(find.byType(Text), findsNWidgets(4));
        expect(find.text('Welcome to OX Coi'), findsOneWidget);
        expect(
            find.text(
                'OX Coi works with any email account. If you have one, please sign in, otherwise register a new account first.'),
            findsOneWidget);
        expect(find.text('SIGN IN'), findsOneWidget);
        expect(find.text('REGISTER'), findsOneWidget);

        // Get loginButton and tap it to get the provider page.
        final loginButton = find.byType(RaisedButton);
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        // We navigate in the screen to get other Provider
        await tester.drag(find.text('Mail.com'), Offset(0.0, -600.0));
        await tester.pumpAndSettle();

        // Get Other mail provider.
        final finder1 = find.text("Other mail account");
        await tester.tap(finder1);
        await tester.pumpAndSettle();

        // Try to sign in with Other mail.
        expect(find.text("Manual Settings"), findsOneWidget);
        expect(find.text("Email address"), findsWidgets);
        expect(find.text("Password"), findsWidgets);
        expect(find.text("Sign in with other?"), findsOneWidget);
        expect(find.text('SIGN IN'), findsOneWidget);

        // Scroll in Other mail provider to tap Manual Settings.
        await tester.enterText(find.byType(TextField).at(0), 'youremail@.com');
        await tester.enterText(find.byType(TextField).at(1), 'yourPassword');

        final finderSINGIN = find.text('SIGN IN');
        await tester.tap(finderSINGIN);
        await tester.pumpAndSettle();
        expect(
            find.text('Please enter a valid e-mail address'), findsOneWidget);
        expect(find.text('Email address'), findsWidgets);

        // Scroll in Other mail to tap Manual settings
        await tester.drag(find.text('SIGN IN'), Offset(0.0, -600.0));
        await tester.pumpAndSettle();

        // Test Manual Settings.
        final finderManualSetting = find.text("Manual Settings");
        await tester.tap(finderManualSetting);
        await tester.pumpAndSettle();
        expect(find.text("SIGN IN"), findsOneWidget);
        expect(find.text("Manual Settings"), findsOneWidget);
        expect(find.text("Please specify your email server settings."),
            findsOneWidget);
        expect(
            find.text(
                "Often you only need to provide your email address, password and server addresses. The remaining values are determined automatically. Sometimes IMAP needs to be enabled in your email website. Consult your email provider or friends for help."),
            findsOneWidget);
        expect(find.text("Base Settings"), findsOneWidget);
        expect(find.text("Email address"), findsOneWidget);
        expect(find.text("Password"), findsOneWidget);
        expect(find.text("Server addresses"), findsOneWidget);
        expect(find.text("IMAP server (e.g. imap.coi.me)"), findsOneWidget);
        expect(find.text("SMTP server (e.g. smtp.coi.me)"), findsOneWidget);
        expect(find.text("Advanced IMAP Settings"), findsOneWidget);
        expect(find.text("IMAP port"), findsOneWidget);
        expect(find.text("IMAP Security"), findsOneWidget);
        expect(find.text("Automatic"), findsWidgets);
        expect(find.text("SMTP Security"), findsOneWidget);
        expect(find.text("SMTP port"), findsOneWidget);
        expect(find.text("Advanced SMTP Settings"), findsOneWidget);
        expect(find.text("Off"), findsWidgets);
        expect(find.text("SSL/TLS"), findsWidgets);
        expect(find.text("StartTLS"), findsWidgets);

        // Login without credential.
        final finderSINGIN2 = find.text('SIGN IN');
        await tester.tap(finderSINGIN2);
        await tester.pumpAndSettle();
        expect(
            find.text('Please enter a valid e-mail address'), findsOneWidget);
      });
    });

    // Test login Coi debug provider.
    testWidgets('Coi debug', (WidgetTester tester) async {
      await tester.pumpWidget(TestWrapper(
        child: Login(_onSuccess),
        mockObserver: mockObserver,
      ));

      await tester.runAsync(() async {
        await tester.pumpAndSettle();

        // Test the full welcome page.
        expect(find.byType(Text), findsNWidgets(4));
        expect(find.text('Welcome to OX Coi'), findsOneWidget);
        expect(
            find.text(
                'OX Coi works with any email account. If you have one, please sign in, otherwise register a new account first.'),
            findsOneWidget);
        expect(find.text('SIGN IN'), findsOneWidget);
        expect(find.text('REGISTER'), findsOneWidget);

        // Get loginButton and tap it to get the provider page.
        final loginButton = find.byType(RaisedButton);
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        // We navigate in the screen to get other Provider
        await tester.drag(find.text('Mail.com'), Offset(0.0, -300.0));
        await tester.pumpAndSettle();

        // Get Other mail provider.
        final finder1 = find.text("Coi debug");
        await tester.tap(finder1);
        await tester.pumpAndSettle();
        expect(find.text("Email address"), findsWidgets);
        expect(find.text("Password"), findsWidgets);
        expect(find.text("Sign in with Coi debug?"), findsOneWidget);
        expect(find.text("SIGN IN"), findsOneWidget);

        // Try to sign in with Coi debug.
        // Without credential.
        final finderSINGIN = find.text('SIGN IN');
        await tester.tap(finderSINGIN);
        await tester.pumpAndSettle();
        expect(
            find.text('Please enter a valid e-mail address'), findsOneWidget);
        expect(find.text('Email address'), findsWidgets);
        //makeTest(tester);
       // Only with Email
        final finderSINGIN1 = find.text('SIGN IN');
        await tester.enterText(find.byType(TextField).at(0), "enyakam3@ox.com");
        await tester.tap(finderSINGIN1);
        await tester.pumpAndSettle();
        expect(find.text('Email address'), findsWidgets);

        // With fake credential.
        await tester.enterText(find.byType(TextField).at(0), "fake2@ox.com");
        await tester.enterText(find.byType(TextField).at(1), "fakepasst");
        final finderSINGIN2 = find.text('SIGN IN');
        await tester.tap(finderSINGIN2);
        await tester.pumpAndSettle();
        expect(
            find.text("Please check your username and password"), findsWidgets);

        // third with real credential.
        await tester.enterText(find.byType(TextField).at(0), 'enyakam3@ox.com');
        await tester.enterText(find.byType(TextField).at(1), 'secret');

        final finderSINGIN3 = find.text('SIGN IN');
        await tester.tap(finderSINGIN3);
        await tester.pumpAndSettle();
        expect(find.text("Login failed"), findsWidgets);
        // Check text Field to be sure that the Email address and password was take in the fields.
        final textField = find.byType(TextField);
        print(textField.toString());
      });
    });
  });
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



/*void  makeTest(WidgetTester tester)async{
  // Only with Email
  final finderSINGIN1 = find.text('SIGN IN');
  await tester.enterText(find.byType(TextField).at(0), "enyakam3@ox.com");
  await tester.tap(finderSINGIN1);
  await tester.pumpAndSettle();
  expect(find.text('Email address'), findsWidgets);

  // With fake credential.
  await tester.enterText(find.byType(TextField).at(0), "fake2@ox.com");
  await tester.enterText(find.byType(TextField).at(1), "fakepasst");
  final finderSINGIN2 = find.text('SIGN IN');
  await tester.tap(finderSINGIN2);
  await tester.pumpAndSettle();
  expect(
      find.text("Please check your username and password"), findsWidgets);

  // third with real credential.
  await tester.enterText(find.byType(TextField).at(0), 'enyakam3@ox.com');
  await tester.enterText(find.byType(TextField).at(1), 'secret');

  final finderSINGIN3 = find.text('SIGN IN');
  await tester.tap(finderSINGIN3);
  await tester.pumpAndSettle();
  expect(find.text("Login failed"), findsWidgets);
  // Check text Field to be sure that the Email address and password was take in the fields.
  final textField = find.byType(TextField);
  print(textField.toString());
}*/