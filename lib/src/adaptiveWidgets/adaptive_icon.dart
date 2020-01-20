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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'adaptive_widget.dart';

enum IconSource {
  flag,
  phone,
  close,
  check,
  add,
  delete,
  mic,
  camera,
  videocam,
  send,
  search,
  arrowForward,
  importContacts,
  block,
  back,
  contentCopy,
  settings,
  error,
  image,
  videoLibrary,
  pictureAsPdf,
  gif,
  insertDriveFile,
  groupAdd,
  chat,
  mail,
  person,
  personAdd,
  lock,
  photo,
  cameraAlt,
  clear,
  arrowBack,
  group,
  verifiedUser,
  edit,
  reportProblem,
  attachFile,
  done,
  doneAll,
  accountCircle,
  notifications,
  https,
  security,
  info,
  bugReport,
  addAPhoto,
  visibility,
  visibilityOff,
  contacts,
  forward,
  share,
  play,
  pending,
  retry,
  checkedCircle,
  circle,
  darkMode,
  qr,
  signature,
  serverSetting,
  feedback,
}

class AdaptiveIcon extends AdaptiveWidget<Icon, Icon> {
  final double size;
  final Color color;
  final IconSource icon;
  final iconData = {
    // No star icon in CupertinoIcons
    IconSource.flag: [Icons.star, Icons.star],
    IconSource.phone: [CupertinoIcons.phone_solid, Icons.phone],
    IconSource.check: [IconData(0xf383, fontFamily: CupertinoIcons.iconFont, fontPackage: CupertinoIcons.iconFontPackage), Icons.check],
    IconSource.close: [CupertinoIcons.clear_thick, Icons.clear],
    IconSource.add: [IconData(0xf2C7, fontFamily: CupertinoIcons.iconFont, fontPackage: CupertinoIcons.iconFontPackage), Icons.add],
    IconSource.delete: [CupertinoIcons.delete_solid, Icons.delete],
    IconSource.mic: [IconData(0xf2EC, fontFamily: CupertinoIcons.iconFont, fontPackage: CupertinoIcons.iconFontPackage), Icons.mic],
    IconSource.camera: [IconData(0xf2D3, fontFamily: CupertinoIcons.iconFont, fontPackage: CupertinoIcons.iconFontPackage), Icons.camera_alt],
    IconSource.videocam: [CupertinoIcons.video_camera_solid, Icons.videocam],
    IconSource.send: [CupertinoIcons.forward, Icons.send],
    IconSource.search: [IconData(0xf4A4, fontFamily: CupertinoIcons.iconFont, fontPackage: CupertinoIcons.iconFontPackage), Icons.search],
    IconSource.arrowForward: [CupertinoIcons.forward, Icons.arrow_forward],
    IconSource.importContacts: [CupertinoIcons.person_add_solid, Icons.import_contacts],
    IconSource.block: [IconData(0xf2E3, fontFamily: CupertinoIcons.iconFont, fontPackage: CupertinoIcons.iconFontPackage), Icons.block],
    IconSource.back: [CupertinoIcons.back, Icons.arrow_back],
    IconSource.contentCopy: [CupertinoIcons.collections, Icons.content_copy],
    IconSource.settings: [IconData(0xf4C3, fontFamily: CupertinoIcons.iconFont, fontPackage: CupertinoIcons.iconFontPackage), Icons.settings],
    // No error icon in CupertinoIcons
    IconSource.error: [Icons.priority_high, Icons.priority_high],
    // No image icon in CupertinoIcons
    IconSource.image: [Icons.image, Icons.image],
    // No video library icon in CupertinoIcons
    IconSource.videoLibrary: [Icons.video_library, Icons.video_library],
    // No picture as pdf icon in CupertinoIcons
    IconSource.pictureAsPdf: [Icons.picture_as_pdf, Icons.picture_as_pdf],
    // No gif icon in CupertinoIcons
    IconSource.gif: [Icons.gif, Icons.gif],
    // No file icon in CupertinoIcons
    IconSource.insertDriveFile: [Icons.insert_drive_file, Icons.insert_drive_file],
    IconSource.groupAdd: [CupertinoIcons.group_solid, Icons.group_add],
    IconSource.chat: [IconData(0xf3FC, fontFamily: CupertinoIcons.iconFont, fontPackage: CupertinoIcons.iconFontPackage), Icons.chat],
    IconSource.mail: [CupertinoIcons.mail_solid, Icons.mail],
    IconSource.person: [CupertinoIcons.person_solid, Icons.person],
    IconSource.personAdd: [CupertinoIcons.person_add_solid, Icons.person_add],
    IconSource.lock: [CupertinoIcons.padlock_solid, Icons.lock],
    // No photo icon in CupertinoIcons
    IconSource.photo: [Icons.photo, Icons.photo],
    IconSource.cameraAlt: [CupertinoIcons.photo_camera_solid, Icons.camera_alt],
    IconSource.clear: [CupertinoIcons.clear_thick, Icons.clear],
    IconSource.arrowBack: [CupertinoIcons.back, Icons.arrow_back],
    IconSource.group: [CupertinoIcons.group_solid, Icons.group],
    // No verified user icon in CupertinoIcons
    IconSource.verifiedUser: [Icons.verified_user, Icons.verified_user],
    IconSource.edit: [CupertinoIcons.pen, Icons.edit],
    // No report problem icon in CupertinoIcons
    IconSource.reportProblem: [Icons.report_problem, Icons.report_problem],
    // No attach file icon in CupertinoIcons
    IconSource.attachFile: [Icons.attach_file, Icons.attach_file],
    // No done icon in CupertinoIcons
    IconSource.done: [Icons.done, Icons.done],
    // No done all icon in CupertinoIcons
    IconSource.doneAll: [Icons.done_all, Icons.done_all],
    // No account circle icon in CupertinoIcons
    IconSource.accountCircle: [Icons.account_circle, Icons.account_circle],
    // No notifications icon in CupertinoIcons
    IconSource.notifications: [Icons.notifications, Icons.notifications],
    // No https icon in CupertinoIcons
    IconSource.https: [Icons.https, Icons.https],
    // No security icon in CupertinoIcons
    IconSource.security: [Icons.security, Icons.security],
    IconSource.info: [IconData(0xf44d, fontFamily: CupertinoIcons.iconFont, fontPackage: CupertinoIcons.iconFontPackage), Icons.info],
    // No bug report icon in CupertinoIcons
    IconSource.bugReport: [Icons.bug_report, Icons.bug_report],
    // No add a photo icon in CupertinoIcons
    IconSource.addAPhoto: [Icons.add_a_photo, Icons.add_a_photo],
    // No visibility icon in CupertinoIcons
    IconSource.visibility: [Icons.visibility, Icons.visibility],
    // No visibility off icon in CupertinoIcons
    IconSource.visibilityOff: [Icons.visibility_off, Icons.visibility_off],
    IconSource.contacts: [IconData(0xf2D9, fontFamily: CupertinoIcons.iconFont, fontPackage: CupertinoIcons.iconFontPackage), Icons.contacts],
    IconSource.forward: [CupertinoIcons.forward, Icons.forward],
    IconSource.share: [CupertinoIcons.share, Icons.share],
    IconSource.play: [CupertinoIcons.play_arrow_solid, Icons.play_arrow],
    IconSource.pending : [Icons.hourglass_empty, Icons.hourglass_empty],
    IconSource.retry : [Icons.autorenew, Icons.autorenew],
    IconSource.checkedCircle : [Icons.check_circle, Icons.check_circle],
    IconSource.circle : [Icons.radio_button_unchecked, Icons.radio_button_unchecked],
    IconSource.darkMode : [Icons.brightness_2, Icons.brightness_2],
    IconSource.qr : [Icons.filter_center_focus, Icons.filter_center_focus],
    IconSource.signature : [Icons.gesture, Icons.gesture],
    IconSource.serverSetting : [Icons.router, Icons.router],
    IconSource.feedback : [Icons.feedback, Icons.feedback],
  };

  AdaptiveIcon({
    Key key,
    this.size,
    this.color,
    @required this.icon,
  }) : super(childKey: key);

  @override
  Icon buildMaterialWidget(BuildContext context) {
    return Icon(
      getIconData(icon),
      size: size,
      color: color,
      key: childKey,
    );
  }

  @override
  Icon buildCupertinoWidget(BuildContext context) {
    return Icon(
      getIconData(icon),
      size: size,
      color: color,
      key: childKey,
    );
  }

  IconData getIconData(IconSource iconDataSet) {
    var icon = iconData[iconDataSet];
    return Platform.isIOS ? icon[0] : icon[1];
  }
}
