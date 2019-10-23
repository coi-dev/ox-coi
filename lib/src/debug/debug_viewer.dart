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
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/debug/debug_viewer_bloc.dart';
import 'package:ox_coi/src/debug/debug_viewer_event_state.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/utils/clipboard.dart';
import 'package:ox_coi/src/utils/text.dart';
import 'package:ox_coi/src/widgets/state_info.dart';

import 'package:ox_coi/src/adaptiveWidgets/adaptive_app_bar.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon_button.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon.dart';

class DebugViewer extends StatefulWidget {
  final String input;

  const DebugViewer({this.input, Key key}) : super(key: key);

  @override
  _DebugViewerState createState() => _DebugViewerState();
}

class _DebugViewerState extends State<DebugViewer> {
  DebugViewerBloc _debugViewerBloc = DebugViewerBloc();
  Navigation navigation = Navigation();

  @override
  void initState() {
    super.initState();
    navigation.current = Navigatable(Type.debugViewer);
    if (isNullOrEmpty(widget.input)) {
      _debugViewerBloc.dispatch(RequestLog());
    } else {
      _debugViewerBloc.dispatch(InputLoaded(input: widget.input));
    }
  }

  @override
  void dispose() {
    _debugViewerBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AdaptiveAppBar(
          leadingIcon: new AdaptiveIconButton(
            icon: new AdaptiveIcon(
                androidIcon: Icons.arrow_back,
                iosIcon: CupertinoIcons.back
            ),
            onPressed: () => navigation.pop(context),
          ),
          title: Text(L10n.get(L.debug)),
          actions: <Widget>[
            AdaptiveIconButton(
              icon: AdaptiveIcon(
                  androidIcon: Icons.content_copy,
                  iosIcon: CupertinoIcons.collections
              ),
              onPressed: () => _onCopy(),
            )
          ],
        ),
        body: _buildDebugOutput(context));
  }

  Widget _buildDebugOutput(BuildContext context) {
    return BlocBuilder(
      bloc: _debugViewerBloc,
      builder: (context, state) {
        if (state is DebugViewerStateInitial) {
          return StateInfo(showLoading: true);
        } else if (state is DebugViewerStateSuccess) {
          return SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              child: Text(state.data),
            ),
          );
        } else {
          return Center(
            child: Icon(Icons.error),
          );
        }
      },
    );
  }

  _onCopy() {
    copyToClipboardWithToast(text: _debugViewerBloc.data, toastText: getDefaultCopyToastText(context));
  }
}
