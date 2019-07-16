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

import 'dart:io';

import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/conversion.dart';

import 'message_item_event_state.dart';

class MessageData extends InheritedWidget {
  final Color backgroundColor;
  final Color textColor;
  final Color secondaryTextColor;
  final String time;
  final bool showPadlock;
  final int state;
  final String text;
  final AttachmentWrapper attachment;

  MessageData({
    Key key,
    @required this.backgroundColor,
    @required this.textColor,
    this.secondaryTextColor,
    this.time,
    this.showPadlock,
    this.state,
    this.text,
    this.attachment,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static MessageData of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(MessageData) as MessageData;
  }
}

class MessageElevated extends StatelessWidget {
  final BorderRadius borderRadius;
  final Widget child;

  const MessageElevated({Key key, @required this.borderRadius, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: messagesElevation,
      borderRadius: borderRadius,
      color: MessageData.of(context).backgroundColor,
      textStyle: TextStyle(color: MessageData.of(context).textColor),
      child: Padding(
        padding: const EdgeInsets.all(messagesInnerPadding),
        child: child,
      ),
    );
  }
}

class MessageText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: Text(
            MessageData.of(context).text,
            style: Theme.of(context).textTheme.subhead.apply(color: MessageData.of(context).textColor),
          ),
        ),
        Padding(padding: EdgeInsets.only(left: messagesContentTimePadding)),
        MessagePartTime(),
        MessagePartPadlock(),
        MessagePartState(),
      ],
    );
  }
}

class MessageAttachment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MessageData.of(context).attachment.type == ChatMsg.typeImage ? MessagePartImageAttachment() : MessagePartGenericAttachment();
  }
}

class MessagePartImageAttachment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    File file = File(MessageData.of(context).attachment.path);
    String text = MessageData.of(context).text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image.file(file),
        text.isNotEmpty ? Padding(padding: EdgeInsets.only(top: messagesContentTimePadding)) : Container(),
        text.isNotEmpty ? Flexible(child: Text(text)) : Container(),
        Padding(padding: EdgeInsets.only(top: messagesContentTimePadding)),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            MessagePartTime(),
            MessagePartPadlock(),
            MessagePartState(),
          ],
        ),
      ],
    );
  }
}

class MessagePartGenericAttachment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AttachmentWrapper attachment = MessageData.of(context).attachment;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.attach_file,
          size: messagesFileIconSize,
          color: MessageData.of(context).textColor,
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                attachment.filename,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
              Text(byteToPrintableSize(attachment.size)),
            ],
          ),
        ),
        Padding(padding: EdgeInsets.only(left: messagesContentTimePadding)),
        MessagePartTime(),
        MessagePartPadlock(),
        MessagePartState(),
      ],
    );
  }
}

class MessagePartTime extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(MessageData.of(context).time, style: TextStyle(color: MessageData.of(context).secondaryTextColor));
  }
}

class MessagePartPadlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: MessageData.of(context).showPadlock,
      child: Padding(
        padding: EdgeInsets.only(left: iconTextPadding, bottom: iconPadlockBottomPadding),
        child: Icon(
          Icons.lock,
          size: iconPadlockSize,
          color: MessageData.of(context).secondaryTextColor,
        ),
      ),
    );
  }
}

class MessagePartState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    switch (MessageData.of(context).state) {
      case ChatMsg.messageStateDelivered:
        return Padding(
          padding: EdgeInsets.only(left: iconTextPadding),
          child: Icon(
            Icons.done,
            size: 14.0,
            color: MessageData.of(context).secondaryTextColor,
          ),
        );
        break;
      case ChatMsg.messageStateReceived:
        return Padding(
          padding: EdgeInsets.only(left: iconTextPadding),
          child: Icon(
            Icons.done_all,
            size: 14.0,
            color: MessageData.of(context).secondaryTextColor,
          ),
        );
        break;
      default:
        return Container();
    }
  }
}
