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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ox_talk/src/l10n/messages_all.dart';

class AppLocalizations {
  static get supportedLocales => [
        const Locale('en', 'US'),
      ];

  static Future<AppLocalizations> load(Locale locale) {
    final String name = locale.countryCode == null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return new AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  //add new translations here
  //call 'flutter pub pub run intl_translation:extract_to_arb --output-dir=lib/source/l10n lib/source/l10n/localizations.dart' in the terminal
  //copy intl_messages.arb and create language specific intl_[language_code].arb files (e.g. intl_en.arb) and translate the file
  //call flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/source/l10n \ --no-use-deferred-loading lib/source/l10n/localizations.dart lib/source/l10n/intl_*.arb
  //translation complete

  // No translation
  String get sslTls => 'SSL/TLS';

  String get startTLS => 'StartTLS';

  String get bigDot => '\u2B24';

  // No translation + DCC default values which should get adjusted
  String get coreChatStatusDefaultValue => "Sent with my Delta Chat Messenger: https://delta.chat";

  // Global
  String get yes => Intl.message('Yes', name: 'yes');

  String get no => Intl.message('No', name: 'no');

  String get delete => Intl.message('Delete', name: 'delete');

  String get import => Intl.message('Import', name: 'import');

  String get advanced => Intl.message('Advanced', name: 'advanced');

  String get inbox => Intl.message('Inbox', name: 'inbox');

  String get outbox => Intl.message('Outbox', name: 'outbox');

  String get emailAddress => Intl.message('Email address', name: 'emailAddress');

  String get password => Intl.message('Password', name: 'password');

  String get automatic => Intl.message('Automatic', name: 'automatic');

  String get off => Intl.message('Off', name: 'off');

  String get name => Intl.message('Name', name: 'name');

  String get ok => Intl.message('Ok', name: 'ok');

  String get cancel => Intl.message('Cancel', name: 'cancel');

  String get block => Intl.message('Block', name: 'block');

  String get unblock => Intl.message('Unblock', name: 'unblock');

  String get gallery => Intl.message('Gallery', name: 'gallery');

  String get camera => Intl.message('Camera', name: 'camera');

  String get invites => Intl.message('Invites', name: 'invites');

  String get chats => Intl.message('Chats', name: 'chats');

  String get video => Intl.message('Video', name: 'video');

  String get image => Intl.message('Image', name: 'image');

  String get poll => Intl.message('Poll', name: 'poll');

  String get location => Intl.message('Location', name: 'location');

  String get file => Intl.message('File', name: 'file');

  String get gif => Intl.message('GIF', name: 'gif');

  String get pdf => Intl.message('PDF', name: 'pdf');

  // Core
  String get coreChatNoMessages => Intl.message('No messages', name: 'coreChatNoMessages');

  String get coreSelf => Intl.message('Me', name: 'coreSelf');

  String get coreDraft => Intl.message('Draft', name: 'coreDraft');

  String get coreMembers => Intl.message('%1\$d member(s)', name: 'createChatWith');

  String get coreContacts => Intl.message('%1\$d contact(s)', name: 'createChatWith');

  String get coreVoiceMessage => Intl.message('Voice message', name: 'coreVoiceMessage');

  String get coreContactRequest => Intl.message('Contact request', name: 'coreContactRequest');

  String get coreImage => Intl.message('Image', name: 'coreImage');

  String get coreVideo => Intl.message('Video', name: 'coreVideo');

  String get coreAudio => Intl.message('Audio', name: 'coreAudio');

  String get coreFile => Intl.message('File', name: 'coreFile');

  String get coreGroupHelloDraft => Intl.message('Hello, I\'ve just created this group for us', name: 'coreGroupHelloDraft');

  String get coreGroupNameChanged => Intl.message('Group name changed', name: 'coreGroupNameChanged');

  String get coreGroupImageChanged => Intl.message('Group image changed', name: 'coreGroupImageChanged');

  String get coreGroupMemberAdded => Intl.message('Member added', name: 'coreGroupMemberAdded');

  String get coreGroupMemberRemoved => Intl.message('Member removed', name: 'coreGroupMemberRemoved');

  String get coreGroupLeft => Intl.message('Group left', name: 'coreGroupLeft');

  String get coreGenericError => Intl.message('Error: ', name: 'coreGenericError');

  String get coreGif => Intl.message('Gif', name: 'coreGif');

  String get coreMessageCannotDecrypt => Intl.message(
      'This message cannot be decrypted.\n\n'
      '• It might already help to simply reply to this message and ask the sender to send the message again.\n\n'
      '• In case you re-installed OX Talk or another email program on this or another device you may want to send an Autocrypt Setup Message from there.',
      name: 'coreMessageCannotDecrypt');

  String get coreReadReceiptSubject => Intl.message('Read receipt', name: 'coreReadReceiptSubject');

  String get coreReadReceiptBody => Intl.message(
      'This is a read receipt.\n\nIt means the message was displayed on the recipient\'s device, not necessarily that the content was read.',
      name: 'coreReadReceiptBody');

  String get coreGroupImageDeleted => Intl.message('Group image deleted', name: 'coreGroupImageDeleted');

  String get coreContactVerified => Intl.message('Contact verified', name: 'coreContactVerified');

  String get coreContactNotVerified => Intl.message('Cannot verify contact', name: 'coreContactNotVerified');

  String get coreContactSetupChanged => Intl.message('Changed setup for contact', name: 'coreContactSetupChanged');

  String get coreArchivedChats => Intl.message('Archived chats', name: 'coreArchivedChats');

  String get coreAutoCryptSetupSubject => Intl.message('Autocrypt Setup Message', name: 'coreAutoCryptSetupSubject');

  String get coreAutoCryptSetupBody => Intl.message(
      'This is the Autocrypt Setup Message used to transfer your end-to-end setup between clients.\n\n'
      'To decrypt and use your setup, open the message in an Autocrypt-compliant client and enter the setup code presented on the generating device.',
      name: 'coreAutoCryptSetupBody');

  String get coreChatSelf => Intl.message('Messages I sent to myself', name: 'coreChatSelf');

  String get coreLoginErrorCannotLogin =>
      Intl.message('Cannot login. Please check if the email-address and the password are correct.', name: 'coreLoginErrorCannotLogin');

  String get coreLoginErrorServerResponse => Intl.message(
      'Response from %1\$s: %1\$2\n\n'
      'Some providers place additional information in your inbox; you can check them it eg. in the web frontend. Consult your provider or friends if you run into problems.',
      name: 'coreLoginErrorServerResponse');

  String get coreActionByUser => Intl.message('%1\$s by %1\$2', name: 'coreActionByUser');

  String get coreActionByMe => Intl.message('%1\$s by me', name: 'coreActionByMe');

  // Form
  String get validatableTextFormFieldHintInvalidEmail =>
      Intl.message('Please enter a valid e-mail address', name: 'validatableTextFormFieldHintInvalidEmail');

  String get validatableTextFormFieldHintInvalidPort =>
      Intl.message('Please enter a valid port (1-65535)', name: 'validatableTextFormFieldHintInvalidPort');

  String get validatableTextFormFieldHintInvalidPassword =>
      Intl.message('Please enter your password', name: 'validatableTextFormFieldHintInvalidPassword');

  String get validatableTextFormFieldHintEmptyString => Intl.message('This field can not be empty', name: 'validatableTextFormFieldHintEmptyString');

  // Login
  String get loginTitle => Intl.message('Login to OX Talk', name: 'loginTitle');

  String get loginInformation => Intl.message(
      'For known email providers additional settings are setup automatically. Sometimes IMAP needs to be enabled in the web frontend. Consult your email provider or friends for help.',
      name: 'loginInformation');

  String get loginHintEmail => Intl.message('Enter your email address', name: 'loginLabelEmail');

  String get loginHintPassword => Intl.message('Enter your password', name: 'loginHintPassword');

  String get loginLabelImapName => Intl.message('IMAP login-name', name: 'loginLabelImapName');

  String get loginLabelImapPassword => Intl.message('IMAP password', name: 'loginLabelImapPassword');

  String get loginLabelImapServer => Intl.message('IMAP server', name: 'loginLabelImapServer');

  String get loginLabelImapPort => Intl.message('IMAP port', name: 'loginLabelImapPort');

  String get loginLabelImapSecurity => Intl.message('IMAP Security', name: 'loginLabelImapSecurity');

  String get loginLabelSmtpName => Intl.message('SMTP login-name', name: 'loginLabelSmtpName');

  String get loginLabelSmtpPassword => Intl.message('SMTP password', name: 'loginLabelSmtpPassword');

  String get loginLabelSmtpServer => Intl.message('SMTP server', name: 'loginLabelSmtpServer');

  String get loginLabelSmtpPort => Intl.message('SMTP port', name: 'loginLabelSmtpPort');

  String get loginLabelSmtpSecurity => Intl.message('SMTP Security', name: 'loginLabelSmtpSecurity');

  String get loginProgressMessage => Intl.message('Logging in, this may take a moment', name: 'loginProgressMessage');

  String get loginErrorDialogTitle => Intl.message('Login failed', name: 'loginErrorDialogTitle');

  // Mail
  String get mailTitle => Intl.message('Mail', name: 'mailTitle');

  // Chat / chat list / invite list
  String get chatTitle => Intl.message('Chat', name: 'chatTitle');

  String get composePlaceholder => Intl.message('Type something...', name: 'composePlaceholder');

  String get inviteEmptyList => Intl.message('No invites', name: 'inviteEmptyList');

  String get chatListEmpty => Intl.message('No chats', name: 'chatListEmpty');

  String get recordingAudioMessageFailure => Intl.message('Audio recording failed, missing permissions', name: 'recordingAudioMessageFailure');

  String get recordingVideoMessageFailure => Intl.message('Video recording failed, missing permissions', name: 'recordingVideoMessageFailure');

  //Chat profile view
  String get chatProfileBlockContactButtonText => Intl.message('Block contact', name: 'chatProfileBlockContactButtonText');

  // Create chat
  String get createChatTitle => Intl.message('Create chat', name: 'createChatTitle');

  String get createChatNewContactButtonText => Intl.message('New contact', name: 'createChatNewContactButtonText');

  String get createChatCreateGroupButtonText => Intl.message('Create group', name: 'createChatCreateGroupButtonText');

  String createChatWith(name) => Intl.message('Start a chat with $name?', name: 'createChatWith', args: [name]);

  // Group
  String get createGroupTitle => Intl.message('Create group chat', name: 'createGroupTitle');

  String get createGroupTextFieldLabel => Intl.message('Group name', name: 'createGroupTextFieldLabel');

  String get createGroupTextFieldHint => Intl.message('Set a group name', name: 'createGroupTextFieldHint');

  String get createGroupSelectContactsInfo => Intl.message('Select all contacts for this group', name: 'createGroupSelectContactsInfo');

  // Contact
  String get contactTitle => Intl.message('Contacts', name: 'contactTitle');

  String get contactChangeAddTitle => Intl.message('Add Contact', name: 'contactChangeAddTitle');

  String get contactChangeAddToast => Intl.message('Contact successfully added', name: 'contactChangeAddToast');

  String get contactChangeEditTitle => Intl.message('Edit Name', name: 'contactChangeEditTitle');

  String get contactChangeEditToast => Intl.message('Contact successfully edited', name: 'contactChangeEditToast');

  String get contactChangeDeleteTitle => Intl.message('Delete Contact', name: 'contactChangeDeleteTitle');

  String get contactChangeDeleteToast => Intl.message('Contact successfully deleted', name: 'contactChangeDeleteToast');

  String get contactChangeDeleteFailedToast => Intl.message('Could not delete contact.', name: 'contactChangeDeleteFailedToast');

  String contactChangeDeleteDialogContent(email, name) =>
      Intl.message('Do you really want to delete $email ($name)?', name: 'contactChangeDeleteDialogContent', args: [email, name]);

  String get contactChangeNameHint => Intl.message('Enter the contact name', name: 'contactChangeNameHint');

  String get contactImportDialogTitle => Intl.message('Import system contacts', name: 'contactImportDialogTitle');

  String get contactImportDialogContent => Intl.message('Would you like to import your system contacts?', name: 'contactImportDialogContent');

  String get contactImportDialogContentExtensionInitial =>
      Intl.message('This action can be also done later via the import button in the top action bar.', name: 'contactImportDialogContent');

  String get contactImportDialogContentExtensionRepeat =>
      Intl.message('Re-importing your contacts will not create duplicates.', name: 'contactImportDialogContent');

  String contactImportSuccess(count) => Intl.message('$count system contacts imported', name: 'contactImportSuccess', args: [count]);

  String get contactImportFailure => Intl.message('Import failed, missing permissions', name: 'contactImportFailure');

  //BlockedContacts
  String get blockedContactsTitle => Intl.message('Blocked contacts', name: 'blockedContactsTitle');

  String get unblockDialogTitle => Intl.message('Unblock contact', name: 'unblockDialogTitle');

  String unblockDialogText(name) => Intl.message('Do you want to unblock $name?', name: 'unblockDialogText', args: [name]);

  String get blockedListEmpty => Intl.message('No blocked contacts', name: 'blockedListEmpty');

  // Profile
  String get profileTitle => Intl.message('Profile', name: 'profileTitle');

  String get profileUsernamePlaceholder => Intl.message('No username set', name: 'profileUsernamePlaceholder');

  String get profileStatusPlaceholder => Intl.message('No status set', name: 'profileStatusPlaceholder');

  String get profileEditButton => Intl.message('Edit profile', name: 'profileEditButton');

  // User settings
  String get editUserSettingsTitle => Intl.message('Edit user settings', name: 'editUserSettingsTitle');

  String get editUserSettingsUsernameLabel => Intl.message('Username', name: 'editUserSettingsUsernameLabel');

  String get editUserSettingsStatusLabel => Intl.message('Status', name: 'editUserSettingsStatusLabel');

  String get editUserSettingsSaveButton => Intl.message('Save', name: 'editUserSettingsSaveButton');

  String get editUserSettingsStatusDefaultValue =>
      Intl.message('Sent with OX Talk - https://github.com/open-xchange/ox-talk', name: 'editUserSettingsStatusDefaultValue');

  String get editUserSettingsRemoveImage => Intl.message('Remove current image', name: 'editUserSettingsRemoveImage');

  // Account settings
  String get editAccountSettingsTitle => Intl.message('Edit account settings', name: 'editAccountSettingsTitle');

  String get editAccountDataProgressMessage => Intl.message('Applying new settings, this may take a moment', name: 'editAccountDataProgressMessage');

  String get editAccountSettingsSuccess => Intl.message('Account settings succesfully changed', name: 'editAccountSettingsSuccess');

  String get editAccountSettingsErrorDialogTitle => Intl.message('Configuration change aborted', name: 'editAccountSettingsErrorDialogTitle');

}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    //TODO: add new locales here like: return ['en', 'es', 'de'].contains(locale.languageCode);
    return ['en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
