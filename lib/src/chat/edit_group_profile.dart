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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/widgets/dynamic_appbar.dart';
import 'package:ox_coi/src/widgets/profile_header.dart';

import 'chat_change_bloc.dart';
import 'chat_change_event_state.dart';

class EditGroupProfile extends StatefulWidget {
  static get viewTitle => L10n.get(L.groupRename);
  final int chatId;

  EditGroupProfile({@required this.chatId});

  @override
  _EditGroupProfileState createState() => _EditGroupProfileState();
}

class _EditGroupProfileState extends State<EditGroupProfile> {
  ChatChangeBloc _chatChangeBloc = ChatChangeBloc();
  Navigation _navigation = Navigation();
  TextEditingController _chatNameController = TextEditingController();
  String _avatarPath;

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.editGroupProfile);
    _chatChangeBloc.add(RequestChatData(chatId: widget.chatId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: DynamicAppBar(
          title: EditGroupProfile.viewTitle,
          leading: AppBarCloseButton(context: context),
          trailingList: [
            IconButton(
              key: Key(keyEditGroupProfileAdaptiveIconIconSource),
              icon: AdaptiveIcon(icon: IconSource.check),
              onPressed: _saveChanges,
            )
          ],
        ),
        body: BlocConsumer(
          bloc: _chatChangeBloc,
          listener: (context, state) {
            if (state is ChatDataLoaded) {
              _chatNameController.text = state.chatName;
              _avatarPath = state.avatarPath;
            } else if (state is ChatChangeStateSuccess) {
              _navigation.pop(context);
            }
          },
          builder: (context, state) {
            if (state is ChatDataLoaded) {
              return EditableProfileHeader(
                nameController: _chatNameController,
                avatar: _avatarPath,
                imageChangedCallback: _setAvatar,
                placeholder: L10n.get(L.name),
                key: Key(keyEditNameEditableProfileHeader),
              );
            } else {
              return Container();
            }
          },
        ));
  }

  _setAvatar(String avatarPath) {
    setState(() {
      _avatarPath = avatarPath;
    });
  }

  void _saveChanges() {
    _chatChangeBloc.add(ChangeChatData(chatId: widget.chatId, chatName: _chatNameController.text, avatarPath: _avatarPath));
  }
}
