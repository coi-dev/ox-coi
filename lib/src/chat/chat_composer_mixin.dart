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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/extensions/color_apis.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/widgets/audio_visualizer.dart';
import 'package:ox_coi/src/widgets/superellipse_icon.dart';

enum ComposerState {
  readyToCompose,
  isComposing,
  isVoiceRecording,
  prepareSending,
}

enum ComposerVoiceState {
  recording,
  locked,
  stopped,
  playing,
  seeking,
}

mixin ChatComposerComponents {
  Widget buildLeftComposerPart({
    @required ComposerState type,
    @required Function onShowAttachmentChooser,
    @required Function onAudioRecordingAbort,
    @required BuildContext context,
  }) {
    SuperellipseIcon icon;
    Function onPressed;
    switch (type) {
      case ComposerState.readyToCompose:
        icon = SuperellipseIcon(
          icon: IconSource.add,
          color: CustomTheme.of(context).onSurface.barely(),
          iconColor: CustomTheme.of(context).accent,
        );
        onPressed = onShowAttachmentChooser;
        break;
      case ComposerState.prepareSending:
      case ComposerState.isComposing:
        icon = SuperellipseIcon(
          icon: IconSource.add,
          color: CustomTheme.of(context).onSurface.barely(),
          iconColor: CustomTheme.of(context).accent.disabled(),
        );
        onPressed = null;
        break;
      case ComposerState.isVoiceRecording:
        icon = SuperellipseIcon(
          icon: IconSource.delete,
          color: CustomTheme.of(context).onSurface.barely(),
          iconColor: CustomTheme.of(context).error,
        );
        onPressed = onAudioRecordingAbort;
        break;
    }
    return IconButton(
      icon: icon,
      onPressed: onPressed,
    );
  }

  Widget buildCenterComposerPart(
      {@required BuildContext context,
      @required ComposerState type,
      @required TextEditingController textController,
      @required Function onTextChanged,
      @required bool isStopped,
      @required bool isPlaying,
      int replayTime = 0,
      List<double> peakList}) {
    Widget child;
    if (ComposerState.isVoiceRecording == type) {
      if (!isPlaying && !isStopped) {
        child = LayoutBuilder(builder: (context, constraints) {
          return VoicePainter(
            dbPeakList: peakList,
            color: CustomTheme.of(context).onSurface,
            withChild: true,
            width: constraints.maxWidth,
          );
        });
      } else {
        child = AudioPlayback(dbPeakList: peakList, replayTime: replayTime);
      }
    } else {
      child = getInputTextField(textController, onTextChanged, context);
    }

    return Flexible(child: child);
  }

  Widget getInputTextField(TextEditingController textController, Function onTextChanged, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        minLines: 1,
        maxLines: 4,
        controller: textController,
        onChanged: onTextChanged,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.all(12.0),
          hintText: L10n.get(L.type),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: CustomTheme.of(context).onSurface.barely()),
            borderRadius: BorderRadius.all(Radius.circular(dimension24dp)),
          ),
        ),
        key: Key(L.getKey(L.type)),
      ),
    );
  }

  Widget getText(String text) {
    return Container(
      child: Text(text ?? ""),
    );
  }

  List<Widget> buildRightComposerPart({
    @required ComposerState type,
    @required Function onSendText,
    @required Function onRecordAudioPressed,
    @required Function onRecordAudioStopped,
    @required Function onRecordAudioStoppedLongPress,
    @required Function onRecordAudioLocked,
    @required Function onAudioPlaying,
    @required Function onAudioPlayingStopped,
    @required Function onRecordVideoPressed,
    @required Function onCaptureImagePressed,
    @required Function onMicTapDown,
    @required BuildContext context,
    @required String text,
    @required bool isLocked,
    @required bool isStopped,
    @required bool isPlaying,
  }) {
    List<Widget> widgets = List();
    if (type != ComposerState.isComposing) {
      widgets.add(Visibility(
        visible: type == ComposerState.readyToCompose,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: SuperellipseIcon(
                icon: IconSource.camera,
                color: CustomTheme.of(context).onSurface.barely(),
                iconColor: CustomTheme.of(context).accent,
              ),
              onPressed: onCaptureImagePressed,
            ),
            IconButton(
              icon: SuperellipseIcon(
                icon: IconSource.video,
                color: CustomTheme.of(context).onSurface.barely(),
                iconColor: CustomTheme.of(context).accent,
              ),
              onPressed: onRecordVideoPressed,
            )
          ],
        ),
      ));
      widgets.add(Visibility(
        visible: type != ComposerState.readyToCompose,
        child: SizedBox(
          width: voiceRecordingRecordTextContainerWidth,
          child: Row(
            children: <Widget>[
              Visibility(
                visible: !isStopped,
                child: Padding(
                  padding: const EdgeInsets.only(left: dimension4dp),
                  child: Icon(
                    Icons.fiber_manual_record,
                    size: dimension12dp,
                    color: Colors.red,
                  ),
                ),
              ),
              Visibility(
                visible: isStopped,
                child: Padding(
                  padding: const EdgeInsets.only(left: voiceRecordingStopIconPadding),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: dimension8dp, right: dimension4dp),
                child: getText(text),
              )
            ],
          ),
        ),
      ));
      widgets.add(GestureDetector(
        onLongPressStart: onRecordAudioPressed,
        onLongPressEnd: onRecordAudioStoppedLongPress,
        onTapDown: onMicTapDown,
        child: Container(
          decoration: BoxDecoration(
            color: isLocked || isStopped || type == ComposerState.readyToCompose ? Colors.transparent : CustomTheme.of(context).onSurface.barely(),
            borderRadius: BorderRadius.all(Radius.circular(voiceRecordingStopLockBackgroundRadius)),
          ),
          child: Row(
            children: <Widget>[
              Visibility(
                visible: type == ComposerState.isVoiceRecording && !isStopped,
                child: IconButton(
                  icon: SuperellipseIcon(
                    icon: isLocked ? IconSource.lock : IconSource.openLock,
                    color: Colors.transparent,
                    iconColor: CustomTheme.of(context).accent,
                    iconSize: dimension16dp,
                  ),
                  onPressed: onRecordAudioLocked,
                ),
                key: Key(KeyChatComposerMixinVoiceComposeAdaptiveSuperellipse),
              ),
              Visibility(
                visible: type == ComposerState.readyToCompose,
                child: IconButton(
                  icon: SuperellipseIcon(
                    icon: IconSource.mic,
                    color: CustomTheme.of(context).onSurface.barely(),
                    iconColor: CustomTheme.of(context).accent,
                  ),
                  onPressed: () {},
                ),
              ),
              Visibility(
                visible: type == ComposerState.isVoiceRecording && !isStopped,
                child: IconButton(
                  icon: SuperellipseIcon(
                    icon: IconSource.stopPlay,
                    color: CustomTheme.of(context).accent,
                    iconColor: CustomTheme.of(context).white,
                  ),
                  onPressed: onRecordAudioStopped,
                ),
              ),
              Visibility(
                visible: type == ComposerState.isVoiceRecording && isStopped,
                child: Container(
                    padding: EdgeInsets.only(left: voiceRecordingStopPlayLeftPadding),
                    child: Row(
                      children: <Widget>[
                        Visibility(
                          visible: !isPlaying,
                          child: IconButton(
                            icon: SuperellipseIcon(
                              icon: IconSource.play,
                              color: CustomTheme.of(context).accent,
                              iconColor: CustomTheme.of(context).white,
                            ),
                            onPressed: onAudioPlaying,
                          ),key: Key(KeyChatComposerPlayComposeAdaptiveSuperellipse)
                        ),
                        Visibility(
                          visible: isPlaying,
                          child: IconButton(
                            icon: SuperellipseIcon(
                              icon: IconSource.stopPlay,
                              color: CustomTheme.of(context).accent,
                              iconColor: CustomTheme.of(context).white,
                            ),
                            onPressed: onAudioPlayingStopped,
                          ),key: Key(KeyChatComposerStopPlayComposeAdaptiveSuperellipse)
                        )
                      ],
                    )),
              )
            ],
          ),
        ),
      ));
    } else {
      widgets.add(IconButton(
        icon: SuperellipseIcon(
          icon: IconSource.send,
          color: CustomTheme.of(context).accent,
          iconColor: CustomTheme.of(context).white,
        ),
        onPressed: onSendText,
        key: Key(KeyChatComposerMixinOnSendTextIcon),
      ));
    }
    return widgets;
  }
}
