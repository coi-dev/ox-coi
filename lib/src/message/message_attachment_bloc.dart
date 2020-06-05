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
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:crypto/crypto.dart';
import 'package:delta_chat_core/delta_chat_core.dart' as Core;
import 'package:logging/logging.dart';
import 'package:open_file/open_file.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/extensions/numbers_apis.dart';
import 'package:ox_coi/src/message/message_attachment_event_state.dart';
import 'package:ox_coi/src/platform/method_channel.dart';
import 'package:ox_coi/src/share/outgoing_shared_data.dart';
import 'package:ox_coi/src/utils/constants.dart';
import 'package:ox_coi/src/utils/video.dart';
import 'package:path/path.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MessageAttachmentBloc extends Bloc<MessageAttachmentEvent, MessageAttachmentState> {
  static final _logger = Logger("message_attachment_bloc");
  Repository<Core.ChatMsg> _messageListRepository;

  @override
  MessageAttachmentState get initialState => MessageAttachmentStateInitial();

  @override
  Stream<MessageAttachmentState> mapEventToState(MessageAttachmentEvent event) async* {
    if (event is RequestAttachment) {
      _messageListRepository = RepositoryManager.get(RepositoryType.chatMessage, event.chatId);
      yield MessageAttachmentStateLoading();
      try {
        _openFile(event.messageId);
        add(AttachmentLoaded());
      } catch (error) {
        yield MessageAttachmentStateFailure(error: error.toString());
      }
    }
    if (event is ShareAttachment) {
      _messageListRepository = RepositoryManager.get(RepositoryType.chatMessage, event.chatId);
      yield MessageAttachmentStateLoading();
      try {
        _shareFile(event.messageId);
        add(AttachmentLoaded());
      } catch (error) {
        yield MessageAttachmentStateFailure(error: error.toString());
      }
    } else if (event is AttachmentLoaded) {
      yield MessageAttachmentStateSuccess();
    } else if (event is LoadThumbnailAndDuration) {
      yield* loadThumbnailAndDuration(event.path, event.duration);
    } else if (event is GetNextPreviousImage) {
      yield* getNextPreviousMessageAsync(event);
    }
  }

  void _openFile(int messageId) async {
    Core.ChatMsg message = _getMessage(messageId);
    OpenFile.open(await message.getFile());
  }

  void _shareFile(int messageId) async {
    Core.ChatMsg message = _getMessage(messageId);
    var text = await message.getText();
    var filePath = await message.getFile();
    var mimeType = filePath.isNotEmpty ? await message.getFileMime() : "text/*";

    final shareData = OutgoingSharedData(
      title: text,
      path: filePath,
      mimeType: mimeType,
      text: text,
    );
    await SharingChannel.instance.invokeMethod(SharingChannel.kMethodSendSharedData, shareData.toMap());
  }

  Core.ChatMsg _getMessage(int messageId) {
    return _messageListRepository.get(messageId);
  }

  Stream<MessageAttachmentState> loadThumbnailAndDuration(String videoPath, int duration) async* {
    String thumbnailPath = await setupAndGetThumbnailPath(videoPath, duration);
    String durationString = await getVideoTime(videoPath, duration);

    yield MessageAttachmentStateSuccess(path: thumbnailPath, duration: durationString);
  }

  Future<String> setupAndGetThumbnailPath(String videoPath, int duration) async {
    String thumbnailPath = _getThumbnailPath(videoPath);
    File file = File(thumbnailPath);
    bool fileExists = await file.exists();
    String result = thumbnailPath;
    if (!fileExists) {
      try {
        final imageData = await VideoThumbnail.thumbnailData(
          video: videoPath,
          imageFormat: ImageFormat.JPEG,
          quality: 25,
        );
        file.writeAsBytes(imageData);
      } catch (error) {
        _logger.warning("Couldn't load thumbnail. Error: $error");
        result = "";
      }
    }
    return result;
  }

  String _getThumbnailPath(String videoPath) {
    final videoPathBytes = utf8.encode(videoPath);
    final videoPathSha1 = sha1.convert(videoPathBytes);
    final thumbnailName = "$videoPathSha1$thumbnailFileExtension";
    final videoDirectory = dirname(videoPath);
    return "$videoDirectory/$thumbnailName";
  }

  Future<String> getVideoTime(String path, int duration) async {
    if (duration == 0) {
      duration = await getDurationInMilliseconds(path);
    }

    return duration.getVideoTimeFromTimestamp();
  }

  Stream<MessageAttachmentState> getNextPreviousMessageAsync(GetNextPreviousImage event) async* {
    Core.Context context = Core.Context();

    int nextMessageId = await context.getNextMedia(
      event.messageId,
      event.dir,
      messageTypeOne: Core.ChatMsg.typeImage,
      messageTypeTwo: Core.ChatMsg.typeVideo,
      messageTypeThree: Core.ChatMsg.typeGif,
    );

    yield MessageAttachmentStateGetNextSuccess(messageId: nextMessageId);
  }
}
