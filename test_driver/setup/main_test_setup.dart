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
import 'package:ox_coi/src/utils/keyMapping.dart';

import 'helper_methods.dart';
import 'test_constants.dart';
import 'test_providers.dart';

const String adbPath = 'adb';

const permissionAudio = 'android.permission.RECORD_AUDIO';
const permissionReadStorage = 'android.permission.READ_EXTERNAL_STORAGE';
const permissionWriteStorage = 'android.permission.WRITE_EXTERNAL_STORAGE';
const permissionReadContacts = 'android.permission.READ_CONTACTS';
const permissionWriteContacts = 'android.permission.WRITE_CONTACTS';

const environmentDeviceId = 'FLUTTER_TEST_DEVICE_ID';
const environmentAppId = 'FLUTTER_TEST_APP_ID';
const environmentTargetPlatform = 'FLUTTER_TEST_TARGET_PLATFORM';
const environmentTargetPlatformAndroid = 'android';
const environmentTargetPlatformIos = 'ios';

/// Sets up all required test components, depending on [performLoginInTestCase]
/// Will automatically perform the authentication and user initialisation per default.
/// If [performLoginInTestCase] is true the test case must handle the login by itself.
Future<FlutterDriver> setupAndGetDriver({bool performLoginInTestCase = false}) async {

  targetPlatform = Platform.environment[environmentTargetPlatform];
  targetProvider = Platform.environment[environmentProvider];

  await initProvidersAsync();

  if (targetPlatform == environmentTargetPlatformAndroid) {
    await setupAndroidAsync();
  }
  /// Connects the driver to the instrumented app.
  FlutterDriver driver = await FlutterDriver.connect();
  var connected = false;
  while (!connected) {
    try {
      await driver.waitUntilFirstFrameRasterized();
      connected = true;
    } catch (error) {}
  }
  if (!performLoginInTestCase) {
    await getAuthenticationAsync(driver, providerName, providerEmail, providerPassword);
  }
  return driver;
}

/// Loads provider information from credential.json.
/// Initializes the matching provider given by [targetProvider].
Future<void> initProvidersAsync() async {
  final contactId1 = 'contact1';
  final contactId2 = 'contact2';

  final providers = await loadTestProviders();
  for (final provider in providers) {
    if (provider.id == targetProvider) {
      providerName = provider.name;
      realServer = provider.server;
      providerEmail = provider.email;
      providerPassword = provider.password;
      for (var contact in provider.contacts) {
        if (contact.id == contactId1) {
          name1 = contact.username;
          email1 = contact.email;
        } else if (contact.id == contactId2) {
          name2 = contact.username;
          email2 = contact.email;
        }
      }
    }
  }
  if (realServer == null || providerEmail == null || providerPassword == null) {
    throw ArgumentError('Provider lookup for "$targetProvider" failed, please select a valid provider from your test_driver/setup/credential.json');
  }
}

/// Closes the driver at the end of the test.
void teardownDriver(FlutterDriver driver) {
  if (driver != null) {
    driver.close();
  }
}

/// Grants permission to allow the Flutter driver to access system functionality for Android device.
Future<void> setupAndroidAsync() async {
  await grantPermissionAsync(adbPath, permissionAudio);
  await grantPermissionAsync(adbPath, permissionReadStorage);
  await grantPermissionAsync(adbPath, permissionWriteStorage);
  await grantPermissionAsync(adbPath, permissionReadContacts);
  await grantPermissionAsync(adbPath, permissionWriteContacts);
}

/// Grants one permission using [adbPath] and [permission] to grant.
Future<void> grantPermissionAsync(String adbPath, String permission) async {
  String deviceId = Platform.environment[environmentDeviceId];
  String appId = Platform.environment[environmentAppId];
  await Process.run(adbPath, ['-s', deviceId, 'shell', 'pm', 'grant', appId, permission]);
}

/// Performs authentication with the selected [provider] with the given [email] and [password].
Future<void> getAuthenticationAsync(FlutterDriver driver, String provider, String email, String password) async {
  await selectProviderAsync(driver, provider);
  await performLoginAsync(driver, email, password);
  await driver.tap(find.byValueKey(keyDynamicNavigationNext));
  await driver.tap(find.byValueKey(keyDynamicNavigationSkip));
}

/// Selects the needed [provider] from the provider list.
Future<void> selectProviderAsync(FlutterDriver driver, String provider) async {
  final providerFinder = find.text(provider);
  await driver.tap(signInFinder);
  await driver.scroll(find.text(providerMailCom), 0, -600, Duration(milliseconds: 500));
  await driver.tap(providerFinder);
}
