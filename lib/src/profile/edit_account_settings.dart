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
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_talk/src/data/config.dart';
import 'package:ox_talk/src/l10n/localizations.dart';
import 'package:ox_talk/src/login/login_bloc.dart';
import 'package:ox_talk/src/login/login_events.dart';
import 'package:ox_talk/src/login/login_state.dart';
import 'package:ox_talk/src/navigation/navigation.dart';
import 'package:ox_talk/src/platform/system.dart';
import 'package:ox_talk/src/profile/user_bloc.dart';
import 'package:ox_talk/src/profile/user_event.dart';
import 'package:ox_talk/src/profile/user_state.dart';
import 'package:ox_talk/src/utils/colors.dart';
import 'package:ox_talk/src/utils/dialog_builder.dart';
import 'package:ox_talk/src/utils/dimensions.dart';
import 'package:ox_talk/src/utils/protocol_security_converter.dart';
import 'package:ox_talk/src/utils/styles.dart';
import 'package:ox_talk/src/utils/toast.dart';
import 'package:ox_talk/src/widgets/progress_handler.dart';
import 'package:ox_talk/src/widgets/validatable_text_form_field.dart';
import 'package:rxdart/rxdart.dart';

class EditAccountSettings extends StatefulWidget {
  @override
  _EditAccountSettingsState createState() => _EditAccountSettingsState();
}

class _EditAccountSettingsState extends State<EditAccountSettings> {
  UserBloc _userBloc = UserBloc();
  LoginBloc _loginBloc = LoginBloc();
  Navigation navigation = Navigation();
  OverlayEntry _progressOverlayEntry;
  FullscreenProgress _progress;
  bool _showedErrorDialog = false;

  final _formKey = GlobalKey<FormState>();
  ValidatableTextFormField imapLoginNameField = ValidatableTextFormField((context) => AppLocalizations.of(context).loginLabelImapName);
  ValidatableTextFormField imapPasswordField = ValidatableTextFormField(
    (context) => AppLocalizations.of(context).password,
    textFormType: TextFormType.password,
  );
  ValidatableTextFormField imapServerField = ValidatableTextFormField((context) => AppLocalizations.of(context).loginLabelImapServer);
  ValidatableTextFormField imapPortField = ValidatableTextFormField(
    (context) => AppLocalizations.of(context).loginLabelImapPort,
    textFormType: TextFormType.port,
    inputType: TextInputType.numberWithOptions(),
  );
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
  String _email = "";

  @override
  void initState() {
    super.initState();
    _userBloc.dispatch(RequestUser());
    final userStatesObservable = new Observable<UserState>(_userBloc.state);
    userStatesObservable.listen((state) => _handleUserStateChange(state));

    final loginObservable = new Observable<LoginState>(_loginBloc.state);
    loginObservable.listen((event) => handleLoginStateChange(event));
  }

  _handleUserStateChange(UserState state) {
    if (state is UserStateSuccess) {
      _fillEditAccountDataView(state.config);
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
      showToast(AppLocalizations.of(context).editAccountSettingsSuccess);
      navigation.pop(context, "EditAccountSettings");
    } else if (state is LoginStateFailure) {
      if (!_showedErrorDialog) {
        _showedErrorDialog = true;
        showInformationDialog(
          context: context,
          title: AppLocalizations.of(context).editAccountSettingsErrorDialogTitle,
          content: state.error,
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
            onPressed: () => navigation.pop(context, "EditAccountSettings"),
          ),
          backgroundColor: contactMain,
          title: Text(AppLocalizations.of(context).editAccountSettingsTitle),
          actions: <Widget>[IconButton(icon: Icon(Icons.check), onPressed: saveAccountData)],
        ),
        body: buildForm());
  }

  Widget buildForm() {
    return BlocBuilder(
        bloc: _userBloc,
        builder: (context, state) {
          if (state is UserStateFailure) {
            showToast(state.error);
          }
          return _buildEditAccountDataView();
        });
  }

  _fillEditAccountDataView(Config config) {
    _email = config.email;
    imapLoginNameField.controller.text = config.imapLogin;
    imapServerField.controller.text = config.imapServer;
    imapPortField.controller.text = config.imapPortAsString;
    smtpLoginNameField.controller.text = config.smtpLogin;
    smtpServerField.controller.text = config.imapServer;
    smtpPortField.controller.text = config.smtpPortAsString;
    _selectedImapSecurity = convertProtocolIntToString(context, config.imapSecurity);
    _selectedSmtpSecurity = convertProtocolIntToString(context, config.smtpSecurity);
  }

  Widget _buildEditAccountDataView() {
    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: formHorizontalPadding,
          vertical: formVerticalPadding,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: formVerticalPadding, bottom: formVerticalPadding),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.mail),
                    Padding(
                      padding: EdgeInsets.only(right: iconFormPadding),
                    ),
                    Text(
                      _email,
                      style: defaultText,
                    ),
                  ],
                ),
              ),
              imapPasswordField,
              Padding(padding: EdgeInsets.only(top: formVerticalPadding)),
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

  saveAccountData() {
    hideKeyboard();
    if (_formKey.currentState.validate()) {
      var imapLogin = imapLoginNameField.controller.text;
      var imapPassword = imapPasswordField.controller.text;
      var imapServer = imapServerField.controller.text;
      var imapPort = imapPortField.controller.text;
      var imapSecurity = convertProtocolStringToInt(context, _selectedImapSecurity);
      var smtpLogin = smtpLoginNameField.controller.text;
      var smtpPassword = smtpPasswordField.controller.text;
      var smtpServer = smtpServerField.controller.text;
      var smtpPort = smtpPortField.controller.text;
      var smtpSecurity = convertProtocolStringToInt(context, _selectedSmtpSecurity);

      _userBloc.dispatch(UserAccountDataChanged(
        imapLogin: imapLogin,
        imapPassword: imapPassword,
        imapServer: imapServer,
        imapPort: imapPort.isNotEmpty ? int.parse(imapPort) : null,
        imapSecurity: imapSecurity,
        smtpLogin: smtpLogin,
        smtpPassword: smtpPassword,
        smtpServer: smtpServer,
        smtpPort: smtpPort.isNotEmpty ? int.parse(smtpPort) : null,
        smtpSecurity: smtpSecurity,
      ));

      _progress = FullscreenProgress(_loginBloc, AppLocalizations.of(context).editAccountDataProgressMessage, true);
      _progressOverlayEntry = OverlayEntry(builder: (context) => _progress);
      OverlayState overlayState = Overlay.of(context);
      overlayState.insert(_progressOverlayEntry);
      _showedErrorDialog = false;
      _loginBloc.dispatch(EditButtonPressed());
    }
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
