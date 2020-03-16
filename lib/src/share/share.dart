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
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon.dart';
import 'package:ox_coi/src/chat/chat.dart';
import 'package:ox_coi/src/chatlist/chat_list_item.dart';
import 'package:ox_coi/src/contact/contact_item.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/message/message_action.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/share/share_bloc.dart';
import 'package:ox_coi/src/share/share_event_state.dart';
import 'package:ox_coi/src/share/shared_data.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/key_generator.dart';
import 'package:ox_coi/src/widgets/dynamic_appbar.dart';
import 'package:ox_coi/src/widgets/state_info.dart';

class Share extends StatefulWidget {
  final List<int> msgIds;
  final MessageActionTag messageActionTag;
  final SharedData sharedData;

  Share({this.msgIds, this.messageActionTag, this.sharedData});

  @override
  _ShareState createState() => _ShareState();
}

class _ShareState extends State<Share> {
  ShareBloc _shareBloc = ShareBloc();

  @override
  void initState() {
    super.initState();
    _shareBloc.add(RequestChatsAndContacts());
  }

  @override
  void dispose() {
    _shareBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: widget.messageActionTag == MessageActionTag.forward ? L10n.get(L.forward) : L10n.get(L.share),
        leading: AppBarBackButton(context: context),
      ),
      body: _buildShareList(),
    );
  }

  Widget _buildShareList() {
    return BlocBuilder(
      bloc: _shareBloc,
      builder: (context, state) {
        if (state is ShareStateSuccess) {
          if (state.chatAndContactIds.length > 0) {
            return buildListView(state);
          } else {
            return Container();
          }
        } else if (state is ShareStateLoading) {
          return StateInfo(showLoading: true);
        } else {
          return AdaptiveIcon(icon: IconSource.error);
        }
      },
    );
  }

  Widget buildListView(ShareStateSuccess state) {
    return ListView.builder(
      padding: EdgeInsets.only(top: listItemPadding),
      itemCount: state.chatAndContactIds.length,
      itemBuilder: (BuildContext context, int index) {
        var chatAndContactIds = state.chatAndContactIds;
        if (state.chatIdCount > 0 && index < state.chatIdCount) {
          var chatId = chatAndContactIds[index];
          var key = createKeyFromId(chatId);
          if (index == 0) {
            return createChatItemWithHeader(chatId);
          } else {
            return ChatListItem(
              chatId: chatId,
              onTap: chatItemTapped,
              switchMultiSelect: null,
              isMultiSelect: false,
              isShareItem: true,
              key: key,
            );
          }
        } else if (state.contactIdCount > 0 && index >= state.chatIdCount) {
          var contactId = chatAndContactIds[index];
          if (index == state.chatIdCount) {
            return createContactItemWithHeader(contactId);
          } else {
            final int previousContactId = (index > state.chatIdCount) ? chatAndContactIds[index - 1] : null;
            return ContactItem(
              contactId: contactId,
              previousContactId: previousContactId,
              contactItemType: ContactItemType.forward,
              onTap: chatItemTapped,
              key: Key(contactId.toString()),
            );
          }
        }
        return Container();
      },
    );
  }

  chatItemTapped(int chatId) {
    Navigation navigation = Navigation();
    if (widget.messageActionTag == MessageActionTag.forward) {
      _shareBloc.add(ForwardMessages(destinationChatId: chatId, messageIds: widget.msgIds));
    }

    navigation.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => Chat(
          chatId: chatId,
          sharedData: widget.sharedData,
        ),
      ),
      ModalRoute.withName(Navigation.root),
      Navigatable(Type.rootChildren),
    );
  }

  Widget createChatItemWithHeader(int chatId) {
    var key = createKeyFromId(chatId);
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            L10n.get(L.chatP, count: L10n.plural),
            style: Theme.of(context).textTheme.headline,
          ),
          ChatListItem(chatId: chatId, onTap: chatItemTapped, switchMultiSelect: null, isMultiSelect: false, isShareItem: true, key: key),
        ],
      ),
    );
  }

  Widget createContactItemWithHeader(int contactId) {
    return Padding(
      padding: EdgeInsets.only(top: listItemPadding),
      child: Column(
        children: <Widget>[
          Text(
            L10n.get(L.contactP, count: L10n.plural),
            style: Theme.of(context).textTheme.headline,
          ),
          ContactItem(
            contactId: contactId,
            contactItemType: ContactItemType.forward,
            onTap: chatItemTapped,
            key: Key(contactId.toString()),
            previousContactId: null,
          ),
        ],
      ),
    );
  }
}
