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
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/settings/settings_autocrypt_bloc.dart';
import 'package:ox_coi/src/settings/settings_autocrypt_event_state.dart';
import 'package:ox_coi/src/utils/colors.dart';
import 'package:ox_coi/src/utils/dimensions.dart';
import 'package:ox_coi/src/utils/toast.dart';
import 'package:ox_coi/src/widgets/state_info.dart';
import 'package:ox_coi/src/widgets/validatable_text_form_field.dart';
import 'package:rxdart/rxdart.dart';

class SettingsAutocryptImport extends StatefulWidget {
  final int chatId;
  final int messageId;

  const SettingsAutocryptImport({Key key, this.chatId, this.messageId}) : super(key: key);

  @override
  _SettingsAutocryptImportState createState() => _SettingsAutocryptImportState();
}

class _SettingsAutocryptImportState extends State<SettingsAutocryptImport> {
  SettingsAutocryptBloc _settingsAutocryptBloc = SettingsAutocryptBloc();
  Navigation navigation = Navigation();
  GlobalKey<FormState> _formKey = GlobalKey();
  ValidatableTextFormField _setupCodeField;
  String setupCodeStart;

  @override
  void initState() {
    super.initState();
    final contactImportObservable = new Observable<SettingsAutocryptState>(_settingsAutocryptBloc.state);
    contactImportObservable.listen((state) => handleAutocryptImport(state));
    _settingsAutocryptBloc.dispatch(PrepareKeyTransfer(chatId: widget.chatId, messageId: widget.messageId));
    navigation.current = Navigatable(Type.settingsAutocryptImport);
  }

  void handleAutocryptImport(SettingsAutocryptState state) {
    if (state is SettingsAutocryptStatePrepared) {
      _setupCodeField = ValidatableTextFormField(
        (context) => AppLocalizations.of(context).securitySettingsAutocryptImportLabel,
        hintText: (context) => AppLocalizations.of(context).securitySettingsAutocryptImportHint,
        inputType: TextInputType.number,
        maxLines: 2,
        needValidation: true,
        validationHint: (context) => AppLocalizations.of(context).validatableTextFormFieldHintEmptyString,
      );
      setupCodeStart = state.setupCodeStart;
    } else if (state is SettingsAutocryptStateFailure) {
      showToast(AppLocalizations.of(context).securitySettingsAutocryptImportFailed);
    } else if (state is SettingsAutocryptStateSuccess) {
      showToast(AppLocalizations.of(context).securitySettingsAutocryptImportSuccess);
      navigation.pop(context);
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
        title: Text(AppLocalizations.of(context).securitySettingsAutocryptImport),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () => onSubmit(),
          )
        ],
      ),
      body: BlocBuilder(
        bloc: _settingsAutocryptBloc,
        builder: (context, state) {
          if (state is SettingsAutocryptStatePrepared || state is SettingsAutocryptStateFailure) {
            return buildForm();
          } else {
            return StateInfo(showLoading: true);
          }
        },
      ),
    );
  }

  onSubmit() {
    if (_formKey.currentState.validate()) {
      _settingsAutocryptBloc.dispatch(ContinueKeyTransfer(messageId: widget.messageId, setupCode: _setupCodeField.controller.text));
    }
  }

  Widget buildForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: formHorizontalPadding, vertical: formVerticalPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: formVerticalPadding),
              child: Text(AppLocalizations.of(context).securitySettingsAutocryptImportText),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: formVerticalPadding),
              child: Text(AppLocalizations.of(context).securitySettingsAutocryptImportCodeHint(setupCodeStart)),
            ),
            _setupCodeField,
          ],
        ),
      ),
    );
  }
}
