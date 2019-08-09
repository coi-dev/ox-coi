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

import 'package:flutter/widgets.dart';
import 'package:ox_coi/src/ui/strings.dart';

import 'l.dart';
import 'l10n.dart';

Map<int, String> getStringMap(BuildContext context) {
  return {
    1: L10n.get(L.chatNoMessages),
    2: L10n.get(L.me),
    3: L10n.get(L.draft),
    4: L10n.get(L.coreMembers),
    6: L10n.get(L.coreContacts),
    7: L10n.get(L.voiceMessage),
    8: L10n.get(L.contactRequest),
    9: L10n.get(L.image),
    10: L10n.get(L.video),
    11: L10n.get(L.audio),
    12: L10n.get(L.file),
    13: "${L10n.get(L.profileDefaultStatus)}: $feedbackUrl",
    14: L10n.get(L.groupNewDraft),
    15: L10n.get(L.groupNameChanged),
    16: L10n.get(L.groupImageChanged),
    17: L10n.get(L.memberAdded),
    18: L10n.get(L.memberRemoved),
    19: L10n.get(L.groupLeft),
    20: L10n.get(L.error),
    23: gif,
    29: L10n.get(L.errorCannotDecrypt),
    31: L10n.get(L.settingReadReceiptP),
    32: L10n.get(L.readReceiptText),
    33: L10n.get(L.groupImageDeleted),
    35: L10n.get(L.contactVerifiedSuccess),
    36: L10n.get(L.contactVerifyFailed),
    37: L10n.get(L.contactSetupChanged),
    40: L10n.get(L.chatArchived),
    42: L10n.get(L.autocryptSetupMessage),
    43: L10n.get(L.autocryptSetupText),
    50: L10n.get(L.chatMessagesSelf),
    60: L10n.get(L.loginErrorWrongCredentials),
    61: L10n.get(L.loginErrorResponseXY),
    62: L10n.get(L.byXY),
    63: L10n.get(L.byMeX)
  };
}
