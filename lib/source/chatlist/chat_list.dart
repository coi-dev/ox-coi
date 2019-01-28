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
import 'package:ox_talk/source/base/base_root_child.dart';
import 'package:ox_talk/source/chatlist/chat_list_item.dart';
import 'package:ox_talk/source/data/chat_repository.dart';
import 'package:ox_talk/source/data/repository.dart';
import 'package:ox_talk/source/l10n/localizations.dart';
import 'package:ox_talk/source/ui/default_colors.dart';
import 'package:ox_talk/source/ui/dimensions.dart';

class ChatListView extends BaseRootChild {

  _ChatListState createState() => _ChatListState();

  @override
  Color getColor() {
    return DefaultColors.chatColor;
  }

  @override
  FloatingActionButton getFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      child: new Icon(Icons.create),
      onPressed: () {},
    );
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

}

class _ChatListState extends State<ChatListView> {
  Repository<Chat> chatRepository;
  List<int> chatIds = List();
  int _listenerId;

  @override
  void initState() {
    super.initState();
    setupChatLists();
    setupChatListListener();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(Dimensions.listItemPadding),
      itemCount: chatIds.length,
      itemBuilder: (BuildContext context, int index) {
        var chatId = chatIds[index];
        var _chat = chatRepository.get(chatId);
        return ChatListItem(_chat);
      },
    );
  }

  void setupChatLists() async {
    ChatList chatList = ChatList();
    int chatCount = await chatList.getChatCnt();

    chatRepository = ChatRepository(Chat.getCreator());
    if (chatCount > 0) {
      for (int i = 0; i < chatCount; i++) {
        int chatId = await chatList.getChat(i);
        chatIds.add(chatId);
      }
    }

    chatRepository.putIfAbsent(ids: chatIds);

    setState(() {});
  }

  void setupChatListListener() async {
    DeltaChatCore core = DeltaChatCore();
    _listenerId = await core.listen(Dc.eventChatModified, _success);
  }

  void _success(Event event) {
    chatIds.clear();
    setState(() {});
    setupChatLists();
  }

  @override
  void dispose() {
    super.dispose();
    tearDownChatListListener();
  }

  void tearDownChatListListener() {
    DeltaChatCore core = DeltaChatCore();
    core.removeListener(Dc.eventChatModified, _listenerId);
  }
}
