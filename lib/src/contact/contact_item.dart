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
import 'package:ox_coi/src/chat/chat_create_mixin.dart';
import 'package:ox_coi/src/contact/contact_change_bloc.dart';
import 'package:ox_coi/src/contact/contact_change_event_state.dart';
import 'package:ox_coi/src/contact/contact_item_bloc.dart';
import 'package:ox_coi/src/contact/contact_item_builder_mixin.dart';
import 'package:ox_coi/src/contact/contact_item_event_state.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/utils/dialog_builder.dart';

import 'contact_details.dart';

enum ContactItemType { display, edit, createChat, blocked, forward }

class ContactItem extends StatefulWidget {
  final int contactId;
  final ContactItemType contactItemType;
  final Function onTap;

  ContactItem({@required this.contactId, this.contactItemType = ContactItemType.display, this.onTap, Key key}) : super(key: key);

  @override
  _ContactItemState createState() => _ContactItemState();
}

class _ContactItemState extends State<ContactItem> with ContactItemBuilder, ChatCreateMixin {
  ContactItemBloc _contactBloc = ContactItemBloc();
  Navigation navigation = Navigation();

  @override
  void initState() {
    super.initState();
    var listType;
    if (widget.contactItemType == ContactItemType.blocked) {
      listType = blockedContacts;
    } else {
      listType = validContacts;
    }
    _contactBloc.add(RequestContact(contactId: widget.contactId, typeOrChatId: listType));
  }

  @override
  void dispose() {
    _contactBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return getAvatarItemBlocBuilder(bloc: _contactBloc, onContactTapped: onContactTapped);
  }

  onContactTapped(String name, String email) async {
    if (widget.contactItemType == ContactItemType.createChat || widget.contactItemType == ContactItemType.forward) {
      return createChatFromContact(context, widget.contactId, _handleCreateChatStateChange);
    } else if (widget.contactItemType == ContactItemType.blocked) {
      return buildUnblockContactDialog(name, email);
    } else if (widget.contactItemType == ContactItemType.edit) {
      navigation.push(
        context,
        MaterialPageRoute(builder: (context) => ContactDetails(contactId: widget.contactId)),
      );
    }
  }

  _handleCreateChatStateChange(int chatId) {
    if (widget.contactItemType == ContactItemType.forward) {
      widget.onTap(chatId);
    } else {
      navigation.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Chat(chatId: chatId)),
        ModalRoute.withName(Navigation.root),
        Navigatable(Type.chatList),
      );
    }
  }

  buildUnblockContactDialog(String name, String email) {
    String contact = name.isNotEmpty ? name : email;
    Navigation navigation = Navigation();
    return showNavigatableDialog(
      context: context,
      navigatable: Navigatable(Type.contactUnblockDialog),
      dialog: AlertDialog(
        title: Text(L10n.get(L.contactUnblock)),
        content: new Text(L10n.getFormatted(L.contactUnblockTextX, [contact])),
        actions: <Widget>[
          new FlatButton(
            child: new Text(L10n.get(L.cancel)),
            onPressed: () {
              navigation.pop(context);
            },
          ),
          new FlatButton(
            child: Text(L10n.get(L.unblock)),
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
    // Ignoring false positive https://github.com/felangel/bloc/issues/587
    // ignore: close_sinks
    ContactChangeBloc contactChangeBloc = ContactChangeBloc();
    contactChangeBloc.add(UnblockContact(id: widget.contactId));
  }
}
