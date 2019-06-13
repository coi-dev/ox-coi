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

import 'package:meta/meta.dart';
import 'package:ox_coi/src/base/bloc_progress_state.dart';
import 'package:ox_coi/src/login/providers.dart';

abstract class LoginEvent {}

class RequestProviders extends LoginEvent{}

class ProviderLoginButtonPressed extends LoginEvent {
  final String email;
  final String password;
  final Provider provider;
  final String imapLogin;
  final String smtpLogin;
  final String smtpPassword;

  ProviderLoginButtonPressed({
      @required this.email,
      @required this.password,
      @required this.provider,
      @required this.imapLogin,
      @required this.smtpLogin,
      @required this.smtpPassword,
    });
}

class LoginButtonPressed extends LoginEvent {
  final String email;
  final String password;
  final String imapLogin;
  final String imapServer;
  final String imapPort;
  final int imapSecurity;
  final String smtpLogin;
  final String smtpPassword;
  final String smtpServer;
  final String smtpPort;
  final int smtpSecurity;

  LoginButtonPressed(
      {@required this.email,
      @required this.password,
      @required this.imapLogin,
      @required this.imapServer,
      @required this.imapPort,
      @required this.imapSecurity,
      @required this.smtpLogin,
      @required this.smtpPassword,
      @required this.smtpServer,
      @required this.smtpPort,
      @required this.smtpSecurity});
}

class EditButtonPressed extends LoginEvent {}

class LoginProgress extends LoginEvent {
  final int progress;
  final error;

  LoginProgress(this.progress, [this.error]);
}

class ProvidersLoaded extends LoginEvent {
  List<Provider> providers;

  ProvidersLoaded({@required this.providers});
}

abstract class LoginState extends ProgressState {
  LoginState({progress}) : super(progress: progress);
}

class LoginStateInitial extends LoginState {}

class LoginStateLoading extends LoginState {
  LoginStateLoading({@required progress}) : super(progress: progress);
}

class LoginStateSuccess extends LoginState {}

class LoginStateProvidersLoaded extends LoginState{
  List<Provider> providers;

  LoginStateProvidersLoaded({@required this.providers});
}

class LoginStateFailure extends LoginState {
  final String error;

  LoginStateFailure({@required this.error});
}