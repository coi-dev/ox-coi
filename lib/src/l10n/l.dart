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
import 'package:ox_coi/src/utils/text.dart';

class L {
  static final _logger = Logger("l");

  static final oxCoiName = _translationKey("OX COI Messenger");
  static final appName = _translationKey("App name");
  static final appVersion = _translationKey("App version");
  static final advanced = _translationKey("Advanced");
  static final audio = _translationKey("Audio");
  static final block = _translationKey("Block");
  static final automatic = _translationKey("Automatic");
  // Action X performed by user Y (e.g. Login by alice)
  static final byXY = _translationKey("%s by %s");
  // Action X performed by the current user (e.g. Login by me)
  static final byMeX = _translationKey("%s by me");
  static final about = _translationKey("About");
  // Will resolve to "By using OX COI Messenger you agree to our terms & conditions and privacy declaration"
  static final agreeToXY = _translationKey("By using OX COI Messenger you agree to our %s and %s");
  static final camera = _translationKey("Camera");
  static final cancel = _translationKey("Cancel");
  static final debug = _translationKey("Debug");
  static final delete = _translationKey("Delete");
  static final draft = _translationKey("Draft");
  static final emailAddress = _translationKey("Email address");
  static final file = _translationKey("File");
  static final error = _translationKey("Error");
  static final forward = _translationKey("Forward");
  static final gallery = _translationKey("Gallery");
  static final image = _translationKey("Image");
  static final import = _translationKey("Import");
  static final inbox = _translationKey("Inbox");
  static final invites= _translationKey("Invites");
  static final email = _translationKey("Email");
  static final location = _translationKey("Location");
  static final me = _translationKey("Me");
  static final name = _translationKey("Name");
  static final no = _translationKey("No");
  static final off = _translationKey("Off");
  static final ok = _translationKey("Ok");
  static final noResultsFound = _translationKey("No results found");
  static final outbox = _translationKey("Outbox");
  static final participantP = _translationKey("Participant", "Participants");
  static final password = _translationKey("Password");
  static final security = _translationKey("Security");
  static final pleaseWait = _translationKey("Please wait a moment.");
  static final register = _translationKey("Register");
  static final save = _translationKey("Save");
  static final setName = _translationKey("Set a name");
  static final share = _translationKey("Share");
  static final signature = _translationKey("Signature");
  static final today = _translationKey("Today");
  static final unblock = _translationKey("Unblock");
  static final typeSomething = _translationKey("Type something...");
  static final username = _translationKey("Username");
  static final video = _translationKey("Video");
  static final welcome = _translationKey("Welcome to %s");
  static final yes = _translationKey("Yes");
  static final yesterday = _translationKey("Yesterday");
  static final textFieldEmptyHint = _translationKey("This field can not be empty");
  static final readReceiptText = _translationKey("This is a read receipt.\n\nIt means the message was displayed on the recipient's device, not necessarily that the content was read.");
  static final voiceMessage = _translationKey("Voice message");
  static final moreMessages = _translationKey("more messages");
  static final privacyDeclaration = _translationKey("privacy declaration");
  static final termsConditions = _translationKey("terms & conditions");
  static final code = _translationKey("Code");
  static final retry = _translationKey("Retry");

  static final autocryptSetupMessage = _translationKey("Autocrypt Setup Message");
  static final autocryptSetupCode = _translationKey("Autocrypt setup code");
  static final autocryptFailed = _translationKey("Autocrypt setup failed. Please check your setup code.");
  static final autocryptSuccess = _translationKey("Autocrypt setup successfully changed");
  static final autocryptText = _translationKey("An Autocrypt setup message securely shares your encryption setup with other Autocrypt-compliant apps. The setup will be secured by a setup code which is displayed here and must be entered on the other device.");
  static final autocryptCreateMessageText = _translationKey("Creates an Autocrypt setup message, which you can load on other devices to use your current encryption setup.");
  static final autocryptImport = _translationKey("Import Autocrypt setup message");
  static final autocryptMessageCreated = _translationKey("Setup message created");
  static final autocryptImportHintX = _translationKey("The associated setup code starts with: %s");
  static final autocryptInputHint = _translationKey("The code can be entered with or without minus signs");
  static final autocryptSetupText = _translationKey("This is the Autocrypt Setup Message used to transfer your end-to-end setup between clients.\n\nTo decrypt and use your setup, open the message in an Autocrypt-compliant client and enter the setup code presented on the generating device.");
  static final autocryptChatMessagePlaceholder = _translationKey("This message is an Autocrypt Setup Message. Tap it to start the import process. You will be guided through the process.");
  static final autocryptCompleteImport = _translationKey("To complete the import of the Autocrypt setup message please provide the security code shown on the originating device. After entering the code below the Autocrypt settings will be applied to your current encryption setup.");
  static final autocryptMessageSentX = _translationKey("Your Autocrypt setup has been sent to yourself. Switch to the other device and open the setup message. You should be prompted for a setup code. Type the following digits into the prompt:\n%s\nOnce you are done, your other device will be ready to use Autocrypt.");

  static final chatP = _translationKey("Chat", "Chats");
  static final chatArchived = _translationKey("Archived chats");
  static final chatCreateText = _translationKey("Do you want to chat with this new contact?");
  static final chatDeleteText = _translationKey("Do you want to delete this chat?");
  static final chatCreate = _translationKey("Create chat");
  static final chatDeleteP = _translationKey("Delete chat", "Delete chats");
  static final chatMessagesSelf = _translationKey("Messages I sent to myself");
  static final chatNoFlagged = _translationKey("No flagged messages");
  static final chatNoMessages = _translationKey("No messages");
  static final chatOpen = _translationKey("Open chat");
  static final chatNewPlaceholder = _translationKey("This is a new chat. Send a message to connect.");
  // Start a chat with a new user (e.g. Start a chat with alice?)
  static final chatStartWithTextX = _translationKey("Start a chat with %s?");
  static final chatListPlaceholder = _translationKey("Welcome to the OX COI Messenger!\nPlease start a new chat by tapping the chat bubble icon.");
  static final chatAudioRecordingFailed = _translationKey("Audio recording failed, please grant the permissions to record audio in the app settings on your device.");
  static final chatVideoRecordingFailed = _translationKey("Video recording failed, please grant the permissions to record video in the app settings on your device.");
  static final chatFavoriteMessages = _translationKey("Your favorite messages");
  static final chatFlagged = _translationKey("Flagged");
  static final chatEncryptionStatusChanged = _translationKey("Your messages are encrypted from now on.");
  static final chatChooseCallNumber = _translationKey("Please choose a number");
  static final chatStart = _translationKey("Start chat");
  static final chatListInviteDialogXY = _translationKey("%s/%s has invited you to chat.");
  static final chatListInviteDialogX = _translationKey("%s has invited you to chat.");

  static final clipboardCopied = _translationKey("Copied to clipboard");
  // Content X copied to clipboard (e.g. Text copied to clipboard)
  static final clipboardCopiedX = _translationKey("%s copied to clipboard");

  static final contactP = _translationKey("Contact", "Contacts");
  static final contactXP = _translationKey("1 contact", "%d contacts");
  static final contactImportSuccessful = _translationKey("System contacts imported successfully");
  static final contactAdd = _translationKey("Add contact");
  static final contactBlock = _translationKey("Block contact");
  static final contactBlocked = _translationKey("Blocked contacts");
  static final contactVerifyFailed = _translationKey("Cannot verify contact");
  static final contactSetupChanged = _translationKey("Changed encryption setup for this contact");
  static final contactImportRunning = _translationKey("Contact import running, please wait");
  static final contactRequest = _translationKey("Contact request");
  static final contactAddedSuccess = _translationKey("Contact successfully added");
  static final contactBlockedSuccess = _translationKey("Contact successfully blocked");
  static final contactDeletedSuccess = _translationKey("Contact successfully deleted");
  static final contactEditedSuccess = _translationKey("Contact successfully edited");
  static final contactVerifiedSuccess = _translationKey("Contact verified");
  static final contactDeleteFailed = _translationKey("Could not delete contact.");
  static final contactDeleteWithActiveChatFailed = _translationKey("Could not delete contact. Active chats with contact found, please remove those chats first.");
  static final contactDelete = _translationKey("Delete contact");
  // Do you really want to block user X with email Y (e.g. Do you really want to block alice (alice@provider.com)?)
  static final contactBlockTextXY = _translationKey("Do you really want to block %s (%s)?");
  // Do you really want to delete user X with email Y (e.g. Do you really want to delete alice (alice@provider.com)?)
  static final contactDeleteTextXY = _translationKey("Do you really want to delete %s (%s)?");
  // Do you really want to delete user with email X (e.g. Do you really want to delete alice@provider.com?)
  static final contactDeleteTextX = _translationKey("Do you really want to delete %s?");
  static final contactEdit = _translationKey("Edit contact");
  // Do you really want to unblock user X (e.g. Do you really want to unblock alice?)
  static final contactUnblockTextX = _translationKey("Do you want to unblock %s?");
  static final contactName = _translationKey("Enter the contact name");
  static final contactImportFailed = _translationKey("Import failed, missing permissions");
  static final contactImport = _translationKey("Import device contacts");
  static final contactNew = _translationKey("New contact");
  static final contactNoBlocked = _translationKey("No blocked contacts");
  static final contactReImportText = _translationKey("Re-importing your contacts will not create duplicates.");
  static final contactSearch = _translationKey("Search contacts");
  static final contactInitialImportText = _translationKey("This action can also be done later via the import button in the top action bar.");
  static final contactVerificationFinished = _translationKey("Verification finished.");
  static final contactVerificationRunning = _translationKey("Verifying. Please wait a moment.");
  static final contactSystemImportText = _translationKey("Would you like to import your contacts from this device?");
  static final contactUnblock = _translationKey("Unblock contact");
  static final contactEditPhoneNumberText = _translationKey("Phone numbers can be added or edited via the local address book and imported afterwards.");
  static final contactNoPhoneNumber = _translationKey("No phone number");
  static final contactNoPhoneNumberText = _translationKey("This contact has no phone number. Please edit this contact in your device address book and add the phone number there.");
  static final contactGooglemailDialogTitle = _translationKey("Googlemail account detected");
  static final contactGooglemailDialogContent = _translationKey("We detected a googlemail address. This leads to broken chats. We recommend to change the mail address to gmail.");
  static final contactGooglemailDialogPositiveButton = _translationKey("Change");
  static final contactGooglemailDialogNegativeButton = _translationKey("Don't change");
  static final contactOwnCardGroupHeaderText = _translationKey("Own Card");

  static final coreMembers = _translationKey('%1\$d member(s)');
  static final coreContacts = _translationKey('%1\$d contact(s)');

  // Security token of the FCM service. FCM is a abbreviation and mustn't be translated
  static final debugFCMToken = _translationKey("FCM token");
  static final debugPushData = _translationKey("Push data");
  static final debugPushResource = _translationKey("Push resource (via push service)");
  static final debugPushResourceRegister = _translationKey("Register new push resource");
  static final debugPushResourceDelete = _translationKey("Delete push resource");

  static final errorCannotDecrypt = _translationKey("This message cannot be decrypted.\n\nIt might help to reply to this message and ask the sender to send the message again.\n\nIn case you re-installed the OX COI Messenger or another email program on this or another device you may want to send an Autocrypt setup message from there.");
  static final errorProgressCanceled = _translationKey("There was an error or the progress was canceled.");

  static final groupAddContactsAlreadyIn = _translationKey("All your contacts are in this chat.");
  static final groupImageChanged = _translationKey("Group image changed");
  static final groupImageDeleted = _translationKey("Group image deleted");
  static final groupLeft = _translationKey("Group left");
  static final groupName = _translationKey("Group name");
  static final groupNameChanged = _translationKey("Group name changed");
  static final groupNewDraft = _translationKey("Hello, I have just created this group for us");
  static final groupLeave = _translationKey("Leave group");
  static final groupAddNoParticipants = _translationKey("No participants selected. Please select at least one person.");
  static final groupLeaveText = _translationKey("Do you really want to leave the group?");
  static final groupCreate = _translationKey("Create group");
  static final groupRemoveImage = _translationKey("Remove current image");
  static final groupRemoveParticipant = _translationKey("Remove participant");
  static final groupRename = _translationKey("Rename group");
  static final groupNameLabel = _translationKey("Set a group name");
  static final groupAddContactAdd = _translationKey("Simply add one by tapping on a contact.");
  static final groupParticipantActionInfo = _translationKey("Info");
  static final groupParticipantActionSendMessage = _translationKey("Send message");
  static final groupParticipantActionRemove = _translationKey("Remove from group");

  static final loginRunning = _translationKey("Logging in, this may take a moment");
  static final loginFailed = _translationKey("Login failed");
  static final login = _translationKey("Log in to OX COI Messenger");
  static final loginWelcome = _translationKey("OX COI Messenger works with any email provider, but best with COI-compatible providers. If you have an existing email account, please sign in, otherwise register a new account first.");
  static final loginWelcomeManual = _translationKey("Often you only need to provide your email address, password and server addresses. The remaining values are determined automatically. Sometimes IMAP needs to be enabled in your email website. Consult your email provider or friends for help.");
  static final loginCheckUsernamePassword = _translationKey("Please check your username and password");
  static final loginCheckMail = _translationKey("Please enter a valid email address");
  static final loginCheckPort = _translationKey("Please enter a valid port (1-65535)");
  static final loginCheckPassword = _translationKey("Please enter your password");
  static final loginChooseProvider = _translationKey("Please select your email provider to sign in");
  static final loginCheckServer = _translationKey("Please specify your email server settings.");
  static final loginErrorWrongCredentials = _translationKey("Cannot login. Please check if the email-address and the password are correct.");
  // Response from server address X with error code Y (e.g. Response from provide.com: Login failed)
  static final loginErrorResponseXY = _translationKey("Response from %s: %s\n\nSome providers place additional information in your inbox; you can check them eg. in the web frontend. Consult your provider or friends if you run into problems.");
  static final loginSignIn = _translationKey("Sign in");
  static final loginImapSmtpName = _translationKey("IMAP/SMTP login names");
  static final loginServerAddresses = _translationKey("Server addresses");
  static final loginManualSetupRequired = _translationKey("We could not determine all settings automatically.");

  static final passwordChangedTitle = _translationKey("Password changed");
  static final passwordChangedInfoText = _translationKey("Your password has changed.\nPlease enter your new one to access your messages.");
  static final passwordChangedButtonText = _translationKey("Login");
  static final passwordChangedCheckPassword = _translationKey("Cannot login. Please check your password.");

  static final memberXP = _translationKey("1 member","%i members");
  static final memberAdded = _translationKey("Member added");
  static final memberRemoved = _translationKey("Member removed");

  static final messageActionForward = _translationKey("Forward");
  static final messageActionCopy = _translationKey("Copy");
  static final messageActionDelete = _translationKey("Delete locally");
  static final messageActionFlagUnflag = _translationKey("Flag/Unflag");
  static final messageActionShare = _translationKey("Share");
  static final messageActionInfo = _translationKey("Info");
  static final messageActionRetry = _translationKey("Send again");
  static final messageActionDeleteFailedMessage = _translationKey("Discard message");

  static final participantXP = _translationKey("1 participant", "%i participants");
  static final participantAdd = _translationKey("Add participants");

  static final profileEdit = _translationKey("Edit profile");
  static final profileNoSignature = _translationKey("No signature set");
  static final profileNoUsername = _translationKey("No username set");
  static final profile = _translationKey("Profile");
  static final profileDefaultStatus = _translationKey("Sent with OX COI Messenger");
  static final profileShareInviteUrl = _translationKey("Share invite link");

  static final inviteShareText = _translationKey("Check out OX COI Messenger - chat via email!");
  static final inviteGetText404Error = _translationKey("The invite was already deleted. Please ask the sender to resend it.");
  static final inviteGetTextGeneralErrorX = _translationKey("Something went wrong and we could not load the invite: %s");

  static final providerRegisterChoose = _translationKey("Choose a provider from the list below to create a new account");
  static final providerAutocompleteText = _translationKey("For known email providers additional settings are set up automatically.\nSometimes IMAP needs to be enabled in the web frontend. Consult your email provider or friends for help.");
  static final providerOtherMailProvider = _translationKey("Other mail provider");
  // Sign in with provide X (e.g. Sign in with provider.com)
  static final providerSignInTextX = _translationKey("Sign in with %s");

  static final qrProfile = _translationKey("Profile QR");
  static final qrAddContactHeader = _translationKey("Or scan QR code");
  static final qrScan = _translationKey("Scan QR code");
  // Scan the QR code to add an verify user X (e.g. Scan this QR code to create a new contact or verify a contact with alice.)
  static final qrScanTextX = _translationKey("Scan this QR code to create a new contact or verify a contact with %s.");
  static final qrShow = _translationKey("Show QR");
  static final qrCameraNotAllowed = _translationKey("Camera not ready");
  static final qrCameraNotAllowedText = _translationKey("No camera permission granted.");
  static final qrNoValidCode = _translationKey("No valid QR code");
  static final qrValidationFailed = _translationKey("Contact validation failed");

  static final settingP = _translationKey("Setting", "Settings");
  static final settingBase = _translationKey("Base Settings");
  static final settingConfigurationChangeFailed = _translationKey("Configuration change aborted");
  // Do you want to import your keys from folder X (e.g. Do you want to import your keys from "/home/alice/keys"?)
  static final settingSecurityImportKeysTextX = _translationKey("Do you want to import your keys from \"%s\"? If no keys are in that folder, the operation will fail.");
  // Do you want to export your keys to folder X (e.g. "Do you want to save your keys in "/home/alice/keys"?")
  static final settingSecurityExportKeysTextX = _translationKey("Do you want to save your keys in \"%s\"?");
  static final settingCopyCode = _translationKey("Copy code");
  static final settingExportKeys = _translationKey("Expert: Export keys");
  static final settingImportKeys = _translationKey("Expert: Import keys");
  static final settingImportKeysText = _translationKey("Import keys from your local storage to change your current encryption setup");
  static final settingIMAPSecurity = _translationKey("IMAP Security");
  static final settingIMAPName = _translationKey("IMAP login name");
  static final settingIMAPPassword = _translationKey("IMAP password");
  static final settingIMAPPort = _translationKey("IMAP port");
  static final settingIMAPServer = _translationKey("IMAP server (e.g. imap.coi.me)");
  static final settingKeyTransferStart = _translationKey("Initiate key transfer");
  static final settingKeyTransferFailed = _translationKey("Key action failed");
  static final settingKeyTransferPermissionFailed = _translationKey("Key action failed, missing permissions");
  static final settingKeyTransferSuccess = _translationKey("Key action successfully done");
  static final settingManual = _translationKey("Manual Settings");
  static final settingChatMessagesUnknownShow = _translationKey("Show messages from unknown contacts");
  static final settingChatMessagesUnknownText = _translationKey("Messages from unknown contacts do not appear in chats anymore. Instead, you can access such messages here:");
  static final settingChatMessagesUnknownNoMessages = _translationKey("There are currently no messages from unknown contacts");
  static final settingMessageSyncing = _translationKey("Message syncing");
  static final settingAntiMobbing = _translationKey("Privacy and Mobbing Protection");
  static final settingAntiMobbingText = _translationKey("Only show messages of known contacts");
  static final settingKeyExportRunning = _translationKey("Performing key export");
  static final settingKeyImportRunning = _translationKey("Performing key import");
  static final settingKeyTransferRunning = _translationKey("Performing key transfer");
  static final settingChooseMessageSyncingType = _translationKey("Please choose what kind of messages you would like to see.");
  static final settingSMTPSecurity = _translationKey("SMTP Security");
  static final settingSMTPLogin = _translationKey("SMTP login name");
  static final settingSMTPPassword = _translationKey("SMTP password");
  static final settingSMTPPort = _translationKey("SMTP port");
  static final settingSMTPServer = _translationKey("SMTP server (e.g. smtp.coi.me)");
  static final settingReadReceiptP = _translationKey("Read receipt", "Read receipts");
  static final settingReadReceiptText = _translationKey("Enable sending and requesting of read receipts.");
  static final settingMessageSyncingTypeAll = _translationKey("Show both chat and email messages from all senders");
  static final settingMessageSyncingTypeChats = _translationKey("Show only chat messages ");
  static final settingMessageSyncingTypeKnown = _translationKey("Show both chat and email messages from my contacts");
  static final settingAccount = _translationKey("Account");
  static final settingAccountChanged = _translationKey("Account settings successfully changed");
  static final settingApplying = _translationKey("Applying new settings, this may take a moment");
  static final settingAdvancedImap = _translationKey("Advanced IMAP Settings");
  static final settingAdvancedSmtp = _translationKey("Advanced SMTP Settings");
  static final settingSecurityExportText = _translationKey("This keys enable another device to use your current encryption setup. Keys are saved on your local storage.");
  static final settingNotificationP = _translationKey("Notification", "Notifications");
  static final settingNotificationPull = _translationKey("Enable background updates");
  static final settingNotificationPullText = _translationKey("If enabled, this setting allows the app to perform periodic background tasks to get new messages");
  static final settingNotificationPush = _translationKey("Change Push Settings");
  static final settingNotificationPushText = _translationKey("Change the push settings for this app in your system settings.");
  static final settingAboutBugReports = _translationKey("Bug reports");
  // "GitHub" is an own name. Please don't translate it
  static final settingAboutBugReportsText = _translationKey("Please report bugs on GitHub.");
  static final settingAboutFeatureRequests = _translationKey("Feature requests");
  // "user echo" is an own name. Please don't translate it
  static final settingAboutFeatureRequestsText = _translationKey("Please suggest your ideas on user echo.");
  static final settingSignatureTitle = _translationKey("Email signature");

  static final settingGroupHeaderGeneralTitle = _translationKey("General Settings");
  static final settingGroupHeaderEmailTitle = _translationKey("Email Settings");
  static final settingGroupHeaderSecurityTitle = _translationKey("Security");

  static final settingItemFlaggedTitle = _translationKey("Flagged messages");
  static final settingItemQRTitle = _translationKey("Show my QR code");
  static final settingItemInviteTitle = _translationKey("Invite friend");
  static final settingItemNotificationsTitle = _translationKey("Notifications");
  static final settingItemChatTitle = _translationKey("Chat");
  static final settingItemSignatureTitle = _translationKey("Email signature");
  static final settingItemServerSettingsTitle = _translationKey("Server settings");
  static final settingItemDarkModeTitle = _translationKey("Dark mode");
  static final settingItemDataProtectionTitle = _translationKey("Data protection");
  static final settingItemBlockedTitle = _translationKey("Blocked contacts");
  static final settingItemEncryptionTitle = _translationKey("Encryption");
  static final settingItemAboutTitle = _translationKey("About");
  static final settingItemFeedbackTitle = _translationKey("Feedback");
  static final settingItemBugReportTitle = _translationKey("Report a bug");


  static List<String> _translationKey(String key, [String pluralKey]) {
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