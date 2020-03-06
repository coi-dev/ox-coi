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

import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/base/bloc_progress_state.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/custom_theme.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/widgets/button.dart';

class FullscreenOverlay<T extends Bloc> extends OverlayEntry {
  bool _isVisible = true;

  FullscreenOverlay({FullscreenProgress fullscreenProgress}) : super(builder: (context) => fullscreenProgress) {
    Navigation().allowBackNavigation = false;
  }

  @override
  void remove() {
    Navigation().allowBackNavigation = true;
    if (_isVisible) {
      _isVisible = false;
      super.remove();
    }
  }
}

class FullscreenProgress<T extends Bloc> extends StatelessWidget {
  final String text;
  final bool showProgressValues;
  final T bloc;
  final bool showCancelButton;
  final Function cancelPressed;

  FullscreenProgress({
    @required this.bloc,
    @required this.text,
    this.showProgressValues = false,
    this.showCancelButton = false,
    this.cancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: bloc,
      builder: (BuildContext context, state) {
        int progress = 0;
        if (state is ProgressState && state.progress != null) {
          progress = state.progress;
        }
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              constraints: BoxConstraints.expand(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(CustomTheme.of(context).onSurface),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: verticalPadding),
                    child: Center(
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subhead.apply(color: CustomTheme.of(context).onSurface),
                      ),
                    ),
                  ),
                  if (showProgressValues)
                    Padding(
                      padding: EdgeInsets.only(top: verticalPaddingSmall),
                      child: Text(
                        buildDisplayableProgress(progress),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subhead.apply(color: CustomTheme.of(context).onSurface),
                      ),
                    ),
                  if (showCancelButton)
                    Padding(
                      padding: EdgeInsets.only(top: verticalPaddingSmall),
                      child: ButtonImportanceLow(
                        child: Text(L10n.get(L.cancel)),
                        onPressed: cancelPressed,
                      ),
                    )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String buildDisplayableProgress(int progress) => "${progress / 10}%";
}
