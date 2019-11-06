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
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/login/login_bloc.dart';
import 'package:ox_coi/src/login/login_events_state.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/platform/system_interaction.dart';
import 'package:ox_coi/src/settings/settings_manual_form.dart';
import 'package:ox_coi/src/settings/settings_manual_form_bloc.dart';
import 'package:ox_coi/src/settings/settings_manual_form_event_state.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/user/user_change_bloc.dart';
import 'package:ox_coi/src/user/user_change_event_state.dart';
import 'package:ox_coi/src/utils/dialog_builder.dart';
import 'package:ox_coi/src/utils/toast.dart';
import 'package:ox_coi/src/widgets/fullscreen_progress.dart';
import 'package:rxdart/rxdart.dart';

import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon_button.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_app_bar.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';

class UserAccountSettings extends StatefulWidget {
  @override
  _UserAccountSettingsState createState() => _UserAccountSettingsState();
}

class _UserAccountSettingsState extends State<UserAccountSettings> {
  UserChangeBloc _userChangeBloc = UserChangeBloc();
  LoginBloc _loginBloc = LoginBloc();
  Navigation navigation = Navigation();
  OverlayEntry _progressOverlayEntry;
  FullscreenProgress _progress;
  bool _showedErrorDialog = false;

  @override
  void initState() {
    super.initState();
    navigation.current = Navigatable(Type.settingsAccount);
    _userChangeBloc.add(RequestUser());
    final userStatesObservable = new Observable<UserChangeState>(_userChangeBloc);
    userStatesObservable.listen((state) => _handleUserChangeStateChange(state));

    final loginObservable = new Observable<LoginState>(_loginBloc);
    loginObservable.listen((event) => handleLoginStateChange(event));
  }

  _handleUserChangeStateChange(UserChangeState state) {
    if (state is UserChangeStateApplied) {
      _showedErrorDialog = false;
      _loginBloc.add(EditButtonPressed());
    } else if (state is UserChangeStateFailure) {
      showToast(state.error);
    }
  }

  void handleLoginStateChange(LoginState state) {
    if (state is LoginStateSuccess || state is LoginStateFailure) {
      if (_progressOverlayEntry != null) {
        _progressOverlayEntry.remove();
        _progressOverlayEntry = null;
      }
    }
    if (state is LoginStateSuccess) {
      showToast(L10n.get(L.settingAccountChanged));
      navigation.pop(context);
    } else if (state is LoginStateFailure) {
      if (!_showedErrorDialog) {
        _showedErrorDialog = true;
        showInformationDialog(
          context: context,
          title: L10n.get(L.settingConfigurationChangeFailed),
          content: state.error,
          navigatable: Navigatable(Type.loginErrorDialog),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (context) {
        var settingsManualFormBloc = SettingsManualFormBloc();
        settingsManualFormBloc.add(SetupSettings(
          shouldLoadConfig: true,
        ));
        return settingsManualFormBloc;
      },
      child: BlocListener<SettingsManualFormBloc, SettingsManualFormState>(
        listener: (BuildContext context, state) {
          if (state is SettingsManualFormStateValidationSuccess) {
            _progress = FullscreenProgress(
              bloc: _loginBloc,
              text: L10n.get(L.loginRunning),
              showProgressValues: true,
              showCancelButton: false,
            );
            _progressOverlayEntry = OverlayEntry(builder: (context) => _progress);
            OverlayState overlayState = Overlay.of(context);
            overlayState.insert(_progressOverlayEntry);
            _userChangeBloc.add(
              UserAccountDataChanged(
                imapLogin: state.imapLogin,
                imapPassword: state.password,
                imapServer: state.imapServer,
                imapPort: state.imapPort,
                imapSecurity: state.imapSecurity,
                smtpLogin: state.smtpLogin,
                smtpPassword: state.password,
                smtpServer: state.smtpServer,
                smtpPort: state.smtpPort,
                smtpSecurity: state.smtpSecurity,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AdaptiveAppBar(
            leadingIcon: new AdaptiveIconButton(
              icon: new AdaptiveIcon(
                icon: IconSource.close,
              ),
              onPressed: () => navigation.pop(context),
            ),
            title: Text(L10n.get(L.settingAccount)),
            actions: <Widget>[
              SaveDataButton(),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(loginManualSettingsPadding),
              child: SettingsManualForm(isLogin: false),
            ),
          ),
        ),
      ),
    );
  }
}

class SaveDataButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdaptiveIconButton(
      icon: AdaptiveIcon(
        icon: IconSource.check,
        key: Key(keyUserAccountAdaptiveIconButtonIconCheck),
      ),
      onPressed: () {
        _saveData(context);
      },
    );
  }

  _saveData(BuildContext context) {
    unFocus(context);
    BlocProvider.of<SettingsManualFormBloc>(context).add(RequestValidateSettings());
  }
}
