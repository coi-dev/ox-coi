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
import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:ox_talk/src/data/config.dart';
import 'package:ox_talk/src/login/login_events.dart';
import 'package:ox_talk/src/login/login_state.dart';
import 'package:ox_talk/src/utils/protocol_security_converter.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  DeltaChatCore _core = DeltaChatCore();
  Context _context = Context();
  var _listenerId;

  LoginState get initialState => LoginStateInitial();

  @override
  Stream<LoginState> mapEventToState(LoginState currentState, LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      yield LoginStateLoading(progress: 0);
      try {
        _setupConfig(event);
        registerListener();
        _context.configure();
      } catch (error) {
        yield LoginStateFailure(error: error.toString());
      }
    } else if (event is LoginProgress) {
      if (_loginSuccess(event.progress)) {
        _updateConfig();
        yield LoginStateSuccess();
      } else if (_loginFailed(event.progress)) {
        yield LoginStateFailure(error: event.error);
      } else {
        yield LoginStateLoading(progress: event.progress);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _core.removeListener(Event.configureProgress, _listenerId);
  }

  void _setupConfig(LoginButtonPressed event) {
    Config config = Config();
    config.setValue(Context.configAddress, event.email);
    config.setValue(Context.configMailPassword, event.password);
    config.setValue(Context.configMailUser, event.imapLogin);
    config.setValue(Context.configMailServer, event.imapServer);
    config.setValue(Context.configMailPassword, event.imapPort);
    config.setValue(Context.configSendUser, event.smtpLogin);
    config.setValue(Context.configSendPassword, event.smtpPassword);
    config.setValue(Context.configSendServer, event.smtpServer);
    config.setValue(Context.configSendPort, event.smtpPort);
    int imapSecurity = event.imapSecurity;
    int smtpSecurity = event.smtpSecurity;
    int serverFlags = createServerFlagInteger(imapSecurity, smtpSecurity);

    config.setValue(Context.configServerFlags, serverFlags, false, ObjectType.int);
  }

  void _updateConfig() {
    Config config = Config();
    config.reload();
  }

  void registerListener() async {
    _listenerId = await _core.listen(Event.configureProgress, _successCallback, _errorCallback);
  }

  bool _loginSuccess(int progress) {
    return progress == 1000;
  }

  bool _loginFailed(int progress) {
    return progress == 0;
  }

  _successCallback(Event event) {
    int progress = event.data1 as int;
    dispatch(LoginProgress(progress));
  }

  _errorCallback(error) {
    dispatch(LoginProgress(0, error));
  }
}
