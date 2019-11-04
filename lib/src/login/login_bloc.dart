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
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ox_coi/src/data/config.dart';
import 'package:ox_coi/src/login/login_events_state.dart';
import 'package:ox_coi/src/login/providers.dart';
import 'package:ox_coi/src/platform/preferences.dart';
import 'package:ox_coi/src/utils/core.dart';
import 'package:ox_coi/src/utils/error.dart';
import 'package:ox_coi/src/utils/text.dart';
import 'package:rxdart/rxdart.dart';

import 'login_provider_list.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  DeltaChatCore _core = DeltaChatCore();
  Context _context = Context();
  bool _listenersRegistered = false;
  PublishSubject<Event> _loginSubject = new PublishSubject();

  // ignore: close_sinks
  BehaviorSubject<Event> _errorSubject = new BehaviorSubject();

  LoginState get initialState => LoginStateInitial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is RequestProviders) {
      try {
        _loadProviders(event.type);
      } catch (error) {
        yield LoginStateFailure(error: error.toString());
      }
    } else if (event is ProviderLoginButtonPressed) {
      yield LoginStateLoading(progress: 0);
      try {
        await _setupConfigWithProvider(event);
        _registerListeners();
        _context.configure();
      } catch (error) {
        yield LoginStateFailure(error: error.toString());
      }
    } else if (event is LoginButtonPressed) {
      yield LoginStateLoading(progress: 0);
      try {
        await _setupConfig(event);
        _registerListeners();
        _context.configure();
      } catch (error) {
        yield LoginStateFailure(error: error.toString());
      }
    } else if (event is EditButtonPressed) {
      yield LoginStateLoading(progress: 0);
      try {
        _registerListeners();
        _context.configure();
      } catch (error) {
        yield LoginStateFailure(error: error.toString());
      }
    } else if (event is LoginProgress) {
      if (_loginSuccess(event.progress)) {
        _updateConfig();
        yield LoginStateSuccess();
      } else if (_loginFailed(event.progress)) {
        String error = event.error;
        if (error == null) {
          error = getErrorMessage(_errorSubject.value);
        }
        yield LoginStateFailure(error: error);
      } else {
        yield LoginStateLoading(progress: event.progress);
      }
    } else if (event is ProvidersLoaded) {
      yield LoginStateProvidersLoaded(providers: event.providers);
    }
  }

  @override
  void close() {
    _unregisterListeners();
    super.close();
  }

  Future<void> _setupConfig(LoginButtonPressed event) async {
    Config config = Config();
    await config.setValue(Context.configAddress, event.email);
    await config.setValue(Context.configMailPassword, event.password);
    await config.setValue(Context.configMailUser, event.imapLogin);
    await config.setValue(Context.configMailServer, event.imapServer);
    await config.setValue(Context.configMailPort, event.imapPort);
    await config.setValue(Context.configSendUser, event.smtpLogin);
    await config.setValue(Context.configSendPassword, event.smtpPassword);
    await config.setValue(Context.configSendServer, event.smtpServer);
    await config.setValue(Context.configSendPort, event.smtpPort);
    int imapSecurity = event.imapSecurity;
    int smtpSecurity = event.smtpSecurity;
    int serverFlags = createServerFlagInteger(imapSecurity, smtpSecurity);

    await config.setValue(Context.configServerFlags, serverFlags);
  }

  void _updateConfig() {
    Config config = Config();
    config.reload();
  }

  void _registerListeners() async {
    if (!_listenersRegistered) {
      _listenersRegistered = true;
      _loginSubject.listen(_successCallback, onError: _errorCallback);
      await _core.listen(Event.configureProgress, _loginSubject);
      await _core.listen(Event.error, _errorSubject);
    }
  }

  void _unregisterListeners() {
    if (_listenersRegistered) {
      _core.removeListener(Event.configureProgress, _loginSubject);
      _core.removeListener(Event.error, _errorSubject);
      _listenersRegistered = false;
    }
  }

  bool _loginSuccess(int progress) {
    return progress == 1000;
  }

  bool _loginFailed(int progress) {
    return progress == 0;
  }

  void _successCallback(Event event) {
    int progress = event.data1 as int;
    add(LoginProgress(progress: progress));
  }

  void _errorCallback(error) async {
    add(LoginProgress(progress: 0, error: error));
  }

  void _loadProviders(ProviderListType type) async {
    Map<String, dynamic> json = await rootBundle.loadString('assets/json/providers.json').then((jsonStr) => jsonDecode(jsonStr));

    Providers providers = Providers.fromJson(json);
    if (type == ProviderListType.register) {
      providers.providerList.removeWhere((provider) => isNullOrEmpty(provider.registerLink));
    }
    add(ProvidersLoaded(providers: providers.providerList));
  }

  _setupConfigWithProvider(ProviderLoginButtonPressed event) async {
    Config config = Config();
    var provider = event.provider;
    Preset preset = provider.preset;

    await config.setValue(Context.configAddress, event.email);
    await config.setValue(Context.configMailPassword, event.password);
    await config.setValue(Context.configMailUser, event.imapLogin);
    await config.setValue(Context.configMailServer, preset.incomingServer);
    await config.setValue(Context.configMailPort, preset.incomingPort.toString());
    await config.setValue(Context.configSendUser, event.smtpLogin);
    await config.setValue(Context.configSendPassword, event.smtpPassword);
    await config.setValue(Context.configSendServer, preset.outgoingServer);
    await config.setValue(Context.configSendPort, preset.outgoingPort.toString());
    int imapSecurity = getSecurityId(preset.incomingSecurity);
    int smtpSecurity = getSecurityId(preset.outgoingSecurity);
    int serverFlags = createServerFlagInteger(imapSecurity, smtpSecurity);
    await config.setValue(Context.configServerFlags, serverFlags);
    await setPreference(preferenceNotificationsPushServiceUrl, provider.pushServiceUrl);
  }
}
