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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/data/config.dart';
import 'package:ox_coi/src/extensions/color_apis.dart';
import 'package:ox_coi/src/flagged/flagged.dart';
import 'package:ox_coi/src/invite/invite_bloc.dart';
import 'package:ox_coi/src/invite/invite_event_state.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/main/main_bloc.dart';
import 'package:ox_coi/src/main/main_event_state.dart';
import 'package:ox_coi/src/main/root_child.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/platform/app_information.dart';
import 'package:ox_coi/src/platform/preferences.dart';
import 'package:ox_coi/src/qr/qr.dart';
import 'package:ox_coi/src/settings/settings_appearance.dart';
import 'package:ox_coi/src/settings/settings_signature.dart';
import 'package:ox_coi/src/user/user_bloc.dart';
import 'package:ox_coi/src/user/user_change_bloc.dart';
import 'package:ox_coi/src/user/user_change_event_state.dart' as UserChange;
import 'package:ox_coi/src/user/user_event_state.dart';
import 'package:ox_coi/src/user/user_settings.dart';
import 'package:ox_coi/src/utils/constants.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/widgets/dialog_builder.dart';
import 'package:ox_coi/src/widgets/dynamic_appbar.dart';
import 'package:ox_coi/src/widgets/fullscreen_progress.dart';
import 'package:ox_coi/src/widgets/list_group_header.dart';
import 'package:ox_coi/src/widgets/profile_header.dart';
import 'package:ox_coi/src/widgets/settings_item.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfile extends RootChild {
  @override
  _ProfileState createState() => _ProfileState();

  @override
  Color getColor(BuildContext context) {
    return CustomTheme.of(context).onSurface;
  }

  @override
  FloatingActionButton getFloatingActionButton(BuildContext context) {
    return null;
  }

  @override
  String getBottomNavigationText() {
    return L10n.get(L.profile);
  }

  @override
  IconSource getBottomNavigationIcon() {
    return IconSource.accountCircle;
  }

  @override
  DynamicAppBar getAppBar(BuildContext context, StreamController<AppBarAction> appBarActionsStream) {
    return DynamicAppBar(title: L10n.get(L.profileAndSettings));
  }
}

class _ProfileState extends State<UserProfile> {
  UserBloc _userBloc = UserBloc();
  UserChangeBloc _userChangeBloc = UserChangeBloc();
  Navigation navigation = Navigation();
  InviteBloc _inviteBloc = InviteBloc();
  OverlayEntry _progressOverlayEntry;
  String _avatarPath = "";

  @override
  void initState() {
    super.initState();

    navigation.current = Navigatable(Type.profile);
    _userBloc.add(RequestUser());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _inviteBloc,
      listener: (context, state) {
        _progressOverlayEntry?.remove();
      },
      child: BlocBuilder(
          bloc: _userBloc,
          builder: (context, state) {
            if (state is UserStateSuccess) {
              return buildProfileView(state.config);
            } else if (state is UserStateFailure) {
              return new Text(state.error);
            } else {
              return new Container();
            }
          }),
    );
  }

  Widget buildProfileView(Config config) {
    _avatarPath = config.avatarPath;
    return SingleChildScrollView(
      child: IntrinsicHeight(
        child: Container(
          color: CustomTheme.of(context).background,
          child: Column(
            children: <Widget>[
              ProfileData(
                text: config.username,
                secondaryText: config.email,
                avatarPath: _avatarPath,
                placeholderText: L10n.get(L.profileNoUsername),
                imageBackgroundColor: CustomTheme.of(context).onBackground.barely(),
                imageActionCallback: _editPhotoCallback,
                withPlaceholder: true,
                editActionCallback: () => _editUserSettings(),
                child: ProfileHeader(),
              ),
              SettingsItem(
                icon: IconSource.flag,
                text: L10n.get(L.settingItemFlaggedTitle),
                iconBackground: CustomTheme.of(context).flagIcon,
                onTap: () => _settingsItemTapped(context, SettingsItemName.flagged),
                key: Key(keyUserProfileFlagIconSource),
              ),
              SettingsItem(
                icon: IconSource.qr,
                text: L10n.get(L.settingItemQRTitle),
                iconBackground: CustomTheme.of(context).qrIcon,
                onTap: () => _settingsItemTapped(context, SettingsItemName.qrShow),
                key: Key(keyUserProfileQrIconSource),
              ),
              SettingsItem(
                icon: IconSource.personAdd,
                text: L10n.get(L.settingItemInviteTitle),
                iconBackground: CustomTheme.of(context).inviteIcon,
                onTap: () => _settingsItemTapped(context, SettingsItemName.invite),
                key: Key(keyUserProfilePersonAddIconSource),
              ),
              ListGroupHeader(
                text: L10n.get(L.settingGroupHeaderGeneralTitle),
              ),
              SettingsItem(
                icon: IconSource.appearance,
                text: SettingsAppearance.viewTitle,
                iconBackground: CustomTheme.of(context).appearanceIcon,
                onTap: () => _settingsItemTapped(context, SettingsItemName.appearance),
                key: Key(keyUserProfileAppearanceIconSource),
              ),
              SettingsItem(
                icon: IconSource.notifications,
                text: L10n.get(L.settingItemNotificationsTitle),
                iconBackground: CustomTheme.of(context).notificationIcon,
                onTap: () => _settingsItemTapped(context, SettingsItemName.notification),
                key: Key(keyUserProfileNotificationIconSource),
              ),
              SettingsItem(
                icon: IconSource.chat,
                text: L10n.get(L.settingItemChatTitle),
                iconBackground: CustomTheme.of(context).chatIcon,
                onTap: () => _settingsItemTapped(context, SettingsItemName.chat),
                key: Key(keyUserProfileChatIconSource),
              ),
              ListGroupHeader(
                text: L10n.get(L.settingGroupHeaderEmailTitle),
              ),
              SettingsItem(
                icon: IconSource.signature,
                text: L10n.get(L.settingItemSignatureTitle),
                iconBackground: CustomTheme.of(context).signatureIcon,
                onTap: () => _settingsItemTapped(context, SettingsItemName.signature),
                key: Key(keyUserProfileSignatureIconSource),
              ),
              SettingsItem(
                icon: IconSource.serverSetting,
                text: L10n.get(L.settingItemServerSettingsTitle),
                iconBackground: CustomTheme.of(context).serverSettingsIcon,
                onTap: () => _settingsItemTapped(context, SettingsItemName.serverSetting),
                key: Key(keyUserProfileServerSettingIconSource),
              ),
              ListGroupHeader(
                text: L10n.get(L.settingGroupHeaderSecurityTitle),
              ),
              SettingsItem(
                icon: IconSource.security,
                text: L10n.get(L.settingItemDataProtectionTitle),
                iconBackground: CustomTheme.of(context).dataProtectionIcon,
                onTap: () => _settingsItemTapped(context, SettingsItemName.dataProtection),
                key: Key(keyUserProfileSecurityIconSource),
              ),
              SettingsItem(
                icon: IconSource.block,
                text: L10n.get(L.settingItemBlockedTitle),
                iconBackground: CustomTheme.of(context).blockIcon,
                onTap: () => _settingsItemTapped(context, SettingsItemName.blocked),
                key: Key(keyUserProfileBlockIconSource),
              ),
              SettingsItem(
                icon: IconSource.lock,
                text: L10n.get(L.settingItemEncryptionTitle),
                iconBackground: CustomTheme.of(context).encryptionIcon,
                onTap: () => _settingsItemTapped(context, SettingsItemName.encryption),
                key: Key(keyUserProfileLockIconSource),
              ),
              ListGroupHeader(
                text: "",
              ),
              SettingsItem(
                icon: IconSource.info,
                text: L10n.get(L.settingItemAboutTitle),
                iconBackground: CustomTheme.of(context).aboutIcon,
                onTap: () => _settingsItemTapped(context, SettingsItemName.about),
                key: Key(keyUserProfileInfoIconSource),
              ),
              SettingsItem(
                icon: IconSource.feedback,
                text: L10n.get(L.settingItemFeedbackTitle),
                iconBackground: CustomTheme.of(context).feedbackIcon,
                showChevron: false,
                onTap: () => _settingsItemTapped(context, SettingsItemName.feedback),
                key: Key(keyUserProfileFeedbackIconSource),
              ),
              SettingsItem(
                icon: IconSource.bugReport,
                text: L10n.get(L.settingItemBugReportTitle),
                iconBackground: CustomTheme.of(context).bugReportIcon,
                showChevron: false,
                onTap: () => _settingsItemTapped(context, SettingsItemName.bugReport),
                key: Key(keyUserProfileBugReportIconSource),
              ),
              if (!isRelease())
                SettingsItem(
                  icon: IconSource.bugReport,
                  text: L10n.get(L.debug),
                  iconBackground: CustomTheme.of(context).bugReportIcon,
                  onTap: () => _settingsItemTapped(context, SettingsItemName.debug),
                ),
              ListGroupHeader(
                text: "",
              ),
              SettingsItem(
                icon: IconSource.logout,
                text: L10n.get(L.logoutTitle),
                iconBackground: CustomTheme.of(context).logoutIcon,
                showChevron: false,
                onTap: () => _settingsItemTapped(context, SettingsItemName.logout),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _settingsItemTapped(BuildContext context, SettingsItemName settingsItemName) {
    switch (settingsItemName) {
      case SettingsItemName.flagged:
        navigation.push(
          context,
          MaterialPageRoute(builder: (context) => Flagged()),
        );
        break;
      case SettingsItemName.qrShow:
        navigation.push(
          context,
          MaterialPageRoute(builder: (context) => QrCode(chatId: 0)),
        );
        break;
      case SettingsItemName.invite:
        _createInviteUrl();
        break;
      case SettingsItemName.appearance:
        navigation.pushNamed(context, Navigation.settingsAppearance);
        break;
      case SettingsItemName.notification:
        navigation.pushNamed(context, Navigation.settingsNotifications);
        break;
      case SettingsItemName.chat:
        navigation.pushNamed(context, Navigation.settingsChat);
        break;
      case SettingsItemName.signature:
        navigation.push(
          context,
          MaterialPageRoute(builder: (context) => EmailSignature()),
        );
        break;
      case SettingsItemName.serverSetting:
        navigation.pushNamed(context, Navigation.settingsAccount);
        break;
      case SettingsItemName.darkMode:
        navigation.pushNamed(context, Navigation.settingsChat);
        break;
      case SettingsItemName.dataProtection:
        navigation.pushNamed(context, Navigation.settingsAntiMobbing);
        break;
      case SettingsItemName.blocked:
        navigation.pushNamed(context, Navigation.contactsBlocked);
        break;
      case SettingsItemName.encryption:
        navigation.pushNamed(context, Navigation.settingsEncryption);
        break;
      case SettingsItemName.about:
        navigation.pushNamed(context, Navigation.settingsAbout);
        break;
      case SettingsItemName.feedback:
        launch(featureRequestUrl, forceSafariVC: false);
        break;
      case SettingsItemName.bugReport:
        launch(issueUrl, forceSafariVC: false);
        break;
      case SettingsItemName.logout:
        _showLogoutDialog(context: context);
        break;
      case SettingsItemName.debug:
        navigation.pushNamed(context, Navigation.settingsDebug);
        break;
    }
  }

  void _showLogoutDialog({BuildContext context}) {
    showConfirmationDialog(
      context: context,
      title: L10n.get(L.logoutTitle),
      content: L10n.get(L.logoutConfirmationText),
      positiveButton: L10n.get(L.logoutTitle),
      positiveAction: _logoutAction,
      navigatable: Navigatable(Type.logout),
    );
  }

  void _logoutAction() {
    // ignore: close_sinks
    final mainBloc = BlocProvider.of<MainBloc>(context);
    mainBloc.add(Logout());
  }

  void _editPhotoCallback(String avatarPath) {
    setState(() {
      _avatarPath = avatarPath;
    });
    _userChangeBloc.add(UserChange.UserAvatarChanged(avatarPath: avatarPath));
  }

  void _editUserSettings() {
    navigation.push(
      context,
      MaterialPageRoute(builder: (context) => UserSettings()),
    );
  }

  void _createInviteUrl() {
    _progressOverlayEntry = FullscreenOverlay(
      fullscreenProgress: FullscreenProgress(
        bloc: _inviteBloc,
        text: L10n.get(L.pleaseWait),
      ),
    );
    Overlay.of(context).insert(_progressOverlayEntry);
    _inviteBloc.add(CreateInviteUrl());
  }
}
