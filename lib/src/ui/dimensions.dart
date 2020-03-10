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

import 'dart:core';

// Global
const zero = 0.0;
const dividerHeight = 1.0;

//default dimensions
const dimension2dp = 2.0;
const dimension4dp = 4.0;
const dimension8dp = 8.0;
const dimension12dp = 12.0;
const dimension16dp = 16.0;
const dimension20dp = 20.0;
const dimension24dp = 24.0;
const dimension28dp = 28.0;
const dimension32dp = 32.0;
const dimension36dp = 36.0;
const dimension40dp = 40.0;
const dimension48dp = 48.0;
const dimension64dp = 64.0;
const dimension72dp = 72.0;

// Buttons
const buttonHeight = 44.0;
const buttonHorizontalContentPadding = dimension16dp;
const buttonMinWidth = 88.0; // https://api.flutter.dev/flutter/material/ButtonTheme/ButtonTheme.html

// Progress
const verticalProgressPadding = dimension8dp;
const imageBlurSigmaValue = 10.0;

// List
const listItemPadding = dimension16dp;
const listItemPaddingSmall = dimension4dp;
const listAvatarRadius = 20.0;
const listAvatarDiameter = listAvatarRadius * 2;
const listStateInfoHorizontalPadding = dimension24dp;
const listStateInfoVerticalPadding = dimension16dp;
const listEmptyHorizontalPadding = 40.0;

const listInviteUnreadIndicatorFontSize = 12.0;
const listInviteUnreadIndicatorBorderRadius = dimension16dp;

// AppBar
const appBarElevationDefault = dimension4dp;

// Icons
const iconTextPadding = dimension4dp;
const iconTextTopPadding = 10.0;
const iconFormPadding = dimension8dp;
const iconSize = 18.0;

// Chat
const composerMessagePadding = 56.0;
const messageListPadding = dimension8dp;
const inviteChoiceButtonSize = 120.0;

// Edit/Add contact
const editAddContactTopPadding = dimension32dp;

//Attachment preview
const previewMaxSize = 100.0;
const previewDefaultIconSize = 100.0;
const previewCloseIconSize = 30.0;
const audioFileImageWidth = 176.0;

// Forms
const formHorizontalPadding = dimension16dp;
const formVerticalPadding = dimension16dp;

//GroupHeader
const groupHeaderHorizontalPadding = dimension16dp;
const groupHeaderBottomPadding = dimension8dp;

//SettingsItem
const settingsItemVerticalPadding = 10.0;

// Messages
const messagesVerticalPadding = dimension8dp;
const messagesVerticalInnerPadding = 11.0;
const messagesVerticalOuterPadding = dimension16dp;
const messagesHorizontalInnerPadding = dimension16dp;
const messagesBoxRadius = 18.0;
const messagesBoxRadiusSmall = dimension2dp;
const messagesFileIconSize = 30.0;
const messagesElevation = 3.0;
const messagesWidthFactor = 0.8;
const messagesUserAvatarGroupSize = 34.0;

// Profile
const profileAvatarSize = 128.0;
const profileHeaderBottomPadding = 18.0;

// Edit profile
const editUserAvatarImageMaxSize = 512;
const editUserAvatarRatio = 1.0;

// Login
const loginLogoSize = 136.0;
const loginHorizontalPadding16dp = dimension16dp;
const loginHorizontalPadding = 40.0;
const loginVerticalPadding = 28.0;
const loginVerticalPaddingBig = 56.0;
const loginTopPadding = dimension28dp;
const loginButtonWidth = 200.0;
const loginVerticalPadding12dp = dimension12dp;
const loginVerticalPadding24dp = dimension24dp;
const loginProviderIconSize = dimension40dp;
const loginManualSettingsSubTitlePadding = dimension8dp;
const loginManualSettingsPadding = dimension20dp;
const loginProviderIconSizeBig = 150.0;
const loginErrorOverlayLeftPadding = dimension12dp;
const loginOtherProviderButtonRadius = 22.0;
const loginWaveTopBottomPadding = dimension32dp;

//Voice Recording
const voiceRecordingAudioPlaybackTopPadding = 30.0;
const voiceRecordingRecordTextContainerWidth = 70.0;
const voiceRecordingStopIconPadding = 18.0;
const voiceRecordingStopLockBackgroundRadius = 30.0;
const voiceRecordingStopPlayLeftPadding = 50.0;

//QR
const qrImageSize = 250.0;

//Custom painter
const verticalLinePainterPositiveY = 10.0;
const verticalLinePainterNegativeY = -10.0;
const barPainterHeight = 30.0;
const barPainterSpaceWidth = 1.0;