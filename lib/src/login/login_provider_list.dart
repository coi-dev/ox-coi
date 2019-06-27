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
import 'package:ox_coi/src/l10n/localizations.dart';
import 'package:ox_coi/src/login/providers.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/platform/app_information.dart';
import 'package:ox_coi/src/utils/dimensions.dart';
import 'package:ox_coi/src/utils/styles.dart';
import 'package:ox_coi/src/widgets/state_info.dart';

import 'login_bloc.dart';
import 'login_events_state.dart';
import 'login_provider_signin.dart';

class ProviderList extends StatefulWidget {
  final Function _success;

  ProviderList(this._success);

  @override
  _ProviderListState createState() => _ProviderListState();
}

class _ProviderListState extends State<ProviderList> {
  final LoginBloc _loginBloc = LoginBloc();

  @override
  void initState() {
    super.initState();
    var navigation = Navigation();
    navigation.current = Navigatable(Type.loginProviderList);
    _loginBloc.dispatch(RequestProviders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: createProviderList()
    );
  }

  Widget createProviderList() {
    return Padding(
      padding: EdgeInsets.only(left: loginHorizontalPadding, right: loginHorizontalPadding, bottom: loginVerticalPadding, top: loginTopPadding),
      child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            AppLocalizations.of(context).loginSignInTitle,
            style: loginTitleText,
          ),
          Padding(padding: EdgeInsets.all(loginVerticalPadding12dp)),
          Text(
            AppLocalizations.of(context).loginSignInInfoText
          ),
          Padding(padding: EdgeInsets.all(loginVerticalPadding20dp)),
          Expanded(
            child: BlocBuilder(
              bloc: _loginBloc,
              builder: (context, state) {
                if (state is LoginStateProvidersLoaded) {
                  return buildListItems(state);
                } else if (state is! LoginStateFailure) {
                  return StateInfo(showLoading: true);
                } else {
                  return Icon(Icons.error);
                }
              },
            )
          ),
        ],
      )
    );
  }

  ListView buildListItems(LoginStateProvidersLoaded state) {
    return ListView.builder(
      padding: EdgeInsets.only(top: listItemPadding),
      itemCount: state.providers.length,
      itemBuilder: (BuildContext context, int index) {
        if(state.providers[index].oauth == null) {
          return createProviderItem(state.providers[index]);
        }
        else{
          return Container();
        }
      },
    );
  }

  Widget createProviderItem(Provider provider) {
    if(provider.id == "coi" && isRelease()){
      return Container();
    }
    return Column(
      children: <Widget>[
        ListTile(
          onTap: () => _onItemTap(provider),
          leading: Image(
            image: AssetImage(getProviderIconPath(context, provider.id)),
            height: loginProviderIconSize,
            width: loginProviderIconSize,
          ),
          title: provider.id != AppLocalizations.of(context).other ? Text(provider.name) : Text(AppLocalizations.of(context).loginOtherMailAccount),
        ),
        Divider(),
      ],
    );
  }

  _onItemTap(Provider provider) {
    var navigation = Navigation();
    navigation.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProviderSignIn(provider, widget._success)
      )
    );
  }
}
