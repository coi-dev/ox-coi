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

import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:logging/logging.dart';
import 'package:mime/mime.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/data/repository_stream_handler.dart';
import 'package:ox_coi/src/invite/invite_mixin.dart';
import 'package:ox_coi/src/utils/video.dart';

import 'message_list_event_state.dart';

class MessageListBloc extends Bloc<MessageListEvent, MessageListState> with InviteMixin {
  final _logger = Logger("message_list_bloc");

  RepositoryMultiEventStreamHandler _messageListRepositoryStreamHandler;
  RepositoryMultiEventStreamHandler _messageRepositoryStreamHandler;
  Repository<ChatMsg> _messageListRepository;
  int _chatId;
  int _messageId;
  String _cacheFilePath = "";
  bool _listenersRegistered = false;
  bool _handlesFlaggedMessages = false;

  @override
  MessageListState get initialState => MessageListStateInitial();

  @override
  Stream<MessageListState> mapEventToState(MessageListEvent event) async* {
    if (event is RequestMessageList || event is RequestFlaggedMessageList) {
      yield MessageListStateLoading();
      try {
        if (event is RequestMessageList) {
          _handlesFlaggedMessages = false;
          _setupBloc(event.chatId, event.messageId);
          yield* _setupMessagesAsync();
        } else if (event is RequestFlaggedMessageList) {
          _handlesFlaggedMessages = true;
          _setupBloc(event.chatId);
          yield* _setupFlaggedMessagesAsync();
        }
      } catch (error) {
        _logger.warning(error.toString());
        yield MessageListStateFailure(error: error.toString());
      }
    } else if (event is UpdateMessageList) {
      try {
        if (_handlesFlaggedMessages) {
          yield* _setupFlaggedMessagesAsync();
        } else {
          yield* _setupMessagesAsync();
        }
      } catch (error) {
        yield MessageListStateFailure(error: error.toString());
      }
    } else if (event is SendMessage) {
      if (_hasAttachment(event)) {
        _submitAttachmentMessageAsync(event.path, event.fileType, event.isShared, event.text);
      } else {
        _submitMessageAsync(event.text);
      }
    } else if (event is DeleteCacheFile) {
      _deleteCacheFile(event.path);
    } else if (event is RetrySendPendingMessages) {
      _retrySendPendingMessagesAsync();
    }
  }

  @override
  Future<void> close() {
    _unregisterListeners();
    return super.close();
  }

  void _setupBloc(int chatId, [int messageId]) {
    _chatId = chatId;
    _messageListRepository = RepositoryManager.get(RepositoryType.chatMessage, _chatId);
    if (isInvite(_chatId, messageId)) {
      _messageId = messageId;
    }
    _registerListeners();
  }

  void _registerListeners() {
    if (!_listenersRegistered) {
      _listenersRegistered = true;
      _messageListRepositoryStreamHandler = RepositoryMultiEventStreamHandler(
        Type.publish,
        [Event.incomingMsg, Event.msgsChanged, Event.msgFailed],
        _onMessageListChanged,
      );
      _messageListRepository.addListener(_messageListRepositoryStreamHandler);
      _messageRepositoryStreamHandler = RepositoryMultiEventStreamHandler(
        Type.replay,
        [Event.msgDelivered, Event.msgRead, Event.msgFailed, Event.msgsChanged],
        _onMessageChanged,
      );
      _messageListRepository.addListener(_messageRepositoryStreamHandler);
    }
  }

  void _unregisterListeners() {
    if (_listenersRegistered) {
      _listenersRegistered = false;
      _messageListRepository?.removeListener(_messageListRepositoryStreamHandler);
      _messageListRepository?.removeListener(_messageRepositoryStreamHandler);
    }
  }

  void _onMessageListChanged(event) {
    if (relevantForChat(event)) {
      _deleteCacheFile(_cacheFilePath);
      add(UpdateMessageList());
    }
  }

  bool relevantForChat(event) => event.data1 == null || (event.data1 == _chatId || event.data1 == 0);

  void _onMessageChanged([Event event]) async {
    if (relevantForChat(event)) {
      _logger.fine("Message in $_chatId was changed");
    }
  }

  void _deleteCacheFile(String path) {
    if (path.isNotEmpty) {
      var cacheFile = File(path);
      if (cacheFile.existsSync()) {
        //TODO:  The cached file should not be deleted before it's copied to another place.
        //cacheFile.delete();
      }
      _cacheFilePath = "";
    }
  }

  Stream<MessageListState> _setupMessagesAsync() async* {
    final context = Context();
    final messageIds = List<int>.from(await context.getChatMessagesAsync(_chatId, Context.chatListAddDayMarker));
    final dateMakerIds = _setupDayMarkerList(messageIds);

    _messageListRepository.putIfAbsent(ids: messageIds);
    if (isInvite(_chatId, _messageId)) {
      final messageIds = List<int>();
      final lastUpdateValues = List<int>();
      final inviteContactId = await getContactIdFromMessageAsync(_messageId);
      await Future.forEach(_messageListRepository.getAll(), (ChatMsg message) async {
        final contactId = await message.getFromIdAsync();
        if (inviteContactId == contactId) {
          messageIds.add(message.id);
          lastUpdateValues.add(message.lastUpdate);
        }
      });

      yield MessageListStateSuccess(
        messageIds: messageIds.reversed.toList(growable: false),
        messageLastUpdateValues: lastUpdateValues.reversed.toList(growable: false),
        dateMarkerIds: dateMakerIds,
        messageChangedStream: _messageRepositoryStreamHandler.streamController.stream,
        handlesFlaggedMessages: _handlesFlaggedMessages,
      );
    } else {
      yield MessageListStateSuccess(
        messageIds: _messageListRepository.getAllIds().reversed.toList(growable: false),
        messageLastUpdateValues: _messageListRepository.getAllLastUpdateValues().reversed.toList(growable: false),
        dateMarkerIds: dateMakerIds,
        messageChangedStream: _messageRepositoryStreamHandler.streamController.stream,
        handlesFlaggedMessages: _handlesFlaggedMessages,
      );
    }
  }

  List<int> _setupDayMarkerList(List messageIds) {
    final dateMakerIds = List<int>();
    for (int index = 0; index < messageIds.length; index++) {
      final previousIndex = index - 1;
      if (previousIndex >= 0 && messageIds[previousIndex] == ChatMsg.idDayMarker) {
        dateMakerIds.add(messageIds[index]);
      }
    }
    messageIds.removeWhere((id) => id == ChatMsg.idDayMarker);
    return dateMakerIds;
  }

  Stream<MessageListState> _setupFlaggedMessagesAsync() async* {
    final context = Context();
    final flaggedMessageListRepository = RepositoryManager.get(RepositoryType.chatMessage, Chat.typeStarred);

    final chatMessageList = List.from(await context.getChatMessagesAsync(_chatId, Context.chatListAddDayMarker));
    final flaggedMessageList = List<int>.from(await context.getChatMessagesAsync(Chat.typeStarred, Context.chatListAddDayMarker));
    flaggedMessageListRepository.putIfAbsent(ids: flaggedMessageList.where((id) => id != ChatMsg.idDayMarker).toList());
    flaggedMessageList.removeWhere((id) => !chatMessageList.contains(id));
    final dateMakerIds = _setupDayMarkerList(flaggedMessageList);

    yield MessageListStateSuccess(
      messageIds: flaggedMessageList.reversed.toList(growable: false),
      messageLastUpdateValues: _messageListRepository.getLastUpdateValuesForIds(flaggedMessageList).reversed.toList(growable: false),
      dateMarkerIds: dateMakerIds,
      messageChangedStream: null,
      handlesFlaggedMessages: _handlesFlaggedMessages,
    );
  }

  bool _hasAttachment(SendMessage event) => event.path != null;

  void _submitMessageAsync(String text) async {
    final context = Context();
    await context.createChatMessageAsync(_chatId, text);
  }

  void _submitAttachmentMessageAsync(String path, int fileType, bool isShared, [String text]) async {
    final context = Context();
    String mimeType = lookupMimeType(path);
    int duration = 0;

    if (isShared) {
      _cacheFilePath = path;
    }
    if (fileType == ChatMsg.typeVideo) {
      duration = await getDurationInMilliseconds(path);
    }

    await context.createChatAttachmentMessageAsync(_chatId, path, fileType, mimeType, duration, text);
  }

  void _retrySendPendingMessagesAsync() async {
    final context = Context();
    await context.retrySendingPendingMessagesAsync();
  }
}
