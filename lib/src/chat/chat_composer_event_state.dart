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

import 'package:file_picker/file_picker.dart';
import 'package:meta/meta.dart';
import 'package:ox_coi/src/chat/chat_composer_mixin.dart';

enum ChatComposerError {
  missingMicrophonePermission,
  missingCameraPermission,
  missingFilesPermission,
  playerNotStarted,
}

abstract class ChatComposerEvent {}

class Typing extends ChatComposerEvent {
  final String text;

  Typing({@required this.text});
}

class CheckPermissions extends ChatComposerEvent {}

class StartAudioRecording extends ChatComposerEvent {}

class StopAudioRecording extends ChatComposerEvent {
  final bool send;
  final bool aborted;

  StopAudioRecording({this.send = false, this.aborted = false});
}

class LockAudioRecording extends ChatComposerEvent {}

class UpdateVoiceRecordingTimer extends ChatComposerEvent {
  final String timer;

  UpdateVoiceRecordingTimer({@required this.timer});
}

class UpdateVoiceRecordingPeak extends ChatComposerEvent {
  final List<double> peakList;

  UpdateVoiceRecordingPeak({@required this.peakList});
}

class RemoveFirstAudioPeak extends ChatComposerEvent {
  final int cutoffValue;

  RemoveFirstAudioPeak({@required this.cutoffValue});
}

class StartImageOrVideoRecording extends ChatComposerEvent {
  final int type;

  StartImageOrVideoRecording({@required this.type});
}

class StopImageOrVideoRecording extends ChatComposerEvent {
  final String filePath;
  final int type;

  StopImageOrVideoRecording({@required this.type, @required this.filePath});
}

class ReplayAudio extends ChatComposerEvent {}

class ReplayAudioTimeUpdate extends ChatComposerEvent {
  final int replayTime;

  ReplayAudioTimeUpdate({@required this.replayTime});
}

class ReplayAudioStopped extends ChatComposerEvent {}

class StopAudioReplay extends ChatComposerEvent {}

class ReplayAudioSeek extends ChatComposerEvent {
  final int seekValue;

  ReplayAudioSeek({@required this.seekValue});
}

class UpdateReplayTime extends ChatComposerEvent {
  final int replayTime;

  UpdateReplayTime({@required this.replayTime});
}

class AttachFile extends ChatComposerEvent {
  final String filePath;
  final FileType fileType;
  final String extension;

  AttachFile({@required this.fileType, this.filePath, this.extension});
}

class DetachFile extends ChatComposerEvent {}

class PrepareMessageForSending extends ChatComposerEvent {}

class ResetComposer extends ChatComposerEvent {}

abstract class ChatComposerState {}

class ChatComposerRecordingAudioStopped extends ChatComposerState {
  String filePath;
  List<double> peakList;
  bool sendAudio;

  ChatComposerRecordingAudioStopped({@required this.filePath, @required this.peakList, @required this.sendAudio});
}

class ChatComposerReplayStopped extends ChatComposerState {}

class ChatComposerPrepared extends ChatComposerState {}

class ChatComposerComposing extends ChatComposerState {
  final ComposerState state;
  final ComposerVoiceState voiceState;
  final String text;
  final String filePath;
  final int fileType;
  final bool voicePermissionGranted;
  final int voiceRecordingTimer;
  final int voiceReplayTimer;
  final List<double> voicePeakList;
  final List<double> voiceVisiblePeakList;
  final ChatComposerError error;

  ChatComposerComposing({
    this.state,
    this.voiceState,
    this.text,
    this.filePath,
    this.fileType,
    this.voicePermissionGranted,
    this.voiceRecordingTimer,
    this.voiceReplayTimer,
    this.voicePeakList,
    this.voiceVisiblePeakList,
    this.error,
  });

  ChatComposerComposing copyWith({
    ComposerState state,
    ComposerVoiceState voiceState,
    String text,
    String filePath,
    int fileType,
    bool voicePermissionGranted,
    String voiceRecordingTimer,
    int voiceReplayTimer,
    List<double> voicePeakList,
    List<double> voiceVisiblePeakList,
    ChatComposerError error,

  }) {
    return ChatComposerComposing(
      state: state ?? this.state,
      voiceState: voiceState ?? this.voiceState,
      text: text ?? this.text,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      voicePermissionGranted: voicePermissionGranted ?? this.voicePermissionGranted,
      voiceRecordingTimer: voiceRecordingTimer ?? this.voiceRecordingTimer,
      voiceReplayTimer: voiceReplayTimer ?? this.voiceReplayTimer,
      voicePeakList: voicePeakList ?? this.voicePeakList,
      voiceVisiblePeakList: voiceVisiblePeakList ?? this.voiceVisiblePeakList,
      error: error ?? null,
    );
  }
}
