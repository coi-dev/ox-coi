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
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/error/error_bloc.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/login/providers.dart';
import 'package:ox_coi/src/main/main_bloc.dart';
import 'package:ox_coi/src/main/main_event_state.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/widgets/button.dart';
import 'package:ox_coi/src/widgets/modal_builder.dart';
import 'package:ox_coi/src/widgets/dynamic_appbar.dart';
import 'package:ox_coi/src/widgets/error_banner.dart';
import 'package:ox_coi/src/widgets/fullscreen_progress.dart';
import 'package:ox_coi/src/widgets/validatable_text_form_field.dart';

import 'login_bloc.dart';
import 'login_events_state.dart';
import 'login_manual_settings.dart';

class ProviderSignIn extends StatefulWidget {
  final Provider provider;

  ProviderSignIn({this.provider});

  @override
  _ProviderSignInState createState() => _ProviderSignInState();
}

class _ProviderSignInState extends State<ProviderSignIn> {
  static const providerOther = 'other';
  final _navigation = Navigation();
  final _simpleLoginKey = GlobalKey<FormState>();
  MainBloc _mainBloc;
  OverlayEntry _progressOverlayEntry;
  LoginBloc _loginBloc;
  OverlayEntry _overlayEntry;
  bool isOtherProvider;

  final emailField = ValidatableTextFormField(
    (context) => L10n.get(L.emailAddress),
    hintText: (context) => L10n.get(L.emailAddress),
    textType: TextType.email,
    inputType: TextInputType.emailAddress,
    needValidation: true,
    validationHint: (context) => L10n.get(L.loginCheckMail),
    icon: AdaptiveIcon(icon: IconSource.person),
    key: Key(keyProviderSignInEmailTextField),
  );
  final passwordField = ValidatableTextFormField(
    (context) => L10n.get(L.password),
    hintText: (context) => L10n.get(L.password),
    textType: TextType.password,
    needValidation: true,
    validationHint: (context) => L10n.get(L.loginCheckPassword),
    icon: AdaptiveIcon(icon: IconSource.lock),
    key: Key(keyProviderSignInPasswordTextField),
  );

  @override
  void initState() {
    super.initState();
    _mainBloc = BlocProvider.of<MainBloc>(context);
    _navigation.current = Navigatable(Type.loginProviderSignIn);
    _loginBloc = LoginBloc(BlocProvider.of<ErrorBloc>(context));
    isOtherProvider = widget.provider.id == providerOther;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _navigation.allowBackNavigation,
      child: Scaffold(
        appBar: DynamicAppBar(
          title: isOtherProvider ? L10n.get(L.providerOtherMailProvider) : widget.provider.name,
          leading: AppBarBackButton(context: context),
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<MainBloc, MainState>(
              listener: (context, state){
                _progressOverlayEntry?.remove();
              },
            ),
            BlocListener(
              bloc: _loginBloc,
              listener: (context, state){
                if (!_navigation.current.equal(Navigatable(Type.loginProviderSignIn))) {
                  return;
                }
                if (state is LoginStateSuccess) {
                  _mainBloc.add(AppLoaded());
                } else if (state is LoginStateFailure) {
                  _progressOverlayEntry?.remove();
                  if (!isOtherProvider) {
                    setState(() {
                      this._overlayEntry = this._createErrorOverlayEntry();
                      Overlay.of(context).insert(this._overlayEntry);
                      showInformationDialog(
                        context: context,
                        title: L10n.get(L.loginFailed),
                        contentText: state.error,
                        navigatable: Navigatable(Type.loginErrorDialog),
                      );
                    });
                  } else {
                    _navigation.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginManualSettings(
                              email: emailField.controller.text,
                              password: passwordField.controller.text,
                              fromError: true,
                            )));
                  }
                }
              },
            )
          ],
          child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                  left: loginHorizontalPadding, right: loginHorizontalPadding, bottom: loginVerticalPadding, top: loginTopPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: AssetImage(getProviderIconPath(context, widget.provider.id)),
                    height: loginProviderIconSizeBig,
                    width: loginProviderIconSizeBig,
                  ),
                  Padding(padding: const EdgeInsets.all(loginVerticalListPadding)),
                  Text(
                    isOtherProvider ? L10n.get(L.loginSignIn) : L10n.getFormatted(L.providerSignInTextX, [widget.provider.name]),
                    style: Theme.of(context).textTheme.headline,
                  ),
                  Padding(padding: const EdgeInsets.all(loginVerticalListPadding)),
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: formHorizontalPadding),
                      child: Form(
                        key: _simpleLoginKey,
                        child: Column(
                          children: <Widget>[emailField, passwordField],
                        ),
                      )),
                  Padding(padding: const EdgeInsets.all(dimension24dp)),
                  ButtonImportanceHigh(
                    minimumWidth: loginButtonWidth,
                    child: Text(L10n.get(L.loginSignIn)),
                    onPressed: _signIn,
                  ),
                  Visibility(
                    visible: isOtherProvider,
                    child: Padding(
                      padding: const EdgeInsets.all(loginVerticalListPadding),
                      child: ButtonImportanceLow(
                        minimumWidth: loginButtonWidth,
                        onPressed: _showManualSettings,
                        child: Text(L10n.get(L.settingManual)),
                      ),
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }

  OverlayEntry _createErrorOverlayEntry() {
    return OverlayEntry(
        builder: (context) => ErrorBanner(
              message: L10n.get(L.loginCheckUsernamePassword),
              closePressed: _closeError,
            ));
  }

  void _signIn() {
    FocusScope.of(context).requestFocus(FocusNode());
    final simpleLoginIsValid = _simpleLoginKey.currentState.validate();
    final email = emailField.controller.text;
    final password = passwordField.controller.text;

    if (simpleLoginIsValid) {
      _closeError();
      _progressOverlayEntry = FullscreenOverlay(
        fullscreenProgress: FullscreenProgress(
          bloc: _loginBloc,
          text: L10n.get(L.loginRunning),
          showProgressValues: true,
        ),
      );
      Overlay.of(context).insert(_progressOverlayEntry);
      _loginBloc.add(ProviderLoginButtonPressed(email: email, password: password, provider: widget.provider));
    }
  }

  void _closeError() {
    _overlayEntry?.remove();
  }

  void _showManualSettings() {
    _navigation.push(
        context,
        MaterialPageRoute(
            builder: (context) => LoginManualSettings(
                  email: emailField.controller.text,
                  password: passwordField.controller.text,
                  fromError: false,
                )));
  }
}
