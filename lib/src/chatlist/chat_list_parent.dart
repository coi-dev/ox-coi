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
import 'package:ox_talk/src/chat/chat_change_bloc.dart';
import 'package:ox_talk/src/chat/chat_change_event.dart';
import 'package:ox_talk/src/chatlist/chat_list.dart';
import 'package:ox_talk/src/chatlist/invite_list.dart';
import 'package:ox_talk/src/l10n/localizations.dart';
import 'package:ox_talk/src/main/root_child.dart';
import 'package:ox_talk/src/message/message_list_bloc.dart';
import 'package:ox_talk/src/message/message_list_event.dart';
import 'package:ox_talk/src/message/message_list_state.dart';
import 'package:ox_talk/src/navigation/navigatable.dart';
import 'package:ox_talk/src/navigation/navigation.dart';
import 'package:ox_talk/src/utils/colors.dart';
import 'package:ox_talk/src/utils/dialog_builder.dart';
import 'package:ox_talk/src/utils/dimensions.dart';

class ChatListParent extends RootChild {
  final Navigation navigation = Navigation();

  ChatListParent(State<StatefulWidget> state) : super(state);

  @override
  _ChatListViewState createState() {
    final state = _ChatListViewState();
    setActions([]);
    return state;
  }

  @override
  Color getColor() {
    return chatMain;
  }

  @override
  FloatingActionButton getFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      child: new Icon(Icons.create),
      onPressed: () {
        _showCreateChatView(context);
      },
    );
  }

  _showCreateChatView(BuildContext context) {
    navigation.pushNamed(context, Navigation.chatCreate);
  }

  @override
  String getTitle(BuildContext context) {
    return AppLocalizations.of(context).chatTitle;
  }

  @override
  String getNavigationText(BuildContext context) {
    return AppLocalizations.of(context).chatTitle;
  }

  @override
  IconData getNavigationIcon() {
    return Icons.chat;
  }

  @override
  getElevation() {
    return zero;
  }
}

class _ChatListViewState extends State<ChatListParent> with SingleTickerProviderStateMixin {
  TabController controller;
  bool _isMultiSelect = false;
  MessageListBloc _messagesBloc = MessageListBloc();
  ChatChangeBloc _chatChangeBloc = ChatChangeBloc();
  List<int> _selectedChats;

  @override
  void initState() {
    super.initState();
    _messagesBloc.dispatch(RequestMessages(1));
    controller = TabController(length: 2, vsync: this);
    _isMultiSelect = false;
    _selectedChats = List();
  }

  @override
  void dispose() {
    _messagesBloc.dispose();
    super.dispose();
  }

  Widget getDeleteAction() {
    return _isMultiSelect
        ? IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(),
          )
        : Container();
  }

  Widget getCancelAction() {
    return _isMultiSelect
        ? IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () => _cancelMultiSelect(),
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        PhysicalModel(
          elevation: appBarElevationDefault,
          color: chatMain,
          child: TabBar(
            tabs: <Widget>[
              Tab(
                child: Text(
                  "Chats",
                ),
              ),
              Tab(
                child: BlocBuilder(
                  bloc: _messagesBloc,
                  builder: (context, state) {
                    var inviteString = AppLocalizations.of(context).invites;
                    var bigDot = AppLocalizations.of(context).bigDot;
                    if (state is MessagesStateSuccess && state.messageIds.length > 0) {
                      inviteString = "$inviteString  $bigDot";
                    }
                    return Text(inviteString);
                  },
                ),
              ),
            ],
            controller: controller,
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: controller,
            children: <Widget>[
              ChatList(_switchMultiSelect, _itemTapped, _isMultiSelect),
              InviteList(),
            ],
          ),
        )
      ],
    );
  }

  _switchMultiSelect(int chatId) {
    setState(() {
      if (_isMultiSelect) {
        _isMultiSelect = false;
        widget.state.setState(() {
          widget.setActions([]);
        });
      } else {
        _isMultiSelect = true;
        _selectedChats.clear();
        _selectedChats.add(chatId);
        widget.state.setState(() {
          widget.setActions([getDeleteAction(), getCancelAction()]);
        });
      }
    });
  }

  _itemTapped(int chatId) {
    if (_selectedChats.contains(chatId)) {
      _selectedChats.remove(chatId);
    } else {
      _selectedChats.add(chatId);
    }
  }

  _showDeleteDialog() {
    if (_selectedChats != null && _selectedChats.length > 0) {
      showConfirmationDialog(
        context: context,
        title: AppLocalizations.of(context).chatListDeleteChatsDialogTitleText,
        content: AppLocalizations.of(context).chatListDeleteChatsInfoText,
        positiveButton: AppLocalizations.of(context).delete,
        positiveAction: () => _deleteSelectedChats(),
        navigatable: Navigatable(Type.chatDeleteDialog),
      );
    }
  }

  _deleteSelectedChats() {
    _chatChangeBloc.dispatch(DeleteChats(chatIds: _selectedChats));
    _switchMultiSelect(null);
  }

  _cancelMultiSelect() {
    _switchMultiSelect(null);
  }
}
