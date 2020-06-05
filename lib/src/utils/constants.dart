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

// App
enum AppState {
  initialStartDone,
  initialLoginDone,
}

// Delta Chat Core - the core places the file in the apps folder structure under ~/files/$dbName
const dbName = "messenger.db";
const maxAttachmentSize = 100 * 1024 * 1024; // Means 100 MB

// Extension database - the file is placed in the apps folder structure under ~/databases/$extensionDbName
const extensionDbName = "extension.db";

// External services
const defaultCoiPushServiceUrl = "https://push.coi.me/push/resource/";
const defaultCoiInviteServiceUrl = "https://invite.coi.me/invite/";

// Paths, filenames, extensions / URLs
const appLogoPath = 'assets/images/app_logo.png';
const thumbnailFileExtension = '.jpg';
const customerConfigPath = "assets/customer/json/config.json";
const customerOnboardingConfigPath = "assets/customer/json/onboarding.json";
const projectUrl = "https://coi.me";
const issueUrl  = "https://github.com/open-xchange/ox-coi/issues";
const featureRequestUrl = "https://openxchange.userecho.com/communities/4-ox-coi-messenger";
const kNotificationChannelMainId = 'com.android.oxcoi.notification.single';
const kNotificationChannelGroupId = 'com.android.oxcoi.notification.group';

// IMAP https://tools.ietf.org/html/rfc5530
const imapErrorAuthenticationFailed = '[AUTHENTICATIONFAILED]';

// Errors
const contactAddGeneric = "contactDelete-generic";
const contactDeleteGeneric = "contactDelete-generic";
const contactDeleteChatExists = "contactDelete-chatExists";

// Miscellaneous
const googlemailDomain = '@googlemail';
const gmailDomain = '@gmail';
