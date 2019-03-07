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

import 'package:bloc/bloc.dart';
import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ox_talk/src/data/config.dart';
import 'package:ox_talk/src/log/bloc_delegate.dart';
import 'package:ox_talk/src/chat/create_chat.dart';
import 'package:ox_talk/src/contact/contact_change.dart';
import 'package:ox_talk/src/l10n/localizations.dart';
import 'package:ox_talk/src/login/login.dart';
import 'package:ox_talk/src/main/root.dart';
import 'package:ox_talk/src/main/splash.dart';
import 'package:ox_talk/src/navigation/navigation.dart';
import 'package:ox_talk/src/profile/edit_account_settings.dart';

void main() {
  BlocSupervisor().delegate = DebugBlocDelegate();
  runApp(new OxTalkApp());
}

class OxTalkApp extends StatelessWidget {
  final Navigation navigation = Navigation();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'),
      ],
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
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
  DeltaChatCore _core = DeltaChatCore();
  Context _context = Context();
  bool _coreLoaded = false;
  bool _configured = false;

  @override
  void initState() {
    super.initState();
    _initCoreAndContext();
  }

  @override
  Widget build(BuildContext context) {
    if (!_coreLoaded) {
      return new Splash();
    } else {
      return _buildMainScreen();
    }
  }

  void _initCoreAndContext() async {
    await _core.init();
    await _isConfigured();
    await _setupDefaultValues();
    setState(() {
      _coreLoaded = true;
    });
  }

  Future _setupDefaultValues() async {
    String status = await _context.getConfigValue(Context.configSelfStatus);
    if (status == AppLocalizations.of(context).deltaChatStatusDefaultValue) {
      Config config = Config();
      config.setValue(Context.configSelfStatus, AppLocalizations.of(context).editUserSettingsStatusDefaultValue);
    }
  }

  Future _isConfigured() async {
    _configured = await _context.isConfigured();
  }

  Widget _buildMainScreen() {
    if (_configured) {
      return new Root();
    } else {
      return new Login(loginSuccess);
    }
  }

  void loginSuccess() async {
    setState(() {
      _configured = true;
    });
  }
}
