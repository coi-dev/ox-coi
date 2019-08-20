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

import 'package:delta_chat_core/delta_chat_core.dart' as Core;
import 'package:flutter/material.dart';
import 'package:ox_coi/src/chat/chat.dart';
import 'package:ox_coi/src/contact/contact_change_bloc.dart';
import 'package:ox_coi/src/contact/contact_change_event_state.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/qr/qr.dart';
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/utils/toast.dart';
import 'package:ox_coi/src/widgets/validatable_text_form_field.dart';
import 'package:rxdart/rxdart.dart';

enum ContactAction {
  add,
  edit,
}

class ContactChange extends StatefulWidget {
  final ContactAction contactAction;
  final int id;
  final String name;
  final String email;
  final bool createChat;

  ContactChange({@required this.contactAction, this.id, this.name, this.email, this.createChat = false});

  @override
  _ContactChangeState createState() => _ContactChangeState();
}

class _ContactChangeState extends State<ContactChange> {
  Navigation navigation = Navigation();
  GlobalKey<FormState> _formKey = GlobalKey();
  ValidatableTextFormField _nameField = ValidatableTextFormField(
    (context) => L10n.get(L.name),
    key: Key(keyContactChangeNameValidatableTextFormField),
    hintText: (context) => L10n.get(L.contactName),
  );
  ValidatableTextFormField _emailField;

  String title;
  String changeToast;

  ContactChangeBloc _contactChangeBloc = ContactChangeBloc();

  Repository<Core.Chat> chatRepository;

  @override
  void initState() {
    super.initState();
    navigation.current = Navigatable(Type.contactChange);
    if (widget.contactAction == ContactAction.add) {
      _emailField = ValidatableTextFormField(
        (context) => L10n.get(L.emailAddress),
        key: Key(keyContactChangeEmailValidatableTextFormField),
        textFormType: TextFormType.email,
        inputType: TextInputType.emailAddress,
        needValidation: true,
        validationHint: (context) => L10n.get(L.loginCheckMail),
      );
    } else {
      _nameField.controller.text = widget.name != null ? widget.name : "";
    }
    final contactAddedObservable = new Observable<ContactChangeState>(_contactChangeBloc.state);
    contactAddedObservable.listen((state) => handleContactChanged(state));
    chatRepository = RepositoryManager.get(RepositoryType.chat);
  }

  handleContactChanged(ContactChangeState state) async {
    if (state is ContactChangeStateSuccess) {
      if (!widget.createChat) {
        showToast(changeToast);
        navigation.pop(context);
      } else {
        if (state.id != null) {
          Core.Context coreContext = Core.Context();
          var chatId = await coreContext.createChatByContactId(state.id);
          chatRepository.putIfAbsent(id: chatId);
          navigation.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Chat(chatId: chatId)),
            ModalRoute.withName(Navigation.root),
            Navigatable(Type.contactList),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.contactAction == ContactAction.add) {
      title = widget.createChat ? L10n.get(L.chatCreate) : L10n.get(L.contactAdd);
      changeToast = L10n.get(L.contactAddedSuccess);
    } else {
      title = L10n.get(L.contactEdit);
      changeToast = L10n.get(L.contactEditedSuccess);
    }
    return Scaffold(
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.close),
            onPressed: () => navigation.pop(context),
          ),
          title: Text(title),
          actions: <Widget>[
            IconButton(
              key: Key(keyContactChangeCheckIconButton),
              icon: Icon(Icons.check),
              onPressed: () => _onSubmit(),
            )
          ],
        ),
        body: _buildForm());
  }

  _onSubmit() {
    if (_formKey.currentState.validate()) {
      _contactChangeBloc.dispatch(ChangeContact(
        name: _getName(),
        email: _getEmail(),
        contactAction: widget.contactAction,
      ));
    }
  }

  Widget _buildForm() {
    return Builder(builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: formHorizontalPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: formVerticalPadding),
                child: Column(
                  children: <Widget>[
                    widget.contactAction != ContactAction.add
                        ? Padding(
                            padding: const EdgeInsets.only(top: formVerticalPadding, bottom: formVerticalPadding),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.mail),
                                Padding(
                                  padding: EdgeInsets.only(right: iconFormPadding),
                                ),
                                Text(
                                  widget.email,
                                  style: Theme.of(context).textTheme.subhead,
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    Row(
                      children: <Widget>[
                        Icon(Icons.person),
                        Padding(
                          padding: EdgeInsets.only(right: iconFormPadding),
                        ),
                        Expanded(child: _nameField),
                      ],
                    ),
                    Visibility(
                      visible: widget.contactAction == ContactAction.add,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.mail),
                          Padding(
                            padding: EdgeInsets.only(right: iconFormPadding),
                          ),
                          Expanded(child: _emailField),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: formVerticalPadding),
                    ),
                    Visibility(
                      visible: widget.contactAction == ContactAction.add,
                      child: RaisedButton(
                        color: accent,
                        textColor: onAccent,
                        child: Text(L10n.get(L.qrScan)),
                        onPressed: scanQr,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _getName() => _nameField.controller.text;

  String _getEmail() => widget.contactAction == ContactAction.add ? _emailField.controller.text : widget.email;

  scanQr() {
    navigation.push(
      context,
      MaterialPageRoute(
          builder: (context) => QrCode(
                chatId: 0,
                initialIndex: 1,
              )),
    );
  }
}
