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

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ox_coi/src/data/config.dart';
import 'package:ox_coi/src/settings/settings_manual_form_event_state.dart';

class SettingsManualFormBloc extends Bloc<SettingsManualFormEvent, SettingsManualFormState> {
  @override
  SettingsManualFormState get initialState => SettingsManualFormStateInitial();

  @override
  Stream<SettingsManualFormState> mapEventToState(SettingsManualFormEvent event) async* {
    if (event is SetupSettings) {
      setupSettings(event.shouldLoadConfig, event.email, event.password);
    } else if (event is SettingsPrefilled) {
      if (event.containsConfig) {
        yield SettingsManualFormStateReady(
          email: event.email,
          imapLogin: event.imapLogin,
          imapServer: event.imapServer,
          imapPort: event.imapPort,
          smtpLogin: event.smtpLogin,
          smtpServer: event.smtpServer,
          smtpPort: event.smtpPort,
          imapSecurity: event.imapSecurity,
          smtpSecurity: event.smtpSecurity,
        );
      } else {
        yield SettingsManualFormStateReady(
          email: event.email,
          password: event.password,
        );
      }
    } else if (event is RequestValidateSettings) {
      yield SettingsManualFormStateValidation();
    } else if (event is ValidationDone) {
      if (event.success) {
        yield SettingsManualFormStateValidationSuccess(
          email: event.email,
          password: event.password,
          imapLogin: event.imapLogin,
          imapServer: event.imapServer,
          imapPort: event.imapPort,
          imapSecurity: event.imapSecurity,
          smtpLogin: event.smtpLogin,
          smtpPassword: event.smtpPassword,
          smtpServer: event.smtpServer,
          smtpPort: event.smtpPort,
          smtpSecurity: event.smtpSecurity,
        );
      } else {
        yield SettingsManualFormStateValidationFailure();
      }
    }
  }

  void setupSettings(bool shouldLoadConfig, String email, String password) {
    if (shouldLoadConfig) {
      var config = Config();
      var imapPort = config.imapPort;
      var smtpPort = config.smtpPort;
      add(SettingsPrefilled(
        containsConfig: true,
        email: config.email,
        imapLogin: config.imapLogin,
        imapServer: config.imapServer,
        imapPort: imapPort == "0" ? "" : imapPort,
        smtpLogin: config.smtpLogin,
        smtpServer: config.smtpServer,
        smtpPort: smtpPort == "0" ? "" : smtpPort,
        imapSecurity: config.imapSecurity,
        smtpSecurity: config.smtpSecurity,
      ));
    } else {
      add(SettingsPrefilled(containsConfig: false, email: email, password: password));
    }
  }
}
