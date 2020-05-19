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
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/error/error_bloc.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/login/login_bloc.dart';
import 'package:ox_coi/src/login/login_events_state.dart';
import 'package:ox_coi/src/main/main_bloc.dart';
import 'package:ox_coi/src/main/main_event_state.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/constants.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/web/web_asset.dart';
import 'package:ox_coi/src/widgets/button.dart';
import 'package:ox_coi/src/widgets/custom_painters.dart';
import 'package:ox_coi/src/widgets/url_text_span.dart';

import 'login_provider_list.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _navigation = Navigation();
  LoginBloc _loginBloc;

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.login);
    _loginBloc = LoginBloc(BlocProvider.of<ErrorBloc>(context));
    _loginBloc.add(RequestProviders(type: ProviderListType.login));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
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
                      padding: const EdgeInsets.only(top: loginHeaderVerticalPadding, right: loginHorizontalPadding, left: loginHorizontalPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Image(
                            image: AssetImage(appLogoPath),
                            height: loginLogoSize,
                            width: loginLogoSize,
                          ),
                          Padding(padding: const EdgeInsets.only(top: dimension16dp)),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: Theme.of(context).textTheme.caption.apply(color: CustomTheme.of(context).onAccent),
                              children: getWelcome(),
                            ),
                          ),
                          Padding(padding: const EdgeInsets.only(top: loginWaveTopBottomPadding)),
                        ],
                      ),
                    ),
                    RepaintBoundary(
                      child: SizedBox(
                        width: viewportConstraints.maxWidth,
                        height: loginWaveHeight,
                        child: CustomPaint(
                          painter: CurvePainter(color: CustomTheme.of(context).primary),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: CustomTheme.of(context).background,
                        width: viewportConstraints.maxWidth,
                        padding: const EdgeInsets.symmetric(horizontal: loginHorizontalPadding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(padding: const EdgeInsets.only(top: loginWaveTopBottomPadding)),
                            ButtonImportanceHigh(
                                minimumWidth: loginButtonWidth,
                                child: Text(
                                  L10n.get(L.loginSignIn),
                                  key: Key(keyLoginLoginSignInText),
                                ),
                                onPressed: () {
                                  _goToProviderList(ProviderListType.login);
                                }),
                            Padding(padding: const EdgeInsets.only(top: dimension24dp)),
                            Padding(
                              padding: const EdgeInsets.all(dimension8dp),
                              child: ButtonImportanceLow(
                                  minimumWidth: loginButtonWidth,
                                  child: Text(
                                    L10n.get(L.register),
                                    key: Key(keyLoginRegisterText),
                                  ),
                                  onPressed: () {
                                    _goToProviderList(ProviderListType.register);
                                  }),
                            ),
                            Padding(padding: const EdgeInsets.only(top: dimension64dp)),
                            Padding(
                              padding: const EdgeInsets.only(bottom: dimension32dp),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.caption.apply(color: CustomTheme.of(context).onBackground),
                                  children: getAgreeTo(),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        );
      }),
    );
  }

  void _goToProviderList(ProviderListType type) {
    _navigation.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProviderList(
          type: type,
        ),
      ),
    );
  }

  List<TextSpan> getWelcome() {
    int spanBoundary = 0;
    final oxCoiName = L10n.get(L.oxCoiName);
    final formattedWelcomeString = L10n.getFormatted(L.welcome, [oxCoiName]);
    final oxCoiNameStartIndex = formattedWelcomeString.indexOf(oxCoiName, spanBoundary);
    final oxCoiNameEndIndex = oxCoiNameStartIndex + oxCoiName.length;

    List<TextSpan> textParts = [];
    textParts.add(TextSpan(
      text: formattedWelcomeString.substring(spanBoundary, oxCoiNameStartIndex),
      style: Theme.of(context).textTheme.headline.copyWith(color: CustomTheme.of(context).onAccent),
    ));
    spanBoundary = oxCoiNameStartIndex;
    if (spanBoundary > 0) {
      textParts.add(TextSpan(text: "\n"));
    }
    textParts.add(TextSpan(
      text: oxCoiName,
      style: Theme.of(context).textTheme.title.copyWith(color: CustomTheme.of(context).onAccent, fontSize: 28.0),
    ));
    spanBoundary = oxCoiNameEndIndex;
    textParts.add(TextSpan(text: formattedWelcomeString.substring(spanBoundary)));
    return textParts;
  }

  List<TextSpan> getAgreeTo() {
    int spanBoundary = 0;
    final termsAndConditions = L10n.get(L.termsConditions);
    final privacyPolicy = L10n.get(L.privacyDeclaration);
    final formattedAgreeString = L10n.getFormatted(L.agreeToXY, [termsAndConditions, privacyPolicy]);
    final termsConditionsStartIndex = formattedAgreeString.indexOf(termsAndConditions, spanBoundary);
    final termsConditionsEndIndex = termsConditionsStartIndex + termsAndConditions.length;
    final privacyPolicyStartIndex = formattedAgreeString.indexOf(privacyPolicy, spanBoundary);
    final privacyPolicyEndIndex = privacyPolicyStartIndex + privacyPolicy.length;

    List<TextSpan> textParts = [];
    textParts.add(TextSpan(text: formattedAgreeString.substring(spanBoundary, termsConditionsStartIndex)));
    spanBoundary = termsConditionsStartIndex;
    textParts.add(UrlTextSpan(
      asset: "assets/html/terms.html",
      text: termsAndConditions,
      onAssetTapped: _onAssetTapped,
      color: CustomTheme.of(context).accent,
    ));
    spanBoundary = termsConditionsEndIndex;
    textParts.add(TextSpan(text: formattedAgreeString.substring(spanBoundary, privacyPolicyStartIndex)));
    spanBoundary = privacyPolicyStartIndex;
    textParts.add(UrlTextSpan(
      asset: "assets/html/privacypolicy.html",
      text: privacyPolicy,
      onAssetTapped: _onAssetTapped,
      color: CustomTheme.of(context).accent,
    ));
    spanBoundary = privacyPolicyEndIndex;
    textParts.add(TextSpan(text: formattedAgreeString.substring(spanBoundary)));
    return textParts;
  }

  _onAssetTapped(String asset) {
    _navigation.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebAsset(
            asset: asset,
          ),
        ));
  }
}
