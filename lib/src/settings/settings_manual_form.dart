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
import 'package:ox_coi/src/l10n/localizations.dart';
import 'package:ox_coi/src/settings/settings_manual_form_bloc.dart';
import 'package:ox_coi/src/settings/settings_manual_form_event_state.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/ui/text_styles.dart';
import 'package:ox_coi/src/utils/core.dart';
import 'package:ox_coi/src/widgets/validatable_text_form_field.dart';

class SettingsManualForm extends StatefulWidget {
  final bool isLogin;

  const SettingsManualForm({Key key, @required this.isLogin}) : super(key: key);

  @override
  _SettingsManualFormState createState() => _SettingsManualFormState();
}

class _SettingsManualFormState extends State<SettingsManualForm> {
  ValidatableTextFormField emailField;
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
    emailField = ValidatableTextFormField(
      (context) => AppLocalizations.of(context).emailAddress,
      textFormType: TextFormType.email,
      inputType: TextInputType.emailAddress,
      needValidation: true,
      enabled: widget.isLogin,
      validationHint: (context) => AppLocalizations.of(context).validatableTextFormFieldHintInvalidEmail,
    );
  }

  final formKey = GlobalKey<FormState>();
  String selectedImapSecurity;
  String selectedSmtpSecurity;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsManualFormBloc, SettingsManualFormState>(
      listener: (context, state) {
        if (state is SettingsManualFormStateReady) {
          emailField.controller.text = state.email;
          passwordField.controller.text = state.password;
          imapLoginNameField.controller.text = state.imapLogin;
          imapServerField.controller.text = state.imapServer;
          imapPortField.controller.text = state.imapPort;
          smtpLoginNameField.controller.text = state.smtpLogin;
          smtpServerField.controller.text = state.imapServer;
          smtpPortField.controller.text = state.smtpPort;
          selectedImapSecurity = convertProtocolIntToString(context, state.imapSecurity);
          selectedSmtpSecurity = convertProtocolIntToString(context, state.smtpSecurity);
        } else if (state is SettingsManualFormStateValidation) {
          var success = formKey.currentState.validate();
          if (success) {
            BlocProvider.of<SettingsManualFormBloc>(context).dispatch(ValidationDone(
              success: success,
              email: emailField.controller.text,
              password: passwordField.controller.text,
              imapServer: imapServerField.controller.text,
              imapPort: imapPortField.controller.text,
              imapSecurity: convertProtocolStringToInt(context, selectedImapSecurity),
              smtpServer: smtpServerField.controller.text,
              smtpPort: smtpPortField.controller.text,
              smtpSecurity: convertProtocolStringToInt(context, selectedSmtpSecurity),
            ));
          }
        }
      },
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context).loginBaseSettingsTitle,
                style: Theme.of(context).textTheme.subhead.merge(primaryW500),
              ),
            ),
            emailField,
            passwordField,
            Padding(padding: EdgeInsets.all(loginVerticalPadding12dp)),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context).loginServerAddressesTitle,
                style: Theme.of(context).textTheme.subhead.merge(primaryW500),
              ),
            ),
            imapServerField,
            smtpServerField,
            Padding(padding: EdgeInsets.all(loginVerticalPadding12dp)),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context).loginAdvancedImapTitle,
                style: Theme.of(context).textTheme.subhead.merge(primaryW500),
              ),
            ),
            imapPortField,
            Padding(padding: EdgeInsets.all(loginVerticalPadding12dp)),
            Text(AppLocalizations.of(context).loginLabelImapSecurity),
            DropdownButton(
                value: selectedImapSecurity == null ? AppLocalizations.of(context).automatic : selectedImapSecurity,
                items: getSecurityOptions(context),
                onChanged: (String newValue) {
                  setState(() {
                    selectedImapSecurity = newValue;
                  });
                }),
            Padding(padding: EdgeInsets.all(loginVerticalPadding12dp)),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context).loginAdvancedSmtpTitle,
                style: Theme.of(context).textTheme.subhead.merge(primaryW500),
              ),
            ),
            smtpPortField,
            Padding(padding: EdgeInsets.all(loginVerticalPadding12dp)),
            Text(AppLocalizations.of(context).loginLabelSmtpSecurity),
            DropdownButton(
              value: selectedSmtpSecurity == null ? AppLocalizations.of(context).automatic : selectedSmtpSecurity,
              items: getSecurityOptions(context),
              onChanged: (String newValue) {
                setState(() {
                  selectedSmtpSecurity = newValue;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> getSecurityOptions(BuildContext context) {
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
