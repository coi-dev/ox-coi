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
import 'package:ox_coi/src/chat/chat_change_bloc.dart';
import 'package:ox_coi/src/chat/chat_change_event.dart';
import 'package:ox_coi/src/chat/chat_profile_group_contact_item.dart';
import 'package:ox_coi/src/contact/contact_list_bloc.dart';
import 'package:ox_coi/src/contact/contact_list_event.dart';
import 'package:ox_coi/src/contact/contact_list_state.dart';
import 'package:ox_coi/src/l10n/localizations.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/utils/dialog_builder.dart';
import 'package:ox_coi/src/utils/dimensions.dart';
import 'package:ox_coi/src/utils/styles.dart';

class ChatProfileGroupView extends StatefulWidget {
  final int _chatId;
  final String _chatName;
  final Color _chatColor;
  final bool _isVerified;

  ChatProfileGroupView(this._chatId, this._chatName, this._chatColor, this._isVerified);

  @override
  _ChatProfileGroupViewState createState() => _ChatProfileGroupViewState();
}

class _ChatProfileGroupViewState extends State<ChatProfileGroupView> {
  ContactListBloc _contactListBloc = ContactListBloc();

  @override
  void initState() {
    super.initState();
    _contactListBloc.dispatch(RequestContacts(listTypeOrChatId: widget._chatId));
  }

  @override
  void dispose() {
    _contactListBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: CircleAvatar(
              maxRadius: profileAvatarMaxRadius,
              backgroundColor: widget._chatColor,
              child: Text(
                widget._chatName.substring(0,1),
                style: chatProfileAvatarInitialText,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Visibility(
                visible: widget._isVerified,
                child: Padding(
                  padding: const EdgeInsets.only(right: iconTextPadding),
                  child: Icon(
                    Icons.verified_user
                  ),
                )
              ),
              Text(
                widget._chatName,
                style: defaultText,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(chatProfileDividerPadding),
            child: Divider(height: dividerHeight,),
          ),
          Card(
            child: ListTile(
              title: Text(AppLocalizations.of(context).chatProfileLeaveGroupButtonText,),
              onTap: () => _showLeaveGroupDialog(),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(chatProfileDividerPadding),
            child: Divider(height: dividerHeight,),
          ),
          _buildGroupMemberList()
        ],
      ),
    );
  }

  Widget _buildGroupMemberList() {
    return BlocBuilder(
      bloc: _contactListBloc,
      builder: (context, state){
        if(state is ContactListStateSuccess){
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(AppLocalizations.of(context).chatProfileGroupMemberCounter(state.contactIds.length)),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(top: listItemPadding),
                  itemCount: state.contactIds.length,
                  itemBuilder: (BuildContext context, int index) {
                    var contactId = state.contactIds[index];
                    var key = "$contactId-${state.contactLastUpdateValues[index]}";
                    return ChatProfileGroupContactItem(contactId, key);
                  })
              )
            ],
          );
        } else {
          return Container();
        }
      }
    );
  }

  _showLeaveGroupDialog() {
    return showConfirmationDialog(
      context: context,
      title: AppLocalizations.of(context).chatProfileLeaveGroupButtonText,
      content: AppLocalizations.of(context).chatProfileLeaveGroupInfoText,
      positiveButton: AppLocalizations.of(context).chatProfileLeaveGroupButtonText,
      positiveAction: () => _leaveGroup(),
      selfClose: false,
      navigatable: Navigatable(Type.chatLeaveGroupDialog),
    );
  }

  _leaveGroup() async{
    ChatChangeBloc chatChangeBloc = ChatChangeBloc();
    chatChangeBloc.dispatch(LeaveGroupChat(chatId: widget._chatId));
    chatChangeBloc.dispatch(DeleteChat(chatId: widget._chatId));
    Navigation navigation = Navigation();
    navigation.popUntil(context, ModalRoute.withName(Navigation.root));
  }
}