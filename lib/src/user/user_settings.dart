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
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/extensions/string_apis.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/user/user_change_bloc.dart';
import 'package:ox_coi/src/user/user_change_event_state.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/widgets/dynamic_appbar.dart';
import 'package:ox_coi/src/widgets/profile_header.dart';

class UserSettings extends StatefulWidget {
  @override
  _UserSettingsState createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  final Navigation _navigation = Navigation();
  final TextEditingController _usernameController = TextEditingController();
  UserChangeBloc _userChangeBloc;
  String _avatar;

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.settingsUser);
    _userChangeBloc = BlocProvider.of<UserChangeBloc>(context);
    _userChangeBloc.add(RequestUser());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: L10n.get(L.profileEdit),
        leading: AppBarCloseButton(context: context),
        trailingList: [
          IconButton(
            key: Key(keyUserSettingsCheckIconButton),
            icon: AdaptiveIcon(icon: IconSource.check),
            onPressed: _saveChanges,
          )
        ],
      ),
      body: BlocConsumer(
        bloc: _userChangeBloc,
        listener: (context, state) {
          if (state is UserChangeStateSuccess) {
            final config = state.config;
            final avatarPath = config.avatarPath;
            _usernameController.text = config.username;
            if (!avatarPath.isNullOrEmpty()) {
              _avatar = config.avatarPath;
            }
          } else if (state is UserChangeStateApplied) {
            _navigation.pop(context);
          }
        },
        builder: (context, state) {
          if (state is UserChangeStateSuccess) {
            return EditableProfileHeader(
              nameController: _usernameController,
              avatar: _avatar,
              imageChangedCallback: _setAvatar,
              placeholder: L10n.get(L.username),
            );
          } else if (state is UserChangeStateFailure) {
            return Text(state.error);
          } else {
            return Container();
          }
        },
      ),
    );
  }

  _setAvatar(String avatarPath) {
    setState(() {
      _avatar = avatarPath;
    });
  }

  void _saveChanges() async {
    final avatarPath = !_avatar.isNullOrEmpty() ? _avatar : null;
    _userChangeBloc.add(UserPersonalDataChanged(username: _usernameController.text, avatarPath: avatarPath));
  }
}
