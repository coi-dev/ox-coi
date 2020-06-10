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

import 'package:logging/logging.dart';
import 'package:ox_coi/src/extensions/string_apis.dart';

// Non-translatable strings
const plain = "Plain";
const sslTls = "SSL/TLS";
const startTLS = "StartTLS";
const gif = "GIF";
const pdf = "PDF";

class L {
  static final _logger = Logger("l");

  static final oxCoiName = translationKey("OX COI Messenger");
  static final appName = translationKey("App name");
  static final appVersion = translationKey("App version");
  static final advanced = translationKey("Advanced");
  static final audio = translationKey("Audio");
  static final block = translationKey("Block");
  static final automatic = translationKey("Automatic");

  // Action X performed by user Y (e.g. Login by alice)
  static final byXY = translationKey("%s by %s");

  // Action X performed by the current user (e.g. Login by me)
  static final byMeX = translationKey("%s by me");
  static final about = translationKey("About");

  // Will resolve to "By using OX COI Messenger you agree to our terms & conditions and privacy declaration"
  static final agreeToXY = translationKey("By using OX COI Messenger you agree to our %s and %s");
  static final camera = translationKey("Take a picture");
  static final cancel = translationKey("Cancel");
  static final debug = translationKey("Debug");
  static final delete = translationKey("Delete");
  static final draft = translationKey("Draft");
  static final emailAddress = translationKey("Email address");
  static final file = translationKey("File");
  static final error = translationKey("Error");
  static final forward = translationKey("Forward");
  static final forwarded = translationKey("Forwarded");
  static final gallery = translationKey("Choose from gallery");
  static final image = translationKey("Image");
  static final import = translationKey("Import");
  static final inbox = translationKey("Inbox");
  static final invites = translationKey("Invites");
  static final invitation = translationKey("Invitation");
  static final email = translationKey("Email");
  static final location = translationKey("Location");
  static final me = translationKey("Me");
  static final name = translationKey("Name");
  static final no = translationKey("No");
  static final off = translationKey("Off");
  static final ok = translationKey("Ok");
  static final noResultsFound = translationKey("No results found");
  static final outbox = translationKey("Outbox");
  static final participantP = translationKey("Participant", "Participants");
  static final password = translationKey("Password");
  static final security = translationKey("Security");
  static final pleaseWait = translationKey("Please wait a moment.");
  static final register = translationKey("Register");
  static final save = translationKey("Save");
  static final setName = translationKey("Set a name");
  static final share = translationKey("Share");
  static final signature = translationKey("Signature");
  static final today = translationKey("Today");
  static final unblock = translationKey("Unblock");
  static final username = translationKey("Username");
  static final video = translationKey("Video");
  static final welcome = translationKey("Welcome to %s");
  static final yes = translationKey("Yes");
  static final yesterday = translationKey("Yesterday");
  static final textFieldEmptyHint = translationKey("This field can not be empty");
  static final readReceiptText =
      translationKey("This is a read receipt.\n\nIt means the message was displayed on the recipient's device, not necessarily that the content was read.");
  static final voiceMessage = translationKey("Voice message");
  static final moreMessagesX = translationKey("%d more messages");
  static final noMoreMedia = translationKey("No other media files available");
  static final privacyDeclaration = translationKey("privacy declaration");
  static final termsConditions = translationKey("terms & conditions");
  static final code = translationKey("Code");
  static final retry = translationKey("Retry");
  static final search = translationKey("Search");
  static final type = translationKey("Type");

  static final autocryptSetupMessage = translationKey("Autocrypt Setup Message");
  static final autocryptSetupCode = translationKey("Autocrypt setup code");
  static final autocryptFailed = translationKey("Autocrypt setup failed. Please check your setup code.");
  static final autocryptSuccess = translationKey("Autocrypt setup successfully changed");
  static final autocryptText = translationKey(
      "An Autocrypt setup message securely shares your encryption setup with other Autocrypt-compliant apps. The setup will be secured by a setup code which is displayed here and must be entered on the other device.");
  static final autocryptCreateMessageText =
      translationKey("Creates an Autocrypt setup message, which you can load on other devices to use your current encryption setup.");
  static final autocryptImport = translationKey("Import Autocrypt setup message");
  static final autocryptMessageCreated = translationKey("Setup message created");
  static final autocryptImportHintX = translationKey("The associated setup code starts with: %s");
  static final autocryptInputHint = translationKey("The code can be entered with or without minus signs");
  static final autocryptSetupText = translationKey(
      "This is the Autocrypt Setup Message used to transfer your end-to-end setup between clients.\n\nTo decrypt and use your setup, open the message in an Autocrypt-compliant client and enter the setup code presented on the generating device.");
  static final autocryptChatMessagePlaceholder =
      translationKey("This message is an Autocrypt Setup Message. Tap it to start the import process. You will be guided through the process.");
  static final autocryptCompleteImport = translationKey(
      "To complete the import of the Autocrypt setup message please provide the security code shown on the originating device. After entering the code below the Autocrypt settings will be applied to your current encryption setup.");
  static final autocryptMessageSentX = translationKey(
      "Your Autocrypt setup has been sent to yourself. Switch to the other device and open the setup message. You should be prompted for a setup code. Type the following digits into the prompt:\n%s\nOnce you are done, your other device will be ready to use Autocrypt.");

  static final chatP = translationKey("Chat", "Chats");
  static final chatArchived = translationKey("Archived chats");
  static final chatCreateText = translationKey("Do you want to chat with this new contact?");
  static final chatDeleteText = translationKey("Do you want to delete this chat?");
  static final chatCreate = translationKey("Create chat");
  static final chatDeleteP = translationKey("Delete chat", "Delete chats");
  static final chatMessagesSelf = translationKey("Messages I sent to myself");
  static final chatNoFlagged = translationKey("No flagged messages");
  static final chatNoMessages = translationKey("No messages");
  static final chatOpen = translationKey("Open chat");
  static final chatNewPlaceholder = translationKey("This is a new chat. Send a message to connect.");

  // Start a chat with a new user (e.g. Start a chat with alice?)
  static final chatStartWithTextX = translationKey("Start a chat with %s?");
  static final chatListPlaceholder = translationKey("Welcome to the OX COI Messenger!\nPlease start a new chat by tapping the chat bubble icon.");
  static final chatAudioRecordingFailed =
      translationKey("Audio recording failed, please grant the permissions to record audio in the app settings on your device.");
  static final chatVideoRecordingFailed =
      translationKey("Video recording failed, please grant the permissions to record video in the app settings on your device.");
  static final chatFavoriteMessages = translationKey("Your favorite messages");
  static final chatFlagged = translationKey("Flagged");
  static final chatEncryptionStatusChanged = translationKey("Your messages are encrypted from now on.");
  static final chatChooseCallNumber = translationKey("Please choose a number");
  static final chatStart = translationKey("Start chat");
  static final chatListInviteDialogXY = translationKey("%s/%s has invited you to chat.");
  static final chatListInviteDialogX = translationKey("%s has invited you to chat.");

  static final clipboardCopied = translationKey("Copied to clipboard");

  // Content X copied to clipboard (e.g. Text copied to clipboard)
  static final clipboardCopiedX = translationKey("%s copied to clipboard");

  static final contactP = translationKey("Contact", "Contacts");
  static final contactXP = translationKey("1 contact", "%d contacts");
  static final contactImportSuccessful = translationKey("System contacts imported successfully");
  static final contactAdd = translationKey("Add contact");
  static final contactBlock = translationKey("Block contact");
  static final contactBlocked = translationKey("Blocked contacts");
  static final contactVerifyFailed = translationKey("Cannot verify contact");
  static final contactSetupChanged = translationKey("Changed encryption setup for this contact");
  static final contactImportRunning = translationKey("Contact import running, please wait");
  static final contactRequest = translationKey("Contact request");
  static final contactAddedSuccess = translationKey("Contact successfully added");
  static final contactBlockedSuccess = translationKey("Contact successfully blocked");
  static final contactDeletedSuccess = translationKey("Contact successfully deleted");
  static final contactEditedSuccess = translationKey("Contact successfully edited");
  static final contactVerifiedSuccess = translationKey("Contact verified");
  static final contactAddFailedAlreadyExists = translationKey("Could not add contact. Email address already in use.");
  static final contactDeleteFailed = translationKey("Could not delete contact. You may have a group conversation with this contact.");
  static final contactDeleteWithActiveChatFailed =
      translationKey("Could not delete contact. Active chats with contact found, please remove those chats first.");
  static final contactDelete = translationKey("Delete contact");

  // Do you really want to block user X with email Y (e.g. Do you really want to block alice (alice@provider.com)?)
  static final contactBlockTextXY = translationKey("Do you really want to block %s (%s)?");

  // Do you really want to delete user X with email Y (e.g. Do you really want to delete alice (alice@provider.com)?)
  static final contactDeleteTextXY = translationKey("Do you really want to delete %s (%s)?");

  // Do you really want to delete user with email X (e.g. Do you really want to delete alice@provider.com?)
  static final contactDeleteTextX = translationKey("Do you really want to delete %s?");
  static final contactEdit = translationKey("Edit contact");

  // Do you really want to unblock user X (e.g. Do you really want to unblock alice?)
  static final contactUnblockTextX = translationKey("Do you want to unblock %s?");
  static final contactName = translationKey("Enter the contact name");
  static final contactImportFailed = translationKey("Import failed, missing permissions");
  static final contactImport = translationKey("Import device contacts");
  static final contactNew = translationKey("New contact");
  static final contactNoBlocked = translationKey("No blocked contacts");
  static final contactReImportText = translationKey("Re-importing your contacts will not create duplicates.");
  static final contactSearch = translationKey("Search contacts");
  static final contactInitialImportText = translationKey("This action can also be done later via the import button in the top action bar.");
  static final contactVerificationFinished = translationKey("Verification finished.");
  static final contactVerificationRunning = translationKey("Verifying. Please wait a moment.");
  static final contactSystemImportText = translationKey("Would you like to import your contacts from this device?");
  static final contactUnblock = translationKey("Unblock contact");
  static final contactEditPhoneNumberText = translationKey("Phone numbers can be added or edited via the local address book and imported afterwards.");
  static final contactNoPhoneNumber = translationKey("No phone number");
  static final contactNoPhoneNumberText =
      translationKey("This contact has no phone number. Please edit this contact in your device address book and add the phone number there.");
  static final contactGooglemailDialogTitle = translationKey("Googlemail account detected");
  static final contactGooglemailDialogContent =
      translationKey("We detected a googlemail address. This leads to broken chats. We recommend to change the mail address to gmail.");
  static final contactGooglemailDialogPositiveButton = translationKey("Change");
  static final contactGooglemailDialogNegativeButton = translationKey("Don't change");
  static final contactOwnCardGroupHeaderText = translationKey("Own Card");

  static final coreMembers = translationKey('%1\$d member(s)');
  static final coreContacts = translationKey('%1\$d contact(s)');

  // Security token of the FCM service. FCM is a abbreviation and mustn't be translated
  static final debugFCMToken = translationKey("FCM token");
  static final debugPushData = translationKey("Push data");
  static final debugPushResource = translationKey("Push resource (via push service)");
  static final debugPushResourceRegister = translationKey("Register new push resource");
  static final debugPushResourceDelete = translationKey("Delete push resource");

  static final errorCannotDecrypt = translationKey(
      "This message cannot be decrypted.\n\nIt might help to reply to this message and ask the sender to send the message again.\n\nIn case you re-installed the OX COI Messenger or another email program on this or another device you may want to send an Autocrypt setup message from there.");
  static final errorProgressCanceled = translationKey("There was an error or the progress was canceled.");

  static final groupAddContactsAlreadyIn = translationKey("All your contacts are in this chat.");
  static final groupImageChanged = translationKey("Group image changed");
  static final groupImageDeleted = translationKey("Group image deleted");
  static final groupLeft = translationKey("Group left");
  static final groupName = translationKey("Group name");
  static final groupNameChanged = translationKey("Group name changed");
  static final groupNewDraft = translationKey("Hello, I have just created this group for us");
  static final groupLeave = translationKey("Leave group");
  static final groupDelete = translationKey("Delete group");
  static final groupAddNoParticipants = translationKey("No participants selected. Please select at least one person.");
  static final groupLeaveText = translationKey("Do you really want to leave the group?");
  static final groupCreate = translationKey("Create group");
  static final groupRemoveImage = translationKey("Remove current image");
  static final groupRemoveParticipant = translationKey("Remove participant");
  static final groupRename = translationKey("Rename group");
  static final groupNameLabel = translationKey("Set a group name");
  static final groupAddContactAdd = translationKey("Simply add one by tapping on a contact.");
  static final groupParticipantActionInfo = translationKey("Info");
  static final groupParticipantActionSendMessage = translationKey("Send message");
  static final groupParticipantActionRemove = translationKey("Remove from group");

  static final loginRunning = translationKey("Logging in, this may take a moment");
  static final loginFailed = translationKey("Login failed");
  static final login = translationKey("Log in to OX COI Messenger");
  static final loginWelcome = translationKey(
      "OX COI Messenger works with any email provider, but best with COI-compatible providers. If you have an existing email account, please sign in, otherwise register a new account first.");
  static final loginWelcomeManual = translationKey(
      "Often you only need to provide your email address, password and server addresses. The remaining values are determined automatically. Sometimes IMAP needs to be enabled in your email website. Consult your email provider or friends for help.");
  static final loginCheckUsernamePassword = translationKey("Please check your username and password");
  static final loginCheckMail = translationKey("Please enter a valid email address");
  static final loginCheckPort = translationKey("Please enter a valid port (1-65535)");
  static final loginCheckPassword = translationKey("Please enter your password");
  static final chooseProviderLogin = translationKey("Please select your email provider to sign in");
  static final loginCheckServer = translationKey("Please specify your email server settings.");
  static final loginErrorWrongCredentials = translationKey("Login failed. Please check if the email-address and the password are correct.");

  // Response from server address X with error code Y (e.g. Response from provider.com: Login failed)
  static final loginErrorResponseXY = translationKey(
      "Response from %s: %s\n\nSome providers place additional information in your inbox; you can check them eg. in the web frontend. Consult your provider or friends if you run into problems.");
  static final loginSignIn = translationKey("Sign in");
  static final loginImapSmtpName = translationKey("IMAP/SMTP login names");
  static final loginServerAddresses = translationKey("Server addresses");
  static final loginManualSetupRequired = translationKey("We could not determine all settings automatically.");

  static final logoutTitle = translationKey("Logout");
  static final logoutConfirmationText = translationKey(
      "Do you really want to log out?\n\nYour settings and messages will be removed from this device. After logging out you need to start the app again to log into another account.");

  static final passwordChangedTitle = translationKey("Password changed");
  static final passwordChangedInfoText = translationKey("Your password has changed.\nPlease enter your new one to access your messages.");
  static final passwordChangedButtonText = translationKey("Login");
  static final passwordChangedCheckPassword = translationKey("Login failed. Please check your password.");

  static final memberXP = translationKey("1 member", "%i members");
  static final memberAdded = translationKey("Member added");
  static final memberRemoved = translationKey("Member removed");

  static final messageActionForward = translationKey("Forward");
  static final messageActionCopy = translationKey("Copy");
  static final messageActionDelete = translationKey("Delete locally");
  static final messageActionFlagUnflag = translationKey("Flag/Unflag");
  static final messageActionShare = translationKey("Share");
  static final messageActionInfo = translationKey("Info");
  static final messageActionRetry = translationKey("Send again");
  static final messageActionDeleteFailedMessage = translationKey("Discard message");
  static final messageActionDeleteMessage = translationKey("Delete message");

  // Error message in case of a failed sending attempt, to user X on date Y (e.g Your message sent to "Bob" on 26.01.2020 - 06:14 could not be transmitted.)
  static final messageFailedDialogContentXY = translationKey(
      "Your message sent to \"%s\" on %s could not be transmitted. Often this happens due to a too large file. Please delete this message to unblock sending subsequent messages.");

  static final participantXP = translationKey("1 participant", "%i participants");
  static final participantAdd = translationKey("Add participants");

  static final profileEdit = translationKey("Edit profile");
  static final profileNoSignature = translationKey("No signature set");
  static final profileNoUsername = translationKey("No username set");
  static final profile = translationKey("Profile");
  static final profileAndSettings = translationKey("Profile & Settings");
  static final profileDefaultStatus = translationKey("Sent with OX COI Messenger");
  static final profileShareInviteUrl = translationKey("Share invite link");

  static final inviteShareText = translationKey("Check out OX COI Messenger - chat via email!");
  static final inviteGetText404Error = translationKey("The invite was already deleted. Please ask the sender to resend it.");
  static final inviteGetTextGeneralErrorX = translationKey("Something went wrong and we could not load the invite: %s");

  static final chooseProviderRegister = translationKey("Choose a provider from the list below to create a new account");
  static final providerAutocompleteText = translationKey(
      "For known email providers additional settings are set up automatically.\nSometimes IMAP needs to be enabled in the web frontend. Consult your email provider or friends for help.");
  static final providerOtherMailProvider = translationKey("Other mail provider");

  // Sign in with provide X (e.g. Sign in with provider.com)
  static final providerSignInTextX = translationKey("Sign in with %s");

  static final qrProfile = translationKey("Profile QR");

  // Text for a section header below the "add contact form". Below the header the "Scan QR code" button is placed
  static final qrAddContactHeader = translationKey("Or scan QR code");
  static final qrScan = translationKey("Scan QR code");

  // Scan the QR code to add an verify user X (e.g. Scan this QR code to create a new contact or verify a contact with alice.)
  static final qrScanTextX = translationKey("Scan this QR code to create a new contact or verify a contact with %s.");
  static final qrShow = translationKey("Show QR");
  static final qrShowErrorX = translationKey("Not possible to create qr code: %s");
  static final qrCameraNotAllowed = translationKey("Camera not ready");
  static final qrCameraNotAllowedText = translationKey("No camera permission granted.");
  static final qrNoValidCode = translationKey("No valid QR code");
  static final qrValidationFailed = translationKey("Contact validation failed");

  static final settingP = translationKey("Setting", "Settings");
  static final settingBase = translationKey("Base Settings");
  static final settingConfigurationChangeFailed = translationKey("Configuration change aborted");

  // Do you want to import your keys from folder X (e.g. Do you want to import your keys from "/home/alice/keys"?)
  static final settingSecurityImportKeysAndroidText =
      translationKey("Do you want to import your keys from your application folder? \n\nIf no keys are in that folder, the operation will fail.");
  static final settingSecurityImportKeysIOSText =
      translationKey("Do you want to import your keys from your app documents folder? \n\nIf no keys are in that folder, the operation will fail.");

  // Do you want to export your keys to folder X (e.g. "Do you want to save your keys in "/home/alice/keys"?")
  static final settingSecurityExportKeysAndroidTextX = translationKey("Do you want to save your keys in the application folder? \n\nThe path is:\n\"%s\"");
  static final settingSecurityExportKeysIOSText =
      translationKey("Do you want to save your keys in your devices documents folder? \n\nYou can access it via the \"Files App\".");
  static final settingCopyCode = translationKey("Copy code");
  static final settingExportKeys = translationKey("Expert: Export keys");
  static final settingImportKeys = translationKey("Expert: Import keys");
  static final settingImportKeysText = translationKey("Import keys from your local storage to change your current encryption setup");
  static final settingIMAPSecurity = translationKey("IMAP Security");
  static final settingIMAPName = translationKey("IMAP login name");
  static final settingIMAPPassword = translationKey("IMAP password");
  static final settingIMAPPort = translationKey("IMAP port");
  static final settingIMAPServer = translationKey("IMAP server (e.g. imap.coi.me)");
  static final settingKeyTransferStart = translationKey("Initiate key transfer");
  static final settingKeyTransferFailed = translationKey("Key action failed");
  static final settingKeyTransferPermissionFailed = translationKey("Key action failed, missing permissions");
  static final settingKeyTransferSuccess = translationKey("Key action successfully done");
  static final settingManual = translationKey("Manual Settings");
  static final settingChatMessagesUnknownShow = translationKey("Messages from unknown contacts");
  static final settingChatMessagesUnknownText =
      translationKey("Messages from unknown contacts do not appear in chats anymore. Instead, you can access such messages here:");
  static final settingChatMessagesUnknownNoMessages = translationKey("There are currently no messages from unknown contacts");
  static final settingMessageSyncing = translationKey("Message syncing");
  static final settingAntiMobbing = translationKey("Privacy and Mobbing Protection");
  static final settingAntiMobbingText = translationKey("Only show messages of known contacts");
  static final settingKeyExportRunning = translationKey("Performing key export");
  static final settingKeyImportRunning = translationKey("Performing key import");
  static final settingKeyTransferRunning = translationKey("Performing key transfer");
  static final settingChooseMessageSyncingType = translationKey("Please choose what kind of messages you would like to see.");
  static final settingSMTPSecurity = translationKey("SMTP Security");
  static final settingSMTPLogin = translationKey("SMTP login name");
  static final settingSMTPPassword = translationKey("SMTP password");
  static final settingSMTPPort = translationKey("SMTP port");
  static final settingSMTPServer = translationKey("SMTP server (e.g. smtp.coi.me)");
  static final settingReadReceiptP = translationKey("Read receipt", "Read receipts");
  static final settingReadReceiptText = translationKey("Enable sending and requesting of read receipts.");
  static final settingMessageSyncingTypeAll = translationKey("Show both chat and email messages from all senders");
  static final settingMessageSyncingTypeChats = translationKey("Show only chat messages ");
  static final settingMessageSyncingTypeKnown = translationKey("Show both chat and email messages from my contacts");
  static final settingAccount = translationKey("Account");
  static final settingAccountChanged = translationKey("Account settings successfully changed");
  static final settingApplying = translationKey("Applying new settings, this may take a moment");
  static final settingAdvancedImap = translationKey("Advanced IMAP Settings");
  static final settingAdvancedSmtp = translationKey("Advanced SMTP Settings");
  static final settingEncryptionExportText =
      translationKey("This keys enable another device to use your current encryption setup. Keys are saved on your local storage.");
  static final settingNotificationP = translationKey("Notification", "Notifications");
  static final settingNotificationPull = translationKey("Enable background updates");
  static final settingNotificationPullText = translationKey("If enabled, this setting allows the app to perform periodic background tasks to get new messages");
  static final settingNotificationPush = translationKey("Change Push Settings");
  static final settingNotificationPushText = translationKey("Change the push settings for this app in your system settings.");
  static final settingAboutBugReports = translationKey("Bug reports");

  // "GitHub" is an own name. Please don't translate it
  static final settingAboutBugReportsText = translationKey("Please report bugs on GitHub.");
  static final settingAboutFeatureRequests = translationKey("Feature requests");

  // "user echo" is an own name. Please don't translate it
  static final settingAboutFeatureRequestsText = translationKey("Please suggest your ideas on user echo.");
  static final settingSignatureTitle = translationKey("Email signature");
  static final settingSignatureDescription = translationKey("Change your Signature");

  static final settingGroupHeaderGeneralTitle = translationKey("General Settings");
  static final settingGroupHeaderEmailTitle = translationKey("Email Settings");
  static final settingGroupHeaderSecurityTitle = translationKey("Security");

  static final settingItemFlaggedTitle = translationKey("Flagged messages");
  static final settingItemQRTitle = translationKey("Show my QR code");
  static final settingItemInviteTitle = translationKey("Invite a friend");
  static final settingItemNotificationsTitle = translationKey("Notifications");
  static final settingItemChatTitle = translationKey("Chat");
  static final settingItemSignatureTitle = translationKey("Email signature");
  static final settingItemServerSettingsTitle = translationKey("Server settings");
  static final settingItemDataProtectionTitle = translationKey("Data protection");
  static final settingItemBlockedTitle = translationKey("Blocked contacts");
  static final settingItemEncryptionTitle = translationKey("Encryption");
  static final settingItemAboutTitle = translationKey("About");
  static final settingItemFeedbackTitle = translationKey("Feedback");
  static final settingItemBugReportTitle = translationKey("Report a bug");

  // Entry in a list of items, opens the appearance settings of the app (e.g. for light / dark mode)
  static final settingsAppearanceTitle = translationKey("Appearance");
  static final settingsAppearanceSystemTitle = translationKey("System");
  static final settingsAppearanceDarkTitle = translationKey("Dark");
  static final settingsAppearanceLightTitle = translationKey("Light");
  static final settingsAppearanceDescription = translationKey(
      "Here you can choose your favorite theme. If you choose '%s', the theme may change automatically. This depends on whether you have selected 'Automatic' in the system preferences or not.");
  static final settingsAppearanceSystemThemeDescription = translationKey("Current System theme is: %s");

  static final notificationChannelTitle = translationKey("Message notifications");
  static final notificationChannelDescription = translationKey("Notifications for incoming messages");

  static final dynamicScreenSkipButtonTitle = L.translationKey("Skip");
  static final dynamicScreenBackButtonTitle = L.translationKey("Back");
  static final dynamicScreenNextButtonTitle = L.translationKey("Next");
  static final dynamicScreenPageIndexTitle = L.translationKey("Step %s of %s");

  static List<String> translationKey(String key, [String pluralKey]) {
    String logging = "Registered localization key: '$key'";
    if (!pluralKey.isNullOrEmpty()) {
      logging += " and plural key: '$pluralKey'";
    }
    _logger.fine(logging);
    return [key, pluralKey];
  }

  static String getKey(List<String> translationKeys) {
    return translationKeys[0];
  }

  static String getPluralKey(List<String> translationKeys) {
    return translationKeys[1];
  }
}
