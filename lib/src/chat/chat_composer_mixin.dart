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
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon_button.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_superellipse_icon.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/ui/custom_theme.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/widgets/audio_visualizer.dart';

enum ComposerModeType {
  compose,
  isComposing,
  isVoiceRecording,
}

mixin ChatComposer {
  Widget buildLeftComposerPart({
    @required ComposerModeType type,
    @required Function onShowAttachmentChooser,
    @required Function onAudioRecordingAbort,
    @required BuildContext context,
  }) {
    AdaptiveSuperellipseIcon icon;
    Function onPressed;
    switch (type) {
      case ComposerModeType.compose:
        icon = AdaptiveSuperellipseIcon(
          icon: IconSource.add,
          color: CustomTheme.of(context).onSurface.barely(),
          iconColor: CustomTheme.of(context).accent,
        );
        onPressed = onShowAttachmentChooser;
        break;
      case ComposerModeType.isComposing:
        icon = AdaptiveSuperellipseIcon(
          icon: IconSource.add,
          color: CustomTheme.of(context).onSurface.barely(),
          iconColor: CustomTheme.of(context).accent.disabled(),
        );
        onPressed = null;
        break;
      case ComposerModeType.isVoiceRecording:
        icon = AdaptiveSuperellipseIcon(
          icon: IconSource.delete,
          color: CustomTheme.of(context).onSurface.barely(),
          iconColor: CustomTheme.of(context).error,
        );
        onPressed = onAudioRecordingAbort;
        break;
    }
    return AdaptiveIconButton(
      icon: icon,
      onPressed: onPressed,
    );
  }

  Widget buildCenterComposerPart(
      {@required BuildContext context,
      @required ComposerModeType type,
      @required TextEditingController textController,
      @required Function onTextChanged,
      @required bool isStopped,
      @required bool isPlaying,
      int replayTime = 0,
      List<double> dbPeakList}) {
    Widget child;
    if (ComposerModeType.isVoiceRecording == type) {
      if (!isPlaying && !isStopped) {
        child = LayoutBuilder(builder: (context, constraints) {
          return VoicePainter(
            dbPeakList: dbPeakList,
            color: CustomTheme.of(context).onSurface,
            withChild: true,
            width: constraints.maxWidth,
          );
        });
      } else {
        child = AudioPlayback(dbPeakList: dbPeakList, replayTime: replayTime);
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
            borderRadius: BorderRadius.all(Radius.circular(composeTextBorderRadius)),
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
    @required ComposerModeType type,
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
    if (type != ComposerModeType.isComposing) {
      widgets.add(Visibility(
        visible: type == ComposerModeType.compose,
        child: Row(
          children: <Widget>[
            AdaptiveIconButton(
              icon: AdaptiveSuperellipseIcon(
                icon: IconSource.camera,
                color: CustomTheme.of(context).onSurface.barely(),
                iconColor: CustomTheme.of(context).accent,
              ),
              onPressed: onCaptureImagePressed,
            ),
            AdaptiveIconButton(
              icon: AdaptiveSuperellipseIcon(
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
        visible: type != ComposerModeType.compose,
        child: SizedBox(
          width: 70.0,
          child: Row(
            children: <Widget>[
              Visibility(
                visible: !isStopped,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Icon(
                    Icons.fiber_manual_record,
                    size: 12,
                    color: Colors.red,
                  ),
                ),
              ),
              Visibility(
                visible: isStopped,
                child: Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 4.0),
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
            color: isLocked || isStopped || type == ComposerModeType.compose
                ? Colors.transparent
                : CustomTheme.of(context).onSurface.barely(),
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
          ),
          child: Row(
            children: <Widget>[
              Visibility(
                visible: type == ComposerModeType.isVoiceRecording && !isStopped,
                child: AdaptiveIconButton(
                  icon: AdaptiveSuperellipseIcon(
                    icon: isLocked ? IconSource.lock : IconSource.openLock,
                    color: Colors.transparent,
                    iconColor: CustomTheme.of(context).accent,
                    iconSize: 16.0,
                  ),
                  onPressed: onRecordAudioLocked,
                ),
              ),
              Visibility(
                visible: type == ComposerModeType.compose,
                child: AdaptiveIconButton(
                  icon: AdaptiveSuperellipseIcon(
                    icon: IconSource.mic,
                    color: CustomTheme.of(context).onSurface.barely(),
                    iconColor: CustomTheme.of(context).accent,
                  ),
                ),
              ),
              Visibility(
                visible: type == ComposerModeType.isVoiceRecording && !isStopped,
                child: AdaptiveIconButton(
                  icon: AdaptiveSuperellipseIcon(
                    icon: IconSource.stopPlay,
                    color: CustomTheme.of(context).accent,
                    iconColor: CustomTheme.of(context).white,
                  ),
                  onPressed: onRecordAudioStopped,
                ),
              ),
              Visibility(
                visible: type == ComposerModeType.isVoiceRecording && isStopped,
                child: Container(
                    padding: EdgeInsets.only(left: 50.0),
                    child: Row(
                      children: <Widget>[
                        Visibility(
                          visible: !isPlaying,
                          child: AdaptiveIconButton(
                            icon: AdaptiveSuperellipseIcon(
                              icon: IconSource.play,
                              color: CustomTheme.of(context).accent,
                              iconColor: CustomTheme.of(context).white,
                            ),
                            onPressed: onAudioPlaying,
                          ),
                        ),
                        Visibility(
                          visible: isPlaying,
                          child: AdaptiveIconButton(
                            icon: AdaptiveSuperellipseIcon(
                              icon: IconSource.stopPlay,
                              color: CustomTheme.of(context).accent,
                              iconColor: CustomTheme.of(context).white,
                            ),
                            onPressed: onAudioPlayingStopped,
                          ),
                        )
                      ],
                    )),
              )
            ],
          ),
        ),
      ));
    } else {
      widgets.add(AdaptiveIconButton(
        icon: AdaptiveSuperellipseIcon(
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
