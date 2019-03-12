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
import 'package:ox_talk/src/l10n/localizations.dart';

Map<int, String> getCoreStringMap(BuildContext context) {
  return {
    1: AppLocalizations.of(context).coreChatNoMessages,
    2: AppLocalizations.of(context).coreSelf,
    3: AppLocalizations.of(context).coreDraft,
    4: AppLocalizations.of(context).coreMembers,
    6: AppLocalizations.of(context).coreContacts,
    7: AppLocalizations.of(context).coreVoiceMessage,
    8: AppLocalizations.of(context).coreContactRequest,
    9: AppLocalizations.of(context).coreImage,
    10: AppLocalizations.of(context).coreVideo,
    11: AppLocalizations.of(context).coreAudio,
    12: AppLocalizations.of(context).coreFile,
    13: AppLocalizations.of(context).coreChatStatusDefaultValue,
    14: AppLocalizations.of(context).coreGroupHelloDraft,
    15: AppLocalizations.of(context).coreGroupNameChanged,
    16: AppLocalizations.of(context).coreGroupImageChanged,
    17: AppLocalizations.of(context).coreGroupMemberAdded,
    18: AppLocalizations.of(context).coreGroupMemberRemoved,
    19: AppLocalizations.of(context).coreGroupLeft,
    20: AppLocalizations.of(context).coreGenericError,
    23: AppLocalizations.of(context).coreGif,
    29: AppLocalizations.of(context).coreMessageCannotDecrypt,
    31: AppLocalizations.of(context).coreReadReceiptSubject,
    32: AppLocalizations.of(context).coreReadReceiptBody,
    33: AppLocalizations.of(context).coreGroupImageDeleted,
    35: AppLocalizations.of(context).coreContactVerified,
    36: AppLocalizations.of(context).coreContactNotVerified,
    37: AppLocalizations.of(context).coreContactSetupChanged,
    40: AppLocalizations.of(context).coreArchivedChats,
    42: AppLocalizations.of(context).coreAutoCryptSetupSubject,
    43: AppLocalizations.of(context).coreAutoCryptSetupBody,
    50: AppLocalizations.of(context).coreChatSelf,
    60: AppLocalizations.of(context).coreLoginErrorCannotLogin,
    61: AppLocalizations.of(context).coreLoginErrorServerResponse,
    62: AppLocalizations.of(context).coreActionByUser,
    63: AppLocalizations.of(context).coreActionByMe
  };
}
