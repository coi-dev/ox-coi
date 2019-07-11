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
import 'package:ox_coi/src/data/repository_stream_handler.dart';
import 'flagged_events_state.dart';

class FlaggedBloc extends Bloc<FlaggedEvent, FlaggedState> {
  RepositoryEventStreamHandler repositoryStreamHandler;
  Repository<ChatMsg> _messageListRepository;

  @override
  FlaggedState get initialState => FlaggedStateInitial();

  @override
  Stream<FlaggedState> mapEventToState(FlaggedState currentState, FlaggedEvent event) async*{
    if(event is RequestFlaggedMessages){
      yield FlaggedStateLoading();
      try{
        _messageListRepository = RepositoryManager.get(RepositoryType.chatMessage, Chat.typeStarred);
        _setupMessagesListener();
        _loadFlaggedMessages();
      }catch (error) {
        yield FlaggedStateFailure(error: error.toString());
      }
    }else if (event is FlaggedMessagesLoaded) {
      yield FlaggedStateSuccess(
        messageIds: event.messageIds,
        messageLastUpdateValues: event.messageLastUpdateValues,
        dateMarkerIds: event.dateMarkerIds,
      );
    }else if(event is UpdateMessages){
      _loadFlaggedMessages();
    }
  }

  @override
  void dispose() {
    _messageListRepository?.removeListener(repositoryStreamHandler);
    super.dispose();
  }

  void _setupMessagesListener() async {
    if (repositoryStreamHandler == null) {
      repositoryStreamHandler =
          RepositoryEventStreamHandler(Type.publish, Event.msgsChanged, _updateMessages);
      _messageListRepository.addListener(repositoryStreamHandler);
    }
  }

  void _updateMessages(Event event) => dispatch(UpdateMessages());

  void _loadFlaggedMessages() async{
    List<int> dateMakerIds = List();
    Context context = Context();
    List<int> messageIds = List.from(await context.getChatMessages(Chat.typeStarred, Context.chatListAddDayMarker));
    for (int index = 0; index < messageIds.length; index++) {
      int previousIndex = index - 1;
      if (previousIndex >= 0 && messageIds[previousIndex] == ChatMsg.idDayMarker) {
        dateMakerIds.add(messageIds[index]);
      }
    }
    messageIds.removeWhere((id) => id == ChatMsg.idDayMarker);
    _messageListRepository.putIfAbsent(ids: messageIds);
    await Future.forEach(messageIds, (id) async {
      ChatMsg message = _messageListRepository.get(id);
      if (await message.isOutgoing()) {
        await message.reloadValue(ChatMsg.methodMessageGetState);
      }
    });

    dispatch(
      FlaggedMessagesLoaded(
        messageIds: _messageListRepository.getAllIds().reversed.toList(growable: false),
        messageLastUpdateValues: _messageListRepository.getAllLastUpdateValues().reversed.toList(growable: false),
        dateMarkerIds: dateMakerIds),
    );
  }

}