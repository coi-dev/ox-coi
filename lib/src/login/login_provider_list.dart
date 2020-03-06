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
import 'package:ox_coi/src/adaptiveWidgets/adaptive_app_bar.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon.dart';
import 'package:ox_coi/src/error/error_bloc.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/login/providers.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/platform/app_information.dart';
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/ui/custom_theme.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/widgets/state_info.dart';
import 'package:url_launcher/url_launcher.dart';

import 'login_bloc.dart';
import 'login_events_state.dart';
import 'login_provider_signin.dart';

enum ProviderListType {
  login,
  register,
}

class ProviderList extends StatefulWidget {
  final Function success;
  final ProviderListType type;

  ProviderList({@required this.type, this.success});

  @override
  _ProviderListState createState() => _ProviderListState();
}

class _ProviderListState extends State<ProviderList> {
  LoginBloc _loginBloc;
  String title;
  String text;
  Provider otherProvider;
  final _navigation = Navigation();

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.loginProviderList);
    _loginBloc = LoginBloc(BlocProvider.of<ErrorBloc>(context));
    _loginBloc.add(RequestProviders(type: widget.type));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == ProviderListType.login) {
      title = L10n.get(L.loginSignIn);
      text = L10n.get(L.loginChooseProvider);
    } else if (widget.type == ProviderListType.register) {
      title = L10n.get(L.register);
      text = L10n.get(L.providerRegisterChoose);
    }
    return Scaffold(
        appBar: AdaptiveAppBar(
          title: Text(title),
      ),
      body: createProviderList()
    );
  }

  Widget createProviderList() {
    return Padding(
        padding: EdgeInsets.only(
            left: loginHorizontalPadding,
            right: loginHorizontalPadding,
            bottom: loginVerticalPadding,
            top: loginTopPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.body1,
            ),
            Padding(padding: EdgeInsets.only(top: loginVerticalPadding24dp)),
            Flexible(
              child: BlocBuilder(
                bloc: _loginBloc,
                builder: (context, state) {
                  if (state is LoginStateProvidersLoaded) {
                    return buildListItems(state);
                  } else if (state is! LoginStateFailure) {
                    return StateInfo(showLoading: true);
                  } else {
                    return AdaptiveIcon(icon: IconSource.error);
                  }
                },
              ),
            ),
            if (widget.type == ProviderListType.login)
              Padding(
                padding: EdgeInsets.only(top: loginVerticalPadding24dp),
                child: RaisedButton(
                  elevation: 0,
                  onPressed: () => _onItemTap(otherProvider),
                  child: Text(L10n.get(L.providerOtherMailProvider)),
                  textColor: CustomTheme.of(context).accent,
                  color: CustomTheme.of(context).background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(loginOtherProviderButtonRadius),
                    side: BorderSide(color: CustomTheme.of(context).accent),
                  ),
                ),
              ),
          ],
        ));
  }

  ListView buildListItems(LoginStateProvidersLoaded state) {
    return ListView.builder(
      padding: EdgeInsets.only(top: listItemPadding),
      itemCount: state.providers.length,
      itemBuilder: (BuildContext context, int index) {
        if (state.providers[index].oauth == null) {
          return createProviderItem(state.providers[index]);
        } else {
          return Container();
        }
      },
    );
  }

  Widget createProviderItem(Provider provider) {
    if (isCoiDebugProvider(provider.id) && isRelease()) {
      return Container();
    }
    if (provider.id == "other") {
      otherProvider = provider;
      return Container();
    }
    return SizedBox(
      height: loginListItemHeight,
      child: InkWell(
        onTap: () => _onItemTap(provider),
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(
                    vertical: loginVerticalPadding12dp,
                    horizontal: loginHorizontalPadding16dp),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: loginHorizontalPadding16dp),
                          child: Image(
                            image: AssetImage(getProviderIconPath(context, provider.id)),
                            height: loginProviderIconSize,
                            width: loginProviderIconSize,
                          ),
                        ),
                        Text(
                          provider.name,
                          style: Theme.of(context).textTheme.body1.apply(color: CustomTheme.of(context).onBackground),
                        ),
                      ],
                    ),
                  ],
                )),
            Divider(
              height: loginListItemDividerHeight,
              color: CustomTheme.of(context).onBackground.barely(),
            ),
          ],
        ),
      ),
    );
  }

  _onItemTap(Provider provider) {
    if (widget.type == ProviderListType.login) {
      var navigation = Navigation();
      navigation.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProviderSignIn(provider: provider, success: widget.success),
        ),
      );
    } else if (widget.type == ProviderListType.register) {
      launch(provider.registerLink, forceSafariVC: false);
    }
  }
}
