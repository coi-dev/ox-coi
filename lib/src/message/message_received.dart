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
import 'package:flutter/widgets.dart';
import 'package:ox_coi/src/message/message_builder.dart';
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/date.dart';
import 'package:ox_coi/src/widgets/avatar.dart';

import 'message_item_event_state.dart';

class MessageReceived extends StatelessWidget {
  final String name;
  final String email;
  final Color color;
  final String text;
  final int timestamp;
  final bool hasFile;
  final bool isGroupChat;
  final bool isFlagged;
  final AttachmentWrapper attachmentWrapper;

  const MessageReceived(
      {Key key, this.name, this.email, this.color, this.text, this.timestamp, this.hasFile, this.isGroupChat, this.isFlagged, this.attachmentWrapper})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String time = getTimeFormTimestamp(timestamp);
    return FractionallySizedBox(
      alignment: Alignment.topLeft,
      widthFactor: 0.8,
      child: MessageData(
        backgroundColor: surface,
        textColor: onSurface,
        secondaryTextColor: onSurface.withOpacity(fade),
        borderRadius: buildBorderRadius(),
        time: time,
        text: text,
        attachment: attachmentWrapper,
        isFlagged: isFlagged,
        isGroup: isGroupChat,
        isSent: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Visibility(
              visible: isGroupChat,
              child: Padding(
                padding: const EdgeInsets.only(right: messagesHorizontalPadding),
                child: Avatar(
                  textPrimary: name,
                  textSecondary: email,
                  color: color,
                  size: 34.0,
                ),
              ),
            ),
            Flexible(
              child: MessageMaterial(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    isGroupChat
                        ? Padding(
                            padding: EdgeInsets.only(
                                top: messagesVerticalPadding,
                                bottom: 2.0,
                                left: messagesHorizontalInnerPadding,
                                right: messagesHorizontalInnerPadding),
                            child: Text(
                              name.isNotEmpty ? name : email,
                              style: TextStyle(color: color),
                            ),
                          )
                        : Container(constraints: BoxConstraints(maxWidth: zero)),
                    hasFile ? MessageAttachment() : MessageText(),
                  ],
                ),
              ),
            ),
            MessagePartFlag(),
          ],
        ),
      ),
    );
  }

  BorderRadius buildBorderRadius() {
    return BorderRadius.only(
      topRight: Radius.circular(messagesBoxRadius),
      topLeft: Radius.circular(messagesBoxRadiusSmall),
      bottomRight: Radius.circular(messagesBoxRadius),
      bottomLeft: Radius.circular(messagesBoxRadius),
    );
  }
}
