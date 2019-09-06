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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';

enum ComposerModeType {
  compose,
  isComposing,
  isVoiceRecording,
}

mixin ChatComposer {
  Widget buildLeftComposerPart(
      {@required ComposerModeType type, @required Function onShowAttachmentChooser, @required Function onAudioRecordingAbort}) {
    IconData icon;
    Function onPressed;
    switch (type) {
      case ComposerModeType.compose:
        icon = Icons.add;
        onPressed = onShowAttachmentChooser;
        break;
      case ComposerModeType.isComposing:
        icon = Icons.add;
        onPressed = null;
        break;
      case ComposerModeType.isVoiceRecording:
        icon = Icons.delete;
        onPressed = onAudioRecordingAbort;
        break;
    }
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }

  Widget buildCenterComposerPart(
      {@required BuildContext context,
      @required ComposerModeType type,
      @required TextEditingController textController,
      @required Function onTextChanged,
      @required String text}) {
    return Flexible(
        child: Container(
      padding: EdgeInsets.all(composerTextFieldPadding),
      decoration: BoxDecoration(
        border: Border.all(color: onBackground.withOpacity(barely)),
        borderRadius: BorderRadius.all(Radius.circular(composeTextBorderRadius)),
      ),
      child: ComposerModeType.isVoiceRecording == type ? getText(text) : getInputTextField(textController, onTextChanged, context),
    ));
  }

  TextField getInputTextField(TextEditingController textController, Function onTextChanged, BuildContext context) {
    return TextField(
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: 4,
      controller: textController,
      onChanged: onTextChanged,
      decoration: new InputDecoration.collapsed(
        hintText: L10n.get(L.typeSomething),
      ),key: Key(L.getKey(L.typeSomething)),
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
      @required Function onCaptureImagePressed}) {
    List<Widget> widgets = List();
    switch (type) {
      case ComposerModeType.compose:
        widgets.add(new IconButton(
          icon: new Icon(Icons.mic),
          onPressed: onRecordAudioPressed,
          key: Key(KeyChatComposerMixinOnRecordAudioPressedIcon),
        ));
        widgets.add(new IconButton(
          icon: new Icon(Icons.camera_alt),
          onPressed: onCaptureImagePressed,
        ));
        widgets.add(new IconButton(
          icon: new Icon(Icons.videocam),
          onPressed: onRecordVideoPressed,
        ));
        break;
      case ComposerModeType.isComposing:
        widgets.add(new IconButton(
          icon: new Icon(Icons.send),
          onPressed: onSendText,key: Key(KeyChatComposerMixinOnSendTextIcon),
        ));
        break;
      case ComposerModeType.isVoiceRecording:
        widgets.add(new IconButton(
          icon: new Icon(Icons.send),
          onPressed: onRecordAudioPressed,key: Key(KeyChatComposerMixinOnRecordAudioSendIcon),
        ));
        break;
    }
    return widgets;
  }
}
