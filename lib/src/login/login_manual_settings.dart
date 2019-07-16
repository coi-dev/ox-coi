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
import 'package:ox_coi/src/l10n/localizations.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/utils/core.dart';
import 'package:ox_coi/src/utils/dialog_builder.dart';
import 'package:ox_coi/src/utils/dimensions.dart';
import 'package:ox_coi/src/utils/styles.dart';
import 'package:ox_coi/src/widgets/progress_handler.dart';
import 'package:ox_coi/src/widgets/validatable_text_form_field.dart';
import 'package:rxdart/rxdart.dart';

import 'login_bloc.dart';
import 'login_events_state.dart';

class ManualSettings extends StatefulWidget {
  final Function _success;
  final bool _fromError;
  final String _email;
  final String _password;

  ManualSettings(this._success, this._email, this._password, this._fromError);

  @override
  _ManualSettingsState createState() => _ManualSettingsState();
}

class _ManualSettingsState extends State<ManualSettings> {
  final _simpleLoginKey = GlobalKey<FormState>();
  OverlayEntry _progressOverlayEntry;
  FullscreenProgress _progress;
  LoginBloc _loginBloc = LoginBloc();

  String _selectedImapSecurity;
  String _selectedSmtpSecurity;

  ValidatableTextFormField emailField = ValidatableTextFormField(
    (context) => AppLocalizations.of(context).emailAddress,
    textFormType: TextFormType.email,
    inputType: TextInputType.emailAddress,
    needValidation: true,
    validationHint: (context) => AppLocalizations.of(context).validatableTextFormFieldHintInvalidEmail,
  );
  ValidatableTextFormField passwordField = ValidatableTextFormField(
    (context) => AppLocalizations.of(context).password,
    textFormType: TextFormType.password,
    needValidation: true,
    validationHint: (context) => AppLocalizations.of(context).validatableTextFormFieldHintInvalidPassword,
  );
  ValidatableTextFormField imapLoginNameField = ValidatableTextFormField((context) => AppLocalizations.of(context).loginLabelImapName);
  ValidatableTextFormField imapServerField = ValidatableTextFormField(
    (context) => AppLocalizations.of(context).loginLabelImapServer,
    inputType: TextInputType.url,
  );
  ValidatableTextFormField imapPortField = ValidatableTextFormField(
    (context) => AppLocalizations.of(context).loginLabelImapPort,
    textFormType: TextFormType.port,
    inputType: TextInputType.number,
    needValidation: true,
    validationHint: (context) => AppLocalizations.of(context).validatableTextFormFieldHintInvalidPort,
  );
  ValidatableTextFormField smtpLoginNameField = ValidatableTextFormField((context) => AppLocalizations.of(context).loginLabelSmtpName);
  ValidatableTextFormField smtpPasswordField = ValidatableTextFormField(
    (context) => AppLocalizations.of(context).loginLabelSmtpPassword,
    textFormType: TextFormType.password,
    needValidation: true,
    validationHint: (context) => AppLocalizations.of(context).validatableTextFormFieldHintInvalidPassword,
  );
  ValidatableTextFormField smtpServerField = ValidatableTextFormField(
    (context) => AppLocalizations.of(context).loginLabelSmtpServer,
    inputType: TextInputType.url,
  );
  ValidatableTextFormField smtpPortField = ValidatableTextFormField(
    (context) => AppLocalizations.of(context).loginLabelSmtpPort,
    textFormType: TextFormType.port,
    inputType: TextInputType.number,
    needValidation: true,
    validationHint: (context) => AppLocalizations.of(context).validatableTextFormFieldHintInvalidPort,
  );

  @override
  void initState() {
    super.initState();
    emailField.controller.text = widget._email;
    passwordField.controller.text = widget._password;
    var navigation = Navigation();
    navigation.current = Navigatable(Type.loginManualSettings);
    final loginObservable = new Observable<LoginState>(_loginBloc.state);
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
      widget._success();
    } else if (state is LoginStateFailure) {
      setState(() {
        showInformationDialog(
          context: context,
          title: AppLocalizations.of(context).loginErrorDialogTitle,
          content: state.error,
          navigatable: Navigatable(Type.loginErrorDialog),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: loginManualSettingsPadding,
              right: loginManualSettingsPadding,
              left: loginManualSettingsPadding,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: FlatButton(
                onPressed: _signIn,
                child: Text(
                  AppLocalizations.of(context).loginSignInButtonText,
                  style: loginManualSettingsSignInButtonText,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: loginManualSettingsPadding,
                  right: loginManualSettingsPadding,
                  bottom: loginManualSettingsPadding,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context).loginManualSettings,
                      style: loginTitleText,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: loginVerticalPadding8dp),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Visibility(
                            visible: widget._fromError,
                            child: Text(
                              AppLocalizations.of(context).loginManualSettingsErrorInfoText,
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(loginManualSettingsSubTitlePadding)),
                          Text(
                            AppLocalizations.of(context).loginManualSettingsInfoText,
                            textAlign: TextAlign.center,
                          ),
                          Padding(padding: EdgeInsets.all(loginManualSettingsSubTitlePadding)),
                          Text(
                            AppLocalizations.of(context).loginManualSettingsSecondInfoText,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: loginVerticalPadding20dp)),
                    Container(
                        child: Form(
                      key: _simpleLoginKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLocalizations.of(context).loginBaseSettingsTitle,
                              style: loginManualSettingHeaderText,
                            ),
                          ),
                          emailField,
                          passwordField,
                          Padding(padding: EdgeInsets.all(loginVerticalPadding12dp)),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLocalizations.of(context).loginServerAddressesTitle,
                              style: loginManualSettingHeaderText,
                            ),
                          ),
                          imapServerField,
                          smtpServerField,
                          Padding(padding: EdgeInsets.all(loginVerticalPadding12dp)),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLocalizations.of(context).loginAdvancedImapTitle,
                              style: loginManualSettingHeaderText,
                            ),
                          ),
                          imapPortField,
                          Padding(padding: EdgeInsets.all(loginVerticalPadding12dp)),
                          Text(AppLocalizations.of(context).loginLabelImapSecurity),
                          DropdownButton(
                              value: _selectedImapSecurity == null ? AppLocalizations.of(context).automatic : _selectedImapSecurity,
                              items: getSecurityOptions(),
                              onChanged: (String newValue) {
                                setState(() {
                                  _selectedImapSecurity = newValue;
                                });
                              }),
                          Padding(padding: EdgeInsets.all(loginVerticalPadding12dp)),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLocalizations.of(context).loginAdvancedSmtpTitle,
                              style: loginManualSettingHeaderText,
                            ),
                          ),
                          smtpPortField,
                          Padding(padding: EdgeInsets.all(loginVerticalPadding12dp)),
                          Text(AppLocalizations.of(context).loginLabelSmtpSecurity),
                          DropdownButton(
                              value: _selectedSmtpSecurity == null ? AppLocalizations.of(context).automatic : _selectedSmtpSecurity,
                              items: getSecurityOptions(),
                              onChanged: (String newValue) {
                                setState(() {
                                  _selectedSmtpSecurity = newValue;
                                });
                              }),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> getSecurityOptions() {
    return [
      AppLocalizations.of(context).automatic,
      AppLocalizations.of(context).sslTls,
      AppLocalizations.of(context).startTLS,
      AppLocalizations.of(context).off,
    ].map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(value: value, child: Text(value));
    }).toList();
  }

  void _signIn() {
    FocusScope.of(context).requestFocus(FocusNode());

    var email = emailField.controller.text;
    var password = passwordField.controller.text;
    var imapLogin = imapLoginNameField.controller.text;
    var imapServer = imapServerField.controller.text;
    var imapPort = imapPortField.controller.text;
    var imapSecurity = convertProtocolStringToInt(context, _selectedImapSecurity);
    var smtpLogin = smtpLoginNameField.controller.text;
    var smtpPassword = smtpPasswordField.controller.text;
    var smtpServer = smtpServerField.controller.text;
    var smtpPort = smtpPortField.controller.text;
    var smtpSecurity = convertProtocolStringToInt(context, _selectedSmtpSecurity);

    bool simpleLoginIsValid = _simpleLoginKey.currentState.validate();

    if (simpleLoginIsValid) {
      _progress = FullscreenProgress(_loginBloc, AppLocalizations.of(context).loginProgressMessage, true, false);
      _progressOverlayEntry = OverlayEntry(builder: (context) => _progress);
      OverlayState overlayState = Overlay.of(context);
      overlayState.insert(_progressOverlayEntry);
      _loginBloc.dispatch(LoginButtonPressed(
        email: email,
        password: password,
        imapLogin: imapLogin,
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
