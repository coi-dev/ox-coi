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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/extensions/color_apis.dart';
import 'package:ox_coi/src/extensions/url_apis.dart';
import 'package:ox_coi/src/message/message_item_event_state.dart';
import 'package:ox_coi/src/ui/dimensions.dart';

class UrlPreview extends StatelessWidget {
  final MessageStateData messageStateData;

  const UrlPreview({Key key, @required this.messageStateData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Uri previewUri = Uri.parse(messageStateData.urlPreviewData.url);
    final descriptionLength = messageStateData.urlPreviewData.description.length;
    final teaserTextLength = 100;
    final teaserText = messageStateData.urlPreviewData.description.substring(0, (descriptionLength > teaserTextLength ? teaserTextLength : descriptionLength));

    final cachedImage = CachedNetworkImage(
      imageUrl: messageStateData.urlPreviewData.image,
    );

    return GestureDetector(
      onTap: () => previewUri.launch(),
      child: Column(
        children: [
          Container(
            child: cachedImage,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: dimension8dp,
                horizontal: dimension8dp
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    messageStateData.urlPreviewData.title,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: CustomTheme.of(context).onSurface,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  child: Text(
                    "$teaserText …",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: CustomTheme.of(context).onSurface.fade(),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(top: dimension8dp),
                        child: Text(
                          previewUri.host,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: CustomTheme.of(context).onSurface.slightly(),
                          ),
                        ),
                      ),
                    )

                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
