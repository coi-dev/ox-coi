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
import 'package:ox_coi/src/contact/contact_item_bloc.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/l10n/localizations.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/qr/qr_bloc.dart';
import 'package:ox_coi/src/qr/qr_event_state.dart';
import 'package:ox_coi/src/user/user_bloc.dart';
import 'package:ox_coi/src/user/user_event_state.dart';
import 'package:ox_coi/src/utils/toast.dart';
import 'package:ox_coi/src/widgets/progress_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShowQr extends StatefulWidget {
  final int _chatId;

  ShowQr(this._chatId);

  @override
  _ShowQrState createState() => _ShowQrState();
}

class _ShowQrState extends State<ShowQr> {
  UserBloc _userBloc = UserBloc();
  QrBloc _qrBloc = QrBloc();
  String _qrText;
  Navigation _navigation = Navigation();

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.showQr);
    _qrBloc.dispatch(RequestQrText(widget._chatId));
    _userBloc.dispatch(RequestUser());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        buildQrCodeArea(),
        Padding(padding: EdgeInsets.only(top: 20.0)),
        buildInfoText(),
      ],
    );
  }

  Widget buildInfoText(){
    return BlocBuilder(
      bloc: _userBloc,
      builder: (context,state){
        if(state is UserStateSuccess){
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(AppLocalizations.of(context).qrInviteInfoText(state.config.email), textAlign: TextAlign.center,),
          );
        }
        else{
          return Container();
        }
      }
    );
  }

  Widget buildQrCodeArea(){
    return BlocBuilder(
      bloc: _qrBloc,
      builder: (context, state){
        if(state is QrStateSuccess){
          if(state.qrText != null && state.qrText.isNotEmpty){
            _qrText = state.qrText;
          }
          return buildQrCode(_qrText);
        }else if(state is QrStateLoading){
          showToast(AppLocalizations.of(context).qrVerifyingText);
          return buildQrCode(_qrText);
        }else if(state is QrStateVerificationFinished){
          showToast(AppLocalizations.of(context).qrVerifyCompleteText);
          return buildQrCode(_qrText);
        }else if(state is QrStateFailure){
          showToast(state.error);
          return buildQrCode(_qrText);
        }
        else{
          return Container();
        }
      },
    );
  }

  Widget buildQrCode(String qrText) {
    return QrImage(
      data: qrText,
      size: 250.0,
      version: 6,
    );
  }
}
