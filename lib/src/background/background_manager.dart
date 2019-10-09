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

import 'package:background_fetch/background_fetch.dart';
import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:logging/logging.dart';
import 'package:ox_coi/src/notifications/local_push_manager.dart';
import 'package:ox_coi/src/utils/constants.dart';

void backgroundHeadlessTask() async {
  var core = DeltaChatCore();
  var init = await core.init(dbName);
  if (init) {
    await getMessages();
    await core.stop();
  }
  BackgroundFetch.finish();
}

Future<void> getMessages() async {
  var context = Context();
  await context.interruptIdleForIncomingMessages();
  var localPushManager = LocalPushManager();
  await localPushManager.setup();
  await localPushManager.triggerLocalPush();
}

class BackgroundManager {
  final Logger _logger = Logger("background_manager");

  static BackgroundManager _instance;

  bool _running = false;

  factory BackgroundManager() => _instance ??= BackgroundManager._internal();

  BackgroundManager._internal();

  setupAndStart() {
    BackgroundFetch.registerHeadlessTask(backgroundHeadlessTask);
    BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 15,
          stopOnTerminate: false,
          enableHeadless: true,
          startOnBoot: true,
        ),
        _callback);
    _running = true;
    _logger.info("Configured and started background fetch");
  }

  Future<void> _callback() async {
    await getMessages();
    BackgroundFetch.finish();
  }

  void start() async {
    if (_running) {
      return;
    }
    await BackgroundFetch.start();
    _logger.info("Started background fetch");
    _running = true;
  }

  void stop() {
    if (!_running) {
      return;
    }
    BackgroundFetch.stop();
    _logger.info("Stopped background fetch");
    _running = false;
  }
}
