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
import 'package:ox_coi/src/message/message_item_state.dart';
import 'package:ox_coi/src/utils/conversion.dart';
import 'package:ox_coi/src/utils/dimensions.dart';
import 'package:ox_coi/src/utils/styles.dart';

mixin MessageBuilder {
  Widget buildTextMessage(String text, String time, bool showPadlock, [int state]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: Text(
            text,
            style: defaultText,
          ),
        ),
        Padding(padding: EdgeInsets.only(left: messagesContentTimePadding)),
        buildTime(time),
        _buildPadlock(showPadlock),
        _buildStateMarker(state),
      ],
    );
  }

  Widget _buildStateMarker(int state) {
    switch(state){
      case ChatMsg.messageStateDelivered:
        return Padding(
          padding: EdgeInsets.only(left: iconTextPadding),
          child: Icon(Icons.done, size: 14.0,),
        );
        break;
      case ChatMsg.messageStateReceived:
        return Padding(
          padding: EdgeInsets.only(left: iconTextPadding),
          child: Icon(Icons.done_all, size: 14.0,),
        );
        break;
      default:
        return Container();
    }
  }

  Widget _buildPadlock(bool showPadlock) {
    return Visibility(
      visible: showPadlock,
      child: Padding(
        padding: EdgeInsets.only(left: iconTextPadding, bottom: iconPadlockBottomPadding),
        child: Icon(Icons.lock, size: iconPadlockSize,),
      ),
    );
  }

  StatelessWidget buildTime(String time) {
    return Text(time, style: messageTimeText);
  }

  Widget buildAttachmentMessage(AttachmentWrapper attachment, String text, String time, [int state]) {
    return Container(
      child: attachment.type == ChatMsg.typeImage
          ? buildImageAttachmentMessage(attachment, text, time, state)
          : buildGenericAttachmentMessage(attachment, time, state),
    );
  }

  Widget buildImageAttachmentMessage(AttachmentWrapper attachment, String text, String time, [int state]) {
    File file = File(attachment.path);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image.file(file),
        text.isNotEmpty ? Padding(padding: EdgeInsets.only(top: messagesContentTimePadding)) : Container(),
        text.isNotEmpty
            ? Flexible(
                child: Text(text),
              )
            : Container(),
        Padding(padding: EdgeInsets.only(top: messagesContentTimePadding)),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            buildTime(time),
            _buildStateMarker(state),
          ],
        ),
      ],
    );
  }

  Row buildGenericAttachmentMessage(AttachmentWrapper attachment, String time, [int state]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.attach_file,
          size: messagesFileIconSize,
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
        buildTime(time),
        _buildStateMarker(state),
      ],
    );
  }

  BoxDecoration buildBoxDecoration(Color shadowColor, Color backgroundColor, BorderRadius borderRadius) {
    return BoxDecoration(
      shape: BoxShape.rectangle,
      boxShadow: [
        new BoxShadow(
          color: shadowColor,
          blurRadius: messagesBlurRadius,
        ),
      ],
      color: backgroundColor,
      borderRadius: borderRadius,
    );
  }

}
