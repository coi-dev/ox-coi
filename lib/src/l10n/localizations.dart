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
import 'package:ox_coi/src/l10n/messages_all.dart';

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

  String get presetSslTls => 'ssltls';

  String get presetStartTLS => 'starttls';

  String get bigDot => '\u2B24';

  String get feedbackUrl => 'https://github.com/open-xchange/ox-coi';

  String get other => 'other';

  // Image path
  String get appLogoUrl => 'assets/images/app_logo.png';

  String get outlookLogoUrl => 'assets/images/outlook_icon.png';

  String get yahooLogoUrl => 'assets/images/yahoo_icon.png';

  String get gmxLogoUrl => 'assets/images/gmx_icon.png';

  String get mailboxLogoUrl => 'assets/images/mailbox_icon.png';

  String get mailcomLogoUrl => 'assets/images/mailcom_icon.png';

  String get otherProviderLogoUrl => 'assets/images/mail_icon.png';

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

  String get copiedToClipboard => Intl.message('Copied to clipboard', name: 'copiedToClipboard');

  String get today => Intl.message('Today', name: 'today');

  String get yesterday => Intl.message('Yesterday', name: 'yesterday');

  String get participants => Intl.message('Participants', name: 'participants');

  String get settings => Intl.message('Settings', name: 'settings');

  String get security => Intl.message('Security', name: 'security');

  String get forward => Intl.message('Forward', name: 'forward');

  String get share => Intl.message('Share', name: 'share');

  String get contacts => Intl.message('Contacts', name: 'contacts');

  String get about => Intl.message('About', name: 'about');

  String get feedback => Intl.message('Feedback', name: 'feedback');

  String get chat => Intl.message('Chat', name: 'chat');

  String get antiMobbing => Intl.message('Anti-Mobbing', name: 'antiMobbing');

  // Debug
  String get debugTitle => Intl.message('Debug', name: 'debugTitle');

  String get debugFcmToken => Intl.message('FCM token', name: 'debugFcmToken');

  // Core
  String get coreChatStatusDefaultValue => "Sent with my Delta Chat Messenger: https://delta.chat";

  String get coreChatNoMessages => Intl.message('No messages', name: 'coreChatNoMessages');

  String get coreSelf => Intl.message('Me', name: 'coreSelf');

  String get coreDraft => Intl.message('Draft', name: 'coreDraft');

  String get coreMembers => Intl.message('%1\$d member(s)', name: 'coreMembers');

  String get coreContacts => Intl.message('%1\$d contact(s)', name: 'coreContacts');

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
      '• In case you re-installed OX Coi or another email program on this or another device you may want to send an Autocrypt Setup Message from there.',
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
  String get loginTitle => Intl.message('Login to OX Coi', name: 'loginTitle');

  String get loginWelcomeText => Intl.message('Welcome to OX Coi', name: 'loginWelcomeText');

  String get loginFirstInformationText =>
      Intl.message('OX Coi works with any email account. If you have one, please sign in, otherwise register a new account first.',
          name: 'loginFirstInformationText');

  String get loginTermsConditionPrivacyText => Intl.message('By using OX Coi you agree to our ', name: 'loginTermsConditionPrivacyText');

  String get loginTermsConditionText => Intl.message('terms & conditions', name: 'loginTermsConditionText');

  String get loginTermsConditionPrivacyAndText => Intl.message(' and ', name: 'loginTermsConditionPrivacyAndText');

  String get loginPrivacyDeclarationText => Intl.message('privacy declaration', name: 'loginPrivacyDeclarationText');

  String get loginSignInButtonText => Intl.message('SIGN IN', name: 'loginSignInButtonText');

  String get loginRegisterButtonText => Intl.message('REGISTER', name: 'loginRegisterButtonText');

  String get loginSignInTitle => Intl.message('Sign in', name: 'loginSignInTitle');

  String get loginSignInInfoText => Intl.message('Please select your email provider to sign in', name: 'loginSignInInfoText');

  String get loginOtherMailProvider => Intl.message('Other Mail Provider', name: 'loginOtherMailProvider');

  String loginProviderSignInText(name) => Intl.message('Sign in with $name?', name: 'loginProviderSignInText', args: [name]);

  String get loginError => Intl.message('Please check your username and password', name: 'loginError');

  String get loginManualSettings => Intl.message('Manual Settings', name: 'loginManualSettings');

  String get loginManualSettingsInfoText => Intl.message('Please specify your email server settings.', name: 'loginManualSettingsInfoText');

  String get loginManualSettingsSecondInfoText => Intl.message(
      'Often you only need to provide your email address, password and server addresses. The remaining values are determined automatically. '
      'Sometimes IMAP needs to be enabled in your email website. Consult your email provider or friends for help.',
      name: 'loginManualSettingsSecondInfoText');

  String get loginManualSettingsErrorInfoText =>
      Intl.message('We could not determine all settings automatically.', name: 'loginManualSettingsErrorInfoText');

  String get loginInformation => Intl.message(
      'For known email providers additional settings are setup automatically. Sometimes IMAP needs to be enabled in the web frontend. Consult your email provider or friends for help.',
      name: 'loginInformation');

  String get loginBaseSettingsTitle => Intl.message('Base Settings', name: 'loginBaseSettingsTitle');

  String get loginServerAddressesTitle => Intl.message('Server addresses', name: 'loginServerAddressesTitle');

  String get loginAdvancedImapTitle => Intl.message('Advanced IMAP Settings', name: 'loginAdvancedImapTitle');

  String get loginAdvancedSmtpTitle => Intl.message('Advanced SMTP Settings', name: 'loginAdvancedSmtpTitle');

  String get loginHintEmail => Intl.message('Email address', name: 'loginLabelEmail');

  String get loginHintPassword => Intl.message('Password', name: 'loginHintPassword');

  String get loginLabelImapName => Intl.message('IMAP login-name', name: 'loginLabelImapName');

  String get loginLabelEmail => Intl.message('E-mail address', name: 'loginLabelEmail');

  String get loginLabelImapPassword => Intl.message('IMAP password', name: 'loginLabelImapPassword');

  String get loginLabelImapServer => Intl.message('IMAP server (e.g. imap.coi.me)', name: 'loginLabelImapServer');

  String get loginLabelImapPort => Intl.message('IMAP port', name: 'loginLabelImapPort');

  String get loginLabelImapSecurity => Intl.message('IMAP Security', name: 'loginLabelImapSecurity');

  String get loginLabelSmtpName => Intl.message('SMTP login-name', name: 'loginLabelSmtpName');

  String get loginLabelSmtpPassword => Intl.message('SMTP password', name: 'loginLabelSmtpPassword');

  String get loginLabelSmtpServer => Intl.message('SMTP server (e.g. smtp.coi.me)', name: 'loginLabelSmtpServer');

  String get loginLabelSmtpPort => Intl.message('SMTP port', name: 'loginLabelSmtpPort');

  String get loginLabelSmtpSecurity => Intl.message('SMTP Security', name: 'loginLabelSmtpSecurity');

  String get loginProgressMessage => Intl.message('Logging in, this may take a moment', name: 'loginProgressMessage');

  String get loginErrorDialogTitle => Intl.message('Login failed', name: 'loginErrorDialogTitle');

  // Register
  String get registerTitle => Intl.message('Register', name: 'registerTitle');

  String get registerText => Intl.message('Choose a provider from the list below to create a new account', name: 'registerText');

  // Mail
  String get mailTitle => Intl.message('Mail', name: 'mailTitle');

  // Chat list / invite list
  String get inviteEmptyList => Intl.message('No invites', name: 'inviteEmptyList');

  String get chatListEmpty => Intl.message('Welcome to OX Coi!\nPlease start a new chat by tapping the chat bubble icon.', name: 'chatListEmpty');

  String get chatListDeleteChatsDialogTitleText => Intl.message('Delete chats', name: 'chatListDeleteChatsDialogTitleText');

  String get chatListDeleteChatsInfoText => Intl.message('Do you want to delete these chats?', name: 'chatListDeleteChatsInfoText');

  // Flagged
  String get flaggedTitle => Intl.message('Flagged', name: 'flaggedTitle');

  String get flaggedSubTitle => Intl.message('Your favorite messages', name: 'flaggedSubTitle');

  String get flaggedEmpty => Intl.message('No flagged messages.', name: 'flaggedEmpty');

  // Chat
  String get chatTitle => Intl.message('Chat', name: 'chatTitle');

  String get composePlaceholder => Intl.message('Type something...', name: 'composePlaceholder');

  String get recordingAudioMessageFailure => Intl.message('Audio recording failed, missing permissions', name: 'recordingAudioMessageFailure');

  String get recordingVideoMessageFailure => Intl.message('Video recording failed, missing permissions', name: 'recordingVideoMessageFailure');

  String get chatEmpty => Intl.message('This is a new chat. Send a message to connect!', name: 'chatEmpty');

  String get chatInviteQuestion => Intl.message('Do you want to chat with this new contact?', name: 'chatInviteQuestion');

  // Chat profile view
  String chatProfileBlockContactContent(email, name) =>
      Intl.message('Do you really want to block $email ($name)?', name: 'chatProfileBlockContactContent', args: [email, name]);

  String get chatProfileBlockContactButtonText => Intl.message('Block contact', name: 'chatProfileBlockContactButtonText');

  String get chatProfileDeleteChatButtonText => Intl.message('Delete chat', name: 'chatProfileDeleteChatButtonText');

  String get chatProfileDeleteChatInfoText => Intl.message('Do you want to delete this chat?', name: 'chatProfileDeleteChatInfoText');

  String get chatProfileClipboardToastMessage => Intl.message('Email copied to clipboard', name: 'chatProfileClipboardToastMessage');

  String get chatProfileLeaveGroupInfoText => Intl.message('Do you really want to leave the group?', name: 'chatProfileLeaveGroupInfoText');

  String get chatProfileLeaveGroupButtonText => Intl.message('Leave group', name: 'chatProfileLeaveGroupButtonText');

  String get chatProfileAddParticipantsButtonText => Intl.message('Add participants', name: 'chatProfileAddParticipantsButtonText');

  String get chatProfileAddParticipantsEmptyList => Intl.message('All your contacts are in this chat.', name: 'chatProfileAddParticipantsEmptyList');

  String get chatProfileRemoveParticipantsButtonText => Intl.message('Remove participant', name: 'chatProfileRemoveParticipantsButtonText');

  String chatProfileGroupMemberCounter(memberCount) =>
      Intl.message('$memberCount Participant(s)', name: 'chatProfileGroupMemberCounter', args: [memberCount]);

  String get setNameTextFieldHint => Intl.message('Set a name', name: 'setNameTextFieldHint');

  String get editGroupNameTitle => Intl.message('Rename group', name: 'editGroupNameTitle');

  // Create chat
  String get createChatTitle => Intl.message('Create chat', name: 'createChatTitle');

  String get createChatNewContactButtonText => Intl.message('New contact', name: 'createChatNewContactButtonText');

  String createChatWith(name) => Intl.message('Start a chat with $name?', name: 'createChatWith', args: [name]);

  // Create group
  String get createGroupButtonText => Intl.message('Create group', name: 'createGroupButtonText');

  String get createGroupNameAndAvatarHeader => Intl.message('Group name', name: 'createChatCreateGroupNameAndAvatarHeader');

  String get createGroupNoParticipantsHint => Intl.message('Simply add one by tapping on a contact.', name: 'createGroupNoParticipantsHint');

  String get createGroupNoParticipantsSelected =>
      Intl.message('No participants selected. Please select at least one person.', name: 'createGroupNoParticipantsSelected');

  String get createGroupTitle => Intl.message('Create group chat', name: 'createGroupTitle');

  String get createGroupTextFieldLabel => Intl.message('Group name', name: 'createGroupTextFieldLabel');

  String get createGroupTextFieldHint => Intl.message('Set a group name', name: 'createGroupTextFieldHint');

  // Contacts
  String get contactChangeAddTitle => Intl.message('Add contact', name: 'contactChangeAddTitle');

  String get contactChangeAddToast => Intl.message('Contact successfully added', name: 'contactChangeAddToast');

  String get contactChangeEditTitle => Intl.message('Edit contact', name: 'contactChangeEditTitle');

  String get contactChangeEditToast => Intl.message('Contact successfully edited', name: 'contactChangeEditToast');

  String get contactChangeBlockToast => Intl.message('Contact successfully blocked', name: 'contactChangeBlockToast');

  String get contactChangeDeleteTitle => Intl.message('Delete contact', name: 'contactChangeDeleteTitle');

  String get contactChangeDeleteToast => Intl.message('Contact successfully deleted', name: 'contactChangeDeleteToast');

  String get contactChangeDeleteFailedToast => Intl.message('Could not delete contact.', name: 'contactChangeDeleteFailedToast');

  String get contactChangeDeleteBecauseChatExistsFailedToast =>
      Intl.message('Could not delete contact. Active chats with contact found, please remove first.', name: 'contactChangeDeleteFailedToast');

  String contactChangeDeleteDialogContent(email, name) =>
      Intl.message('Do you really want to delete $email ($name)?', name: 'contactChangeDeleteDialogContent', args: [email, name]);

  String get contactChangeNameHint => Intl.message('Enter the contact name', name: 'contactChangeNameHint');

  String get contactChangeScanQrButton => Intl.message('Scan QR', name: 'contactChangeScanQrButton');

  String get contactImportDialogTitle => Intl.message('Import system contacts', name: 'contactImportDialogTitle');

  String get contactImportDialogContent => Intl.message('Would you like to import your system contacts?', name: 'contactImportDialogContent');

  String get contactImportDialogContentExtensionInitial =>
      Intl.message('This action can be also done later via the import button in the top action bar.', name: 'contactImportDialogContent');

  String get contactImportDialogContentExtensionRepeat =>
      Intl.message('Re-importing your contacts will not create duplicates.', name: 'contactImportDialogContent');

  String get contactImportProgress => Intl.message('Contact import running, please wait', name: 'contactImportProgress');

  String contactImportSuccess(count) => Intl.message('$count system contacts imported', name: 'contactImportSuccess', args: [count]);

  String get contactImportFailure => Intl.message('Import failed, missing permissions', name: 'contactImportFailure');

  String get contactsSearchHint => Intl.message('Search contacts', name: 'contactsSearchHint');

  String get contactsOpenChat => Intl.message('Open chat', name: 'contactsOpenChat');

  // Blocked contacts
  String get blockedContactsTitle => Intl.message('Blocked contacts', name: 'blockedContactsTitle');

  String get unblockDialogTitle => Intl.message('Unblock contact', name: 'unblockDialogTitle');

  String unblockDialogText(name) => Intl.message('Do you want to unblock $name?', name: 'unblockDialogText', args: [name]);

  String get blockedListEmpty => Intl.message('No blocked contacts', name: 'blockedListEmpty');

  // Profile
  String get profileTitle => Intl.message('Profile', name: 'profileTitle');

  String get profileUsernamePlaceholder => Intl.message('No username set', name: 'profileUsernamePlaceholder');

  String get profileStatusPlaceholder => Intl.message('No status set', name: 'profileStatusPlaceholder');

  String get profileEditButton => Intl.message('Edit profile', name: 'profileEditButton');

  String get showQrButton => Intl.message('QR', name: 'showQrButton');

  //QR
  String get qrTitle => Intl.message('QR', name: 'qrTitle');

  String qrInviteInfoText(name) => Intl.message('Scan this code to create a verified chat with $name.', name: 'qrInviteInfoText', args: [name]);

  String get showQrTabTitle => Intl.message('Show QR', name: 'showQrTabTitle');

  String get scanQrTabTitle => Intl.message('Scan QR', name: 'scanQrTabTitle');

  String get qrErrorCancelText => Intl.message('There was an error or the progress was canceled.', name: 'qrErrorCancelText');

  String get qrProgressInfoText => Intl.message('Please wait a moment.', name: 'qrProgressInfoText');

  String get qrVerifyingText => Intl.message('Verifying. Please wait a moment.', name: 'qrVerifyingText');

  String get qrVerifyCompleteText => Intl.message('Verification finished.', name: 'qrVerifyCompleteText');

  // User settings
  String get userSettingsTitle => Intl.message('Edit user settings', name: 'userSettingsTitle');

  String get userSettingsUsernameLabel => Intl.message('Username', name: 'userSettingsUsernameLabel');

  String get userSettingsStatusLabel => Intl.message('Status', name: 'userSettingsStatusLabel');

  String get userSettingsSaveButton => Intl.message('Save', name: 'userSettingsSaveButton');

  String get userSettingsStatusDefaultValue =>
      Intl.message('Sent with OX Coi - https://github.com/open-xchange/ox-coi', name: 'userSettingsStatusDefaultValue');

  String get userSettingsRemoveImage => Intl.message('Remove current image', name: 'userSettingsRemoveImage');

  // Account settings
  String get accountSettingsTitle => Intl.message('Account settings', name: 'accountSettingsTitle');

  String get accountSettingsDataProgressMessage =>
      Intl.message('Applying new settings, this may take a moment', name: 'accountSettingsDataProgressMessage');

  String get accountSettingsSuccess => Intl.message('Account settings succesfully changed', name: 'accountSettingsSuccess');

  String get accountSettingsErrorDialogTitle => Intl.message('Configuration change aborted', name: 'accountSettingsErrorDialogTitle');

  // Security settings
  String get securitySettingsExportKeys => Intl.message('Export keys', name: 'securitySettingsExportKeys');

  String get securitySettingsExportKeysText =>
      Intl.message('This keys enable another device to use your current encryption setup. Keys are saved on your local storage',
          name: 'securitySettingsExportKeysText');

  String securitySettingsExportKeysDialog(path) =>
      Intl.message('Do you want to save your keys in "$path"?', name: 'securitySettingsExportKeysDialog', args: [path]);

  String get securitySettingsExportKeysPerforming => Intl.message('Performing key export', name: 'securitySettingsExportKeysPerforming');

  String get securitySettingsImportKeys => Intl.message('Import keys', name: 'securitySettingsImportKeys');

  String get securitySettingsImportKeysText =>
      Intl.message('Import keys from your local storage to change your current encryption setup', name: 'securitySettingsImportKeysText');

  String securitySettingsImportKeysDialog(path) =>
      Intl.message('Do you want to import your keys from "$path"? If there are no keys present in that folder, the operation will fail.',
          name: 'securitySettingsImportKeysDialog', args: [path]);

  String get securitySettingsImportKeysPerforming => Intl.message('Performing key import', name: 'securitySettingsImportKeysPerforming');

  String get securitySettingsKeyActionSuccess => Intl.message('Key action successfully done', name: 'securitySettingsKeyActionSuccess');

  String get securitySettingsKeyActionFailed => Intl.message('Key action failed', name: 'securitySettingsKeyActionFailed');

  String get securitySettingsKeyActionFailedNoPermission =>
      Intl.message('Key action failed, missing permissions', name: 'securitySettingsKeyActionFailedNoPermission');

  String get securitySettingsInitiateKeyTransfer => Intl.message('Initiate key transfer', name: 'securitySettingsInitiateKeyTransfer');

  String get securitySettingsInitiateKeyTransferPerforming =>
      Intl.message('Performing key transfer', name: 'securitySettingsInitiateKeyTransferPerforming');

  String get securitySettingsInitiateKeyTransferText =>
      Intl.message('Creates an Autocrypt Setup Message on the server, you can load on other devices to use your current encryption setup.',
          name: 'securitySettingsInitiateKeyTransferText');

  String get securitySettingsInitiateKeyTransferDialog => Intl.message(
      'An Autocrypt Setup Message securely shares your end-to-end setup with other Autocrypt-compliant apps. '
      'The setup will be encrypted by a setup code which is displayed here and must be typed on the other device',
      name: 'securitySettingsInitiateKeyTransferDialog');

  String get securitySettingsInitiateKeyTransferDone => Intl.message('Setup message created', name: 'securitySettingsInitiateKeyTransferDone');

  String securitySettingsInitiateKeyTransferDoneDialog(setupCode) => Intl.message(
      'Your key has been sent to yourself. Switch to the other device and '
      'open the setup message. You should be prompted for a setup code. '
      'Type the following digits into the prompt:\n$setupCode\n'
      'Once you\'re done, your other device will be ready to use Autocrypt.',
      name: 'securitySettingsInitiateKeyTransferDoneDialog',
      args: [setupCode]);

  String get securitySettingsInitiateKeyTransferCopy => Intl.message('Copy code', name: 'securitySettingsInitiateKeyTransferCopy');

  String get securitySettingsInitiateKeyTransferCopyDone =>
      Intl.message('Code copied to clipboard', name: 'securitySettingsInitiateKeyTransferCopyDone');

  String get securitySettingsAutocryptMessage =>
      Intl.message('This message is an Autocrypt Setup Message. Tap it to start the import process. You will be guided through the process.',
          name: 'securitySettingsAutocryptMessage');

  String get securitySettingsAutocryptImport => Intl.message('Import Autocrypt message', name: 'securitySettingsAutocryptImport');

  String get securitySettingsAutocryptImportText => Intl.message(
      'To complete the import of the Autocrypt Setup Message please provide the security code '
      'shown in a dialog during creation of the message. After entering the code below the Autocrypt settings will be applied to your current encryption setup.',
      name: 'securitySettingsAutocryptImportText');

  String get securitySettingsAutocryptImportLabel => Intl.message('Autocrypt setup code', name: 'securitySettingsAutocryptImportLabel');

  String get securitySettingsAutocryptImportHint =>
      Intl.message('The code can be entered with or without minus signs', name: 'securitySettingsAutocryptImportHint');

  String securitySettingsAutocryptImportCodeHint(setupCodeStart) =>
      Intl.message('The associated setup code starts with: $setupCodeStart', name: 'securitySettingsAutocryptImportCodeHint', args: [setupCodeStart]);

  String get securitySettingsAutocryptImportSuccess =>
      Intl.message('Autocrypt setup successfully changed', name: 'securitySettingsAutocryptImportSuccess');

  String get securitySettingsAutocryptImportFailed =>
      Intl.message('Autocrypt setup adjustment failed. Please check the entered setup code.', name: 'securitySettingsAutocryptImportFailed');

  // Chat settings
  String get chatSettingsChangeReadReceipts => Intl.message('Read receipts', name: 'chatSettingsChangeReadReceipts');

  String get chatSettingsChangeReadReceiptsText =>
      Intl.message('Enable sending and requesting of read receipts.', name: 'chatSettingsChangeReadReceiptsText');

  String get chatSettingsChangeMessageSync => Intl.message('Message syncing', name: 'chatSettingsChangeMessageSync');

  String get chatSettingsChangeMessageSyncText =>
      Intl.message('Please choose what kind of messages you would like to see.', name: 'chatSettingsChangeMessageSyncText');

  String get chatSettingsChangeMessageSyncOption1 => Intl.message('Show only chat messages ', name: 'chatSettingsChangeMessageSyncOption1');

  String get chatSettingsChangeMessageSyncOption2 => Intl.message('Show only messages of my contacts', name: 'chatSettingsChangeMessageSyncOption2');

  String get chatSettingsChangeMessageSyncOption3 =>
      Intl.message('Show all messages, including normal email messages', name: 'chatSettingsChangeMessageSyncOption3');

  // Anti-Mobbing settings
  String get antiMobbingSettingsChangeSetting => Intl.message('Only show messages of known contacts', name: 'antiMobbingSettingsChangeSetting');

  String get antiMobbingSettingsInfoText =>
      Intl.message('Messages from unknown contacts do not appear in chats anymore. Instead, you can access such messages here:',
          name: 'antiMobbingSettingsHelpText');

  String get antiMobbingSettingsUnknownContactsButtonText =>
      Intl.message('Messages from unknown contacts', name: 'antiMobbingSettingsUnknownContactsButtonText');

  // Notifications
  String get moreMessages => Intl.message('more messages', name: 'moreMessages');

  // About
  String get aboutSettingsName => Intl.message('App name', name: 'aboutSettingsName');

  String get aboutSettingsVersion => Intl.message('App version', name: 'aboutSettingsVersion');

  // Search
  String get searchEmpty => Intl.message('No results found.', name: 'searchEmpty');
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
