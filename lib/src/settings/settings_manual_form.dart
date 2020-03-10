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
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/settings/settings_manual_form_bloc.dart';
import 'package:ox_coi/src/settings/settings_manual_form_event_state.dart';
import 'package:ox_coi/src/ui/custom_theme.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/ui/strings.dart';
import 'package:ox_coi/src/utils/core.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
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
    (context) => L10n.get(L.password),
    textFormType: TextFormType.password,
    needValidation: true,
    validationHint: (context) => L10n.get(L.loginCheckPassword),
    key: Key(keySettingsManuelFormValidatableTextFormFieldPasswordField),
  );
  ValidatableTextFormField imapLoginNameField = ValidatableTextFormField(
    (context) => L10n.get(L.settingIMAPName),
  );
  ValidatableTextFormField imapServerField = ValidatableTextFormField(
    (context) => L10n.get(L.settingIMAPServer),
    inputType: TextInputType.url,
    key: Key(keySettingsManuelFormValidatableTextFormFieldImapServerField),
  );
  ValidatableTextFormField imapPortField = ValidatableTextFormField(
    (context) => L10n.get(L.settingIMAPPort),
    textFormType: TextFormType.port,
    inputType: TextInputType.number,
    needValidation: true,
    validationHint: (context) => L10n.get(L.loginCheckPort),
  );
  ValidatableTextFormField smtpLoginNameField = ValidatableTextFormField(
    (context) => L10n.get(L.settingSMTPLogin),
  );
  ValidatableTextFormField smtpPasswordField = ValidatableTextFormField(
    (context) => L10n.get(L.settingSMTPPassword),
    textFormType: TextFormType.password,
    needValidation: false,
    validationHint: (context) => L10n.get(L.loginCheckPassword),
  );
  ValidatableTextFormField smtpServerField = ValidatableTextFormField(
    (context) => L10n.get(L.settingSMTPServer),
    key: Key(keySettingsManuelFormValidatableTextFormFieldSMTPServerField),
    inputType: TextInputType.url,
  );
  ValidatableTextFormField smtpPortField = ValidatableTextFormField(
    (context) => L10n.get(L.settingSMTPPort),
    textFormType: TextFormType.port,
    inputType: TextInputType.number,
    needValidation: true,
    validationHint: (context) => L10n.get(L.loginCheckPort),
  );

  @override
  void initState() {
    super.initState();
    emailField = ValidatableTextFormField(
      (context) => L10n.get(L.emailAddress),
      textFormType: TextFormType.email,
      inputType: TextInputType.emailAddress,
      needValidation: true,
      enabled: widget.isLogin,
      validationHint: (context) => L10n.get(L.loginCheckMail),
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
          smtpServerField.controller.text = state.smtpServer;
          smtpPortField.controller.text = state.smtpPort;
          setState(() {
            selectedImapSecurity = convertProtocolIntToString(context, state.imapSecurity);
            selectedSmtpSecurity = convertProtocolIntToString(context, state.smtpSecurity);
          });
        } else if (state is SettingsManualFormStateValidation) {
          var success = formKey.currentState.validate();
          if (success) {
            BlocProvider.of<SettingsManualFormBloc>(context).add(ValidationDone(
              success: success,
              email: emailField.controller.text,
              password: passwordField.controller.text,
              imapLogin: imapLoginNameField.controller.text,
              imapServer: imapServerField.controller.text,
              imapPort: imapPortField.controller.text,
              imapSecurity: convertProtocolStringToInt(context, selectedImapSecurity),
              smtpLogin: smtpLoginNameField.controller.text,
              smtpPassword: smtpPasswordField.controller.text,
              smtpServer: smtpServerField.controller.text,
              smtpPort: smtpPortField.controller.text,
              smtpSecurity: convertProtocolStringToInt(context, selectedSmtpSecurity),
            ));
          }
        }
      },
      child: BlocBuilder<SettingsManualFormBloc, SettingsManualFormState>(
        builder: (context, state) {
          if (state is SettingsManualFormStateReady ||
              state is SettingsManualFormStateValidation ||
              state is SettingsManualFormStateValidationSuccess) {
            return Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      L10n.get(L.settingBase),
                      style: Theme.of(context).textTheme.body2.apply(color: CustomTheme.of(context).onBackground),
                    ),
                  ),
                  emailField,
                  passwordField,
                  Padding(padding: const EdgeInsets.all(loginVerticalPadding12dp)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      L10n.get(L.loginImapSmtpName),
                      style: Theme.of(context).textTheme.body2.apply(color: CustomTheme.of(context).onBackground),
                    ),
                  ),
                  imapLoginNameField,
                  smtpLoginNameField,
                  smtpPasswordField,
                  Padding(padding: const EdgeInsets.all(loginVerticalPadding12dp)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      L10n.get(L.loginServerAddresses),
                      style: Theme.of(context).textTheme.body2.apply(color: CustomTheme.of(context).onBackground),
                    ),
                  ),
                  imapServerField,
                  smtpServerField,
                  Padding(padding: const EdgeInsets.all(loginVerticalPadding12dp)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      L10n.get(L.settingAdvancedImap),
                      style: Theme.of(context).textTheme.body2.apply(color: CustomTheme.of(context).onBackground),
                    ),
                  ),
                  imapPortField,
                  Padding(padding: const EdgeInsets.all(loginVerticalPadding12dp)),
                  Text(L10n.get(L.settingIMAPSecurity)),
                  DropdownButton(
                      value: selectedImapSecurity == null ? L10n.get(L.automatic) : selectedImapSecurity,
                      items: getSecurityOptions(context),
                      onChanged: (String newValue) {
                        setState(() {
                          selectedImapSecurity = newValue;
                        });
                      }),
                  Padding(padding: const EdgeInsets.all(loginVerticalPadding12dp)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      L10n.get(L.settingAdvancedSmtp),
                      style: Theme.of(context).textTheme.body2.apply(color: CustomTheme.of(context).onBackground),
                    ),
                  ),
                  smtpPortField,
                  Padding(padding: const EdgeInsets.all(loginVerticalPadding12dp)),
                  Text(L10n.get(L.settingSMTPSecurity)),
                  DropdownButton(
                    value: selectedSmtpSecurity == null ? L10n.get(L.automatic) : selectedSmtpSecurity,
                    items: getSecurityOptions(context),
                    onChanged: (String newValue) {
                      setState(() {
                        selectedSmtpSecurity = newValue;
                      });
                    },
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  List<DropdownMenuItem<String>> getSecurityOptions(BuildContext context) {
    return [
      L10n.get(L.automatic),
      sslTls,
      startTLS,
      L10n.get(L.off),
    ].map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(value: value, child: Text(value));
    }).toList();
  }
}
