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
import 'package:ox_talk/source/data/config.dart';
import 'package:ox_talk/source/profile/user_event.dart';
import 'package:ox_talk/source/profile/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  @override
  UserState get initialState => UserStateInitial();

  @override
  Stream<UserState> mapEventToState(UserState currentState, UserEvent event) async* {
    if (event is RequestUser) {
      yield UserStateLoading();
      try {
        _setupUser();
      } catch (error) {
        yield UserStateFailure(error: error.toString());
      }
    } else if (event is UserLoaded) {
      yield UserStateSuccess(config: event.config);
    } else if (event is UserChanged) {
      yield UserStateSuccess(config: event.config);
    } else if (event is UserPersonalDataChanged) {
      try {
        _saveUserPersonalData(event);
      } catch (error) {
        yield UserStateFailure(error: error.toString());
      }
    } else if (event is UserAccountDataChanged) {
      try {
        _saveUserAccountData(event);
      } catch (error) {
        yield UserStateFailure(error: error.toString());
      }
    }
  }

  void _setupUser() async {
    Config config = Config();
    await config.load();
    dispatch(UserLoaded(config: config));
  }

  void _saveUserPersonalData(UserPersonalDataChanged event) async {
    Config config = Config();
    config.setValue(Context.configDisplayName, event.username, true, ObjectType.String);
    config.setValue(Context.configSelfStatus, event.status, true, ObjectType.String);
    var avatarPath = event.avatarPath;
    config.setValue(Context.configSelfAvatar, avatarPath, true, ObjectType.String);
    dispatch(UserChanged(config: config));
  }

  void _saveUserAccountData(UserAccountDataChanged event) {
    Config config = Config();
    config.setValue(Context.configMailUser, event.imapLogin, true, ObjectType.String);
    config.setValue(Context.configMailPassword, event.imapPassword, true, ObjectType.String);
    config.setValue(Context.configMailServer, event.imapServer, true, ObjectType.String);
    config.setValue(Context.configMailPort, event.imapPort, true, ObjectType.int);
    config.setValue(Context.configSendUser, event.smtpLogin, true, ObjectType.String);
    config.setValue(Context.configSendPassword, event.smtpPassword, true, ObjectType.String);
    config.setValue(Context.configSendServer, event.smtpServer, true, ObjectType.String);
    config.setValue(Context.configSendPort, event.smtpPort, true, ObjectType.int);
    dispatch(UserChanged(config: config));
  }
}
