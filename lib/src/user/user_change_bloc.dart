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
import 'package:ox_coi/src/user/user_change_event_state.dart';

class UserChangeBloc extends Bloc<UserChangeEvent, UserChangeState> {

  @override
  UserChangeState get initialState => UserChangeStateInitial();

  @override
  Stream<UserChangeState> mapEventToState(UserChangeEvent event) async* {
    if (event is RequestUser) {
      yield UserChangeStateLoading();
      try {
        yield* _setupUserAsync();
      } catch (error) {
        yield UserChangeStateFailure(error: error.toString());
      }
    } else if (event is UserPersonalDataChanged) {
      try {
        yield* _saveUserPersonalDataAsync(event);
      } catch (error) {
        yield UserChangeStateFailure(error: error.toString());
      }
    } else if (event is UserSignatureChanged) {
      try {
        yield* _saveUserSignatureAsync(event);
      } catch (error) {
        yield UserChangeStateFailure(error: error.toString());
      }
    } else if (event is UserAccountDataChanged) {
      try {
        yield* _saveUserAccountDataAsync(event);
      } catch (error) {
        yield UserChangeStateFailure(error: error.toString());
      }
    } else if (event is UserAvatarChanged) {
      try {
        yield* _saveUserAvatarAsync(event);
      } catch (error) {
        yield UserChangeStateFailure(error: error.toString());
      }
    }
  }

  Stream<UserChangeState> _setupUserAsync() async* {
    final config = Config();
    await config.load();
    yield UserChangeStateSuccess(config: config);
  }

  Stream<UserChangeState> _saveUserPersonalDataAsync(UserPersonalDataChanged event) async* {
    final config = Config();
    await config.setValue(Context.configDisplayName, event.username);
    await config.setValue(Context.configSelfAvatar, event.avatarPath);
    yield UserChangeStateApplied();
  }

  Stream<UserChangeState> _saveUserSignatureAsync(UserSignatureChanged event) async* {
    final config = Config();
    await config.setValue(Context.configSelfStatus, event.signature);
    yield UserChangeStateApplied();
  }

  Stream<UserChangeState> _saveUserAvatarAsync(UserAvatarChanged event) async* {
    final config = Config();
    await config.setValue(Context.configSelfAvatar, event.avatarPath);
    yield UserChangeStateApplied();
  }

  Stream<UserChangeState> _saveUserAccountDataAsync(UserAccountDataChanged event) async* {
    final config = Config();
    await config.setValue(Context.configMailUser, event.imapLogin.isNotEmpty ? event.imapLogin : null);
    await config.setValue(Context.configMailPassword, event.imapPassword);
    await config.setValue(Context.configMailServer, event.imapServer);
    await config.setValue(Context.configMailPort, event.imapPort);
    await config.setValue(Context.configImapSecurity, event.imapSecurity);
    await config.setValue(Context.configSendUser, event.smtpLogin.isNotEmpty ? event.smtpLogin : null);
    await config.setValue(Context.configSendPassword, event.smtpPassword);
    await config.setValue(Context.configSendServer, event.smtpServer);
    await config.setValue(Context.configSendPort, event.smtpPort);
    await config.setValue(Context.configSmtpSecurity, event.smtpSecurity);
    yield UserChangeStateApplied();
  }
}
