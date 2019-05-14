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
import 'package:ox_coi/src/chat/chat.dart';
import 'package:ox_coi/src/chat/chat_change_bloc.dart';
import 'package:ox_coi/src/chat/chat_change_event.dart';
import 'package:ox_coi/src/chat/chat_change_state.dart';
import 'package:ox_coi/src/contact/contact_change.dart';
import 'package:ox_coi/src/contact/contact_change_bloc.dart';
import 'package:ox_coi/src/contact/contact_change_event.dart';
import 'package:ox_coi/src/contact/contact_item_bloc.dart';
import 'package:ox_coi/src/contact/contact_item_builder_mixin.dart';
import 'package:ox_coi/src/contact/contact_item_event.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/l10n/localizations.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/utils/dialog_builder.dart';
import 'package:rxdart/rxdart.dart';

enum ContactItemType {
  display,
  edit,
  createChat,
  blocked,
  forward
}

class ContactItem extends StatefulWidget {
  final int _contactId;
  final ContactItemType contactItemType;
  final Function _onTap;

  ContactItem(this._contactId, key, [this.contactItemType = ContactItemType.display, this._onTap]) : super(key: Key(key));

  @override
  _ContactItemState createState() => _ContactItemState();
}

class _ContactItemState extends State<ContactItem> with ContactItemBuilder {
  ContactItemBloc _contactBloc = ContactItemBloc();
  Navigation navigation = Navigation();

  @override
  void initState() {
    super.initState();
    var listType;
    if (widget.contactItemType == ContactItemType.blocked) {
      listType = ContactRepository.blockedContacts;
    } else {
      listType = ContactRepository.validContacts;
    }
    _contactBloc.dispatch(RequestContact(contactId: widget._contactId, listType: listType));
  }

  @override
  void dispose() {
    _contactBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return getAvatarItemBlocBuilder(_contactBloc, onContactTapped);
  }

  onContactTapped(String name, String email) async {
    if (widget.contactItemType == ContactItemType.createChat || widget.contactItemType == ContactItemType.forward) {
      return createChat();
    } else if (widget.contactItemType == ContactItemType.blocked) {
      return buildUnblockContactDialog(name, email);
    } else if (widget.contactItemType == ContactItemType.edit) {
      navigation.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactChange(
                  contactAction: ContactAction.edit,
                  id: widget._contactId,
                  email: email,
                  name: name,
                )),
      );
    }
  }

  void createChat() {
    ChatChangeBloc createChatBloc = ChatChangeBloc();
    final createChatStatesObservable = new Observable<ChatChangeState>(createChatBloc.state);
    createChatStatesObservable.listen((state) => _handleCreateChatStateChange(state));
    createChatBloc.dispatch(CreateChat(contactId: widget._contactId));
  }

  _handleCreateChatStateChange(ChatChangeState state) {
    if (state is CreateChatStateSuccess) {
      int chatId = state.chatId;
      if(widget.contactItemType == ContactItemType.forward){
        widget._onTap(chatId);
      }else {
        navigation.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Chat(state.chatId)),
        );
      }
    }
  }

  buildUnblockContactDialog(String name, String email) {
    String contact = name.isNotEmpty ? name : email;
    Navigation navigation = Navigation();
    return showNavigatableDialog(
      context: context,
      navigatable: Navigatable(Type.contactUnblockDialog),
      dialog: AlertDialog(
        title: Text(AppLocalizations.of(context).unblockDialogTitle),
        content: new Text(AppLocalizations.of(context).unblockDialogText(contact)),
        actions: <Widget>[
          new FlatButton(
            child: new Text(AppLocalizations.of(context).cancel),
            onPressed: () {
              navigation.pop(context);
            },
          ),
          new FlatButton(
            child: new Text(AppLocalizations.of(context).unblock),
            onPressed: () {
              unblockContact();
              navigation.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void unblockContact() {
    ContactChangeBloc contactChangeBloc = ContactChangeBloc();
    contactChangeBloc.dispatch(UnblockContact(widget._contactId));
  }
}
