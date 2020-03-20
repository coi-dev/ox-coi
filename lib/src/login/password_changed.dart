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
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/error/error_bloc.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/login/login_bloc.dart';
import 'package:ox_coi/src/login/login_events_state.dart';
import 'package:ox_coi/src/login/password_changed_bloc.dart';
import 'package:ox_coi/src/login/password_changed_event_state.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/constants.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/widgets/button.dart';
import 'package:ox_coi/src/widgets/custom_painters.dart';
import 'package:ox_coi/src/widgets/error_banner.dart';
import 'package:ox_coi/src/widgets/fullscreen_progress.dart';
import 'package:ox_coi/src/widgets/superellipse_icon.dart';
import 'package:ox_coi/src/widgets/validatable_text_form_field.dart';

class PasswordChanged extends StatefulWidget {
  final Function passwordChangedCallback;

  PasswordChanged({@required this.passwordChangedCallback});

  @override
  _PasswordChangedState createState() => _PasswordChangedState();
}

class _PasswordChangedState extends State<PasswordChanged> {
  // ignore: close_sinks
  PasswordChangedBloc _passwordChangedBloc = PasswordChangedBloc();

  LoginBloc _loginBloc;
  OverlayEntry _progressOverlayEntry;
  OverlayEntry _errorOverlayEntry;
  Navigation _navigation = Navigation();
  final formKey = GlobalKey<FormState>();
  ValidatableTextFormField emailField;
  ValidatableTextFormField passwordField = ValidatableTextFormField(
    (context) => L10n.get(L.password),
    key: Key(keySettingsManuelFormValidatableTextFormFieldPasswordField),
    textFormType: TextFormType.password,
    needValidation: true,
    validationHint: (context) => L10n.get(L.loginCheckPassword),
  );

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.passwordChanged);
    _loginBloc = LoginBloc(BlocProvider.of<ErrorBloc>(context));
    emailField = ValidatableTextFormField(
      (context) => L10n.get(L.emailAddress),
      textFormType: TextFormType.email,
      inputType: TextInputType.emailAddress,
      needValidation: true,
      enabled: false,
      validationHint: (context) => L10n.get(L.loginCheckMail),
    );
    _passwordChangedBloc.add(LoadData());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _navigation.allowBackNavigation,
      child: Scaffold(
        body: MultiBlocListener(
          listeners: [
            BlocListener(
                bloc: _passwordChangedBloc,
                listener: (context, state) {
                  if (state is PasswordChangedDataLoaded) {
                    emailField.controller.text = state.email;
                  }
                }),
            BlocListener(
                bloc: _loginBloc,
                listener: (context, state) {
                  if (state is LoginStateSuccess || state is LoginStateFailure) {
                    _progressOverlayEntry?.remove();
                  }
                  if (state is LoginStateSuccess) {
                    _passwordChangedBloc.add(ResetAuthenticationError());
                    widget.passwordChangedCallback();
                  } else if (state is LoginStateFailure) {
                    this._errorOverlayEntry = this._createErrorOverlayEntry();
                    Overlay.of(context).insert(_errorOverlayEntry);
                  }
                }),
          ],
          child: _createBody(),
        ),
      ),
    );
  }

  Widget _createBody() {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: <Widget>[
                  Container(
                    color: CustomTheme.of(context).primary,
                    width: viewportConstraints.maxWidth,
                    padding: EdgeInsets.only(top: loginHeaderVerticalPadding, right: loginHorizontalPadding, left: loginHorizontalPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Image(
                          image: AssetImage(appLogoPath),
                          height: loginLogoSize,
                          width: loginLogoSize,
                        ),
                        Padding(padding: EdgeInsets.only(top: loginWaveTopBottomPadding)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: viewportConstraints.maxWidth,
                    height: 50,
                    child: CustomPaint(
                      painter: CurvePainter(color: CustomTheme.of(context).primary),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: CustomTheme.of(context).background,
                      width: viewportConstraints.maxWidth,
                      padding: EdgeInsets.symmetric(horizontal: loginHorizontalPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(padding: EdgeInsets.only(top: loginWaveTopBottomPadding)),
                          Row(
                            children: <Widget>[
                              SuperellipseIcon(
                                color: CustomTheme.of(context).error,
                                iconColor: CustomTheme.of(context).white,
                                icon: IconSource.error,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: iconTextPadding),
                              ),
                              Text(
                                L10n.get(L.passwordChangedTitle),
                                style: Theme.of(context).textTheme.headline.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.all(dimension8dp),
                          ),
                          Text(
                            L10n.get(L.passwordChangedInfoText),
                            style: Theme.of(context).textTheme.subhead,
                          ),
                          Padding(
                            padding: EdgeInsets.all(dimension24dp),
                          ),
                          Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                emailField,
                                Padding(
                                  padding: EdgeInsets.all(dimension12dp),
                                ),
                                passwordField,
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(dimension28dp),
                            child: ButtonImportanceHigh(
                              minimumWidth: loginButtonWidth,
                              child: Text(L10n.get(L.passwordChangedButtonText)),
                              onPressed: _login,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
      );
    });
  }

  void _login() {
    _closeError();
    bool validated = formKey.currentState.validate();
    if (validated) {
      FocusScope.of(context).requestFocus(FocusNode());
      _progressOverlayEntry = FullscreenOverlay(
        fullscreenProgress: FullscreenProgress(
          bloc: _loginBloc,
          text: L10n.get(L.loginRunning),
          showProgressValues: true,
        ),
      );
      Overlay.of(context).insert(_progressOverlayEntry);
      _loginBloc.add(LoginWithNewPassword(password: passwordField.controller.text));
    }
  }

  OverlayEntry _createErrorOverlayEntry() {
    return OverlayEntry(
        builder: (context) => ErrorBanner(
              message: L10n.get(L.passwordChangedCheckPassword),
              closePressed: _closeError,
            ));
  }

  void _closeError() {
    if (_errorOverlayEntry != null) {
      _errorOverlayEntry.remove();
      _errorOverlayEntry = null;
    }
  }
}
