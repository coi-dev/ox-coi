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
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/conversion.dart';
import 'package:ox_coi/src/utils/date.dart';
import 'package:transparent_image/transparent_image.dart';

import 'message_item_event_state.dart';

class MessageData extends InheritedWidget {
  final Color backgroundColor;
  final Color textColor;
  final Color secondaryTextColor;
  final String time;
  final int state;
  final String text;
  final Icon icon;
  final AttachmentWrapper attachment;
  final BorderRadius borderRadius;
  final bool isFlagged;
  final bool isGroup;
  final bool isSent;

  MessageData({
    Key key,
    @required this.backgroundColor,
    @required this.textColor,
    @required this.borderRadius,
    this.secondaryTextColor,
    this.time,
    this.state,
    this.text,
    this.icon,
    this.attachment,
    this.isFlagged = false,
    this.isGroup = false,
    this.isSent,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static MessageData of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(MessageData) as MessageData;
  }
}

class MessageMaterial extends StatelessWidget {
  final Widget child;
  final double elevation;

  const MessageMaterial({Key key, @required this.child, this.elevation = messagesElevation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      borderRadius: MessageData.of(context).borderRadius,
      color: MessageData.of(context).backgroundColor,
      textStyle: TextStyle(color: MessageData.of(context).textColor),
      child: child,
    );
  }
}

class MessageText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: getNamePaddingForGroups(context),
      child: Text(
        MessageData.of(context).text,
        style: Theme.of(context).textTheme.subhead.apply(color: MessageData.of(context).textColor),
      ),
    );
  }
}

class MessageStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Icon icon = MessageData.of(context).icon;
    if (icon != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: messagesVerticalInnerPadding, horizontal: messagesHorizontalInnerPadding),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: iconTextPadding),
              child: icon,
            ),
            Flexible(
              child: Text(
                MessageData.of(context).text,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: messagesVerticalInnerPadding, horizontal: messagesHorizontalInnerPadding),
        child: Text(
          MessageData.of(context).text,
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}

class MessageAttachment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return isImage(context) ? MessagePartImageAttachment() : MessagePartGenericAttachment();
  }
}

bool isImage(BuildContext context) {
  final attachment = MessageData.of(context).attachment;
  return attachment != null && attachment.type == ChatMsg.typeImage;
}

class MessagePartImageAttachment extends StatefulWidget {
  @override
  _MessagePartImageAttachmentState createState() => _MessagePartImageAttachmentState();
}

class _MessagePartImageAttachmentState extends State<MessagePartImageAttachment> {
  ImageProvider imageProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    File file = File(MessageData.of(context).attachment.path);
    imageProvider = FileImage(file);
    precacheImage(imageProvider, context, onError: (error, stacktrace) {
      setState(() {
        imageProvider = MemoryImage(kTransparentImage);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var text = MessageData.of(context).text;
    BorderRadius imageBorderRadius = getImageBorderRadius(context, text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AspectRatio(
          child: ClipRRect(
            borderRadius: imageBorderRadius,
            child: Image(
              image: imageProvider,
              fit: BoxFit.fitWidth,
            ),
          ),
          aspectRatio: 4 / 3,
        ),
        Visibility(
          visible: text.isNotEmpty,
          child: Flexible(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: messagesVerticalPadding,
                  bottom: messagesVerticalInnerPadding,
                  left: messagesHorizontalInnerPadding,
                  right: messagesHorizontalInnerPadding),
              child: Text(text),
            ),
          ),
        ),
      ],
    );
  }

  BorderRadius getImageBorderRadius(BuildContext context, String text) {
    var messageBorderRadius = MessageData.of(context).borderRadius;
    if (MessageData.of(context).isGroup && !MessageData.of(context).isSent && text.isNotEmpty) {
      messageBorderRadius = BorderRadius.zero;
    } else if (MessageData.of(context).isGroup && !MessageData.of(context).isSent && text.isEmpty) {
      messageBorderRadius = BorderRadius.only(bottomLeft: messageBorderRadius.bottomLeft, bottomRight: messageBorderRadius.bottomRight);
    } else if (text.isNotEmpty) {
      messageBorderRadius = BorderRadius.only(topLeft: messageBorderRadius.topLeft, topRight: messageBorderRadius.topRight);
    }
    return messageBorderRadius;
  }
}

class MessagePartGenericAttachment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var text = MessageData.of(context).text;
    AttachmentWrapper attachment = MessageData.of(context).attachment;
    return Padding(
      padding: getNamePaddingForGroups(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: iconTextPadding),
                child: Icon(
                  Icons.attach_file,
                  size: messagesFileIconSize,
                  color: MessageData.of(context).textColor,
                ),
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
            ],
          ),
          Visibility(
            visible: text.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.only(top: messagesVerticalInnerPadding),
              child: Text(text),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageDateTime extends StatelessWidget {
  final int timestamp;
  final bool hasDateMarker;
  final bool showTime;

  const MessageDateTime({Key key, @required this.timestamp, this.hasDateMarker = false, this.showTime = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String date;
    if (hasDateMarker && showTime) {
      date = "${getDateFromTimestamp(timestamp, true, true)} - ${getTimeFormTimestamp(timestamp)}";
    } else if (hasDateMarker) {
      date = getDateFromTimestamp(timestamp, true, true);
    } else {
      date = getTimeFormTimestamp(timestamp);
    }
    return Center(
      child: Text(
        date,
        style: TextStyle(
          color: onSurface.withOpacity(fade),
        ),
      ),
    );
  }
}

class MessagePartTime extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      MessageData.of(context).time,
      style: TextStyle(color: MessageData.of(context).secondaryTextColor),
    );
  }
}

class MessagePartState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    switch (MessageData.of(context).state) {
      case ChatMsg.messageStateDelivered:
        return Padding(
          padding: EdgeInsets.only(top: 10.0, left: iconTextPadding),
          child: Icon(
            Icons.done,
            size: 16.0,
            color: MessageData.of(context).secondaryTextColor,
          ),
        );
        break;
      case ChatMsg.messageStateReceived:
        return Padding(
          padding: EdgeInsets.only(top: 10.0, left: iconTextPadding),
          child: Icon(
            Icons.done_all,
            size: 16.0,
            color: MessageData.of(context).secondaryTextColor,
          ),
        );
        break;
      default:
        return Container(
          width: 20.0,
        );
    }
  }
}

class MessagePartFlag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: MessageData.of(context).isFlagged,
      child: Padding(
        padding: EdgeInsets.only(top: 8.0, right: 4.0, left: 4.0),
        child: Icon(
          Icons.star,
          color: Colors.yellow,
        ),
      ),
    );
  }
}

EdgeInsetsGeometry getNamePaddingForGroups(BuildContext context) {
  if (MessageData.of(context).isGroup) {
    return EdgeInsets.only(
      top: 2.0,
      bottom: messagesVerticalInnerPadding,
      left: messagesHorizontalInnerPadding,
      right: messagesHorizontalInnerPadding,
    );
  } else {
    return EdgeInsets.symmetric(vertical: messagesVerticalInnerPadding, horizontal: messagesHorizontalInnerPadding);
  }
}
