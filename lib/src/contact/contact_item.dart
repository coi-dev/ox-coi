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
import 'package:ox_talk/src/chat/chat.dart';
import 'package:ox_talk/src/chat/change_chat_bloc.dart';
import 'package:ox_talk/src/chat/change_chat_event.dart';
import 'package:ox_talk/src/chat/change_chat_state.dart';
import 'package:ox_talk/src/contact/contact_change.dart';
import 'package:ox_talk/src/contact/contact_change_bloc.dart';
import 'package:ox_talk/src/contact/contact_change_event.dart';
import 'package:ox_talk/src/contact/contact_item_bloc.dart';
import 'package:ox_talk/src/contact/contact_item_event.dart';
import 'package:ox_talk/src/l10n/localizations.dart';
import 'package:ox_talk/src/contact/contact_item_builder_mixin.dart';
import 'package:ox_talk/src/navigation/navigation.dart';
import 'package:rxdart/rxdart.dart';

class ContactItem extends StatefulWidget {
  final int _contactId;
  final bool _createChat;
  final bool _isBlocked;

  ContactItem(this._contactId, this._createChat, this._isBlocked, key) : super(key: Key(key));

  @override
  _ContactItemState createState() => _ContactItemState();
}

class _ContactItemState extends State<ContactItem> with ContactItemBuilder {
  ContactItemBloc _contactBloc = ContactItemBloc();
  Navigation navigation = Navigation();

  @override
  void initState() {
    super.initState();
    _contactBloc.dispatch(RequestContact(widget._contactId));
  }

  @override
  void dispose() {
    _contactBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return getBlocBuilder(_contactBloc, onContactTapped);
  }

  onContactTapped(String name, String email) async {
    if (widget._createChat) {
      return buildCreateChatDialog(name, email);
    } else if(widget._isBlocked){
      return buildUnblockContactDialog(name, email);
    } else {
      navigation.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
            ContactChange(
              contactAction: ContactAction.edit,
              id: widget._contactId,
              email: email,
              name: name,
            )),
        "ContactChange"
      );
    }
  }

  Future<void> buildCreateChatDialog(String name, String email) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          String contact = name.isNotEmpty ? name : email;
          return AlertDialog(
            title: Text(AppLocalizations
                .of(context)
                .createChatTitle),
            content: new Text(AppLocalizations.of(context).createChatWith(contact)),
            actions: <Widget>[
              new FlatButton(
                child: new Text(AppLocalizations
                    .of(context)
                    .cancel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text(AppLocalizations
                    .of(context)
                    .yes),
                onPressed: () {
                  createChat();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void createChat() async {
    ChangeChatBloc createChatBloc = ChangeChatBloc();
    final createChatStatesObservable = new Observable<ChangeChatState>(createChatBloc.state);
    createChatStatesObservable.listen((state) => _handleCreateChatStateChange(state));
    createChatBloc.dispatch(CreateChat(contactId: widget._contactId));
  }

  _handleCreateChatStateChange(ChangeChatState state) {
    if (state is CreateChatStateSuccess) {
      navigation.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatScreen(state.chatId)), "ChatScreen");
    }
  }

  buildUnblockContactDialog(String name, String email) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        String contact = name.isNotEmpty ? name : email;
        return AlertDialog(
          title: Text(AppLocalizations
            .of(context)
            .unblockDialogTitle),
          content: new Text(AppLocalizations.of(context).unblockDialogText(contact)),
          actions: <Widget>[
            new FlatButton(
              child: new Text(AppLocalizations
                .of(context)
                .cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text(AppLocalizations
                .of(context)
                .unblock),
              onPressed: () {
                unblockContact();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
  }

  void unblockContact() {
    ContactChangeBloc contactChangeBloc = ContactChangeBloc();
    contactChangeBloc.dispatch(UnblockContact(widget._contactId));
  }
}
