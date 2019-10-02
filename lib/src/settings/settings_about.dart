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
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/settings/settings_about_bloc.dart';
import 'package:ox_coi/src/settings/settings_about_event_state.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/ui/strings.dart';
import 'package:ox_coi/src/widgets/state_info.dart';


import 'package:url_launcher/url_launcher.dart';

class SettingsAbout extends StatefulWidget {
  @override
  _SettingsAboutState createState() => _SettingsAboutState();
}

class _SettingsAboutState extends State<SettingsAbout> {
  SettingsAboutBloc _settingsAboutBloc = SettingsAboutBloc();

  @override
  void initState() {
    super.initState();
    Navigation navigation = Navigation();
    navigation.current = Navigatable(Type.settingsAbout);
    _settingsAboutBloc.dispatch(RequestAbout());
  }

  @override
  void dispose() {
    _settingsAboutBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(L10n.get(L.about)),
        ),
        body: _buildPreferenceList(context));
  }

  Widget _buildPreferenceList(BuildContext context) {
    return BlocBuilder(
      bloc: _settingsAboutBloc,
      builder: (context, state) {
        if (state is SettingsAboutStateInitial) {
          return StateInfo(showLoading: true);
        } else if (state is SettingsAboutStateSuccess) {
          return ListView(
            children: ListTile.divideTiles(context: context, tiles: [
              ListTile(
                title: Text(L10n.get(L.appName)),
                subtitle: Text(state.name),
              ),
              ListTile(
                title: Text(L10n.get(L.appVersion)),
                subtitle: Text(state.version),
              ),
              ListTile(
                title: Text(L10n.get(L.settingAboutFeatureRequests)),
                subtitle: Text(L10n.get(L.settingAboutFeatureRequestsText)),
                onTap: () {
                  launch(featureRequestUrl, forceSafariVC: false);
                },
              ),
              ListTile(
                title: Text(L10n.get(L.settingAboutBugReports)),
                subtitle: Text(L10n.get(L.settingAboutBugReportsText)),
                onTap: () {
                  launch(issueUrl, forceSafariVC: false);
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
