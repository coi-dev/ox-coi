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
          color: CustomTheme.of(context).onSurface.withOpacity(barely),
          iconColor: CustomTheme.of(context).accent,
        );
        onPressed = onShowAttachmentChooser;
        break;
      case ComposerModeType.isComposing:
        icon = AdaptiveSuperellipseIcon(
          icon: IconSource.add,
          color: CustomTheme.of(context).onSurface.withOpacity(barely),
          iconColor: CustomTheme.of(context).accent.withOpacity(disabled),
        );
        onPressed = null;
        break;
      case ComposerModeType.isVoiceRecording:
        icon = AdaptiveSuperellipseIcon(
          icon: IconSource.delete,
          color: CustomTheme.of(context).onSurface.withOpacity(barely),
          iconColor: CustomTheme.of(context).accent,
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
      @required String text}) {
    return Flexible(child: ComposerModeType.isVoiceRecording == type ? getText(text) : getInputTextField(textController, onTextChanged, context));
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
          hintText: L10n.get(L.typeSomething),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: CustomTheme.of(context).onSurface.withOpacity(barely)),
            borderRadius: BorderRadius.all(Radius.circular(composeTextBorderRadius)),
          ),
        ),
        key: Key(L.getKey(L.typeSomething)),
      ),
    );
  }

  Widget getText(String text) {
    return Container(
      child: Text(text),
      width: double.infinity,
    );
  }

  List<Widget> buildRightComposerPart(
      {@required ComposerModeType type,
      @required Function onSendText,
      @required Function onRecordAudioPressed,
      @required Function onRecordVideoPressed,
      @required Function onCaptureImagePressed,
      @required BuildContext context}) {
    List<Widget> widgets = List();
    switch (type) {
      case ComposerModeType.compose:
        widgets.add(AdaptiveIconButton(
          icon: AdaptiveSuperellipseIcon(
            icon: IconSource.mic,
            color: CustomTheme.of(context).onSurface.withOpacity(barely),
            iconColor: CustomTheme.of(context).accent,
          ),
          onPressed: onRecordAudioPressed,
          key: Key(KeyChatComposerMixinOnRecordAudioPressedIcon),
        ));
        widgets.add(AdaptiveIconButton(
          icon: AdaptiveSuperellipseIcon(
            icon: IconSource.camera,
            color: CustomTheme.of(context).onSurface.withOpacity(barely),
            iconColor: CustomTheme.of(context).accent,
          ),
          onPressed: onCaptureImagePressed,
        ));
        widgets.add(AdaptiveIconButton(
          icon: AdaptiveSuperellipseIcon(
            icon: IconSource.videocam,
            color: CustomTheme.of(context).onSurface.withOpacity(barely),
            iconColor: CustomTheme.of(context).accent,
          ),
          onPressed: onRecordVideoPressed,
        ));
        break;
      case ComposerModeType.isComposing:
        widgets.add(AdaptiveIconButton(
          icon: AdaptiveSuperellipseIcon(
            icon: IconSource.send,
            color: CustomTheme.of(context).onSurface.withOpacity(barely),
            iconColor: CustomTheme.of(context).accent,
          ),
          onPressed: onSendText,
          key: Key(KeyChatComposerMixinOnSendTextIcon),
        ));
        break;
      case ComposerModeType.isVoiceRecording:
        widgets.add(AdaptiveIconButton(
          icon: AdaptiveSuperellipseIcon(
            icon: IconSource.send,
            color: CustomTheme.of(context).onSurface.withOpacity(barely),
            iconColor: CustomTheme.of(context).accent,
          ),
          onPressed: onRecordAudioPressed,
          key: Key(KeyChatComposerMixinOnRecordAudioSendIcon),
        ));
        break;
    }
    return widgets;
  }
}
