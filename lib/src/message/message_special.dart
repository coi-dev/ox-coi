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
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/date.dart';

import 'message_builder.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon.dart';

enum MessageSpecialType { setup, encryptionStatusChanged, info }

class MessageSpecial extends StatelessWidget {
  final MessageSpecialType type;
  final String messageText;
  final int timestamp;

  const MessageSpecial({Key key, this.type, this.messageText, this.timestamp}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (type == MessageSpecialType.setup) {
      return MessageSetup(timestamp: timestamp);
    } else if (type == MessageSpecialType.encryptionStatusChanged) {
      return MessageInfo(
        messageText: L10n.get(L.chatEncryptionStatusChanged),
        icon: AdaptiveIcon(
            icon: IconSource.lock
        ),
      );
    } else if (type == MessageSpecialType.info) {
      return MessageInfo(messageText: messageText);
    }
    throw ArgumentError("Type is not supported, please choose a valid MessageSpecialType");
  }
}

class MessageSetup extends StatelessWidget {
  final int timestamp;

  const MessageSetup({Key key, this.timestamp}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.topRight,
      widthFactor: 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          MessageData(
            backgroundColor: secondary,
            textColor: onSecondary,
            secondaryTextColor: onSecondary.withOpacity(fade),
            borderRadius: buildInfoBorderRadius(),
            time: getTimeFormTimestamp(timestamp),
            text: L10n.get(L.autocryptChatMessagePlaceholder),
            child: MessageMaterial(
              child: MessageText(),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageInfo extends StatelessWidget {
  final String messageText;
  final AdaptiveIcon icon;

  const MessageInfo({Key key, this.messageText, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: Center(
          child: MessageData(
            backgroundColor: info,
            textColor: onInfo,
            borderRadius: buildInfoBorderRadius(),
            text: messageText,
            icon: icon,
            child: MessageMaterial(
              elevation: zero,
              child: MessageStatus(),
            ),
          ),
        ),
      ),
    );
  }
}

BorderRadius buildInfoBorderRadius() {
  return BorderRadius.all(Radius.circular(messagesBoxRadius));
}
