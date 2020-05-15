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

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ox_coi/src/customer/customer.dart';

enum IconSource {
  flag,
  phone,
  close,
  check,
  add,
  delete,
  mic,
  camera,
  video,
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
  pause,
  play,
  pending,
  retry,
  checkedCircle,
  circle,
  appearance,
  qr,
  signature,
  serverSetting,
  feedback,
  openLock,
  stopPlay,
  logout,
  iosChevron,
  create,
}

const iconData = {
  IconSource.flag: Icons.star,
  IconSource.phone: Icons.phone,
  IconSource.check: Icons.check,
  IconSource.close: Icons.clear,
  IconSource.add: Icons.add,
  IconSource.delete: Icons.delete,
  IconSource.mic: Icons.mic,
  IconSource.camera: Icons.camera_alt,
  IconSource.video: Icons.videocam,
  IconSource.send: Icons.send,
  IconSource.search: Icons.search,
  IconSource.arrowForward: Icons.arrow_forward,
  IconSource.importContacts: Icons.import_contacts,
  IconSource.block: Icons.block,
  IconSource.back: Icons.arrow_back,
  IconSource.contentCopy: Icons.content_copy,
  IconSource.settings: Icons.settings,
  IconSource.error: Icons.priority_high,
  IconSource.image: Icons.image,
  IconSource.videoLibrary: Icons.video_library,
  IconSource.pictureAsPdf: Icons.picture_as_pdf,
  IconSource.gif: Icons.gif,
  IconSource.insertDriveFile: Icons.insert_drive_file,
  IconSource.groupAdd: Icons.group_add,
  IconSource.chat: Icons.chat,
  IconSource.mail: Icons.mail,
  IconSource.person: Icons.person,
  IconSource.personAdd: Icons.person_add,
  IconSource.lock: Icons.lock,
  IconSource.photo: Icons.photo,
  IconSource.cameraAlt: Icons.camera_alt,
  IconSource.clear: Icons.clear,
  IconSource.arrowBack: Icons.arrow_back,
  IconSource.group: Icons.group,
  IconSource.verifiedUser: Icons.verified_user,
  IconSource.edit: Icons.edit,
  IconSource.reportProblem: Icons.report_problem,
  IconSource.attachFile: Icons.attach_file,
  IconSource.done: Icons.done,
  IconSource.doneAll: Icons.done_all,
  IconSource.accountCircle: Icons.account_circle,
  IconSource.notifications: Icons.notifications,
  IconSource.https: Icons.https,
  IconSource.security: Icons.security,
  IconSource.info: Icons.info,
  IconSource.bugReport: Icons.bug_report,
  IconSource.addAPhoto: Icons.add_a_photo,
  IconSource.visibility: Icons.visibility,
  IconSource.visibilityOff: Icons.visibility_off,
  IconSource.contacts: Icons.contacts,
  IconSource.forward: Icons.forward,
  IconSource.share: Icons.share,
  IconSource.play: Icons.play_arrow,
  IconSource.pending: Icons.hourglass_empty,
  IconSource.retry: Icons.autorenew,
  IconSource.checkedCircle: Icons.check_circle,
  IconSource.circle: Icons.radio_button_unchecked,
  IconSource.appearance: Icons.palette,
  IconSource.qr: Icons.filter_center_focus,
  IconSource.signature: Icons.gesture,
  IconSource.serverSetting: Icons.router,
  IconSource.feedback: Icons.feedback,
  IconSource.openLock : Icons.lock_open,
  IconSource.stopPlay : Icons.stop,
  IconSource.iosChevron: CupertinoIcons.right_chevron,
  IconSource.logout: Icons.add,
  IconSource.create: Icons.create,
  IconSource.pause: Icons.pause,
};

class AdaptiveIcon extends StatelessWidget {
  final double size;
  final Color color;
  final IconSource icon;

  AdaptiveIcon({
    Key key,
    this.size,
    this.color,
    @required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (_hasCustomIcon(icon)) {
      return ImageIcon(
        AssetImage(_getPath()),
        key: key,
        size: size,
        color: color,
      );
    } else {
      return Icon(
        _getIconData(icon),
        key: key,
        size: size,
        color: color,
      );
    }
  }

  bool _hasCustomIcon(IconSource icon) {
    final iconName = describeEnum(icon);
    return Customer.icons.contains(iconName);
  }

  String _getPath() => "assets/images/${describeEnum(icon)}.png";

  IconData _getIconData(IconSource iconDataSet) => iconData[iconDataSet];
}
