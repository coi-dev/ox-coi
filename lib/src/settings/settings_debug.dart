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
import 'package:logging/logging.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_app_bar.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/platform/preferences.dart';
import 'package:ox_coi/src/push/push_bloc.dart';
import 'package:ox_coi/src/push/push_event_state.dart';
import 'package:ox_coi/src/settings/settings_debug_bloc.dart';
import 'package:ox_coi/src/settings/settings_debug_event_state.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/clipboard.dart';
import 'package:ox_coi/src/utils/toast.dart';
import 'package:ox_coi/src/widgets/dynamic_appbar.dart';
import 'package:ox_coi/src/widgets/state_info.dart';

class SettingsDebug extends StatefulWidget {
  @override
  _SettingsDebugState createState() => _SettingsDebugState();
}

class _SettingsDebugState extends State<SettingsDebug> {
  SettingsDebugBloc _settingsDebugBloc = SettingsDebugBloc();
  Logger _logger;
  PushBloc _pushBloc;
  Navigation navigation = Navigation();

  @override
  void initState() {
    super.initState();
    var type = Type.settingsDebug;
    navigation.current = Navigatable(type);
    _logger = Logger(Navigatable.getTag(type));
    _settingsDebugBloc.add(RequestDebug());
    _pushBloc = BlocProvider.of<PushBloc>(context);
    _pushBloc.listen((state) {
      if (state is PushStateSuccess) {
        _settingsDebugBloc.add(RequestDebug());
      }
    });
  }

  @override
  void dispose() {
    _settingsDebugBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: L10n.get(L.debug),
        leading: AppBarBackButton(context: context),
      ),
      body: BlocBuilder(
        bloc: _settingsDebugBloc,
        builder: (context, state) {
          if (state is SettingsDebugStateInitial) {
            return StateInfo(showLoading: true);
          } else if (state is SettingsDebugStateSuccess) {
            var token = state.token;
            var pushResource = state.pushResource;
            var pushData = "Push status: ${state.pushState}\n"
                "Push endpoint: ${state.endpoint}\n"
                "Push service url: ${state.pushServiceUrl}";
            return ListView(
              children: ListTile.divideTiles(context: context, tiles: [
                ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: listItemPadding, horizontal: listItemPadding),
                  title: Text(L10n.get(L.debugFCMToken)),
                  subtitle: Text(token),
                  onTap: () {
                    _logger.info(token);
                    copyToClipboardWithToast(text: token, toastText: getDefaultCopyToastText(context));
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: listItemPadding, horizontal: listItemPadding),
                  title: Text(L10n.get(L.debugPushData)),
                  subtitle: Text(pushData),
                  onTap: () {
                    _logger.info(pushData);
                    copyToClipboardWithToast(text: pushData, toastText: getDefaultCopyToastText(context));
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: listItemPadding, horizontal: listItemPadding),
                  title: Text(L10n.get(L.debugPushResource)),
                  subtitle: Text(pushResource),
                  onTap: () {
                    _logger.info(pushResource);
                    copyToClipboardWithToast(text: pushResource, toastText: getDefaultCopyToastText(context));
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: listItemPadding, horizontal: listItemPadding),
                  title: Text(L10n.get(L.debugPushResourceRegister)),
                  onTap: () {
                    _pushBloc.add(RegisterPushResource());
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: listItemPadding, horizontal: listItemPadding),
                  title: Text(L10n.get(L.debugPushResourceDelete)),
                  onTap: () {
                    _pushBloc.add(DeletePushResource());
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: listItemPadding, horizontal: listItemPadding),
                  title: Text("Manually set push service url"),
                  subtitle: TextField(
                    // TODO remove
                    onSubmitted: (text) async {
                      await setPreference(preferenceNotificationsPushServiceUrl, text);
                      showToast("$text was set as push service URL");
                      _settingsDebugBloc.add(RequestDebug());
                    },
                  ),
                ),
              ]).toList(),
            );
          } else {
            return Center(
              child: AdaptiveIcon(
                  icon: IconSource.error
              ),
            );
          }
        },
      ),
    );
  }
}
