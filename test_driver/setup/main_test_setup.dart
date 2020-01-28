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
import 'package:test/test.dart';

import 'global_consts.dart';
import 'helper_methods.dart';

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

class Setup {
  FlutterDriver _driver;

  FlutterDriver get driver => _driver;

  perform([bool isLogin = false]) {
    setUpAll(() async {
      String targetPlatform = Platform.environment[environmentTargetPlatform];
      if (targetPlatform == environmentTargetPlatformAndroid) {
        await setupAndroid();
      }
      _driver = await FlutterDriver.connect();

      if (!isLogin) {
        await getAuthentication(
          _driver,
          coiDebug,
          realEmail,
          realPassword,
        );
      }
    });

    tearDownAll(() async {
      if (_driver != null) {
        _driver.close();
      }
    });
  }

  Future setupAndroid() async {
    await grantPermission(adbPath, permissionAudio);
    await grantPermission(adbPath, permissionReadStorage);
    await grantPermission(adbPath, permissionWriteStorage);
    await grantPermission(adbPath, permissionReadContacts);
    await grantPermission(adbPath, permissionWriteContacts);
  }

  Future grantPermission(String adbPath, String permission) async {
    String deviceId = Platform.environment[environmentDeviceId];
    String appId = Platform.environment[environmentAppId];
    await Process.run(
      adbPath,
      [
        '-s',
        deviceId,
        'shell',
        'pm',
        'grant',
        appId,
        permission,
      ],
    );
  }

  Future getAuthentication(
    FlutterDriver driver,
    String provider,
    String email,
    String password,
  ) async {
    final providerFinder = find.text(provider);
    await driver.tap(signInFinder);
    await driver.scroll(find.text(mailCom), 0, -600, Duration(milliseconds: 500));
    await driver.tap(providerFinder);
    await logIn(driver, email, password);
  }
}
