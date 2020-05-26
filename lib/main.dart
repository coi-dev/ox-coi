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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/customer/customer.dart';
import 'package:ox_coi/src/customer/customer_delegate.dart';
import 'package:ox_coi/src/customer/customer_delegate_change_notifier.dart';
import 'package:ox_coi/src/dynamic_screen/dynamic_screen.dart';
import 'package:ox_coi/src/error/error_bloc.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/lifecycle/lifecycle_bloc.dart';
import 'package:ox_coi/src/lifecycle/lifecycle_event_state.dart';
import 'package:ox_coi/src/log/log_manager.dart';
import 'package:ox_coi/src/login/login.dart';
import 'package:ox_coi/src/login/password_changed.dart';
import 'package:ox_coi/src/main/main_bloc.dart';
import 'package:ox_coi/src/main/main_event_state.dart';
import 'package:ox_coi/src/main/root.dart';
import 'package:ox_coi/src/main/splash.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/notifications/notification_manager.dart';
import 'package:ox_coi/src/push/push_bloc.dart';
import 'package:ox_coi/src/push/push_event_state.dart';
import 'package:ox_coi/src/widgets/view_switcher.dart';
import 'package:provider/provider.dart';

void main() {
  final LogManager _logManager = LogManager();
  // ignore: close_sinks
  final errorBloc = ErrorBloc();
  // ignore: close_sinks
  final pushBloc = PushBloc();

  WidgetsFlutterBinding.ensureInitialized(); // Required to allow plugin calls prior runApp() (performed by LogManager.setup())
  _logManager.setup(logToFile: true, logLevel: Level.INFO).then((value) => runApp(
        MultiBlocProvider(
          providers: [
            BlocProvider<LifecycleBloc>(
              create: (BuildContext context) {
                var lifecycleBloc = LifecycleBloc();
                lifecycleBloc.add(ListenerSetup());
                return lifecycleBloc;
              },
            ),
            BlocProvider<PushBloc>(
              create: (BuildContext context) => pushBloc,
            ),
            BlocProvider<ErrorBloc>(
              create: (BuildContext context) => errorBloc,
            ),
            BlocProvider<MainBloc>(
              create: (BuildContext context) => MainBloc(errorBloc, pushBloc),
            ),
          ],
          child: CustomTheme(
            initialThemeKey: ThemeKey.light,
            child: OxCoiApp(),
          ),
        ),
      ));
}

class OxCoiApp extends StatelessWidget {
  final navigation = Navigation();

  @override
  Widget build(BuildContext context) {
    var customTheme = CustomTheme.of(context);
    final themeData = ThemeData(
      brightness: customTheme.brightness,
      backgroundColor: customTheme.background,
      scaffoldBackgroundColor: customTheme.background,
      toggleableActiveColor: customTheme.accent,
      accentColor: customTheme.accent,
      primaryIconTheme: Theme.of(context).primaryIconTheme.copyWith(
            color: customTheme.onSurface,
          ),
      primaryTextTheme: Theme.of(context).primaryTextTheme.apply(
            bodyColor: customTheme.onSurface,
          ),
    );

    return MaterialApp(
      theme: themeData,
      themeMode: customTheme.brightness == Brightness.light ? ThemeMode.light : ThemeMode.dark,
      localizationsDelegates: getLocalizationsDelegates(),
      supportedLocales: L10n.supportedLocales,
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        getLocaleResolutionCallback(deviceLocale);
        return deviceLocale;
      },
      initialRoute: Navigation.root,
      routes: navigation.routesMapping,
    );
  }

  List<LocalizationsDelegate> getLocalizationsDelegates() {
    return [
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ];
  }

  void getLocaleResolutionCallback(Locale deviceLocale) {
    L10n.loadTranslation(deviceLocale);
    L10n.setLanguage(deviceLocale);
  }
}

class OxCoi extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OxCoiState();
}

class _OxCoiState extends State<OxCoi> {
  MainBloc _mainBloc;
  Navigation _navigation = Navigation();
  CustomerDelegate _customerDelegate;

  @override
  void initState() {
    super.initState();
    _mainBloc = BlocProvider.of<MainBloc>(context);
    _mainBloc.add(PrepareApp());
    _customerDelegate = CustomerDelegate();
  }

  @override
  Widget build(BuildContext context) {
    return ViewSwitcher(
      child: BlocConsumer(
        bloc: _mainBloc,
        listener: (context, state) {
          if (state is MainStateSuccess) {
            _navigation.popUntilRoot(context);
            if (state.configured && !state.needsOnboarding && !state.hasAuthenticationError && state.notificationsActivated) {
              NotificationManager().setup(context);
            }
          }
        },
        builder: (context, state) {
          if (state is MainStateSuccess) {
            if (state.configured && !state.hasAuthenticationError && state.needsOnboarding) {
              // TODO: NEEDS TO BE DISCUSSED!
              // TODO: Maybe we should add an additional 'Onboarding' layer here, from within the 'DynamicScreen' is being called, just for separation purposes.
              return MultiProvider(providers: [
                Provider<DynamicScreenModel>.value(value: Customer.onboardingModel),
                Provider<DynamicScreenCustomerDelegate>.value(value: _customerDelegate),
                ChangeNotifierProvider<CustomerDelegateChangeNotifier>.value(value: _customerDelegate.changeNotifier)
              ], child: DynamicScreen());
            } else if (state.configured && !state.hasAuthenticationError && !state.needsOnboarding) {
              return Root();
            } else if (state.configured && state.hasAuthenticationError) {
              return PasswordChanged(passwordChangedCallback: () => _loginSuccess);
            } else {
              return Login();
            }
          } else {
            return Splash();
          }
        },
      ),
    );
  }

  void _loginSuccess() {
    BlocProvider.of<PushBloc>(context).add(RegisterPushResource());
    _navigation.popUntilRoot(context);
    _mainBloc.add(AppLoaded());
  }
}
