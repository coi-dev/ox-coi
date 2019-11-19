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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon_button.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_raised_button.dart';
import 'package:ox_coi/src/data/config.dart';
import 'package:ox_coi/src/invite/invite_bloc.dart';
import 'package:ox_coi/src/invite/invite_event_state.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/main/root_child.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/qr/qr.dart';
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/user/user_bloc.dart';
import 'package:ox_coi/src/user/user_event_state.dart';
import 'package:ox_coi/src/user/user_settings.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/widgets/fullscreen_progress.dart';
import 'package:ox_coi/src/widgets/placeholder_text.dart';
import 'package:ox_coi/src/widgets/profile_header.dart';

class UserProfile extends RootChild {
  UserProfile({State<StatefulWidget> state}) : super(state: state);

  @override
  _ProfileState createState() {
    final state = _ProfileState();
    setActions([state.getSettings()]);
    return state;
  }

  @override
  Color getColor() {
    return primary;
  }

  @override
  FloatingActionButton getFloatingActionButton(BuildContext context) {
    return null;
  }

  @override
  String getTitle(BuildContext context) {
    return L10n.get(L.profile);
  }

  @override
  String getNavigationText(BuildContext context) {
    return L10n.get(L.profile);
  }

  @override
  IconSource getNavigationIcon() {
    return IconSource.accountCircle;
  }
}

class _ProfileState extends State<UserProfile> {
  UserBloc _userBloc = UserBloc();
  Navigation navigation = Navigation();
  InviteBloc _inviteBloc = InviteBloc();
  OverlayEntry _fullScreenOverlayEntry;

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
        _fullScreenOverlayEntry.remove();
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
    return Container(
      constraints: BoxConstraints.expand(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: profileSectionsVerticalPadding),
              child: buildAvatar(config),
            ),
            PlaceholderText(
              text: config.username,
              style: Theme.of(context).textTheme.headline,
              align: TextAlign.center,
              placeholderText: L10n.get(L.profileNoUsername),
              placeholderStyle: Theme.of(context).textTheme.headline.apply(color: onBackground.withOpacity(disabled)),
              placeHolderAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.only(top: profileVerticalPadding),
              child: Text(
                config.email,
                style: Theme.of(context).textTheme.subhead,
                key: Key(keyUserProfileEmailText),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: profileSectionsVerticalPadding),
              child: PlaceholderText(
                text: config.status,
                align: TextAlign.center,
                style: Theme.of(context).textTheme.subhead,
                placeholderText: L10n.get(L.profileNoSignature),
                placeholderStyle: Theme.of(context).textTheme.subhead.apply(color: onBackground.withOpacity(disabled)),
                placeHolderAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AdaptiveRaisedButton(
                  child: Text(L10n.get(L.profileEdit)),
                  onPressed: editUserSettings,
                  color: accent,
                  textColor: onAccent,
                  key: Key(keyUserProfileEditProfileRaisedButton),
                ),
                Padding(padding: EdgeInsets.all(chatProfileButtonPadding)),
                AdaptiveRaisedButton(
                  child: Text(L10n.get(L.qrProfile)),
                  onPressed: showQr,
                  color: accent,
                  textColor: onAccent,
                  key: Key(keyUserProfileShowQrRaisedButton),
                ),
              ],
            ),
            AdaptiveRaisedButton(
              child: Text(L10n.get(L.profileShareInviteUrl)),
              onPressed: createInviteUrl,
              color: accent,
              textColor: onAccent,
              key: Key(""),
            ),
          ],
        ),
      ),
    );
  }

  ProfileData buildAvatar(Config config) {
    return ProfileData(
        color: accent,
        child: ProfileAvatar(
          imagePath: config.avatarPath,
        ));
  }

  Widget getSettings() {
    return AdaptiveIconButton(
      icon: AdaptiveIcon(
        icon: IconSource.settings,
      ),
      onPressed: () => _settings(context),
      key: Key(keyUserProfileSettingsAdaptiveIcon),
    );
  }

  _settings(BuildContext context) {
    navigation.pushNamed(context, Navigation.settings);
  }

  editUserSettings() {
    navigation.push(
      context,
      MaterialPageRoute(builder: (context) => UserSettings()),
    );
  }

  showQr() {
    navigation.push(
      context,
      MaterialPageRoute(builder: (context) => QrCode(chatId: 0)),
    );
  }

  createInviteUrl() {
    _fullScreenOverlayEntry = OverlayEntry(
      builder: (context) => FullscreenProgress(
        bloc: _inviteBloc,
        text: L10n.get(L.pleaseWait),
      ),
    );
    Overlay.of(context).insert(_fullScreenOverlayEntry);
    _inviteBloc.add(CreateInviteUrl());
  }
}
