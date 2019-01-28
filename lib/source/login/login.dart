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
import 'package:ox_talk/source/form/validatable_text_form_field.dart';
import 'package:ox_talk/source/login/login_bloc.dart';
import 'package:ox_talk/source/login/login_events.dart';
import 'package:ox_talk/source/login/login_state.dart';
import 'package:ox_talk/source/ui/progress_handler.dart';
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
  final emailField =
      ValidatableTextFormField("Email address", "Enter your email address", textFormType: TextFormType.email, inputType: TextInputType.emailAddress);
  final passwordField = ValidatableTextFormField("Password", "Enter your password", textFormType: TextFormType.password);
  final imapLoginNameField = ValidatableTextFormField("IMAP login-name", "");
  final imapServerField = ValidatableTextFormField("IMAP server", "");
  final imapPortField = ValidatableTextFormField("IMAP port", "", textFormType: TextFormType.port, inputType: TextInputType.numberWithOptions());
  final smtpLoginNameField = ValidatableTextFormField("SMTP login-name", "");
  final smtpPasswordField = ValidatableTextFormField("SMTP password", "", textFormType: TextFormType.password, needValidation: false);
  final smtpServerField = ValidatableTextFormField("SMTP server", "");
  final smtpPortField = ValidatableTextFormField("SMTP port", "", textFormType: TextFormType.port, inputType: TextInputType.numberWithOptions());

  List<String> _securityOptions = List();
  String _selectedImapSecurity;
  String _selectedSmtpSecurity;
  bool _showAdvanced = false;
  OverlayEntry _progressOverlayEntry;
  FullscreenProgress _progress;

  @override
  void initState() {
    super.initState();
    _securityOptions.addAll(["Automatic", "SSL/TLS", "StartTLS", "Off"]);
    _selectedImapSecurity = _securityOptions.elementAt(0);
    _selectedSmtpSecurity = _securityOptions.elementAt(0);
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
      _progress = FullscreenProgress(_loginBloc, "Logging in, this may take a moment.", true);
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
          title: Text("Login to COI"),
          actions: <Widget>[IconButton(icon: Icon(Icons.check), onPressed: _loginPressed)],
        ),
        body: createBuilder());
  }

  Widget createBuilder() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.all(12.0),
              color: Colors.blueGrey,
              child: Text(
                  "For known email providers additional settings are setup automatically. Sometimes IMAP needs to be enabled in the web frontend. Consult your email provider or friends for help.",
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white))),
          Container(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
              ),
              child: Form(
                key: _simpleLoginKey,
                child: Column(
                  children: <Widget>[emailField, passwordField],
                ),
              )),
          OutlineButton(
            onPressed: _advancedPressed,
            borderSide: BorderSide(color: Colors.transparent),
            highlightedBorderColor: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Advanced",
                  style: TextStyle(fontSize: 16.0),
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
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Form(
          key: _advancedLoginKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text("Inbox"),
              imapLoginNameField,
              imapServerField,
              imapPortField,
              Padding(padding: EdgeInsets.only(top: 12.0)),
              Text("IMAP Security"),
              DropdownButton(
                  value: _selectedImapSecurity,
                  items: _securityOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (String newValue) {
                    setState(() {
                      _selectedImapSecurity = newValue;
                    });
                  }),
              Padding(padding: EdgeInsets.only(top: 12.0)),
              Text("Outbox"),
              smtpLoginNameField,
              smtpPasswordField,
              smtpServerField,
              smtpPortField,
              Padding(padding: EdgeInsets.only(top: 12.0)),
              Text("SMTP Security"),
              DropdownButton(
                  value: _selectedSmtpSecurity,
                  items: _securityOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (String newValue) {
                    setState(() {
                      _selectedSmtpSecurity = newValue;
                    });
                  }),
            ],
          ),
        ));
  }
}
