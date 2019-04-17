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
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ox_talk/src/chat/chat_composer_event.dart';
import 'package:ox_talk/src/chat/chat_composer_state.dart';
import 'package:ox_talk/src/utils/date.dart';
import 'package:ox_talk/src/utils/security.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:delta_chat_core/delta_chat_core.dart' as Dcc;

class ChatComposerBloc extends Bloc<ChatComposerEvent, ChatComposerState> {
  StreamSubscription<RecordStatus> _recorderSubscription;
  FlutterSound _flutterSound = FlutterSound();
  String _audioPath;

  @override
  ChatComposerState get initialState => ChatComposerInitial();

  @override
  Stream<ChatComposerState> mapEventToState(ChatComposerState currentState, ChatComposerEvent event) async* {
    if (event is StartAudioRecording) {
      try {
        bool hasContactPermission = await hasPermission(PermissionGroup.microphone);
        bool hasFilesPermission = await hasPermission(PermissionGroup.storage);
        if (hasContactPermission && hasFilesPermission) {
          await startAudioRecorder();
          yield ChatComposerRecordingAudio(timer: "00:00:00");
        } else {
          yield ChatComposerRecordingAborted(error: ChatComposerStateError.missingMicrophonePermission);
        }
      } catch (err) {
        print('startRecorder error: $err');
        yield ChatComposerRecordingAudioStopped(filePath: null, shouldSend: false);
      }
    } else if (event is UpdateAudioRecording) {
      yield ChatComposerRecordingAudio(timer: event.timer);
    } else if (event is StopAudioRecording) {
      stopAudioRecorder(event.shouldSend);
    } else if (event is AudioRecordingStopped) {
      yield ChatComposerRecordingAudioStopped(filePath: _audioPath, shouldSend: event.shouldSend);
    } else if (event is StartImageOrVideoRecording) {
      bool hasCameraPermission = await hasPermission(PermissionGroup.camera);
      if (hasCameraPermission) {
        startImageOrVideoRecorder(event.pickImage);
      } else {
        yield ChatComposerRecordingAborted(error: ChatComposerStateError.missingCameraPermission);
      }
    } else if (event is StopImageOrVideoRecording) {
      if (!_wasImageOrVideoRecordingCanceled(event.filePath, event.type)) {
        yield ChatComposerRecordingImageOrVideoStopped(filePath: event.filePath, type: event.type);
      }
    }
  }

  Future<void> startAudioRecorder() async {
    Directory tempDir = await getTemporaryDirectory();
    String path = tempDir.path + separator;
    String name = getNowTimestamp().toString() + ".m4a";
    _audioPath = await _flutterSound.startRecorder("$path$name", bitRate: 64000, numChannels: 1);
    _recorderSubscription = _flutterSound.onRecorderStateChanged.listen((e) {
      String timer = getTimerFormTimestamp(e.currentPosition.toInt());
      dispatch(UpdateAudioRecording(timer: timer));
    });
  }

  void stopAudioRecorder(bool shouldSend) async {
    try {
      String result = await _flutterSound.stopRecorder();
      print('stopRecorder: $result');

      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
      }
    } catch (err) {
      print('stopRecorder error: $err');
    }
    dispatch(AudioRecordingStopped(audioPath: _audioPath, shouldSend: shouldSend));
  }

  Future<void> startImageOrVideoRecorder(bool pickImage) async {
    File file;
    int type;
    if (pickImage) {
      file = await ImagePicker.pickImage(source: ImageSource.camera);
      type = Dcc.ChatMsg.typeImage;
    } else {
      file = await ImagePicker.pickVideo(source: ImageSource.camera);
      type = Dcc.ChatMsg.typeVideo;
    }
    if (file != null) {
      dispatch(StopImageOrVideoRecording(filePath: file.path, type: type));
    } else {
      dispatch(StopImageOrVideoRecording(filePath: null, type: 0));
    }
  }

  bool _wasImageOrVideoRecordingCanceled(String filePath, int type) {
    return filePath == null && type == 0;
  }
}
