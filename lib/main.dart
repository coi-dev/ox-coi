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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'package:ox_coi/src/background/background_bloc.dart';
import 'package:ox_coi/src/background/background_event_state.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/log/log_manager.dart';
import 'package:ox_coi/src/login/login.dart';
import 'package:ox_coi/src/main/main_bloc.dart';
import 'package:ox_coi/src/main/main_event_state.dart';
import 'package:ox_coi/src/main/root.dart';
import 'package:ox_coi/src/main/splash.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/push/push_bloc.dart';
import 'package:ox_coi/src/push/push_event_state.dart';
import 'package:ox_coi/src/share/share_bloc.dart';
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/widgets/view_switcher.dart';

void main() {
  LogManager _logManager = LogManager();
  _logManager.setup(logToFile: false, logLevel: Level.INFO);
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<BackgroundBloc>(
          builder: (BuildContext context) {
            var backgroundBloc = BackgroundBloc();
            backgroundBloc.dispatch(BackgroundListenerSetup());
            return backgroundBloc;
          },
        ),
        BlocProvider<PushBloc>(
          builder: (BuildContext context) => PushBloc(),
        )
      ],
      child: OxCoiApp(),
    ),
  );
}

class OxCoiApp extends StatelessWidget {
  final navigation = Navigation();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: primary,
        accentColor: accent,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: L10n.supportedLocales,
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        L10n.loadTranslation(deviceLocale);
        L10n.setLanguage(deviceLocale);
        return deviceLocale;
      },
      initialRoute: Navigation.root,
      routes: navigation.routesMapping,
    );
  }
}

class OxCoi extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OxCoiState();
}

class _OxCoiState extends State<OxCoi> {
  MainBloc _mainBloc = MainBloc();
  ShareBloc shareBloc = ShareBloc();

  @override
  void initState() {
    super.initState();
    _mainBloc.dispatch(PrepareApp(context: context));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _mainBloc,
      builder: (context, state) {
        Widget child;
        if (state is MainStateSuccess) {
          if (state.configured) {
            child = Root();
          } else {
            child = Login(success: _loginSuccess);
          }
        } else {
          child = Splash();
        }
        return ViewSwitcher(child);
      },
    );
  }

  _loginSuccess() {
    BlocProvider.of<PushBloc>(context).dispatch(RegisterPushResource());
    Navigation navigation = Navigation();
    navigation.popUntil(context, ModalRoute.withName(Navigation.root));
    _mainBloc.dispatch(AppLoaded(configured: true));
  }
}
