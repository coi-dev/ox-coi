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
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/chat/chat.dart';
import 'package:ox_coi/src/chat/chat_create_mixin.dart';
import 'package:ox_coi/src/message/message_item_bloc.dart';
import 'package:ox_coi/src/message/message_item_event_state.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/widgets/avatar_list_item.dart';

class InviteItem extends StatefulWidget {
  final int chatId;
  final int messageId;

  InviteItem({@required this.chatId, @required this.messageId, key}) : super(key: key);

  @override
  _InviteItemState createState() => _InviteItemState();
}

class _InviteItemState extends State<InviteItem> with ChatCreateMixin {
  MessageItemBloc _messageItemBloc = MessageItemBloc();
  Navigation navigation = Navigation();

  @override
  void initState() {
    super.initState();
    _messageItemBloc.add(LoadMessage(chatId: widget.chatId, messageId: widget.messageId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _messageItemBloc,
      builder: (context, state) {
        String name;
        String preview;
        Color color;
        int timestamp = 0;
        if (state is MessageItemStateSuccess) {
          MessageStateData messageStateData = state.messageStateData;
          name = messageStateData.contactStateData.address;
          preview = messageStateData.preview;
          timestamp = messageStateData.timestamp;
          color = CustomTheme.of(context).primary;
        } else {
          name = "";
          preview = "";
        }
        return AvatarListItem(
          title: name,
          subTitle: preview,
          color: color,
          timestamp: timestamp,
          onTap: inviteItemTapped,
          isInvite: true,
        );
      },
    );
  }

  inviteItemTapped(String name, String message) {
    navigation.push(
      context,
      MaterialPageRoute(
        builder: (context) => Chat(
          chatId: widget.chatId,
          messageId: widget.messageId,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageItemBloc.close();
    super.dispose();
  }
}
