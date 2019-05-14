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
import 'package:ox_coi/src/chat/chat_bloc.dart';
import 'package:ox_coi/src/chat/chat_event.dart';
import 'package:ox_coi/src/chat/chat_profile_group_view.dart';
import 'package:ox_coi/src/chat/chat_profile_single_view.dart';
import 'package:ox_coi/src/chat/chat_state.dart';
import 'package:ox_coi/src/contact/contact_list_bloc.dart';
import 'package:ox_coi/src/contact/contact_list_event.dart';
import 'package:ox_coi/src/contact/contact_list_state.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';

class ChatProfile extends StatefulWidget {
  final int _chatId;

  ChatProfile(this._chatId);

  @override
  _ChatProfileState createState() => _ChatProfileState();
}

class _ChatProfileState extends State<ChatProfile> {
  ChatBloc _chatBloc = ChatBloc();
  ContactListBloc _contactListBloc = ContactListBloc();
  final Navigation navigation = Navigation();

  @override
  void initState() {
    super.initState();
    navigation.current = Navigatable(Type.chatProfile);
    _chatBloc.dispatch(RequestChat(widget._chatId));
    _contactListBloc.dispatch(RequestContacts(listTypeOrChatId: widget._chatId));
  }

  @override
  void dispose() {
    _chatBloc.dispose();
    _contactListBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder(
        bloc: _chatBloc,
        builder: (context, state){
          if(state is ChatStateSuccess){
            bool _isVerified = state.isVerified;
            if(state.isGroupChat){
              return ChatProfileGroupView(widget._chatId, state.name, state.color, _isVerified);
            }else{
              bool _isSelfTalk = state.isSelfTalk;
              return BlocBuilder(
                bloc: _contactListBloc,
                builder: (context, state){
                  if(state is ContactListStateSuccess){
                    var key = "${state.contactIds[0]}-${state.contactLastUpdateValues[0]}";
                    return ChatProfileSingleView(widget._chatId, _isSelfTalk, _isVerified, state.contactIds[0], key);
                  }else{
                    return Container();
                  }
                }
              );
            }
          } else {
            return Container();
          }
        }
      )
    );
  }
}
