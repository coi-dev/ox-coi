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
import 'package:ox_coi/src/adaptiveWidgets/adaptive_raised_button.dart';
import 'package:ox_coi/src/error/error_bloc.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/login/providers.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/custom_theme.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/dialog_builder.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/widgets/error_banner.dart';
import 'package:ox_coi/src/widgets/fullscreen_progress.dart';
import 'package:ox_coi/src/widgets/validatable_text_form_field.dart';
import 'package:rxdart/rxdart.dart';

import 'login_bloc.dart';
import 'login_events_state.dart';
import 'login_manual_settings.dart';

class ProviderSignIn extends StatefulWidget {

  final Provider provider;
  final Function success;

  ProviderSignIn({this.provider, this.success});

  @override
  _ProviderSignInState createState() => _ProviderSignInState();
}

class _ProviderSignInState extends State<ProviderSignIn> {
  static const providerOther = 'other';
  final _simpleLoginKey = GlobalKey<FormState>();

  OverlayEntry _progressOverlayEntry;
  LoginBloc _loginBloc;
  OverlayEntry _overlayEntry;
  var _navigation = Navigation();

  ValidatableTextFormField emailField = ValidatableTextFormField(
    (context) => L10n.get(L.emailAddress),
    hintText: (context) => L10n.get(L.emailAddress),
    textFormType: TextFormType.email,
    inputType: TextInputType.emailAddress,
    needValidation: true,
    validationHint: (context) => L10n.get(L.loginCheckMail),
    showIcon: true,
    key: Key(keyProviderSignInEmailTextField),
  );
  ValidatableTextFormField passwordField = ValidatableTextFormField(
    (context) => L10n.get(L.password),
    hintText: (context) => L10n.get(L.password),
    textFormType: TextFormType.password,
    needValidation: true,
    validationHint: (context) => L10n.get(L.loginCheckPassword),
    showIcon: true,
    key: Key(keyProviderSignInPasswordTextField),
  );

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.loginProviderSignIn);
    _loginBloc = LoginBloc(BlocProvider.of<ErrorBloc>(context));
    final loginObservable = new Observable<LoginState>(_loginBloc);
    loginObservable.listen((state) => handleLoginStateChange(state));
  }

  void handleLoginStateChange(LoginState state) {
    if (!_navigation.current.equal(Navigatable(Type.loginProviderSignIn))) {
      return;
    }
    if (state is LoginStateSuccess || state is LoginStateFailure) {
      if (_progressOverlayEntry != null) {
        _progressOverlayEntry.remove();
        _progressOverlayEntry = null;
      }
    }
    if (state is LoginStateSuccess) {
      widget.success();
    } else if (state is LoginStateFailure) {
      if (widget.provider.id != providerOther) {
        setState(() {
          this._overlayEntry = this._createErrorOverlayEntry();
          Overlay.of(context).insert(this._overlayEntry);
          showInformationDialog(
            context: context,
            title: L10n.get(L.loginFailed),
            content: state.error,
            navigatable: Navigatable(Type.loginErrorDialog),
          );
        });
      } else {
        _navigation.push(
            context,
            MaterialPageRoute(
                builder: (context) => LoginManualSettings(
                    success: widget.success, email: emailField.controller.text, password: passwordField.controller.text, fromError: true)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: createProviderSignIn());
  }

  Widget createProviderSignIn() {
    return SingleChildScrollView(
        padding: EdgeInsets.only(left: loginHorizontalPadding, right: loginHorizontalPadding, bottom: loginVerticalPadding, top: loginTopPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage(getProviderIconPath(context, widget.provider.id)),
              height: loginProviderIconSizeBig,
              width: loginProviderIconSizeBig,
            ),
            Padding(padding: EdgeInsets.all(loginVerticalPadding12dp)),
            Text(
              L10n.getFormatted(L.providerSignInTextX, [widget.provider.name]),
              style: Theme.of(context).textTheme.headline,
            ),
            Padding(padding: EdgeInsets.all(loginVerticalPadding12dp)),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: formHorizontalPadding),
                child: Form(
                  key: _simpleLoginKey,
                  child: Column(
                    children: <Widget>[emailField, passwordField],
                  ),
                )),
            Padding(padding: EdgeInsets.all(loginVerticalPadding24dp)),
            AdaptiveRaisedButton(
                child: Text(L10n.get(L.loginSignIn).toUpperCase()),
                onPressed: _signIn,
                buttonWidth: loginButtonWidth,
                color: CustomTheme.of(context).accent,
                textColor: CustomTheme.of(context).onAccent),
            Visibility(
              visible: widget.provider.id == providerOther,
              child: FlatButton(
                  onPressed: _showManualSettings,
                  child: Text(
                    L10n.get(L.settingManual),
                    style: TextStyle(color: CustomTheme.of(context).accent),
                  )),
            )
          ],
        ));
  }

  OverlayEntry _createErrorOverlayEntry() {
    return OverlayEntry(
        builder: (context) => ErrorBanner(
              message: L10n.get(L.loginCheckUsernamePassword),
              closePressed: _closeError,
            ));
  }

  void _signIn() {
    _closeError();
    FocusScope.of(context).requestFocus(FocusNode());
    bool simpleLoginIsValid = _simpleLoginKey.currentState.validate();
    var email = emailField.controller.text;
    var password = passwordField.controller.text;

    if (simpleLoginIsValid) {
      _progressOverlayEntry = OverlayEntry(
        builder: (context) => FullscreenProgress(
          bloc: _loginBloc,
          text: L10n.get(L.loginRunning),
          showProgressValues: true,
          showCancelButton: false,
        ),
      );
      Overlay.of(context).insert(_progressOverlayEntry);
      _loginBloc.add(ProviderLoginButtonPressed(email: email, password: password, provider: widget.provider));
    }
  }

  void _closeError() {
    if (_overlayEntry != null) {
      _overlayEntry.remove();
      _overlayEntry = null;
    }
  }

  void _showManualSettings() {
    _navigation.push(
        context,
        MaterialPageRoute(
            builder: (context) => LoginManualSettings(
                success: widget.success, email: emailField.controller.text, password: passwordField.controller.text, fromError: false)));
  }
}
