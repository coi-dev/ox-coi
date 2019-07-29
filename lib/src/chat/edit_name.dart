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
import 'package:ox_coi/src/widgets/validatable_text_form_field.dart';

import 'chat_bloc.dart';
import 'chat_change_bloc.dart';
import 'chat_change_event_state.dart';
import 'chat_event_state.dart';

class EditName extends StatefulWidget {
  final int chatId;
  final String actualName;
  final String title;

  EditName({@required this.chatId, @required this.actualName, @required this.title});

  @override
  _EditNameState createState() => _EditNameState();
}

class _EditNameState extends State<EditName> {
  ChatChangeBloc _chatChangeBloc = ChatChangeBloc();
  ChatBloc _chatBloc;
  Navigation _navigation = Navigation();

  ValidatableTextFormField _nameField = ValidatableTextFormField(
    (context) => AppLocalizations.of(context).name,
    hintText: (context) => AppLocalizations.of(context).setNameTextFieldHint,
    needValidation: true,
    validationHint: (context) => AppLocalizations.of(context).validatableTextFormFieldHintEmptyString,
  );
  GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.editName);
    _chatBloc = BlocProvider.of<ChatBloc>(context);
    _nameField.controller.text = widget.actualName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.close),
            onPressed: () => _navigation.pop(context),
          ),
          title: Text(widget.title),
          actions: <Widget>[IconButton(icon: Icon(Icons.check), onPressed: saveNewName)],
        ),
        body: BlocListener(
          bloc: _chatChangeBloc,
          listener: (context, state) {
            if (state is ChangeNameSuccess) {
              _chatBloc.dispatch(RequestChat(chatId: widget.chatId));
              _navigation.pop(context);
            }
          },
          child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: _nameField,
              )),
        ));
  }

  void saveNewName() {
    if (_formKey.currentState.validate()) {
      _chatChangeBloc.dispatch(SetName(chatId: widget.chatId, newName: _nameField.controller.text));
    }
  }
}
