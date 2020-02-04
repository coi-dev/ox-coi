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
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ox_coi/src/chat/chat_composer_event_state.dart';
import 'package:ox_coi/src/utils/date.dart';
import 'package:ox_coi/src/utils/security.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatComposerBloc extends Bloc<ChatComposerEvent, ChatComposerState> {
  StreamSubscription<RecordStatus> _recorderSubscription;
  StreamSubscription<double> _recorderDBPeakSubscription;
  StreamSubscription<PlayStatus> _playerSubscription;
  FlutterSound _flutterSound = FlutterSound();
  String _audioPath;
  bool _removeFirstEntry;
  int _cutoffValue;
  int _replayTime;
  bool _isSeeking;
  List<double> _dbPeakList = List<double>();

  @override
  ChatComposerState get initialState => ChatComposerInitial();

  @override
  Stream<ChatComposerState> mapEventToState(ChatComposerEvent event) async* {
    if (event is CheckPermissions) {
      bool hasMicPermission = await hasPermission(PermissionGroup.microphone);
      bool hasFilesPermission = await hasPermission(PermissionGroup.storage);

      if (hasMicPermission && hasFilesPermission) {
        yield ChatComposerPermissionsAccepted();
      } else {
        yield ChatComposerRecordingFailed(error: ChatComposerStateError.missingMicrophonePermission);
      }
    } else if (event is StartAudioRecording) {
      try {
        _removeFirstEntry = false;
        _cutoffValue = 1;
        _replayTime = 0;
        _isSeeking = false;
        _dbPeakList = List<double>();

        await startAudioRecorder();
      } catch (err) {
        print('startRecorder error: $err');
        yield ChatComposerRecordingAudioStopped(filePath: null, dbPeakList: null, sendAudio: false);
      }
    } else if (event is UpdateAudioRecording) {
      yield ChatComposerRecordingAudio(timer: event.timer);
    } else if (event is UpdateAudioDBPeak) {
      yield ChatComposerDBPeakUpdated(dbPeakList: event.dbPeakList);
    } else if (event is RemoveFirstAudioDBPeak) {
      if (_removeFirstEntry != event.removeFirstEntry) {
        _removeFirstEntry = event.removeFirstEntry;
      }

      _cutoffValue = event.cutoffValue;
    } else if (event is StopAudioRecording) {
      yield* stopAudioRecorder(sendAudio: event.sendAudio);
    } else if (event is AbortAudioRecording) {
      yield* stopAudioRecorder(isAborted: true);
    } else if (event is StartImageOrVideoRecording) {
      bool hasCameraPermission = await hasPermission(PermissionGroup.camera);

      if (hasCameraPermission) {
        startImageOrVideoRecorder(event.pickImage);
      } else {
        yield ChatComposerRecordingFailed(error: ChatComposerStateError.missingCameraPermission);
      }
    } else if (event is StopImageOrVideoRecording) {
      if (!_wasImageOrVideoRecordingCanceled(event.filePath, event.type)) {
        yield ChatComposerRecordingImageOrVideoStopped(filePath: event.filePath, type: event.type);
      }
    } else if (event is ReplayAudio) {
      _replayAudio();
    } else if (event is ReplayAudioStopped) {
      yield ChatComposerReplayStopped();
    } else if (event is ReplayAudioTimeUpdate) {
      yield ChatComposerReplayTimeUpdated(dbPeakList: _dbPeakList, replayTime: event.replayTime);
    } else if (event is ReplayAudioSeek) {
      _seekAudioPlayer(event.seekValue);
    } else if (event is UpdateReplayTime) {
      _isSeeking = true;
      _replayTime = event.replayTime;
      yield ChatComposerReplayTimeUpdated(dbPeakList: _dbPeakList, replayTime: _replayTime);
    } else if (event is StopAudioReplay) {
      _stopAudio();
    }
  }

  Future<void> startAudioRecorder() async {
    _dbPeakList = List<double>();
    final shortPeakList = List<double>();

    _audioPath = await _flutterSound.startRecorder(null, bitRate: 64000, numChannels: 1);

    _flutterSound.setDbLevelEnabled(true);
    _flutterSound.setDbPeakLevelUpdate(1.0);

    _recorderDBPeakSubscription = _flutterSound.onRecorderDbPeakChanged.listen((newDBPeak) {
      var newPeak = (newDBPeak / 5);
      _dbPeakList.add(newPeak);
      shortPeakList.add((newPeak));
      if (_removeFirstEntry) {
        shortPeakList.removeRange(0, _cutoffValue);
      }
      add(UpdateAudioDBPeak(dbPeakList: shortPeakList));
    });

    _recorderSubscription = _flutterSound.onRecorderStateChanged.listen((e) {
      String timer = getTimerFromTimestamp(e.currentPosition.toInt());
      add(UpdateAudioRecording(timer: timer));
    });
  }

  _seekAudioPlayer(int seekValue) async {
    _isSeeking = false;
    _replayTime = seekValue;
    int milliSeconds = (seekValue * 1000);

    add(ReplayAudioTimeUpdate(replayTime: _replayTime));

    await _flutterSound.seekToPlayer(milliSeconds);
  }

  _replayAudio() async {
    _replayTime = 0;

    await _flutterSound.startPlayer(_audioPath);

    _playerSubscription = _flutterSound.onPlayerStateChanged.listen((data) {
      if (data?.duration != data?.currentPosition) {
        int currentTimer = (data.currentPosition / 1000).round();
        if (currentTimer > _replayTime && _replayTime <= _dbPeakList.length && !_isSeeking) {
          _replayTime = currentTimer;
          add(ReplayAudioTimeUpdate(replayTime: _replayTime));
        }
      } else {
        add(ReplayAudioStopped());
      }
    });
  }

  _stopAudio() async {
    await _flutterSound.stopPlayer();

    _isSeeking = false;

    if (_playerSubscription != null) {
      _playerSubscription.cancel();
      _playerSubscription = null;
    }
  }

  Stream<ChatComposerState> stopAudioRecorder({bool isAborted = false, bool sendAudio}) async* {
    try {
      String result = await _flutterSound.stopRecorder();
      print('stopRecorder: $result');

      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
        _recorderSubscription = null;
      }
      if (_recorderDBPeakSubscription != null) {
        _recorderDBPeakSubscription.cancel();
        _recorderDBPeakSubscription = null;
      }
    } catch (err) {
      print('stopRecorder error: $err');
    }

    if (isAborted) {
      if(_flutterSound.isPlaying){
        await _flutterSound.stopPlayer();
      }
      yield ChatComposerRecordingAudioAborted();
    } else {
      yield ChatComposerRecordingAudioStopped(filePath: _audioPath, dbPeakList: _dbPeakList, sendAudio: sendAudio);
    }
  }

  Future<void> startImageOrVideoRecorder(bool pickImage) async {
    File file;
    int type;
    
    if (pickImage) {
      file = await ImagePicker.pickImage(source: ImageSource.camera);
      type = ChatMsg.typeImage;
    } else {
      file = await ImagePicker.pickVideo(source: ImageSource.camera);
      type = ChatMsg.typeVideo;
    }
    if (file != null) {
      add(StopImageOrVideoRecording(filePath: file.path, type: type));
    } else {
      add(StopImageOrVideoRecording(filePath: null, type: 0));
    }
  }

  bool _wasImageOrVideoRecordingCanceled(String filePath, int type) {
    return filePath == null && type == 0;
  }
}
