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
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/login/login_bloc.dart';
import 'package:ox_coi/src/login/login_events_state.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/constants.dart';
import 'package:ox_coi/src/utils/dialog_builder.dart';
import 'package:ox_coi/src/widgets/url_text_span.dart';
import 'package:rxdart/rxdart.dart';

import 'login_provider_list.dart';

class Login extends StatefulWidget {
  final Function success;

  Login({@required this.success});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final LoginBloc _loginBloc = LoginBloc();
  bool _showedErrorDialog = false;
  OverlayEntry _progressOverlayEntry;

  @override
  void initState() {
    super.initState();
    var navigation = Navigation();
    navigation.current = Navigatable(Type.login);
    _loginBloc.dispatch(RequestProviders(type: ProviderListType.login));
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
      if (!_showedErrorDialog) {
        _showedErrorDialog = true;
        showInformationDialog(
          context: context,
          title: L10n.get(L.loginFailed),
          content: state.error,
          navigatable: Navigatable(Type.loginErrorDialog),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: createWelcomeScreen());
  }

  Widget createWelcomeScreen() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: loginHorizontalPadding, right: loginHorizontalPadding, bottom: loginVerticalPadding, top: loginTopPadding),
      child: Column(
        children: <Widget>[
          Text(
            L10n.get(L.welcome),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline,
          ),
          Image(
            image: AssetImage(appLogoUrl),
            height: loginLogoSize,
            width: loginLogoSize,
          ),
          Padding(
            padding: EdgeInsets.only(bottom: loginVerticalPadding),
            child: Text(
              L10n.get(L.loginWelcome),
              textAlign: TextAlign.center,
            ),
          ),
          RaisedButton(
              color: accent,
              textColor: onAccent,
              child: SizedBox(
                width: loginButtonWidth,
                child: Text(
                  L10n.get(L.loginSignIn).toUpperCase(),
                  textAlign: TextAlign.center,
                ),
              ),
              onPressed: () {
                _goToProviderList(ProviderListType.login);
              }),
          Padding(
            padding: EdgeInsets.all(loginVerticalPadding8dp),
            child: FlatButton(
                child: Text(
                  L10n.get(L.register).toUpperCase(),
                  style: TextStyle(color: accent),
                ),
                onPressed: () {
                  _goToProviderList(ProviderListType.register);
                }),
          ),
          RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  style: Theme.of(context).textTheme.caption.apply(color: onBackground),
                  text: L10n.get(L.agreeTo),
                  children: [
                    TextSpan(text: " "),
                    UrlTextSpan(url: null, text: L10n.get(L.termsConditions)),
                    TextSpan(text: " ${L10n.get(L.and)} "),
                    UrlTextSpan(url: null, text: L10n.get(L.privacyDeclaration))
                  ])),
        ],
      ),
    );
  }

  void _goToProviderList(ProviderListType type) {
    var navigation = Navigation();
    navigation.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProviderList(
                  type: type,
                  success: widget.success,
                )));
  }
}
