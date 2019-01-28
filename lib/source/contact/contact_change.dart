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
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ox_talk/source/contact/contact_change_bloc.dart';
import 'package:ox_talk/source/contact/contact_change_event.dart';
import 'package:ox_talk/source/contact/contact_change_state.dart';
import 'package:ox_talk/source/form/validatable_text_form_field.dart';
import 'package:ox_talk/source/ui/default_colors.dart';
import 'package:ox_talk/source/error/error.dart';
import 'package:rxdart/rxdart.dart';

class ContactChange extends StatefulWidget {
  final bool add;
  final int id;
  final String name;
  final String email;

  ContactChange({@required this.add, this.id, this.name, this.email});

  @override
  _ContactChangeState createState() => _ContactChangeState();
}

class _ContactChangeState extends State<ContactChange> {
  GlobalKey<FormState> _formKey = GlobalKey();
  ValidatableTextFormField _nameField = ValidatableTextFormField("Name", "Enter a name for the contact");
  ValidatableTextFormField _emailField;

  String title;
  String deleteButton;
  String editToast;
  String deleteToast;
  String deleteFailedToast;

  ContactChangeBloc _contactChangeBloc = ContactChangeBloc();

  @override
  void initState() {
    super.initState();
    if (widget.add) {
      title = "Add Contact";
      editToast = "Contact successfully added";
      _emailField = ValidatableTextFormField("Email address", "Enter a valid email address",
          textFormType: TextFormType.email, inputType: TextInputType.emailAddress);
    } else {
      deleteButton = "Delete Contact";
      title = "Edit Name";
      editToast = "Contact successfully edited";
      deleteToast = "Contact successfully deleted";
      deleteFailedToast = "Could not delete contact. Please delete active chats first.";
      _nameField.controller.text = widget.name != null ? widget.name : "";
    }
    final contactAddedObservable = new Observable<ContactChangeState>(_contactChangeBloc.state);
    contactAddedObservable.listen((state) => handleContactChanged(state));
  }

  handleContactChanged(ContactChangeState state) {
    if (state is ContactChangeStateSuccess) {
      if (state.delete) {
        _showToast(deleteToast);
      } else {
        _showToast(editToast);
      }
      Navigator.pop(context);
    } else if (state is ContactChangeStateFailure && state.error == Error.contactDelete) {
      _showToast(deleteFailedToast);
    }
  }

  _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIos: 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: DefaultColors.contactColor,
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
      _contactChangeBloc.dispatch(ChangeContact(getName(), getEmail(), widget.add));
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
                    !widget.add
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
                    widget.add
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
              !widget.add
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
            title: Text("Delete contact"),
            content: new Text("Do you really want to delete ${getEmail()} (${getName()})?"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("No"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text("Delete"),
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

  String getEmail() => widget.add ? _emailField.controller.text : widget.email;
}
