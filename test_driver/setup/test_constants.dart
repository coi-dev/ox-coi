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

import 'test_config_credential.dart';

// Credentials
String email2;
String email1;
String providerEmail;
String providerPassword;
List<Provider> providers;

const email3 = 'enyakam33@ox.com';
const mailInvalid = 'enyakam3@ox.com3';
const passwordInvalid = 'secret2';

// Login provider
const environmentProvider = 'FLUTTER_TEST_PROVIDER_TO_USE';
const providerMailCom = 'Mail.com';
const providerCoiDebug = 'Debug (mobile-qa)';
final providerDemoBetaEnvironment = "Demo / Beta Environment";

// IMap server configuration
String realServer;
final fakeIMAPCoiServer="fakeIMAPCoiServer";
final fakeSMTPCoiServer="fakeIMAPCoiServer";

// Platform info
String targetPlatform;
String targetProvider;


// User names
String name1;
String name2;

const nameMe = 'Me';
const nameNewMe = 'newMe';

// Texts / placeholders
const textEmailAddress = 'Email address';
const textName = 'Name';
const textSavedMessages = 'Saved messages';

// Input
const inputHelloWorld =
    'Hello world, hello really. Hi at world. Helllllloooo Woooooooorrrrllllldddddddd. Helllllloooo Woooooooorrrrllllldddddddd. Helllllloooo Woooooooorrrrlllllddddddddoooooooooooooooooo. ';
const inputTestMessage =
    'Test message, hello really. Hi at world. Helllllloooo Woooooooorrrrllllldddddddd. Helllllloooo Woooooooorrrrllllldddddddd. Tessssss Messageeeee Twooooooooooooooooooooooooooooooo. ';

// Message Ids
const messageIdOne = 10;
const messageIdTwo = 11;
const messageIdThree = 12;
const messageIdFour = 13;

// Finders
final pageBackFinder = find.byValueKey(keyBackOrCloseButton);
final profileFinder = find.text(L.getKey(L.profile));
final flaggedMessagesFinder = find.text(L.getKey(L.settingItemFlaggedTitle));
final contactsFinder = find.text(L.getPluralKey(L.contactP));
final chatsFinder = find.text(L.getPluralKey(L.chatP));
final signInFinder = find.text(L.getKey(L.loginSignIn));
final composeInputFinder = find.byValueKey(L.getKey(L.type));
final cancelFinder = find.byValueKey(keyConfirmationDialogCancelButton);
final createChatFinder = find.byValueKey(keyChatListCreateChatButton);
final contactAddFinder = find.byValueKey(keyContactListAddContactButton);
final userSettingsSubmitFinder = find.byValueKey(keyUserSettingsCheckIconButton);
final contactChangeNameInputFinder = find.byValueKey(keyContactChangeNameValidatableTextFormField);
final contactChangeSubmitFinder = find.byValueKey(keyContactChangeCheckIconButton);
final chatSavedMessagesFinder = find.text(textSavedMessages);
final finderMessageOne = find.byValueKey(messageIdOne);
final finderMessageTwo = find.byValueKey(messageIdTwo);
final finderMessageThree = find.byValueKey(messageIdThree);
