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

import 'package:flutter/material.dart';
import 'package:ox_coi/src/extensions/string_apis.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/image.dart';
import 'package:transparent_image/transparent_image.dart';

class Avatar extends StatelessWidget {
  final String imagePath;
  final String textPrimary;
  final String textSecondary;
  final Color color;
  final double size;

  Avatar({this.imagePath, @required this.textPrimary, this.textSecondary, this.color, this.size = listAvatarDiameter});

  @override
  Widget build(BuildContext context) {
    String initials = "";
    ImageProvider avatarImage;
    if (imagePath.isNullOrEmpty()) {
      avatarImage = MemoryImage(kTransparentImage);
      initials = getInitials(textPrimary, textSecondary);
    } else {
      avatarImage = FileImage(File(imagePath));
    }

    return Container(
      alignment: Alignment.center,
      constraints: BoxConstraints.expand(width: size, height: size),
      decoration: ShapeDecoration(
        shape: getSuperEllipseShape(size),
        color: color,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: avatarImage,
        ),
      ),
      child: Visibility(
        visible: imagePath.isNullOrEmpty(),
        child: Text(
          initials,
          style: Theme.of(context).textTheme.subhead.apply(color: CustomTheme.of(context).white),
        ),
      ),
    );
  }

  static String getInitials(String textPrimary, [String textSecondary]) {
    if (textPrimary != null && textPrimary.isNotEmpty) {
      return textPrimary.substring(0, 1);
    }
    if (textSecondary != null && textSecondary.isNotEmpty) {
      return textSecondary.substring(0, 1);
    }
    return "";
  }
}
