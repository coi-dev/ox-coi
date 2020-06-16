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
import 'package:file_picker/file_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ox_coi/src/chat/chat_composer_event_state.dart';
import 'package:ox_coi/src/chat/chat_composer_mixin.dart';
import 'package:ox_coi/src/extensions/numbers_apis.dart';
import 'package:ox_coi/src/extensions/string_apis.dart';
import 'package:ox_coi/src/utils/video.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatComposerBloc extends Bloc<ChatComposerEvent, ChatComposerState> {
  StreamSubscription<RecordStatus> _recorderSubscription;
  StreamSubscription<double> _recorderPeakSubscription;
  StreamSubscription<PlayStatus> _playerSubscription;
  FlutterSound _flutterSound = FlutterSound();
  int _cutoffValue;
  bool _isSeeking;

  ChatComposerComposing get composingState => (state as ChatComposerComposing);

  @override
  ChatComposerState get initialState => ChatComposerComposing(state: ComposerState.readyToCompose);

  @override
  Stream<ChatComposerState> mapEventToState(ChatComposerEvent event) async* {
    if (event is CheckPermissions) {
      bool hasMicPermission = await Permission.microphone.request().isGranted;
      bool hasFilesPermission = await Permission.storage.request().isGranted;
      if (!hasMicPermission || !hasFilesPermission) {
        yield composingState.copyWith(error: ChatComposerError.missingMicrophonePermission);
      } else {
        yield composingState.copyWith(voicePermissionGranted: true);
      }
    } else if (event is StartAudioRecording) {
      try {
        bool hasMicPermission = await Permission.microphone.request().isGranted;
        bool hasFilesPermission = await Permission.storage.request().isGranted;
        if (!hasMicPermission || !hasFilesPermission) {
          yield composingState.copyWith(error: ChatComposerError.missingMicrophonePermission);
        } else {
          yield* _startAudioRecorder();
        }
      } catch (err) {
        print('startRecorder error: $err');
        yield composingState.copyWith(error: ChatComposerError.playerNotStarted);
      }
    } else if (event is UpdateVoiceRecordingTimer) {
      if (state is ChatComposerComposing) {
        yield composingState.copyWith(voiceRecordingTimer: event.timer);
      }
    } else if (event is UpdateVoiceRecordingPeak) {
      if (state is ChatComposerComposing) {
        final visiblePeakList = event.peakList;
        if (_cutoffValue > 0) {
          visiblePeakList.removeRange(0, _cutoffValue);
        }
        yield composingState.copyWith(voicePeakList: event.peakList, voiceVisiblePeakList: visiblePeakList);
      }
    } else if (event is RemoveFirstAudioPeak) {
      _cutoffValue = event.cutoffValue;
    } else if (event is StopAudioRecording) {
      yield* _stopAudioRecorder(sendAudio: event.send, isAborted: event.aborted);
    } else if (event is StartImageOrVideoRecording) {
      bool hasCameraPermission = await Permission.camera.request().isGranted;
      if (hasCameraPermission) {
        yield* _startImageOrVideoCapture(event.type);
      } else {
        yield composingState.copyWith(error: ChatComposerError.missingCameraPermission);
      }
    } else if (event is ReplayAudio) {
      yield* _startAudioPlayer();
    } else if (event is ReplayAudioStopped) {
      yield composingState.copyWith(voiceState: ComposerVoiceState.stopped);
    } else if (event is ReplayAudioTimeUpdate) {
      yield composingState.copyWith(voiceReplayTimer: event.replayTime);
    } else if (event is ReplayAudioSeek) {
      _seekAudioPlayer(event.seekValue);
    } else if (event is UpdateReplayTime) {
      _isSeeking = true;
      yield composingState.copyWith(voiceReplayTimer: event.replayTime);
    } else if (event is StopAudioReplay) {
      yield* _stopAudioPlayer();
    } else if (event is AttachFile) {
      final filePath = event.filePath;
      if (filePath.isNullOrEmpty()) {
        yield* _attachFile(event.fileType, event.extension);
      } else {
        yield composingState.copyWith(filePath: filePath, fileType: _convertToDccFileType(event.fileType));
      }
    } else if (event is PrepareMessageForSending) {
      yield composingState.copyWith(state: ComposerState.prepareSending);
    } else if (event is DetachFile) {
      yield* _detachFile();
    } else if (event is Typing) {
      yield composingState.copyWith(state: _isTyping(event) ? ComposerState.isComposing : ComposerState.readyToCompose, text: event.text);
    } else if (event is ResetComposer) {
      yield ChatComposerComposing(state: ComposerState.readyToCompose);
    }
  }

  Stream<ChatComposerState> _startAudioRecorder() async* {
    final peakList = <double>[];
    _flutterSound.setDbLevelEnabled(true);
    _flutterSound.setDbPeakLevelUpdate(1.0);

    final voiceFilePath = await _flutterSound.startRecorder(null, bitRate: 64000, numChannels: 1);

    _recorderPeakSubscription = _flutterSound.onRecorderDbPeakChanged.listen((newPeak) {
      peakList.add(newPeak / 5);
      if (state is ChatComposerComposing) {
        add(UpdateVoiceRecordingPeak(peakList: peakList));
      }
    });

    _recorderSubscription = _flutterSound.onRecorderStateChanged.listen((event) {
      if (state is ChatComposerComposing) {
        String timer = event.currentPosition.toInt().getTimerFromTimestamp();
        add(UpdateVoiceRecordingTimer(timer: timer));
      }
    });

    yield ChatComposerComposing(
      state: ComposerState.isVoiceRecording,
      voiceState: ComposerVoiceState.recording,
      voiceVisiblePeakList: peakList,
      voiceRecordingTimer: "00:00",
      filePath: voiceFilePath,
      fileType: ChatMsg.typeVoice,
    );
  }

  Stream<ChatComposerState> _stopAudioRecorder({bool isAborted, bool sendAudio}) async* {
    try {
      String result;
      if (_flutterSound.isRecording) {
        result = await _flutterSound.stopRecorder();
      } else {
        result = "Already stopped";
      }
      print('stopRecorder: $result');
      _recorderSubscription?.cancel();
      _recorderSubscription = null;
      _recorderPeakSubscription?.cancel();
      _recorderPeakSubscription = null;
    } catch (err, trace) {
      print('stopRecorder error: $err ($trace)');
    }

    if (isAborted) {
      if (_flutterSound.isPlaying) {
        await _flutterSound.stopPlayer();
      }
      yield ChatComposerPrepared();
    } else {
      if (sendAudio) {
        yield composingState.copyWith(fileType: ChatMsg.typeVoice);
      } else {
        yield composingState.copyWith(voiceState: ComposerVoiceState.stopped);
      }
    }
  }

  Stream<ChatComposerState> _startAudioPlayer() async* {
    int replayTime = 0;
    final filePath = composingState.filePath;
    await _flutterSound.startPlayer(filePath);

    _playerSubscription = _flutterSound.onPlayerStateChanged.listen((data) {
      if (data?.duration != data?.currentPosition) {
        int currentTimer = (data.currentPosition / 1000).round();
        final dbPeakList = composingState.voicePeakList;
        if (currentTimer > replayTime && replayTime <= dbPeakList.length && !_isSeeking) {
          replayTime = currentTimer;
          add(ReplayAudioTimeUpdate(replayTime: replayTime));
        }
      } else {
        add(ReplayAudioStopped());
      }
    });
  }

  Future<void> _seekAudioPlayer(int seekValue) async {
    _isSeeking = false;
    int milliSeconds = (seekValue * 1000);

    add(ReplayAudioTimeUpdate(replayTime: seekValue));

    await _flutterSound.seekToPlayer(milliSeconds);
  }

  Stream<ChatComposerState> _stopAudioPlayer() async* {
    await _flutterSound.stopPlayer();
    _isSeeking = false;
    _playerSubscription?.cancel();
    _playerSubscription = null;
    yield composingState.copyWith(voiceState: ComposerVoiceState.stopped);
  }

  Stream<ChatComposerState> _startImageOrVideoCapture(int type) async* {
    File file = ChatMsg.typeImage == type ? await ImagePicker.pickImage(source: ImageSource.camera) : await ImagePicker.pickVideo(source: ImageSource.camera);
    if (file != null) {
      final filePath = file.path;
      if (filePath != null) {
        yield composingState.copyWith(state: ComposerState.isComposing, filePath: filePath, fileType: type);
      }
    } else {
      yield* _detachFile();
    }
  }

  Stream<ChatComposerState> _attachFile(FileType fileType, [String extension]) async* {
    String filePath;
    try {
      filePath = await FilePicker.getFilePath(type: fileType, fileExtension: extension);
    } catch (error) {
      yield composingState.copyWith(error: ChatComposerError.missingFilesPermission);
    }
    if (filePath == null) {
      return;
    }
    if (fileType == FileType.video) {
      filePath = await getVideoPathFromFilePickerInputAsync(filePath);
    }
    yield composingState.copyWith(state: ComposerState.isComposing, filePath: filePath, fileType: _convertToDccFileType(fileType));
  }

  Stream<ChatComposerState> _detachFile() async* {
    yield composingState.copyWith(state: _isTyping() ? ComposerState.isComposing : ComposerState.readyToCompose, filePath: "", fileType: null);
  }

  int _convertToDccFileType(FileType selectedFilePickerType, [int knownType]) {
    int type = 0;
    if (knownType == null) {
      switch (selectedFilePickerType) {
        case FileType.image:
          type = ChatMsg.typeImage;
          break;
        case FileType.video:
          type = ChatMsg.typeVideo;
          break;
        case FileType.audio:
          type = ChatMsg.typeAudio;
          break;
        case FileType.custom:
          type = ChatMsg.typeFile;
          break;
        case FileType.any:
          type = ChatMsg.typeFile;
          break;
      }
    } else {
      type = knownType;
    }
    return type;
  }

  /// Checks either the given [Typing] event or the current [ChatComposerComposing] state if the user is typing
  bool _isTyping([Typing event]) {
    String text;
    if (event != null) {
      text = event.text?.trim();
    } else {
      text = composingState.text?.trim();
    }
    return text?.isNotEmpty ?? false;
  }
}
