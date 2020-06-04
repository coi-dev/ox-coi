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
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/chat/chat.dart';
import 'package:ox_coi/src/chat/chat_bloc.dart';
import 'package:ox_coi/src/chat/chat_event_state.dart';
import 'package:ox_coi/src/extensions/string_markdown.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/widgets/avatar_list_item.dart';

class ChatListItem extends StatefulWidget {
  final int chatId;
  final Function onTap;
  final Function switchMultiSelect;
  final bool isMultiSelect;
  final bool isShareItem;

  ChatListItem({
    @required this.chatId,
    @required this.onTap,
    @required this.switchMultiSelect,
    @required this.isMultiSelect,
    @required this.isShareItem,
    key,
  }) : super(key: key);

  @override
  _ChatListItemState createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> {
  ChatBloc _chatBloc = ChatBloc();
  Navigation navigation = Navigation();
  bool _isSelected;

  @override
  void initState() {
    super.initState();
    _chatBloc.add(RequestChat(chatId: widget.chatId));
    _isSelected = false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _chatBloc,
      builder: (context, state) {
        String name = "";
        Color color;
        int freshMessageCount = 0;
        int timestamp = 0;
        String preview;
        String imagePath = "";
        bool hasError = false;
        bool isGroupChat = false;
        bool isDeviceTalk = false;

        if (state is ChatStateSuccess) {
          name = state.name;
          color = state.color;
          freshMessageCount = state.freshMessageCount;
          timestamp = state.timestamp;
          preview = state.preview;
          imagePath = state.avatarPath;
          isGroupChat = state.isGroupChat;
          isDeviceTalk = state.isDeviceTalk;
        } else if (state is ChatStateFailure) {
          hasError = true;
        }

        return Visibility(
          visible: !hasError && !isDeviceTalk,
          child: InkWell(
            child: AvatarListItem(
              title: name,
              subTitle: preview.stripMarkdown(),
              color: color,
              imagePath: imagePath,
              freshMessageCount: freshMessageCount,
              timestamp: timestamp,
              subTitleIcon: isGroupChat
                  ? AdaptiveIcon(
                      icon: IconSource.group,
                      size: iconSize,
                    )
                  : null,
              onTap: chatItemTapped,
            ),
          ),
        );
      },
    );
  }

  chatItemTapped(String name, String subtitle) {
    if (widget.isMultiSelect) {
      setState(() {
        _isSelected = _isSelected ? false : true;
      });
      widget.onTap(widget.chatId);
    } else if (widget.isShareItem) {
      widget.onTap(widget.chatId);
    } else {
      navigation.push(
        context,
        MaterialPageRoute(
          builder: (context) => Chat(chatId: widget.chatId),
        ),
      );
    }
  }

  chatItemLongPress() {
    if (!widget.isMultiSelect) {
      setState(() {
        _isSelected = _isSelected ? false : true;
      });
      widget.onTap(widget.chatId);
      widget.switchMultiSelect(widget.chatId);
    }
  }
}
