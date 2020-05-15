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
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:ox_coi/src/background_refresh/background_refresh_manager.dart';
import 'package:ox_coi/src/contact/contact_list_bloc.dart';
import 'package:ox_coi/src/contact/contact_list_event_state.dart';
import 'package:ox_coi/src/customer/customer.dart';
import 'package:ox_coi/src/customer/model/customer_chat.dart';
import 'package:ox_coi/src/data/config.dart';
import 'package:ox_coi/src/data/contact_extension.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/error/error_bloc.dart';
import 'package:ox_coi/src/error/error_event_state.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/main/main_event_state.dart';
import 'package:ox_coi/src/notifications/local_notification_manager.dart';
import 'package:ox_coi/src/notifications/notification_manager.dart';
import 'package:ox_coi/src/platform/app_information.dart';
import 'package:ox_coi/src/platform/preferences.dart';
import 'package:ox_coi/src/push/push_manager.dart';
import 'package:ox_coi/src/utils/constants.dart';
import 'package:ox_coi/src/utils/url_preview_cache.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  final _logger = Logger("main_bloc");
  final _notificationManager = NotificationManager();
  final _pushManager = PushManager();
  final _localNotificationManager = LocalNotificationManager();

  Config _config = Config();
  Context _context = Context();

  var _core = DeltaChatCore();
  DeltaChatCore get core => _core;

  final ErrorBloc _errorBloc;
  StreamSubscription _errorBlocSubscription;

  MainBloc(this._errorBloc) {
    _errorBlocSubscription = _errorBloc.listen((state) {
      if (state is ErrorStateUserVisibleError) {
        add(UserVisibleErrorEncountered(userVisibleError: state.userVisibleError));
      }
    });
  }

  @override
  MainState get initialState => MainStateInitial();

  @override
  Future<void> close() {
    _errorBlocSubscription.cancel();
    return super.close();
  }

  @override
  Stream<MainState> mapEventToState(MainEvent event) async* {
    if (event is PrepareApp) {
      yield MainStateLoading();
      try {
        await _initCore();
        await _openExtensionDatabase();
        await _setupDatabaseExtensions();
        String appState = await getPreference(preferenceAppState);
        if (appState == null || appState.isEmpty) {
          await _setupDefaultValues();
        }
        await _setupBlocs();

        await Customer().configureAsync();
        await UrlPreviewCache().prepareCache();

        add(AppLoaded());
      } catch (error) {
        yield MainStateFailure(error: error.toString());
      }
    } else if (event is AppLoaded) {
      final bool configured = await _context.isConfigured();
      if (configured) {
        await _setupLoggedInAppState();
      }

      final needsOnboarding = Customer.needsOnboarding;
      if (needsOnboarding) {
        await Customer().configureOnboardingAsync();
      }

      final bool hasAuthenticationError = await _checkForAuthenticationError();
      yield MainStateSuccess(
        configured: configured,
        hasAuthenticationError: hasAuthenticationError,
        needsOnboarding: needsOnboarding
      );

    } else if (event is Logout) {
      await _logout();
    } else if (event is DatabaseDeleteErrorEncountered) {
      yield MainStateFailure(error: event.error);
    }

    if (event is UserVisibleErrorEncountered) {
      final configured = await _context.isConfigured();
      final hasAuthenticationError = event.userVisibleError == UserVisibleError.authenticationFailed;
      yield MainStateSuccess(
          configured: configured,
          hasAuthenticationError: hasAuthenticationError,
          needsOnboarding: Customer.needsOnboarding
      );
    }
  }

  Future<void> _setupBlocs() async {
    _errorBloc.add(SetupListeners());
  }

  Future<void> setupManagers(BuildContext context) async {
    _notificationManager.setup(context);
    _pushManager.setup(context);
    _localNotificationManager.setup();
  }

  Future<void> _applyCustomerConfig() async {
    if (Customer.chats.length > 0) {
      Context context = Context();
      for (CustomerChat chat in Customer.chats) {
        int contactId = await context.createContact(chat.name, chat.email);
        await context.createChatByContactId(contactId);
      }
    }
  }

  Future<void> _initCore() async {
    await core.init(dbName);
  }

  Future<void> _setupDefaultValues() async {
    await _config.setValue(Context.configSelfStatus, "${L10n.get(L.profileDefaultStatus)} - $projectUrl");
    await _config.setValue(Context.configShowEmails, Context.showEmailsOff);
    String version = await getAppVersion();
    await setPreference(preferenceAppVersion, version);
    await setPreference(preferenceAppState, AppState.initialStartDone.toString());
  }

  Future<void> _setupLoggedInAppState() async {
    var context = Context();
    await _config.load();
    bool coiSupported = await isCoiSupported(context);
    String appState = await getPreference(preferenceAppState);
    if (coiSupported) {
      await _setupCoi(context);
    }
    if (isFreshLogin(appState)) {
      await _setupFreshLoggedInAppState();
    }
    await _config.setValue(Context.configMaxAttachSize, maxAttachmentSize);
    _logger.info("Setting max attachment size to $maxAttachmentSize");
    await setupBackgroundRefreshManager(coiSupported);
    preloadContacts();
  }

  bool isFreshLogin(String appState) => appState == AppState.initialStartDone.toString();

  Future<void> setupBackgroundRefreshManager(bool coiSupported) async {
    bool pullPreference = await getPreference(preferenceNotificationsPull);
    if ((pullPreference == null && !coiSupported) || (pullPreference != null && pullPreference)) {
      var backgroundRefreshManager = BackgroundRefreshManager();
      backgroundRefreshManager.setupAndStart();
    }
  }

  void preloadContacts() {
    // Ignoring false positive https://github.com/felangel/bloc/issues/587
    // ignore: close_sinks
    ContactListBloc contactListBloc = ContactListBloc();
    contactListBloc.add(RequestContacts(typeOrChatId: validContacts));
  }

  Future<void> _setupFreshLoggedInAppState() async {
    await _config.setValue(Context.configRfc724MsgIdPrefix, Context.enableChatPrefix);
    _logger.info("Setting coi message prefix to 1");
    await _applyCustomerConfig();
    await setPreference(preferenceAppState, AppState.initialLoginDone.toString());
  }

  Future<void> _setupCoi(Context context) async {
    if (!await isCoiEnabled(context)) {
      _logger.info("Setting coi enable to 1");
      await context.setCoiEnabled(1, 1);
    }
    if (!await isCoiMessageFilterEnabled(context)) {
      _logger.info("Setting coi message filter to 1");
      await context.setCoiMessageFilter(1, 1);
    }
  }

  Future<bool> isCoiSupported(Context context) async => (await context.isCoiSupported()) == 1;

  Future<bool> isCoiEnabled(Context context) async => (await context.isCoiEnabled()) == 1;

  Future<bool> isCoiMessageFilterEnabled(Context context) async => (await context.isCoiMessageFilterEnabled()) == 1;

  Future<void> _setupDatabaseExtensions() async {
    final contactExtensionProvider = ContactExtensionProvider();
    await contactExtensionProvider.createTable();
  }

  Future<void> _openExtensionDatabase() async {
    final contactExtensionProvider = ContactExtensionProvider();
    await contactExtensionProvider.open(extensionDbName);
  }

  Future<bool> _checkForAuthenticationError() async {
    return await getPreference(preferenceHasAuthenticationError) ?? false;
  }

  Future<void> _logout() async {
    await clearPreferences();

    try {
      final dbFile = File(core.dbPath);
      await dbFile.delete();

      final contactExtensionProvider = ContactExtensionProvider();
      final extensionDbFile = File(contactExtensionProvider.path);
      await extensionDbFile.delete();

      await core.logout();

      if (Platform.isAndroid) {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      }
    } on FileSystemException catch(error) {
      debugPrint(error.toString());
      add(DatabaseDeleteErrorEncountered(error: error));
    }
  }
}
