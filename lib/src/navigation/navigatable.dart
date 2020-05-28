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

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

enum Type {
  addAttachmentModal,
  antiMobbingList,
  changeProfilePhotoModal,
  chat,
  chatAddGroupParticipants,
  chatCreate,
  chatCreateGroupParticipants,
  chatCreateGroupSettings,
  chatDeleteDialog,
  chatGroupProfile,
  chatList,
  chatListInviteDialog,
  chatListInviteErrorDialog,
  chatLeaveGroupDialog,
  chatProfile,
  contactAdd,
  contactChange,
  contactListBlocked,
  contactList,
  contactBlockDialog,
  contactDeleteDialog,
  contactGooglemailDetectedDialog,
  contactImportDialog,
  contactInviteDialog,
  contactProfile,
  contactUnblockDialog,
  contactStartCallDialog,
  contactNoNumberDialog,
  debugViewer,
  editGroupProfile,
  flagged,
  gallery,
  login,
  loginProviderList,
  loginManualSettings,
  loginProviderSignIn,
  loginErrorDialog,
  logout,
  messageFailedDialog,
  messageInfoDialog,
  onboarding,
  passwordChanged,
  profile,
  rootChildren,
  search,
  settings,
  settingsAccount,
  settingsAbout,
  settingsDataProtection,
  settingsChat,
  settingsDebug,
  settingsSecurity,
  settingsSignature,
  settingsUser,
  settingsExportKeysDialog,
  settingsImportKeysDialog,
  settingsKeyTransferDialog,
  settingsKeyTransferDoneDialog,
  settingsAutocryptImport,
  settingsNotifications,
  settingsAppearance,
  splash,
  share,
  showQr,
  scanQr,
  webAsset,
}

class Navigatable {
  final Type type;

  List params;

  String get tag => describeEnum(type);

  Navigatable(this.type, {this.params});

  equal(Navigatable other) {
    if (other == null) {
      return false;
    }
    bool equal = equalType(other);
    if (equal) {
      equal = ListEquality().equals(params, other.params);
    }
    return equal;
  }

  bool equalType(Navigatable other) => type == other.type;

  static String getTag(Type type, [String subTag]) => describeEnum(type) + getSubTag(subTag);

  static String getSubTag(String subTag) => subTag ?? "";
}
