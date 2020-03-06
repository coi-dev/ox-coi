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
import 'package:ox_coi/src/error/error_bloc.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/login/login_bloc.dart';
import 'package:ox_coi/src/login/login_events_state.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/custom_theme.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/constants.dart';
import 'package:ox_coi/src/utils/dialog_builder.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/web/web_asset.dart';
import 'package:ox_coi/src/widgets/button.dart';
import 'package:ox_coi/src/widgets/custom_painters.dart';
import 'package:ox_coi/src/widgets/url_text_span.dart';

import 'login_provider_list.dart';

class Login extends StatefulWidget {
  final Function success;

  Login({@required this.success});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  LoginBloc _loginBloc;
  Navigation _navigation = Navigation();
  bool _showedErrorDialog = false;
  OverlayEntry _progressOverlayEntry;

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.login);
    _loginBloc = LoginBloc(BlocProvider.of<ErrorBloc>(context));
    _loginBloc.add(RequestProviders(type: ProviderListType.login));
    _loginBloc.listen((state) => handleLoginStateChange(state));
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
                    padding: EdgeInsets.only(top: loginVerticalPaddingBig, right: loginHorizontalPadding, left: loginHorizontalPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Image(
                          image: AssetImage(appLogoPath),
                          height: loginLogoSize,
                          width: loginLogoSize,
                        ),
                        Padding(padding: EdgeInsets.only(top: loginLogoTextPadding)),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.caption.apply(color: CustomTheme.of(context).onAccent),
                            children: getWelcome(),
                          ),
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
                          ButtonImportanceHigh(
                              minimumWidth: loginButtonWidth,
                              child: Text(
                                L10n.get(L.loginSignIn),
                                key: Key(keyLoginLoginSignInText),
                              ),
                              onPressed: () {
                                _goToProviderList(ProviderListType.login);
                              }),
                          Padding(padding: EdgeInsets.only(top: loginButtonPadding)),
                          Padding(
                            padding: EdgeInsets.all(loginVerticalPadding8dp),
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
                          Padding(padding: EdgeInsets.only(top: loginRichTextButtonPadding)),
                          Padding(
                            padding: EdgeInsets.only(bottom: loginRichTextBottomPadding),
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
    });
  }

  void _goToProviderList(ProviderListType type) {
    _navigation.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProviderList(
          type: type,
          success: widget.success,
        ),
      ),
    );
  }

  List<TextSpan> getWelcome() {
    int spanBoundary = 0;
    var oxCoiName = L10n.get(L.oxCoiName);
    var formattedWelcomeString = L10n.getFormatted(L.welcome, [oxCoiName]);
    var oxCoiNameStartIndex = formattedWelcomeString.indexOf(oxCoiName, spanBoundary);
    var oxCoiNameEndIndex = oxCoiNameStartIndex + oxCoiName.length;

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
    var termsAndConditions = L10n.get(L.termsConditions);
    var privacyPolicy = L10n.get(L.privacyDeclaration);
    var formattedAgreeString = L10n.getFormatted(L.agreeToXY, [termsAndConditions, privacyPolicy]);
    var termsConditionsStartIndex = formattedAgreeString.indexOf(termsAndConditions, spanBoundary);
    var termsConditionsEndIndex = termsConditionsStartIndex + termsAndConditions.length;
    var privacyPolicyStartIndex = formattedAgreeString.indexOf(privacyPolicy, spanBoundary);
    var privacyPolicyEndIndex = privacyPolicyStartIndex + privacyPolicy.length;

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
