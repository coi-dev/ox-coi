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
import 'package:ox_talk/source/form/validatable_text_form_field.dart';
import 'package:ox_talk/source/l10n/localizations.dart';
import 'package:ox_talk/source/profile/user.dart';
import 'package:ox_talk/source/profile/user_bloc.dart';
import 'package:ox_talk/source/profile/user_event.dart';
import 'package:ox_talk/source/profile/user_state.dart';
import 'package:ox_talk/source/ui/default_colors.dart';

class EditAccountSettings extends StatefulWidget {
  final String imapLogin;
  final String imapServer;
  final String imapPort;
  final String smtpLogin;
  final String smtpPassword;
  final String smtpServer;
  final String smtpPort;

  EditAccountSettings({@required this.imapLogin, @required this.imapServer, @required this.imapPort, @required this.smtpLogin, @required this.smtpPassword, @required this.smtpServer, @required this.smtpPort});

  @override
  _EditAccountSettingsState createState() => _EditAccountSettingsState();
}

class _EditAccountSettingsState extends State<EditAccountSettings> {
  UserBloc _userBloc = UserBloc();

  final _advancedLoginKey = GlobalKey<FormState>();
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

  @override
  void initState(){
    super.initState();
    _securityOptions.addAll(["Automatic", "SSL/TLS", "StartTLS", "Off"]);
    _selectedImapSecurity = _securityOptions.elementAt(0);
    _selectedSmtpSecurity = _securityOptions.elementAt(0);

    imapLoginNameField.controller.text = widget.imapLogin != null ? widget.imapLogin : "";
    imapServerField.controller.text = widget.imapServer != null ? widget.imapServer : "";
    imapPortField.controller.text = widget.imapPort != null  ? widget.imapPort : "";
    smtpLoginNameField.controller.text = widget.smtpLogin != null ? widget.smtpLogin : "";
    smtpPasswordField.controller.text = widget.smtpPassword != null ? widget.smtpPassword : "";
    smtpServerField.controller.text = widget.smtpServer != null ? widget.smtpServer : "";
    smtpPortField.controller.text = widget.smtpPort != null ? widget.smtpPort : "";

    _userBloc.dispatch(RequestUser());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: DefaultColors.contactColor,
          title: Text(AppLocalizations.of(context).editAccountSettingsTitle),
          actions: <Widget>[IconButton(icon: Icon(Icons.check), onPressed: saveAccountData)],
        ),
        body: buildForm());
  }

  Widget buildForm(){
    return BlocBuilder(
        bloc: _userBloc,
        builder: (context, state){
          if(state is UserStateSuccess){
            return buildEditAccountDataView();
          }else if (state is UserStateFailure) {
            return new Text(state.error);
          } else {
            return new Container();
          }
        }
    );
  }

  Widget buildEditAccountDataView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
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
      )
    );
  }

  saveAccountData() {
    if(_advancedLoginKey.currentState.validate()){
      var imapLogin = imapLoginNameField.controller.text;
      var imapServer = imapServerField.controller.text;
      var imapPort = imapPortField.controller.text;
      var smtpLogin = smtpLoginNameField.controller.text;
      var smtpPassword = smtpPasswordField.controller.text;
      var smtpServer = smtpServerField.controller.text;
      var smtpPort = smtpPortField.controller.text;
      _userBloc.dispatch(
        UserAccountDataChanged(
          imapLogin: imapLogin,
          imapServer: imapServer,
          imapPort: imapPort.isNotEmpty ? int.parse(imapPort) : null,
          smtpLogin: smtpLogin,
          smtpPassword: smtpPassword,
          smtpServer: smtpServer,
          smtpPort: smtpPort.isNotEmpty ? int.parse(smtpPort) : null,
        )
      );
      Navigator.pop(context);
    }
  }
}
