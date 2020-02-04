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
import 'package:ox_coi/src/chat/chat.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/qr/qr_bloc.dart';
import 'package:ox_coi/src/qr/qr_event_state.dart';
import 'package:ox_coi/src/utils/text.dart';
import 'package:ox_coi/src/utils/toast.dart';
import 'package:ox_coi/src/widgets/fullscreen_progress.dart';
import 'package:ox_coi/src/widgets/state_info.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

class ScanQr extends StatefulWidget {
  @override
  _ScanQrState createState() => _ScanQrState();
}

class _ScanQrState extends State<ScanQr> {
  QrBloc _qrBloc = QrBloc();
  OverlayEntry _progressOverlayEntry;
  bool _qrCodeDetected = false;
  Navigation _navigation = Navigation();

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.scanQr);
    requestQrCamera();
    _qrBloc.listen((state) {
      if (state is QrStateSuccess) {
        _qrCodeDetected = false;
        if (state.chatId != 0) {
          _navigation.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Chat(chatId: state.chatId)),
            ModalRoute.withName(Navigation.root),
            Navigatable(Type.chat),
          );
        } else {
          showToast(L10n.get(L.errorProgressCanceled));
        }
        _progressOverlayEntry?.remove();
      } else if (state is QrStateFailure) {
        _qrCodeDetected = false;

        var error = state.error;
        if (!isNullOrEmpty(error)) {
          showToast(error);
          Future.delayed(const Duration(milliseconds: 2000), () {
            requestQrCamera();
          });
        }
        _progressOverlayEntry?.remove();
      }
    });
  }

  void requestQrCamera() {
    _qrBloc.add(RequestQrCamera());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _qrBloc,
      builder: (context, state) {
        if (state is QrStateCameraRequested) {
          if (state.successfullyLoaded) {
            return Center(
              child: QrCamera(
                qrCodeCallback: (code) {
                  setState(() {
                    if (!_qrCodeDetected) {
                      String qrString = code;
                      if (qrString.isNotEmpty) {
                        _qrCodeDetected = true;
                        checkAndJoinQr(qrString);
                      }
                    }
                  });
                },
              ),
            );
          } else {
            return StateInfo(
              title: L10n.get(L.qrCameraNotAllowed),
              subTitle: L10n.get(L.qrCameraNotAllowedText),
              actionTitle: L10n.get(L.retry),
              action: requestQrCamera,
            );
          }
        } else if (state is QrStateLoading) {
          return Container();
        } else {
          return StateInfo(showLoading: true);
        }
      },
    );
  }

  void checkAndJoinQr(String qrString) {
    _progressOverlayEntry = FullscreenOverlay(
      fullscreenProgress: FullscreenProgress(
        bloc: _qrBloc,
        text: L10n.get(L.pleaseWait),
        showProgressValues: false,
        showCancelButton: true,
        cancelPressed: _cancelPressed,
      ),
    );
    Overlay.of(context).insert(_progressOverlayEntry);
    _qrBloc.add(CheckQr(qrText: qrString));
  }

  void _cancelPressed() {
    _progressOverlayEntry?.remove();
    _qrCodeDetected = false;
    _qrBloc.add(CancelQrProcess());
  }
}
