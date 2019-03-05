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
import 'package:ox_talk/src/utils/dimensions.dart';

class MailListItem extends StatelessWidget {
  const MailListItem(this.mail);

  final Mail mail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: listItemPaddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: CircleAvatar(
              radius: 24.0,
              child: Text(mail.name.substring(0, 1)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: listItemPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          mail.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0),
                        ),
                      ),
                      Text(
                        mail.time,
                        style: TextStyle(color: Colors.black45),
                      ),
                    ],
                  ),
                  Text(
                    mail.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: listItemPaddingSmall),
                    child: Text(
                      mail.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.black45),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: listItemPaddingSmall),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        getMailStarredStateWidget(),
                        getMailAttachmentStateWidget(),
                        getMailForwardWidget(),
                        getMailReplyWidget(),
                      ],
                    ),
                  ),
                  Divider(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  StatelessWidget getMailStarredStateWidget() {
    return mail.starred
        ? Icon(
            Icons.star,
            color: Colors.yellow,
          )
        : Container();
  }

  StatelessWidget getMailAttachmentStateWidget() {
    return mail.attachment
        ? Icon(
            Icons.attachment,
            color: Colors.black45,
          )
        : Container();
  }

  StatelessWidget getMailForwardWidget() {
    return mail.forward
        ? Icon(
            Icons.forward,
            color: Colors.black45,
          )
        : Container();
  }

  StatelessWidget getMailReplyWidget() {
    return mail.reply
        ? Icon(
            Icons.reply,
            color: Colors.black45,
          )
        : Container();
  }
}

//TODO Remove dummy mail class
class Mail {
  final String name;

  final String subject;

  final String message;

  final bool starred;

  final bool attachment;

  final bool forward;

  final bool reply;

  final String time = "15:22";

  Mail(this.name, this.subject, this.message, this.starred, this.attachment, this.forward, this.reply);
}
