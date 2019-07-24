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

import 'package:bloc/bloc.dart';
import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/qr/qr_event_state.dart';
import 'package:ox_coi/src/utils/error.dart';
import 'package:rxdart/rxdart.dart';

class QrBloc extends Bloc<QrEvent, QrState>{
  DeltaChatCore _core = DeltaChatCore();
  int _qrInviterListenerId;
  int _qrJoinerListenerId;
  int _errorSubjectListenerId;

  PublishSubject<Event> _qrSubject = new PublishSubject();
  // ignore: close_sinks
  BehaviorSubject<Event> _errorSubject = new BehaviorSubject();

  @override
  QrState get initialState => QrStateInitial();

  @override
  Stream<QrState> mapEventToState(QrState currentState, QrEvent event) async*{
    if(event is RequestQrText){
      yield QrStateLoading(progress: 0);
      try{
        _registerListeners();
        getQrText(event.chatId);
      }
      catch(error){
        yield QrStateFailure(error: error.toString());
      }
    }
    else if(event is QrTextLoaded){
      yield QrStateSuccess(qrText: event.qrText);
    }
    else if(event is JoinDone){
      yield QrStateSuccess(chatId: event.chatId);
    }
    else if(event is CheckQr){
      yield QrStateLoading(progress: 0);
      checkQr(event.qrText);
    }
    else if(event is CheckQrDone){
     joinSecurejoin(event.qrText);
    }
    else if(event is QrJoinInviteProgress){
      if(_joinInviteSuccess(event.progress)){
        yield QrStateVerificationFinished();
      }else if(_joinInviteFailed(event.progress)){
        String error = event.error;
        if (error == null) {
          error = getErrorMessage(_errorSubject.value);
        }
        yield QrStateFailure(error: error);
      }else{
        yield QrStateLoading(progress: event.progress);
      }
    }else if(event is CancelQrProcess){
      cancelQrProcess();
    }
  }

  bool _joinInviteSuccess(int progress) {
    return progress == 1000;
  }

  bool _joinInviteFailed(int progress) {
    return progress == 0;
  }

  @override
  void dispose() {
    _unregisterListeners();
    super.dispose();
  }

  void _registerListeners() async {
    if (_qrInviterListenerId == null || _qrJoinerListenerId == null) {
      _qrSubject.listen(_successCallback, onError: _errorCallback);
      _qrInviterListenerId = await _core.listen(Event.secureJoinInviterProgress, _qrSubject);
      _qrJoinerListenerId = await _core.listen(Event.secureJoinJoinerProgress, _qrSubject);
      _errorSubjectListenerId = await _core.listen(Event.error, _errorSubject);
    }
  }

  void _unregisterListeners() {
    _core.removeListener(Event.secureJoinInviterProgress, _qrInviterListenerId);
    _core.removeListener(Event.secureJoinJoinerProgress, _qrJoinerListenerId);
    _core.removeListener(Event.error, _errorSubjectListenerId);
    _qrInviterListenerId = null;
    _qrJoinerListenerId = null;
    _errorSubjectListenerId = null;
  }

  void getQrText(int chatId) async{
    Context context = Context();
    String qrText = await context.getSecureJoinQr(chatId);
    dispatch(QrTextLoaded(qrText: qrText));
  }

  void checkQr(String qrText) async{
    Context context = Context();
    var result = await context.checkQr(qrText);
    QrCodeResult qrResult = QrCodeResult.fromMethodChannel(result);
    if(qrResult.state == Context.qrAskVerifyContact || qrResult.state == Context.qrAskVerifyGroup){
      dispatch(CheckQrDone(qrText: qrText));
    }
  }

  void _successCallback(Event event) {
    int progress = event.data2 as int;
    dispatch(QrJoinInviteProgress(progress: progress));
  }

  void _errorCallback(error) async {
    dispatch(QrJoinInviteProgress(progress: 0, error: error));
  }

  void joinSecurejoin(String qrText) async{
    Context context = Context();
    int chatId = await context.joinSecurejoinQr(qrText);
    if(chatId == 0){
      dispatch(JoinFailed());
    }else{
      Repository<Chat> chatRepository = RepositoryManager.get(RepositoryType.chat);
      chatRepository.putIfAbsent(id: chatId);
      dispatch(JoinDone(chatId: chatId));
    }
  }

  void cancelQrProcess() async{
    Context context = Context();
    await context.stopOngoingProcess();
  }
}