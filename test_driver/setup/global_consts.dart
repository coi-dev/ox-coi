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

const timeout = Duration(seconds: 120);

const realEmail = 'enyakam3@ox.com';

const fakeEmail = 'enyakam3@ox.com3';

const fakePassword = 'secret2';

const testUserNameUserProfile = 'EDN tester';

const realPassword = 'secret';

const coiDebug = 'Debug (mobile-qa)';

const meContact = 'Me';

const emailAddress = 'Email address';

const newContact = 'New contact';

const name = 'Name';

const enterContactName = 'Enter the contact name';

const emptyChat = 'This is a new chat. Send a message to connect.';

const profile = 'Profile';

const chat = 'Chats';

const contacts = 'Contacts';

const blockContact = 'Block contact';

const unblock = 'Unblock';

const newTestContact01 = 'enyakam1@ox.com';

const newTestContact02 = 'enyakam2@ox.com';

const newTestContact04 = 'enyakam4@ox.com';

const newTestName01 = 'Douglas01';

const newTestName02 = 'Douglas02';

const newMe = 'newMe';

const mailCom = 'Mail.com';

const profileUserStatus = 'Sent with OX COI Messenger - https://github.com/open-xchange/ox-coi';

const searchString = 'Douglas0';

const typeSomethingComposePlaceholder = 'Type something...';

const helloWorld = 'Hello word';

final typeSomethingComposePlaceholderFinder = find.byValueKey(typeSomethingComposePlaceholder);

final chatWelcomeMessage = L.getKey(L.chatListPlaceholder);

final coiDebugProviderFinder = find.text(coiDebug);

final chatWelcomeFinder = find.text(chatWelcomeMessage);

final profileFinder = find.text(profile);

final pageBack = find.pageBack();

final helloWorldFinder = find.text(helloWorld);

final contactsFinder = find.text(contacts);

final chatsFinder = find.text(chat);

final signInFinder = find.text(L.getKey(L.loginSignIn).toUpperCase());

final providerEmailFinder = find.byValueKey(keyProviderSignInEmailTextField);

final providerPasswordFinder = find.byValueKey(keyProviderSignInPasswordTextField);

final cancelFinder = find.byValueKey(keyDialogBuilderCancelFlatButton);

final createChatFinder = find.byValueKey(keyChatListChatFloatingActionButton);

final personAddFinder = find.byValueKey(keyContactListPersonAddFloatingActionButton);

final userProfileEditRaisedButtonFinder = find.byValueKey(keyUserProfileEditProfileRaisedButton);

final userSettingsCheckIconButtonFinder = find.byValueKey(keyUserSettingsCheckIconButton);

final positiveFinder = find.byValueKey(keyDialogBuilderPositiveFlatButton);

final keyContactChangeNameFinder = find.byValueKey(keyContactChangeNameValidatableTextFormField);

final keyContactChangeEmailFinder = find.byValueKey(keyContactChangeEmailValidatableTextFormField);

final keyContactChangeCheckFinder = find.byValueKey(keyContactChangeCheckIconButton);

final keyDialogBuilderAlertDialogOkFlatButtonFinder = find.byValueKey(keyDialogBuilderAlertDialogOkFlatButton);
