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
import 'package:flutter_driver/flutter_driver.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';

const realEmail = 'enyakam@ox.com';

const fakeInvalidEmail = 'enyakam3@ox.com3';

const fakeValidEmail = 'enyakam33@ox.com';

const fakePassword = 'secret2';

const realPassword = 'secret';

const coiDebug = 'Debug (mobile-qa)';

const meContact = 'Me';

const emailAddress = 'Email address';

const name = 'Name';

const newTestEmail02 = 'enyakam2@ox.com';

const newTestEmail04 = 'enyakam4@ox.com';

const newTestName01 = 'Douglas01';

const newTestName02 = 'Douglas02';

const newMe = 'newMe';

const mailCom = 'Mail.com';

const helloWorld = 'Hello world';

final typeSomethingComposePlaceholderFinder = find.byValueKey(L.getKey(L.type));

final profileFinder = find.text(L.getKey(L.profile));

final pageBack = find.pageBack();

final helloWorldFinder = find.text(helloWorld);

final contactsFinder = find.text(L.getPluralKey(L.contactP));

final chatsFinder = find.text(L.getPluralKey(L.chatP));

final signInFinder = find.text(L.getKey(L.loginSignIn));

final cancelFinder = find.byValueKey(keyConfirmationDialogCancelButton);

final createChatFinder = find.byValueKey(keyChatListCreateChatButton);

final personAddFinder = find.byValueKey(keyContactListAddContactButton);

final userSettingsCheckIconButtonFinder = find.byValueKey(keyUserSettingsCheckIconButton);

final keyContactChangeNameFinder = find.byValueKey(keyContactChangeNameValidatableTextFormField);

final keyContactChangeCheckFinder = find.byValueKey(keyContactChangeCheckIconButton);



