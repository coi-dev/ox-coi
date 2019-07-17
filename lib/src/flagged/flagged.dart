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

import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/l10n/localizations.dart';
import 'package:ox_coi/src/message/message_item.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/utils/dimensions.dart';
import 'package:ox_coi/src/utils/styles.dart';
import 'package:ox_coi/src/widgets/state_info.dart';

import 'flagged_bloc.dart';
import 'flagged_events_state.dart';

class Flagged extends StatefulWidget {
  @override
  _FlaggedState createState() => _FlaggedState();
}

class _FlaggedState extends State<Flagged> {
  Navigation _navigation = Navigation();
  FlaggedBloc _flaggedBloc = FlaggedBloc();

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.flagged);
    _flaggedBloc.dispatch(RequestFlaggedMessages());
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: buildTitle(),
        ),
        body: buildListView());
  }

  buildTitle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppLocalizations.of(context).flaggedTitle,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: twoLineHeaderTitle,
        ),
        Text(
          AppLocalizations.of(context).flaggedSubTitle,
          style: twoLineHeaderSubTitle,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget buildListView() {
    return BlocBuilder(
      bloc: _flaggedBloc,
      builder: (context, state) {
        if (state is FlaggedStateSuccess) {
          if (state.messageIds.length > 0) {
            return buildListItems(state);
          } else {
            return Padding(
              padding: const EdgeInsets.all(listItemPaddingBig),
              child: Center(
                child: Text(
                  AppLocalizations.of(context).flaggedEmpty,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
        } else {
          return StateInfo(showLoading: true);
        }
      },
    );
  }

  ListView buildListItems(FlaggedStateSuccess state) {
    return ListView.builder(
      padding: new EdgeInsets.all(listItemPadding),
      reverse: true,
      itemCount: state.messageIds.length,
      itemBuilder: (BuildContext context, int index) {
        int messageId = state.messageIds[index];
        bool hasDateMarker = state.dateMarkerIds.contains(messageId);
        var key = "$messageId-${state.messageLastUpdateValues[index]}";
        return ChatMessageItem(Chat.typeStarred, messageId, true, hasDateMarker, key);
      },
    );
  }
}
