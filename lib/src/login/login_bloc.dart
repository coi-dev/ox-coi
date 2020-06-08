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
import 'package:ox_coi/src/data/config.dart';
import 'package:ox_coi/src/error/error_bloc.dart';
import 'package:ox_coi/src/error/error_event_state.dart';
import 'package:ox_coi/src/extensions/string_apis.dart';
import 'package:ox_coi/src/login/login_events_state.dart';
import 'package:ox_coi/src/login/providers.dart';
import 'package:ox_coi/src/platform/preferences.dart';
import 'package:ox_coi/src/utils/assets.dart';
import 'package:ox_coi/src/utils/core.dart';
import 'package:rxdart/rxdart.dart';

import 'login_provider_list.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final ErrorBloc errorBloc;
  DeltaChatCore _core = DeltaChatCore();
  Context _context = Context();
  bool _listenersRegistered = false;
  PublishSubject<Event> _loginSubject = new PublishSubject();

  // ignore: close_sinks
  BehaviorSubject<Event> _errorSubject = new BehaviorSubject();

  LoginBloc(this.errorBloc);

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
        performLogin();
      } catch (error) {
        yield LoginStateFailure(error: error.toString());
      }
    } else if (event is LoginButtonPressed) {
      yield LoginStateLoading(progress: 0);
      try {
        await _setupConfig(event);
        _registerListeners();
        performLogin();
      } catch (error) {
        yield LoginStateFailure(error: error.toString());
      }
    } else if (event is LoginWithNewPassword) {
      yield LoginStateLoading(progress: 0);
      try {
        await _setNewPassword(event.password);
        _registerListeners();
        performLogin();
      } catch (error) {
        yield LoginStateFailure(error: error.toString());
      }
    } else if (event is EditButtonPressed) {
      yield LoginStateLoading(progress: 0);
      try {
        _registerListeners();
        performLogin();
      } catch (error) {
        yield LoginStateFailure(error: error.toString());
      }
    } else if (event is LoginProgress) {
      if (_loginSuccess(event.progress)) {
        errorBloc.add(UpdateHandleErrors(delegateAndHandleErrors: true));
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

  void performLogin() {
    errorBloc.add(UpdateHandleErrors(delegateAndHandleErrors: false));
    _context.configure();
  }

  @override
  Future<void> close() {
    _unregisterListeners();
    return super.close();
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
    await config.setValue(Context.configSmtpSecurity, event.smtpSecurity);
    await config.setValue(Context.configImapSecurity, event.imapSecurity);
  }

  void _updateConfig() {
    Config config = Config();
    config.load();
  }

  void _registerListeners() async {
    if (!_listenersRegistered) {
      _listenersRegistered = true;
      _loginSubject.listen(_successCallback, onError: _errorCallback);
      _core.addListener(eventId: Event.configureProgress, streamController: _loginSubject);
      _core.addListener(eventId: Event.errorNoNetwork, streamController: _errorSubject);
    }
  }

  void _unregisterListeners() {
    if (_listenersRegistered) {
      _core.removeListener(_loginSubject);
      _core.removeListener(_errorSubject);
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
    Map<String, dynamic> json = await loadJsonAssetAsMapAsync('assets/customer/json/providers.json');

    Providers providers = Providers.fromJson(json);
    if (type == ProviderListType.register) {
      providers.providerList.removeWhere((provider) => provider.registerLink.isNullOrEmpty());
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
    await config.setValue(Context.configImapSecurity, preset.incomingSecurity.toString());
    await config.setValue(Context.configSmtpSecurity, preset.outgoingSecurity.toString());
    await setPreference(preferenceNotificationsPushServiceUrl, provider.pushServiceUrl);
    await setPreference(preferenceInviteServiceUrl, provider.inviteServiceUrl);
  }

  Future<void> _setNewPassword(String password) async {
    Config config = Config();
    await config.setValue(Context.configMailPassword, password);
  }
}
