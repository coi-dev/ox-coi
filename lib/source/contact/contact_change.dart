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

import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/material.dart';
import 'package:ox_talk/source/chat/chat.dart';
import 'package:ox_talk/source/contact/contact_change_bloc.dart';
import 'package:ox_talk/source/contact/contact_change_event.dart';
import 'package:ox_talk/source/contact/contact_change_state.dart';
import 'package:ox_talk/source/data/chat_repository.dart';
import 'package:ox_talk/source/data/repository.dart';
import 'package:ox_talk/source/utils/error.dart';
import 'package:ox_talk/source/widgets/validatable_text_form_field.dart';
import 'package:ox_talk/source/l10n/localizations.dart';
import 'package:ox_talk/source/utils/colors.dart';
import 'package:ox_talk/source/utils/toast.dart';
import 'package:rxdart/rxdart.dart';

enum ContactAction {
  add,
  edit,
  delete,
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
  GlobalKey<FormState> _formKey = GlobalKey();
  ValidatableTextFormField _nameField = ValidatableTextFormField(
    (context) => AppLocalizations.of(context).name,
    hintText: (context) => AppLocalizations.of(context).contactChangeNameHint,
  );
  ValidatableTextFormField _emailField;

  String title;
  String deleteButton;
  String changeToast;
  String deleteToast;
  String deleteFailedToast;

  ContactChangeBloc _contactChangeBloc = ContactChangeBloc();

  Repository<Chat> chatRepository;

  @override
  void initState() {
    super.initState();
    if (widget.contactAction == ContactAction.add) {
      _emailField = ValidatableTextFormField(
        (context) => AppLocalizations.of(context).emailAddress,
        textFormType: TextFormType.email,
        inputType: TextInputType.emailAddress,
      );
    }
    final contactAddedObservable = new Observable<ContactChangeState>(_contactChangeBloc.state);
    contactAddedObservable.listen((state) => handleContactChanged(state));
    chatRepository = ChatRepository(Chat.getCreator());
  }

  handleContactChanged(ContactChangeState state) async {
    if (state is ContactChangeStateSuccess) {
      if (!widget.createChat) {
        if (state.delete) {
          showToast(deleteToast);
        } else {
          showToast(changeToast);
        }
        Navigator.pop(context);
      } else {
        if (state.id != null) {
          Context coreContext = Context();
          var chatId = await coreContext.createChatByContactId(state.id);
          chatRepository.putIfAbsent(id: chatId);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ChatScreen(chatId)), ModalRoute.withName('/'));
        }
      }
    } else if (state is ContactChangeStateFailure && state.error == contactDelete) {
      showToast(deleteFailedToast);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.contactAction == ContactAction.add) {
      title = AppLocalizations.of(context).contactChangeAddTitle;
      changeToast = AppLocalizations.of(context).contactChangeAddToast;
    } else {
      deleteButton = AppLocalizations.of(context).contactChangeDeleteTitle;
      title = AppLocalizations.of(context).contactChangeEditTitle;
      changeToast = AppLocalizations.of(context).contactChangeEditToast;
      deleteToast = AppLocalizations.of(context).contactChangeDeleteToast;
      deleteFailedToast = AppLocalizations.of(context).contactChangeDeleteFailedToast;
      _nameField.controller.text = widget.name != null ? widget.name : "";
    }
    return Scaffold(
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: contactMain,
          title: Text(title),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () => onSubmit(),
            )
          ],
        ),
        body: buildForm());
  }

  onSubmit() {
    if (_formKey.currentState.validate()) {
      _contactChangeBloc.dispatch(ChangeContact(getName(), getEmail(), widget.contactAction));
    }
  }

  Widget buildForm() {
    return Builder(builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                child: Column(
                  children: <Widget>[
                    widget.contactAction != ContactAction.add
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.mail),
                                Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                ),
                                Text(
                                  widget.email,
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    Row(
                      children: <Widget>[
                        Icon(Icons.person),
                        Padding(
                          padding: EdgeInsets.only(right: 8),
                        ),
                        Expanded(child: _nameField),
                      ],
                    ),
                    widget.contactAction == ContactAction.add
                        ? Row(
                            children: <Widget>[
                              Icon(Icons.mail),
                              Padding(
                                padding: EdgeInsets.only(right: 8),
                              ),
                              Expanded(child: _emailField),
                            ],
                          )
                        : Container(),
                  ],
                ),
              ),
              widget.contactAction != ContactAction.add
                  ? Center(
                      child: OutlineButton(
                        highlightedBorderColor: Theme.of(context).errorColor,
                        borderSide: BorderSide(color: Theme.of(context).errorColor),
                        textColor: Theme.of(context).errorColor,
                        onPressed: () => onDelete(context),
                        child: Text(deleteButton),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      );
    });
  }

  onDelete(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context).contactChangeDeleteTitle),
            content: new Text(AppLocalizations.of(context).contactChangeDeleteDialogContent(getEmail(), getName())),
            actions: <Widget>[
              new FlatButton(
                child: new Text(AppLocalizations.of(context).no),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text(AppLocalizations.of(context).delete),
                onPressed: () {
                  _contactChangeBloc.dispatch(DeleteContact(widget.id));
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  String getName() => _nameField.controller.text;

  String getEmail() => widget.contactAction == ContactAction.add ? _emailField.controller.text : widget.email;
}
