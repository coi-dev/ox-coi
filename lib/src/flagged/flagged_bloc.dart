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
  RepositoryEventStreamHandler _repositoryStreamHandler;
  Repository<ChatMsg> _messageListRepository = RepositoryManager.get(RepositoryType.chatMessage, Chat.typeStarred);
  bool _listenersRegistered = false;
  int _chatId;

  @override
  FlaggedState get initialState => FlaggedStateInitial();

  @override
  Stream<FlaggedState> mapEventToState(FlaggedEvent event) async* {
    if (event is RequestFlaggedMessages) {
      yield FlaggedStateLoading();
      try {
        _chatId = event.chatId;
        _registerListeners();
        _loadFlaggedMessages();
      } catch (error) {
        yield FlaggedStateFailure(error: error.toString());
      }
    } else if (event is FlaggedMessagesLoaded) {
      yield FlaggedStateSuccess(
        messageIds: event.messageIds,
        messageLastUpdateValues: event.messageLastUpdateValues,
        dateMarkerIds: event.dateMarkerIds,
      );
    } else if (event is UpdateMessages) {
      _loadFlaggedMessages();
    }
  }

  @override
  Future<void> close() {
    _unregisterListeners();
    return super.close();
  }

  void _registerListeners() {
    if (!_listenersRegistered) {
      _listenersRegistered = true;
      _repositoryStreamHandler = RepositoryEventStreamHandler(Type.publish, Event.msgsChanged, _updateMessages);
      _messageListRepository.addListener(_repositoryStreamHandler);
    }
  }

  void _unregisterListeners() {
    if (_listenersRegistered) {
      _listenersRegistered = false;
      _messageListRepository?.removeListener(_repositoryStreamHandler);
    }
  }

  void _updateMessages(Event event) => add(UpdateMessages());

  void _loadFlaggedMessages() async {
    final List<int> dateMakerIds = List();
    final Context context = Context();
    final List<int> messageIds = List.from(await context.getChatMessages(Chat.typeStarred, Context.chatListAddDayMarker));
    _messageListRepository.putIfAbsent(ids: messageIds.where((id) => id != ChatMsg.idDayMarker).toList());

    if (null != _chatId) {
      final List<int> messageIdsFromChat = List.from(await context.getChatMessages(_chatId, Context.chatListAddDayMarker));
      messageIds.removeWhere((id) => !messageIdsFromChat.contains(id));
    }

    for (int index = 0; index < messageIds.length; index++) {
      final previousIndex = index - 1;
      if (previousIndex >= 0 && messageIds[previousIndex] == ChatMsg.idDayMarker) {
        dateMakerIds.add(messageIds[index]);
      }
    }
    messageIds.removeWhere((id) => id == ChatMsg.idDayMarker);
    add(
      FlaggedMessagesLoaded(
          messageIds: messageIds.reversed.toList(growable: false),
          messageLastUpdateValues: _messageListRepository.getLastUpdateValuesForIds(messageIds).reversed.toList(growable: false),
          dateMarkerIds: dateMakerIds),
    );
  }
}
