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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/data/config.dart';
import 'package:ox_coi/src/l10n/localizations.dart';
import 'package:ox_coi/src/login/login_bloc.dart';
import 'package:ox_coi/src/login/login_events_state.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/platform/system.dart';
import 'package:ox_coi/src/settings/settings_manual_mixin.dart';
import 'package:ox_coi/src/user/user_change_bloc.dart';
import 'package:ox_coi/src/user/user_change_event_state.dart';
import 'package:ox_coi/src/utils/core.dart';
import 'package:ox_coi/src/utils/dialog_builder.dart';
import 'package:ox_coi/src/utils/toast.dart';
import 'package:ox_coi/src/widgets/progress_handler.dart';
import 'package:rxdart/rxdart.dart';

class UserAccountSettings extends StatefulWidget {
  @override
  _UserAccountSettingsState createState() => _UserAccountSettingsState();
}

class _UserAccountSettingsState extends State<UserAccountSettings> with ManualSettings {
  UserChangeBloc _userChangeBloc = UserChangeBloc();
  LoginBloc _loginBloc = LoginBloc();
  Navigation navigation = Navigation();
  OverlayEntry _progressOverlayEntry;
  FullscreenProgress _progress;
  bool _showedErrorDialog = false;

  bool _firstBuild = true;

  @override
  void initState() {
    super.initState();
    navigation.current = Navigatable(Type.settingsAccount);
    _userChangeBloc.dispatch(RequestUser());
    final userStatesObservable = new Observable<UserChangeState>(_userChangeBloc.state);
    userStatesObservable.listen((state) => _handleUserChangeStateChange(state));

    final loginObservable = new Observable<LoginState>(_loginBloc.state);
    loginObservable.listen((event) => handleLoginStateChange(event));
  }

  _handleUserChangeStateChange(UserChangeState state) {
    if (state is UserChangeStateApplied) {
      _progress = FullscreenProgress(
        bloc: _loginBloc,
        text: AppLocalizations.of(context).accountSettingsDataProgressMessage,
        showProgressValues: true,
        showCancelButton: false,
      );
      _progressOverlayEntry = OverlayEntry(builder: (context) => _progress);
      OverlayState overlayState = Overlay.of(context);
      overlayState.insert(_progressOverlayEntry);
      _showedErrorDialog = false;
      _loginBloc.dispatch(EditButtonPressed());
    }
  }

  void handleLoginStateChange(LoginState state) {
    if (state is LoginStateSuccess || state is LoginStateFailure) {
      if (_progressOverlayEntry != null) {
        _progressOverlayEntry.remove();
        _progressOverlayEntry = null;
      }
    }
    if (state is LoginStateSuccess) {
      showToast(AppLocalizations.of(context).accountSettingsSuccess);
      navigation.pop(context);
    } else if (state is LoginStateFailure) {
      if (!_showedErrorDialog) {
        _showedErrorDialog = true;
        showInformationDialog(
          context: context,
          title: AppLocalizations.of(context).accountSettingsErrorDialogTitle,
          content: state.error,
          navigatable: Navigatable(Type.loginErrorDialog),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.close),
            onPressed: () => navigation.pop(context),
          ),
          title: Text(AppLocalizations.of(context).accountSettingsTitle),
          actions: <Widget>[IconButton(icon: Icon(Icons.check), onPressed: saveAccountData)],
        ),
        body: buildForm());
  }

  Widget buildForm() {
    return BlocBuilder(
        bloc: _userChangeBloc,
        builder: (context, state) {
          if (state is UserChangeStateSuccess) {
            if (_firstBuild) {
              _firstBuild = false;
              _fillEditAccountDataView(state.config);
            }
            return _buildEditAccountDataView();
          } else if (state is UserChangeStateFailure) {
            showToast(state.error);
            return _buildEditAccountDataView();
          } else if (state is UserChangeStateApplied) {
            return _buildEditAccountDataView();
          } else {
            return Container();
          }
        });
  }

  _fillEditAccountDataView(Config config) {
    disabledEmailField.controller.text = config.email;
    imapLoginNameField.controller.text = config.imapLogin;
    imapServerField.controller.text = config.imapServer;
    imapPortField.controller.text = config.imapPort;
    smtpLoginNameField.controller.text = config.smtpLogin;
    smtpServerField.controller.text = config.imapServer;
    smtpPortField.controller.text = config.smtpPort;
    selectedImapSecurity = convertProtocolIntToString(context, config.imapSecurity);
    selectedSmtpSecurity = convertProtocolIntToString(context, config.smtpSecurity);
  }

  Widget _buildEditAccountDataView() {
    return getFormFields(context: context, isLogin: false);
  }

  saveAccountData() {
    hideKeyboard();
    if (formKey.currentState.validate()) {
      var imapLogin = disabledEmailField.controller.text;
      var imapPassword = passwordField.controller.text;
      var imapServer = imapServerField.controller.text;
      var imapPort = imapPortField.controller.text;
      var imapSecurity = convertProtocolStringToInt(context, selectedImapSecurity);
      var smtpLogin = smtpLoginNameField.controller.text;
      var smtpPassword = smtpPasswordField.controller.text;
      var smtpServer = smtpServerField.controller.text;
      var smtpPort = smtpPortField.controller.text;
      var smtpSecurity = convertProtocolStringToInt(context, selectedSmtpSecurity);

      _userChangeBloc.dispatch(UserAccountDataChanged(
        imapLogin: imapLogin,
        imapPassword: imapPassword,
        imapServer: imapServer,
        imapPort: imapPort,
        imapSecurity: imapSecurity,
        smtpLogin: smtpLogin,
        smtpPassword: smtpPassword,
        smtpServer: smtpServer,
        smtpPort: smtpPort,
        smtpSecurity: smtpSecurity,
      ));
    }
  }
}
