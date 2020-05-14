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
  final Navigation _navigation = Navigation();
  final InviteBloc _inviteBloc = InviteBloc();
  final UserChangeBloc _userChangeBloc = UserChangeBloc();

  UserBloc _userBloc;
  OverlayEntry _progressOverlayEntry;
  String _avatarPath = "";

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.profile);

    _userBloc = UserBloc(userChangeBloc: _userChangeBloc);
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
              final config = state.config;
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
                          pushesNewScreen: true,
                          icon: IconSource.flag,
                          text: L10n.get(L.settingItemFlaggedTitle),
                          iconBackground: CustomTheme.of(context).flagIcon,
                          onTap: () => _navigation.push(
                            context,
                            MaterialPageRoute(builder: (context) => Flagged()),
                          ),
                          key: Key(keyUserProfileFlagIconSource),
                        ),
                        SettingsItem(
                          pushesNewScreen: true,
                          icon: IconSource.qr,
                          text: L10n.get(L.settingItemQRTitle),
                          iconBackground: CustomTheme.of(context).qrIcon,
                          onTap: () => _navigation.push(
                            context,
                            MaterialPageRoute(builder: (context) => QrCode(chatId: 0)),
                          ),
                          key: Key(keyUserProfileQrIconSource),
                        ),
                        SettingsItem(
                          pushesNewScreen: false,
                          icon: IconSource.personAdd,
                          text: L10n.get(L.settingItemInviteTitle),
                          iconBackground: CustomTheme.of(context).inviteIcon,
                          onTap: _createInviteUrl,
                          key: Key(keyUserProfilePersonAddIconSource),
                        ),
                        ListGroupHeader(
                          text: L10n.get(L.settingGroupHeaderGeneralTitle),
                        ),
                        SettingsItem(
                          pushesNewScreen: true,
                          icon: IconSource.appearance,
                          text: SettingsAppearance.viewTitle,
                          iconBackground: CustomTheme.of(context).appearanceIcon,
                          onTap: () => _navigation.pushNamed(context, Navigation.settingsAppearance),
                          key: Key(keyUserProfileAppearanceIconSource),
                        ),
                        SettingsItem(
                          pushesNewScreen: true,
                          icon: IconSource.notifications,
                          text: L10n.get(L.settingItemNotificationsTitle),
                          iconBackground: CustomTheme.of(context).notificationIcon,
                          onTap: () => _navigation.pushNamed(context, Navigation.settingsNotifications),
                          key: Key(keyUserProfileNotificationIconSource),
                        ),
                        SettingsItem(
                          pushesNewScreen: true,
                          icon: IconSource.chat,
                          text: L10n.get(L.settingItemChatTitle),
                          iconBackground: CustomTheme.of(context).chatIcon,
                          onTap: () => _navigation.pushNamed(context, Navigation.settingsChat),
                          key: Key(keyUserProfileChatIconSource),
                        ),
                        ListGroupHeader(
                          text: L10n.get(L.settingGroupHeaderEmailTitle),
                        ),
                        SettingsItem(
                          pushesNewScreen: true,
                          icon: IconSource.signature,
                          text: L10n.get(L.settingItemSignatureTitle),
                          iconBackground: CustomTheme.of(context).signatureIcon,
                          onTap: () => _navigation.push(
                            context,
                            MaterialPageRoute(builder: (context) => EmailSignature()),
                          ),
                          key: Key(keyUserProfileSignatureIconSource),
                        ),
                        SettingsItem(
                          pushesNewScreen: true,
                          icon: IconSource.serverSetting,
                          text: L10n.get(L.settingItemServerSettingsTitle),
                          iconBackground: CustomTheme.of(context).serverSettingsIcon,
                          onTap: () => _navigation.pushNamed(context, Navigation.settingsAccount),
                          key: Key(keyUserProfileServerSettingIconSource),
                        ),
                        ListGroupHeader(
                          text: L10n.get(L.settingGroupHeaderSecurityTitle),
                        ),
                        SettingsItem(
                          pushesNewScreen: true,
                          icon: IconSource.security,
                          text: L10n.get(L.settingItemDataProtectionTitle),
                          iconBackground: CustomTheme.of(context).dataProtectionIcon,
                          onTap: () => _navigation.pushNamed(context, Navigation.settingsAntiMobbing),
                          key: Key(keyUserProfileSecurityIconSource),
                        ),
                        SettingsItem(
                          pushesNewScreen: true,
                          icon: IconSource.block,
                          text: L10n.get(L.settingItemBlockedTitle),
                          iconBackground: CustomTheme.of(context).blockIcon,
                          onTap: () => _navigation.pushNamed(context, Navigation.contactsBlocked),
                          key: Key(keyUserProfileBlockIconSource),
                        ),
                        SettingsItem(
                          pushesNewScreen: true,
                          icon: IconSource.lock,
                          text: L10n.get(L.settingItemEncryptionTitle),
                          iconBackground: CustomTheme.of(context).encryptionIcon,
                          onTap: () => _navigation.pushNamed(context, Navigation.settingsEncryption),
                          key: Key(keyUserProfileLockIconSource),
                        ),
                        ListGroupHeader(
                          text: "",
                        ),
                        SettingsItem(
                          pushesNewScreen: true,
                          icon: IconSource.info,
                          text: L10n.get(L.settingItemAboutTitle),
                          iconBackground: CustomTheme.of(context).aboutIcon,
                          onTap: () => _navigation.pushNamed(context, Navigation.settingsAbout),
                          key: Key(keyUserProfileInfoIconSource),
                        ),
                        SettingsItem(
                          pushesNewScreen: false,
                          icon: IconSource.feedback,
                          text: L10n.get(L.settingItemFeedbackTitle),
                          iconBackground: CustomTheme.of(context).feedbackIcon,
                          onTap: () => launch(featureRequestUrl, forceSafariVC: false),
                          key: Key(keyUserProfileFeedbackIconSource),
                        ),
                        SettingsItem(
                          pushesNewScreen: false,
                          icon: IconSource.bugReport,
                          text: L10n.get(L.settingItemBugReportTitle),
                          iconBackground: CustomTheme.of(context).bugReportIcon,
                          onTap: () => launch(issueUrl, forceSafariVC: false),
                          key: Key(keyUserProfileBugReportIconSource),
                        ),
                        if (!isRelease())
                          SettingsItem(
                            pushesNewScreen: true,
                            icon: IconSource.bugReport,
                            text: L10n.get(L.debug),
                            iconBackground: CustomTheme.of(context).bugReportIcon,
                            onTap: () => _navigation.pushNamed(context, Navigation.settingsDebug),
                          ),
                        ListGroupHeader(
                          text: "",
                        ),
                        SettingsItem(
                          pushesNewScreen: false,
                          icon: IconSource.logout,
                          text: L10n.get(L.logoutTitle),
                          iconBackground: CustomTheme.of(context).logoutIcon,
                          onTap: () => _showLogoutDialog(context: context),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is UserStateFailure) {
              return Text(state.error);
            } else {
              return Container();
            }
          }),
    );
  }

  void _showLogoutDialog({BuildContext context}) {
    showConfirmationDialog(
      context: context,
      title: L10n.get(L.logoutTitle),
      contentText: L10n.get(L.logoutConfirmationText),
      positiveButton: L10n.get(L.logoutTitle),
      positiveAction: _logoutAction,
      navigatable: Navigatable(Type.logout),
    );
  }

  void _logoutAction() {
    BlocProvider.of<MainBloc>(context).add(Logout());
  }

  void _editPhotoCallback(String avatarPath) {
    setState(() {
      _avatarPath = avatarPath;
    });
    _userChangeBloc.add(UserChange.UserAvatarChanged(avatarPath: avatarPath));
  }

  void _editUserSettings() async {
    _navigation.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: _userChangeBloc,
          child: UserSettings(),
        ),
      ),
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
