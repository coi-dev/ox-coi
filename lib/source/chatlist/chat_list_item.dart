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
import 'package:ox_talk/source/chat/chat.dart';
import 'package:ox_talk/source/ui/dimensions.dart';

class ChatListItem extends StatefulWidget
{
  final Chat _chat;

  ChatListItem(this._chat);

  @override
  _ChatListItemState createState() => _ChatListItemState();
}

class _ChatListItemState  extends State<ChatListItem>
{
  String _name;
  String _subtitle;

  @override
  void initState() {
    super.initState();
    setupChatItem();
  }

  void setupChatItem() async {
    _name = await widget._chat.getName();
    _subtitle = await widget._chat.getSubtitle();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
  return GestureDetector(
    onTap:() => chatItemTapped(),
    child: Padding(
    padding: const EdgeInsets.only(top: Dimensions.listItemPaddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 24.0,
            child: Text(getInitial()),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.listItemPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: _name != null ? Text(
                          _name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),
                        ) : Container(),
                      ),
                    ],
                  ),
                  _subtitle != null ?
                  Text(_subtitle)
                      : Container(),
                  Divider(),
                ],
              ),
            ),
          )
        ],
      ),
    )
  );
  }

  String getInitial() {
    if (_name != null && _name.isNotEmpty) {
      return _name.substring(0, 1);
    }
    return "";
  }

  chatItemTapped() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(widget._chat)),
    );
  }
}