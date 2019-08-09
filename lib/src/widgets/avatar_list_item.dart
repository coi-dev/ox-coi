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
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/date.dart';
import 'package:ox_coi/src/widgets/avatar.dart';

class AvatarListItem extends StatelessWidget {
  final String title;
  final String subTitle;
  final String imagePath;
  final Color color;
  final int freshMessageCount;
  final Function onTap;
  final Widget titleIcon;
  final Widget subTitleIcon;
  final IconData avatarIcon;
  final int timestamp;
  final bool isVerified;
  final bool isInvite;
  final bool isGroupListItem;
  final PopupMenuButton moreButton;

  AvatarListItem(
      {@required this.title,
      @required this.subTitle,
      @required this.onTap,
      this.avatarIcon,
      this.imagePath,
      this.color,
      this.freshMessageCount = 0,
      this.titleIcon,
      this.subTitleIcon,
      this.timestamp = 0,
      this.isVerified = false,
      this.isInvite = false,
      this.isGroupListItem = false,
      this.moreButton});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(title, subTitle),
      child: Container(
        padding: const EdgeInsets.only(
          left: listItemPadding,
          right: listItemPadding,
          top: listItemPaddingSmall,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            avatarIcon == null
                ? Avatar(
                    imagePath: imagePath,
                    textPrimary: title,
                    textSecondary: subTitle,
                    color: color,
                  )
                : CircleAvatar(
                    radius: listAvatarRadius,
                    foregroundColor: primary,
                    child: Icon(avatarIcon),
                  ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: iconTextPadding),
                        child: titleIcon != null ? titleIcon : Container(),
                      ),
                      Expanded(child: getTitle(context)),
                      Visibility(
                          visible: timestamp != null && timestamp != 0,
                          child: Text(
                            getChatListTime(timestamp),
                            style: TextStyle(
                                color: shouldHighlight() ? Colors.black : Colors.grey,
                                fontWeight: shouldHighlight() ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14.0),
                          )),
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(
                    vertical: listItemPaddingSmall,
                  )),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: iconTextPadding),
                        child: subTitleIcon != null ? subTitleIcon : Container(),
                      ),
                      Visibility(
                        visible: isVerified,
                        child: Padding(
                          padding: const EdgeInsets.only(right: iconTextPadding),
                          child: Icon(
                            Icons.verified_user,
                            size: iconSize,
                          ),
                        ),
                      ),
                      Expanded(child: getSubTitle(context)),
                      Visibility(
                        visible: isInvite,
                        child: Container(
                          width: 23.0,
                          padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
                          decoration: BoxDecoration(color: Colors.orangeAccent, borderRadius: BorderRadius.circular(16)),
                          child: Text(
                            "!",
                            style: TextStyle(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: hasNewMessages(),
                        child: Container(
                          padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
                          decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(16)),
                          child: Text(
                            freshMessageCount <= 99 ? freshMessageCount.toString() : "99+",
                            style: TextStyle(color: Colors.white, fontSize: 12.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  !isGroupListItem ? Padding(padding: EdgeInsets.all(8.0)) : Divider(),
                ],
              ),
            ),
            Visibility(
              visible: moreButton != null,
              child: Container(child: moreButton),
            )
          ],
        ),
      ),
    );
  }

  bool hasNewMessages() => freshMessageCount != null && freshMessageCount > 0;

  bool shouldHighlight() => isInvite || (freshMessageCount != null && freshMessageCount > 0);

  StatelessWidget getTitle(BuildContext context) {
    return Visibility(
        visible: title != null,
        child: Text(
          title != null ? title : "",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.subhead.copyWith(fontWeight: FontWeight.w500),
        ));
  }

  StatelessWidget getSubTitle(BuildContext context) {
    return Visibility(
        visible: subTitle != null,
        child: Text(
          subTitle != null ? subTitle : "",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.body1.apply(color: onBackground.withOpacity(fade)),
        ));
  }
}
