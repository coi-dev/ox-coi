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
import 'package:ox_coi/src/l10n/localizations.dart';
import 'package:ox_coi/src/login/providers.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/utils/colors.dart';
import 'package:ox_coi/src/utils/dialog_builder.dart';
import 'package:ox_coi/src/utils/dimensions.dart';
import 'package:ox_coi/src/utils/styles.dart';
import 'package:ox_coi/src/widgets/progress_handler.dart';
import 'package:ox_coi/src/widgets/validatable_text_form_field.dart';
import 'package:rxdart/rxdart.dart';

import 'login_bloc.dart';
import 'login_events_state.dart';
import 'login_manual_settings.dart';

class ProviderSignIn extends StatefulWidget {
  Provider provider;
  final Function success;

  ProviderSignIn({this.provider, this.success});

  @override
  _ProviderSignInState createState() => _ProviderSignInState();
}

class _ProviderSignInState extends State<ProviderSignIn> {
  final _simpleLoginKey = GlobalKey<FormState>();
  OverlayEntry _progressOverlayEntry;
  FullscreenProgress _progress;
  LoginBloc _loginBloc = LoginBloc();
  OverlayEntry _overlayEntry;
  var _navigation = Navigation();

  ValidatableTextFormField emailField = ValidatableTextFormField(
    (context) => AppLocalizations.of(context).emailAddress,
    hintText: (context) => AppLocalizations.of(context).loginHintEmail,
    textFormType: TextFormType.email,
    inputType: TextInputType.emailAddress,
    needValidation: true,
    validationHint: (context) => AppLocalizations.of(context).validatableTextFormFieldHintInvalidEmail,
    showIcon: true,
  );
  ValidatableTextFormField passwordField = ValidatableTextFormField(
    (context) => AppLocalizations.of(context).password,
    hintText: (context) => AppLocalizations.of(context).loginHintPassword,
    textFormType: TextFormType.password,
    needValidation: true,
    validationHint: (context) => AppLocalizations.of(context).validatableTextFormFieldHintInvalidPassword,
    showIcon: true,
  );

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.loginProviderSignIn);
    final loginObservable = new Observable<LoginState>(_loginBloc.state);
    loginObservable.listen((state) => handleLoginStateChange(state));
  }

  void handleLoginStateChange(LoginState state) {
    if (state is LoginStateSuccess || state is LoginStateFailure) {
      if (_progressOverlayEntry != null) {
        _progressOverlayEntry.remove();
        _progressOverlayEntry = null;
      }
    }
    if (state is LoginStateSuccess) {
      widget.success();
    } else if (state is LoginStateFailure) {
      if (widget.provider.id != AppLocalizations.of(context).other) {
        setState(() {
          this._overlayEntry = this._createErrorOverlayEntry();
          Overlay.of(context).insert(this._overlayEntry);
          showInformationDialog(
            context: context,
            title: AppLocalizations.of(context).loginErrorDialogTitle,
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
              AppLocalizations.of(context).loginProviderSignInText(widget.provider.name),
              style: loginTitleText,
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
            Padding(padding: EdgeInsets.all(loginVerticalPadding20dp)),
            RaisedButton(
                color: accent,
                textColor: text,
                child: SizedBox(
                  width: loginButtonWidth,
                  child: Text(
                    AppLocalizations.of(context).loginSignInButtonText,
                    textAlign: TextAlign.center,
                  ),
                ),
                onPressed: _signIn),
            Visibility(
              visible: widget.provider.id == AppLocalizations.of(context).other,
              child: FlatButton(
                  onPressed: _showManualSettings,
                  child: Text(
                    AppLocalizations.of(context).loginManualSettings,
                    style: loginFlatButtonText,
                  )),
            )
          ],
        ));
  }

  OverlayEntry _createErrorOverlayEntry() {
    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;

    return OverlayEntry(
        builder: (context) => Positioned(
              left: 0,
              top: 24,
              width: size.width,
              child: Material(
                elevation: 4.0,
                child: Container(
                  color: error,
                  height: loginErrorOverlayHeight,
                  child: Row(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: loginErrorOverlayLeftPadding),
                          ),
                          Icon(
                            Icons.report_problem,
                            size: iconSize,
                            color: textInverted,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: loginErrorOverlayLeftPadding),
                          ),
                          Text(
                            AppLocalizations.of(context).loginError,
                            style: loginErrorOverlayText,
                          ),
                        ],
                      ),
                      Spacer(),
                      IconButton(
                          icon: Icon(
                            Icons.clear,
                            size: loginErrorOverlayIconSize,
                            color: textInverted,
                          ),
                          onPressed: _closeError),
                    ],
                  ),
                ),
              ),
            ));
  }

  void _signIn() {
    if(_overlayEntry != null) {
      _overlayEntry.remove();
    }
    FocusScope.of(context).requestFocus(FocusNode());
    bool simpleLoginIsValid = _simpleLoginKey.currentState.validate();
    var email = emailField.controller.text;
    var password = passwordField.controller.text;

    if (simpleLoginIsValid) {
      _progress = FullscreenProgress(_loginBloc, AppLocalizations.of(context).loginProgressMessage, true, false);
      _progressOverlayEntry = OverlayEntry(builder: (context) => _progress);
      OverlayState overlayState = Overlay.of(context);
      overlayState.insert(_progressOverlayEntry);
      _loginBloc.dispatch(ProviderLoginButtonPressed(email: email, password: password, provider: widget.provider));
    }
  }

  void _closeError() {
    this._overlayEntry.remove();
  }

  void _showManualSettings() {
    _navigation.push(
        context,
        MaterialPageRoute(
            builder: (context) => LoginManualSettings(
                success: widget.success, email: emailField.controller.text, password: passwordField.controller.text, fromError: false)));
  }
}
