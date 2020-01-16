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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/error/error_bloc.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/platform/system_interaction.dart';
import 'package:ox_coi/src/settings/settings_manual_form.dart';
import 'package:ox_coi/src/settings/settings_manual_form_bloc.dart';
import 'package:ox_coi/src/settings/settings_manual_form_event_state.dart';
import 'package:ox_coi/src/ui/custom_theme.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/dialog_builder.dart';
import 'package:ox_coi/src/widgets/fullscreen_progress.dart';
import 'package:rxdart/rxdart.dart';

import 'login_bloc.dart';
import 'login_events_state.dart';

class LoginManualSettings extends StatefulWidget {
  final Function success;
  final bool fromError;
  final String email;
  final String password;

  LoginManualSettings({@required this.success, @required this.fromError, this.email, this.password});

  @override
  _LoginManualSettingsState createState() => _LoginManualSettingsState();
}

class _LoginManualSettingsState extends State<LoginManualSettings> {
  OverlayEntry _progressOverlayEntry;
  FullscreenProgress _progress;
  LoginBloc _loginBloc;

  @override
  void initState() {
    super.initState();
    var navigation = Navigation();
    navigation.current = Navigatable(Type.loginManualSettings);
    _loginBloc = LoginBloc(BlocProvider.of<ErrorBloc>(context));
    final loginObservable = new Observable<LoginState>(_loginBloc);
    loginObservable.listen((state) => handleLoginStateChange(state));
  }

  void handleLoginStateChange(LoginState state) {
    if (state is LoginStateSuccess || state is LoginStateFailure) {
      if (_progressOverlayEntry != null) {
        _progressOverlayEntry.remove();
        _progressOverlayEntry = null;
      }
    }
    if (state is LoginStateSuccess) {
      widget.success();
    } else if (state is LoginStateFailure) {
      setState(() {
        showInformationDialog(
          context: context,
          title: L10n.get(L.loginFailed),
          content: state.error,
          navigatable: Navigatable(Type.loginErrorDialog),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (context) {
        var settingsManualFormBloc = SettingsManualFormBloc();
        settingsManualFormBloc.add(SetupSettings(
          shouldLoadConfig: false,
          email: widget.email,
          password: widget.password,
        ));
        return settingsManualFormBloc;
      },
      child: BlocListener<SettingsManualFormBloc, SettingsManualFormState>(
        listener: (BuildContext context, state) {
          if (state is SettingsManualFormStateValidationSuccess) {
            _progress = FullscreenProgress(
              bloc: _loginBloc,
              text: L10n.get(L.loginRunning),
              showProgressValues: true,
              showCancelButton: false,
            );
            _progressOverlayEntry = OverlayEntry(builder: (context) => _progress);
            OverlayState overlayState = Overlay.of(context);
            overlayState.insert(_progressOverlayEntry);
            _loginBloc.add(LoginButtonPressed(
              email: state.email,
              password: state.password,
              imapLogin: state.imapLogin,
              imapServer: state.imapServer,
              imapPort: state.imapPort,
              imapSecurity: state.imapSecurity,
              smtpLogin: state.smtpLogin,
              smtpPassword: state.smtpPassword,
              smtpServer: state.smtpServer,
              smtpPort: state.smtpPort,
              smtpSecurity: state.smtpSecurity,
            ));
          }
        },
        child: Scaffold(
          body: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  top: loginManualSettingsPadding,
                  right: loginManualSettingsPadding,
                  left: loginManualSettingsPadding,
                ),
                child: LoginButton(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(loginManualSettingsPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          L10n.get(L.settingManual),
                          style: Theme.of(context).textTheme.headline,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: loginVerticalPadding8dp),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Visibility(
                                visible: widget.fromError,
                                child: Text(
                                  L10n.get(L.loginManualSetupRequired),
                                ),
                              ),
                              Padding(padding: EdgeInsets.all(loginManualSettingsSubTitlePadding)),
                              Text(
                                L10n.get(L.loginCheckServer),
                                textAlign: TextAlign.center,
                              ),
                              Padding(padding: EdgeInsets.all(loginManualSettingsSubTitlePadding)),
                              Text(
                                L10n.get(L.loginWelcomeManual),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: loginVerticalPadding),
                          child: SettingsManualForm(isLogin: true),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FlatButton(
        onPressed: () => _performLogin(context),
        child: Text(
          L10n.get(L.loginSignIn).toUpperCase(),
          style: Theme.of(context).textTheme.subhead.apply(color: CustomTheme.of(context).accent),
        ),
      ),
    );
  }

  void _performLogin(BuildContext context) {
    unFocus(context);
    BlocProvider.of<SettingsManualFormBloc>(context).add(RequestValidateSettings());
  }
}
