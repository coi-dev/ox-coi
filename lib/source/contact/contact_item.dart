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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_talk/source/chat/chat.dart';
import 'package:ox_talk/source/contact/contact_change.dart';
import 'package:ox_talk/source/contact/contact_item_bloc.dart';
import 'package:ox_talk/source/contact/contact_item_event.dart';
import 'package:ox_talk/source/contact/contact_item_state.dart';
import 'package:ox_talk/source/data/chat_repository.dart';
import 'package:ox_talk/source/data/repository.dart';
import 'package:ox_talk/source/widgets/avatar_list_item.dart';

class ContactItem extends StatefulWidget {
  final int _contactId;
  final bool _createChat;

  ContactItem(this._contactId, this._createChat, key) : super(key: Key(key));

  @override
  _ContactItemState createState() => _ContactItemState();
}

class _ContactItemState extends State<ContactItem> {
  ContactItemBloc _contactBloc = ContactItemBloc();
  Repository<Chat> chatRepository = ChatRepository(Chat.getCreator());

  @override
  void initState() {
    super.initState();
    _contactBloc.dispatch(RequestContact(widget._contactId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: _contactBloc,
        builder: (context, state) {
          if (state is ContactItemStateSuccess) {
            return AvatarListItem(
              title: state.name,
              subTitle: state.email,
              color: state.color,
              onTap: onContactTapped,
            );
          } else if (state is ContactItemStateFailure) {
            return new Text(state.error);
          } else {
            return AvatarListItem(
              title: "",
              subTitle: "",
              onTap: onContactTapped,
            );
          }
        });
  }

  onContactTapped(String name, String email) async {
    if (!widget._createChat) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactChange(
                  contactAction: ContactAction.edit,
                  id: widget._contactId,
                  email: email,
                  name: name,
                )),
      );
    } else {
      return showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Start a chat"),
              content: new Text("Do you want to start a chat with $name?"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                  child: new Text("Yes"),
                  onPressed: () {
                    createChat();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  void createChat() async {
    Context coreContext = Context();
    var chatId = await coreContext.createChatByContactId(widget._contactId);
    chatRepository.putIfAbsent(id: chatId);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatScreen(chatId)));
  }
}
