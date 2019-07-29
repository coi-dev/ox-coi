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
import 'package:ox_coi/src/l10n/localizations.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/utils/dialog_builder.dart';

class ProfileActionList extends StatelessWidget {
  final List<Widget> tiles;

  const ProfileActionList({Key key, @required this.tiles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: ListTile.divideTiles(context: context, tiles: tiles).toList(),
    );
  }
}

class ProfileAction extends StatelessWidget {
  final IconData iconData;
  final String text;
  final Function onTap;
  final Color color;

  const ProfileAction({@required this.iconData, @required this.text, @required this.onTap, this.color, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        iconData,
        color: color,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: color
        ),
      ),
      onTap: onTap,
    );
  }
}

enum ProfileActionType { deleteChat, block, leave, deleteContact }

enum ProfileActionParams { email, name }

showActionDialog(BuildContext context, ProfileActionType action, Function onPerform, [Map<ProfileActionParams, String> params]) {
  String title;
  String content;
  String positiveButton;
  Type type;

  var appLocalizations = AppLocalizations.of(context);
  switch (action) {
    case ProfileActionType.block:
      title = appLocalizations.block;
      content = appLocalizations.chatProfileBlockContactInfoText;
      positiveButton = appLocalizations.chatProfileBlockContactButtonText;
      type = Type.contactBlockDialog;
      break;
    case ProfileActionType.deleteChat:
      title = appLocalizations.delete;
      content = appLocalizations.chatProfileDeleteChatInfoText;
      positiveButton = appLocalizations.chatProfileDeleteChatButtonText;
      type = Type.chatDeleteDialog;
      break;
    case ProfileActionType.leave:
      title = appLocalizations.chatProfileLeaveGroupButtonText;
      content = appLocalizations.chatProfileLeaveGroupInfoText;
      positiveButton = appLocalizations.chatProfileLeaveGroupButtonText;
      type = Type.chatLeaveGroupDialog;
      break;
    case ProfileActionType.deleteContact:
      title = appLocalizations.contactChangeDeleteTitle;
      content = appLocalizations.contactChangeDeleteDialogContent(params[ProfileActionParams.email], params[ProfileActionParams.name]);
      positiveButton = appLocalizations.delete;
      type = Type.contactDeleteDialog;
      break;
  }

  return showConfirmationDialog(
    context: context,
    title: title,
    content: content,
    positiveButton: positiveButton,
    positiveAction: onPerform,
    selfClose: false,
    navigatable: Navigatable(type),
  );
}
