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
import 'package:ox_talk/source/profile/user_event.dart';
import 'package:ox_talk/source/profile/user_state.dart';
import 'package:ox_talk/source/data/repository.dart';
import 'package:ox_talk/source/data/repository_manager.dart';
import 'package:ox_talk/source/profile/user.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  Context _context = Context();

  final Repository<User> userRepository = RepositoryManager.get(RepositoryType.user);
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
    }
    else if (event is UserLoaded) {
      yield UserStateSuccess(user: userRepository.get(1));
    }
    else if(event is UserChanged){
      yield UserStateSuccess(user: userRepository.get(1));
    }
    else if (event is UserPersonalDataChanged) {
      try {
        _saveUserPersonalData(event);
      } catch (error) {
        yield UserStateFailure(error: error.toString());
      }
    }
    else if (event is UserAccountDataChanged) {
      try {
        _saveUserAccountData(event);
      } catch (error) {
        yield UserStateFailure(error: error.toString());
      }
    }
  }

  void _setupUser() async {
    User user = new User();
    user.username = await _context.getConfigValue(Context.configDisplayName);
    user.avatarPath = await _context.getConfigValue(Context.configSelfAvatar);
    user.status = await _context.getConfigValue(Context.configSelfStatus);
    user.email = await _context.getConfigValue(Context.configAddress);
    user.imapLogin = await _context.getConfigValue(Context.configMailUser);
    user.imapServer = await _context.getConfigValue(Context.configMailServer);
    user.imapPort = await _context.getConfigValue(Context.configMailPort);
    user.smtpLogin = await _context.getConfigValue(Context.configSendUser);
    user.smtpPassword = await _context.getConfigValue(Context.configSendPassword);
    user.smtpServer = await _context.getConfigValue(Context.configSendServer);
    user.smtpPort = await _context.getConfigValue(Context.configSendPort);
    userRepository.putIfAbsent(id: user.id);
    dispatch(UserLoaded());
  }

  void _saveUserPersonalData(UserPersonalDataChanged event) {
    User user = userRepository.get(1);
    _context.setConfigValue(Context.configDisplayName, event.username);
    _context.setConfigValue(Context.configSelfStatus, event.status);
    _context.setConfigValue(Context.configSelfAvatar, event.avatarPath);
    user.username = event.username;
    user.status = event.status;
    user.avatarPath = event.avatarPath;
    dispatch(UserChanged());
  }

  void _saveUserAccountData(UserAccountDataChanged event) {
    User user = userRepository.get(1);
    setConfigValueIfPresent(Context.configMailUser, event.imapLogin);
    setConfigValueIfPresent(Context.configMailServer, event.imapServer);
    setConfigValueIfPresent(Context.configMailPort, event.imapPort.toString());
    setConfigValueIfPresent(Context.configSendUser, event.smtpLogin);
    setConfigValueIfPresent(Context.configSendPassword, event.smtpPassword);
    setConfigValueIfPresent(Context.configSendServer, event.smtpServer);
    setConfigValueIfPresent(Context.configSendPort, event.smtpPort.toString());

    user.imapLogin = event.imapLogin;
    user.imapServer = event.imapServer;
    user.imapPort = event.imapPort != null ? event.imapPort.toString() : "";
    user.smtpLogin = event.smtpLogin;
    user.smtpPassword = event.smtpPassword;
    user.smtpServer = event.smtpServer;
    user.smtpPort = event.smtpPort != null ? event.smtpPort.toString() : "";

    dispatch(UserChanged());
  }

  void setConfigValueIfPresent(String key, var value) async {
    if (value == null || (value is String && value.isEmpty)) {
      return;
    }
    await _context.setConfigValue(key, value);
  }
}
