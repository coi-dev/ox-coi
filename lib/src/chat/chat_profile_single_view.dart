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
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_talk/src/chat/chat_change_bloc.dart';
import 'package:ox_talk/src/chat/chat_change_event.dart';
import 'package:ox_talk/src/contact/contact_change_bloc.dart';
import 'package:ox_talk/src/contact/contact_change_event.dart';
import 'package:ox_talk/src/contact/contact_item_bloc.dart';
import 'package:ox_talk/src/contact/contact_item_event.dart';
import 'package:ox_talk/src/contact/contact_item_state.dart';
import 'package:ox_talk/src/data/contact_repository.dart';
import 'package:ox_talk/src/l10n/localizations.dart';
import 'package:ox_talk/src/navigation/navigatable.dart';
import 'package:ox_talk/src/navigation/navigation.dart';
import 'package:ox_talk/src/utils/dialog_builder.dart';
import 'package:ox_talk/src/utils/dimensions.dart';
import 'package:ox_talk/src/utils/styles.dart';
import 'package:ox_talk/src/utils/toast.dart';

enum ChatProfileViewAction{
  delete,
  block
}

class ChatProfileSingleView extends StatefulWidget {
  final int _chatId;
  final int _contactId;
  final bool _isSelfTalk;
  final bool _isVerified;

  ChatProfileSingleView(this._chatId, this._isSelfTalk, this._isVerified, this._contactId, key) : super(key: Key(key));

  @override
  _ChatProfileSingleViewState createState() => _ChatProfileSingleViewState();
}

class _ChatProfileSingleViewState extends State<ChatProfileSingleView> {
  ContactItemBloc _contactItemBloc = ContactItemBloc();
  Navigation navigation = Navigation();

  @override
  void initState() {
    super.initState();
    _contactItemBloc.dispatch(RequestContact(contactId: widget._contactId, listType: ContactRepository.validContacts));
  }

  @override
  void dispose() {
    _contactItemBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _contactItemBloc,
      builder: (context, state){
        if(state is ContactItemStateSuccess){
          return _buildSingleProfileInfo(state.name, state.email, state.color);
        }
        else{
          return Container();
        }
      }
    );
  }

  Widget _buildSingleProfileInfo(String chatName, String email, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: CircleAvatar(
            maxRadius: profileAvatarMaxRadius,
            backgroundColor: color,
            child: Text(
              chatName.isNotEmpty ? chatName.substring(0,1) : email.substring(0,1),
              style: chatProfileAvatarInitialText,
            ),
          ),
        ),
        Visibility(
          visible: chatName.isNotEmpty,
          child: Text(
            chatName,
            style: defaultText,
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
            InkWell(
              onTap: () => {
                Clipboard.setData(ClipboardData(text: email)),
                showToast(AppLocalizations.of(context).chatProfileClipboardToastMessage)
              },
              child: Text(
                email,
                style: defaultText,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.all(chatProfileDividerPadding),
          child: Divider(height: dividerHeight,),
        ),
        Visibility(
          visible: !widget._isSelfTalk,
          child: Card(
            child: ListTile(
              title: Text(AppLocalizations.of(context).chatProfileBlockContactButtonText,),
              onTap: () => _showBlockContactDialog(ChatProfileViewAction.block),
            ),
          )
        ),
        Card(
          child: ListTile(
            title: Text(AppLocalizations.of(context).chatProfileDeleteChatButtonText,),
            onTap: () => _showBlockContactDialog(ChatProfileViewAction.delete),
          ),
        )
      ],
    );
  }

  _showBlockContactDialog(ChatProfileViewAction action){
    String title;
    String content;
    String positiveButtonText;
    Function positiveAction;
    Type type;

    switch(action){
      case ChatProfileViewAction.block:
        title = AppLocalizations.of(context).block;
        content = AppLocalizations.of(context).chatProfileBlockContactInfoText;
        positiveButtonText = AppLocalizations.of(context).chatProfileBlockContactButtonText;
        positiveAction = () => _blockContact();
        type = Type.contactBlockDialog;
        break;
      case ChatProfileViewAction.delete:
        title = AppLocalizations.of(context).delete;
        content = AppLocalizations.of(context).chatProfileDeleteChatInfoText;
        positiveButtonText = AppLocalizations.of(context).chatProfileDeleteChatButtonText;
        positiveAction = () => _deleteChat();
        type = Type.chatDeleteDialog;
        break;
    }

    return showConfirmationDialog(
      context: context,
      title: title,
      content: content,
      positiveButton: positiveButtonText,
      positiveAction: positiveAction,
      selfClose: false,
      navigatable: Navigatable(type),
    );
  }

  _blockContact() {
    ContactChangeBloc contactChangeBloc = ContactChangeBloc();
    contactChangeBloc.dispatch(BlockContact(widget._contactId, widget._chatId));
    navigation.popUntil(context, ModalRoute.withName(Navigation.root));
  }

  _deleteChat() {
    ChatChangeBloc chatChangeBloc = ChatChangeBloc();
    chatChangeBloc.dispatch(DeleteChat(chatId: widget._chatId));
    navigation.popUntil(context, ModalRoute.withName(Navigation.root));
  }
}