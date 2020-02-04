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

import 'package:meta/meta.dart';

abstract class ChatComposerEvent {}

class StartAudioRecording extends ChatComposerEvent {}

class CheckPermissions extends ChatComposerEvent {}

class UpdateAudioRecording extends ChatComposerEvent {
  final String timer;

  UpdateAudioRecording({@required this.timer});
}

class UpdateAudioDBPeak extends ChatComposerEvent {
  final List<double> dbPeakList;

  UpdateAudioDBPeak({@required this.dbPeakList});
}

class RemoveFirstAudioDBPeak extends ChatComposerEvent {
  final bool removeFirstEntry;
  final int cutoffValue;

  RemoveFirstAudioDBPeak({@required this.removeFirstEntry, @required this.cutoffValue});
}

class StopAudioRecording extends ChatComposerEvent {
  final bool sendAudio;

  StopAudioRecording({this.sendAudio = false});
}

class AbortAudioRecording extends ChatComposerEvent {}

class StartImageOrVideoRecording extends ChatComposerEvent {
  final bool pickImage;

  StartImageOrVideoRecording({@required this.pickImage});
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

enum ChatComposerStateError {
  missingMicrophonePermission,
  missingCameraPermission,
}

abstract class ChatComposerState {}

class ChatComposerInitial extends ChatComposerState {}

class ChatComposerPermissionsAccepted extends ChatComposerState {}

class ChatComposerRecordingAudio extends ChatComposerState {
  String timer;

  ChatComposerRecordingAudio({@required this.timer});
}

class ChatComposerDBPeakUpdated extends ChatComposerState {
  List<double> dbPeakList;

  ChatComposerDBPeakUpdated({@required this.dbPeakList});
}

class ChatComposerRecordingAudioStopped extends ChatComposerState {
  String filePath;
  List<double> dbPeakList;
  bool sendAudio;

  ChatComposerRecordingAudioStopped({@required this.filePath, @required this.dbPeakList, @required this.sendAudio});
}

class ChatComposerRecordingAudioAborted extends ChatComposerState {}

class ChatComposerRecordingFailed extends ChatComposerState {
  ChatComposerStateError error;

  ChatComposerRecordingFailed({@required this.error});
}

class ChatComposerReplayStopped extends ChatComposerState {}

class ChatComposerReplayTimeUpdated extends ChatComposerState {
  final List<double> dbPeakList;
  final int replayTime;

  ChatComposerReplayTimeUpdated({@required this.dbPeakList, @required this.replayTime});
}

class ChatComposerRecordingImageOrVideoStopped extends ChatComposerState {
  String filePath;
  int type;

  ChatComposerRecordingImageOrVideoStopped({@required this.filePath, @required this.type});
}
