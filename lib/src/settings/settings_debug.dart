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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:ox_coi/src/l10n/localizations.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/settings/settings_debug_bloc.dart';
import 'package:ox_coi/src/settings/settings_debug_event_state.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/clipboard.dart';
import 'package:ox_coi/src/widgets/state_info.dart';

class SettingsDebug extends StatefulWidget {
  @override
  _SettingsDebugState createState() => _SettingsDebugState();
}

class _SettingsDebugState extends State<SettingsDebug> {
  SettingsDebugBloc _settingsDebugBloc = SettingsDebugBloc();
  Logger _logger;

  @override
  void initState() {
    super.initState();
    Navigation navigation = Navigation();
    var type = Type.settingsDebug;
    navigation.current = Navigatable(type);
    _logger = Logger(Navigatable.getTag(type));
    _settingsDebugBloc.dispatch(RequestDebug());
  }

  @override
  void dispose() {
    _settingsDebugBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).debugTitle),
        ),
        body: _buildPreferenceList(context));
  }

  Widget _buildPreferenceList(BuildContext context) {
    return BlocBuilder(
      bloc: _settingsDebugBloc,
      builder: (context, state) {
        if (state is SettingsDebugStateInitial) {
          return StateInfo(showLoading: true);
        } else if (state is SettingsDebugStateSuccess) {
          var token = state.token;
          return ListView(
            children: ListTile.divideTiles(context: context, tiles: [
              ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: listItemPadding, horizontal: listItemPaddingBig),
                title: Text(AppLocalizations.of(context).debugFcmToken),
                subtitle: Text(token),
                onTap: () {
                  _logger.info(token);
                  copyToClipboardWithToast(text: token, toastText: getDefaultCopyToastText(context));
                },
              ),
            ]).toList(),
          );
        } else {
          return Center(
            child: Icon(Icons.error),
          );
        }
      },
    );
  }
}
