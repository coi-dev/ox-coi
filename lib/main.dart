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

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ox_talk/src/log/bloc_delegate.dart';
import 'package:ox_talk/src/l10n/localizations.dart';
import 'package:ox_talk/src/login/login.dart';
import 'package:ox_talk/src/main/main_bloc.dart';
import 'package:ox_talk/src/main/main_event.dart';
import 'package:ox_talk/src/main/main_state.dart';
import 'package:ox_talk/src/main/root.dart';
import 'package:ox_talk/src/main/splash.dart';
import 'package:ox_talk/src/navigation/navigation.dart';
import 'package:ox_talk/src/utils/colors.dart';
import 'package:ox_talk/src/widgets/root_view_switcher.dart';

void main() {
  BlocSupervisor().delegate = DebugBlocDelegate();
  runApp(new OxTalkApp());
}

class OxTalkApp extends StatelessWidget {
  final Navigation navigation = Navigation();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
        primaryColor: chatMain,
        accentColor: accent,
      ),
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: Navigation.ROUTES_ROOT,
      routes: navigation.routeMapping,
    );
  }
}

class OxTalk extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OxTalkState();
}

class _OxTalkState extends State<OxTalk> {
  MainBloc _mainBloc = MainBloc();

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
            child = Login(_mainBloc.onLoginSuccess);
          }
        } else {
          child = Splash();
        }
        return RootViewSwitcher(child);
      },
    );
  }
}
