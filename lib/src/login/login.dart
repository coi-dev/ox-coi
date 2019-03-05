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
import 'package:ox_talk/src/l10n/localizations.dart';
import 'package:ox_talk/src/login/login_bloc.dart';
import 'package:ox_talk/src/login/login_events.dart';
import 'package:ox_talk/src/login/login_state.dart';
import 'package:ox_talk/src/utils/colors.dart';
import 'package:ox_talk/src/utils/dimensions.dart';
import 'package:ox_talk/src/utils/styles.dart';
import 'package:ox_talk/src/widgets/progress_handler.dart';
import 'package:ox_talk/src/widgets/validatable_text_form_field.dart';
import 'package:rxdart/rxdart.dart';

class Login extends StatefulWidget {
  final Function _success;

  Login(this._success);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final LoginBloc _loginBloc = LoginBloc();
  final _simpleLoginKey = GlobalKey<FormState>();
  final _advancedLoginKey = GlobalKey<FormState>();
  ValidatableTextFormField emailField = ValidatableTextFormField(
    (context) => AppLocalizations.of(context).emailAddress,
    hintText: (context) => AppLocalizations.of(context).loginHintEmail,
    textFormType: TextFormType.email,
    inputType: TextInputType.emailAddress,
  );
  ValidatableTextFormField passwordField = ValidatableTextFormField(
    (context) => AppLocalizations.of(context).password,
    hintText: (context) => AppLocalizations.of(context).loginHintPassword,
    textFormType: TextFormType.password,
  );
  ValidatableTextFormField imapLoginNameField = ValidatableTextFormField((context) => AppLocalizations.of(context).loginLabelImapName);
  ValidatableTextFormField imapServerField = ValidatableTextFormField((context) => AppLocalizations.of(context).loginLabelImapServer);
  ValidatableTextFormField imapPortField = ValidatableTextFormField((context) => AppLocalizations.of(context).loginLabelImapPort);
  ValidatableTextFormField smtpLoginNameField = ValidatableTextFormField((context) => AppLocalizations.of(context).loginLabelSmtpName);
  ValidatableTextFormField smtpPasswordField = ValidatableTextFormField(
    (context) => AppLocalizations.of(context).loginLabelSmtpPassword,
    textFormType: TextFormType.password,
    needValidation: false,
  );
  ValidatableTextFormField smtpServerField = ValidatableTextFormField((context) => AppLocalizations.of(context).loginLabelSmtpServer);
  ValidatableTextFormField smtpPortField = ValidatableTextFormField(
    (context) => AppLocalizations.of(context).loginLabelSmtpPort,
    textFormType: TextFormType.port,
    inputType: TextInputType.numberWithOptions(),
  );

  String _selectedImapSecurity;
  String _selectedSmtpSecurity;
  bool _showAdvanced = false;
  OverlayEntry _progressOverlayEntry;
  FullscreenProgress _progress;

  @override
  void initState() {
    super.initState();
    final loginObservable = new Observable<LoginState>(_loginBloc.state);
    loginObservable.listen((event) => handleLoginStateChange(event));
  }

  void handleLoginStateChange(LoginState state) {
    if (state is LoginStateSuccess || state is LoginStateFailure) {
      _progressOverlayEntry.remove();
    }
    if (state is LoginStateSuccess) {
      widget._success();
    }
  }

  void _advancedPressed() {
    setState(() {
      _showAdvanced = !_showAdvanced;
    });
  }

  void _loginPressed() async {
    FocusScope.of(context).requestFocus(FocusNode());

    var email = emailField.controller.text;
    var password = passwordField.controller.text;
    var imapLogin = imapLoginNameField.controller.text;
    var imapServer = imapServerField.controller.text;
    var imapPort = imapPortField.controller.text;
    var smtpLogin = smtpLoginNameField.controller.text;
    var smtpPassword = smtpPasswordField.controller.text;
    var smtpServer = smtpServerField.controller.text;
    var smtpPort = smtpPortField.controller.text;

    bool simpleLoginIsValid = _simpleLoginKey.currentState.validate();
    bool advancedLoginIsValid = _advancedLoginKey.currentState != null ? _advancedLoginKey.currentState.validate() : true;

    if (simpleLoginIsValid && advancedLoginIsValid) {
      _progress = FullscreenProgress(_loginBloc, AppLocalizations.of(context).loginProgressMessage, true);
      _progressOverlayEntry = OverlayEntry(builder: (context) => _progress);
      OverlayState overlayState = Overlay.of(context);
      overlayState.insert(_progressOverlayEntry);

      _loginBloc.dispatch(LoginButtonPressed(
        email: email,
        password: password,
        imapLogin: imapLogin,
        imapServer: imapServer,
        imapPort: imapPort.isNotEmpty ? int.parse(imapPort) : null,
        smtpLogin: smtpLogin,
        smtpPassword: smtpPassword,
        smtpServer: smtpServer,
        smtpPort: smtpPort.isNotEmpty ? int.parse(smtpPort) : null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).loginTitle),
          actions: <Widget>[IconButton(icon: Icon(Icons.check), onPressed: _loginPressed)],
        ),
        body: createBuilder());
  }

  Widget createBuilder() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(formVerticalPadding),
            color: loginHintBackground,
            child: Text(
              AppLocalizations.of(context).loginInformation,
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(color: textColorInverted),
            ),
          ),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: formHorizontalPadding),
              child: Form(
                key: _simpleLoginKey,
                child: Column(
                  children: <Widget>[emailField, passwordField],
                ),
              )),
          OutlineButton(
            onPressed: _advancedPressed,
            borderSide: BorderSide(color: transparent),
            highlightedBorderColor: transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).advanced,
                  style: defaultText,
                ),
                _showAdvanced ? Icon(Icons.arrow_drop_up) : Icon(Icons.arrow_drop_down)
              ],
            ),
          ),
          _showAdvanced ? buildAdvancedForm() : Container(),
        ],
      ),
    );
  }

  Container buildAdvancedForm() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: formHorizontalPadding),
        child: Form(
          key: _advancedLoginKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(AppLocalizations.of(context).inbox),
              imapLoginNameField,
              imapServerField,
              imapPortField,
              Padding(padding: EdgeInsets.only(top: formVerticalPadding)),
              Text(AppLocalizations.of(context).loginLabelImapSecurity),
              DropdownButton(
                  value: _selectedImapSecurity,
                  items: getSecurityOptions(),
                  onChanged: (String newValue) {
                    setState(() {
                      _selectedImapSecurity = newValue;
                    });
                  }),
              Padding(padding: EdgeInsets.only(top: formVerticalPadding)),
              Text(AppLocalizations.of(context).outbox),
              smtpLoginNameField,
              smtpPasswordField,
              smtpServerField,
              smtpPortField,
              Padding(padding: EdgeInsets.only(top: formVerticalPadding)),
              Text(AppLocalizations.of(context).loginLabelSmtpSecurity),
              DropdownButton(
                  value: _selectedSmtpSecurity,
                  items: getSecurityOptions(),
                  onChanged: (String newValue) {
                    setState(() {
                      _selectedSmtpSecurity = newValue;
                    });
                  }),
            ],
          ),
        ));
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
}
