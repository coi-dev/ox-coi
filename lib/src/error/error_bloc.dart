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

import 'package:bloc/bloc.dart';
import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:ox_coi/src/error/error_event_state.dart';
import 'package:ox_coi/src/platform/preferences.dart';
import 'package:ox_coi/src/utils/constants.dart';
import 'package:rxdart/rxdart.dart';

class ErrorBloc extends Bloc<ErrorEvent, ErrorState> {
  PublishSubject<Event> _errorSubject = new PublishSubject();
  var _core = DeltaChatCore();
  bool _delegateAndHandleErrors = true;
  bool _listenersRegistered = false;

  @override
  ErrorState get initialState => ErrorStateInitial();

  @override
  Stream<ErrorState> mapEventToState(ErrorEvent event) async* {
    if (event is SetupListeners) {
      try {
        yield* setupListeners();
      } catch (error) {
        yield ErrorStateFailure();
      }
    } else if (event is UpdateHandleErrors) {
      _delegateAndHandleErrors = event.delegateAndHandleErrors;
      yield ErrorStateHandleErrorsUpdated();
    } else if (event is DelegateUserVisibleError) {
      yield ErrorStateUserVisibleError(userVisibleError: event.userVisibleError);
    }
  }

  @override
  void close() {
    _unregisterListeners();
    super.close();
  }

  Stream<ErrorState> setupListeners() async* {
    _registerListeners();
    yield ErrorStateSetupDone();
  }

  void _registerListeners() async {
    if (!_listenersRegistered) {
      _errorSubject.listen(_errorCallback);
      _core.addListener(eventIdList: Event.allErrorsList, streamController: _errorSubject);
      _listenersRegistered = true;
    }
  }

  void _unregisterListeners() {
    if (_listenersRegistered) {
      _core.removeListener(_errorSubject);
      _listenersRegistered = false;
    }
  }

  void _errorCallback(Event event) {
    if (_delegateAndHandleErrors) {
      if (isAuthenticationError(event)) {
        _delegateAndHandleErrors = false;
        delegateAndHandleAuthenticationError();
      }
    }
  }

  void delegateAndHandleAuthenticationError() async {
    await setPreference(preferenceHasAuthenticationError, true);
    add(DelegateUserVisibleError(userVisibleError: UserVisibleError.authenticationFailed));
  }

  bool isAuthenticationError(Event event) {
    String data2 = event.data2;
    return (event.eventId == Event.errorNoNetwork && data2.contains(imapErrorAuthenticationFailed));
  }
}
