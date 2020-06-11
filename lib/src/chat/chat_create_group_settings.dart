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

import 'package:delta_chat_core/delta_chat_core.dart' as Core;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/chat/chat_create_mixin.dart';
import 'package:ox_coi/src/contact/contact_list_bloc.dart';
import 'package:ox_coi/src/contact/contact_list_content.dart';
import 'package:ox_coi/src/contact/contact_list_event_state.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/extensions/color_apis.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/utils/key_generator.dart';
import 'package:ox_coi/src/widgets/dynamic_appbar.dart';
import 'package:ox_coi/src/widgets/profile_header.dart';
import 'package:ox_coi/src/widgets/state_info.dart';
import 'package:ox_coi/src/widgets/validatable_text_form_field.dart';

class ChatCreateGroupSettings extends StatefulWidget {
  static get viewTitle => L10n.get(L.groupCreate);

  final List<int> selectedContacts;

  ChatCreateGroupSettings({@required this.selectedContacts});

  @override
  _ChatCreateGroupSettingsState createState() => _ChatCreateGroupSettingsState();
}

class _ChatCreateGroupSettingsState extends State<ChatCreateGroupSettings> with ChatCreateMixin {
  ContactListBloc _contactListBloc = ContactListBloc();
  ValidatableTextFormField _groupNameField = ValidatableTextFormField(
    (context) => L10n.get(L.groupName),
    key: Key(keyChatCreateGroupSettingsGroupNameField),
    hintText: (context) => L10n.get(L.groupNameLabel),
    needValidation: true,
    validationHint: (context) => L10n.get(L.textFieldEmptyHint),
  );
  GlobalKey<FormState> _formKey = GlobalKey();
  Repository<Core.Chat> chatRepository;
  Navigation navigation = Navigation();
  String _avatar;

  @override
  void initState() {
    super.initState();
    navigation.current = Navigatable(Type.chatCreateGroupSettings);
    _contactListBloc.add(RequestContacts(typeOrChatId: validContacts));
    chatRepository = RepositoryManager.get(RepositoryType.chat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: ChatCreateGroupSettings.viewTitle,
        leading: AppBarBackButton(context: context),
        trailingList: [
          IconButton(
            key: Key(keyChatCreateGroupSettingCheckIconButton),
            icon: AdaptiveIcon(
              icon: IconSource.check,
            ),
            onPressed: () => _onSubmit(),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: BlocBuilder(
          bloc: _contactListBloc,
          builder: (context, state) {
            if (state is ContactListStateSuccess) {
              final contactElements = state.contactElements;
              contactElements.removeWhere((contactElement) {
                final key = getKeyFromContactElement(contactElement);
                final idOrHeader = extractId(key);
                return !widget.selectedContacts.contains(idOrHeader);
              });
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Align(
                      alignment: Alignment.center,
                      child: ProfileData(
                        imageBackgroundColor: CustomTheme.of(context).onBackground.barely(),
                        imageActionCallback: _setAvatar,
                        avatarPath: _avatar,
                        child: ProfileHeader(),
                      )),
                  Padding(
                    padding: EdgeInsets.only(
                      left: formHorizontalPadding,
                      right: formHorizontalPadding,
                      top: formVerticalPadding,
                    ),
                    child: Text(
                      L10n.get(L.groupName),
                      style: Theme.of(context).textTheme.body2.apply(color: CustomTheme.of(context).primary),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: formHorizontalPadding, right: formHorizontalPadding),
                    child: Form(
                      key: _formKey,
                      child: _groupNameField,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: formHorizontalPadding,
                      right: formHorizontalPadding,
                      top: formVerticalPadding,
                    ),
                    child: Text(
                      L10n.get(L.participantP, count: L10n.plural),
                      style: Theme.of(context).textTheme.body2.apply(color: CustomTheme.of(context).primary),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: listItemPadding),
                    child: Divider(height: 1),
                  ),
                  Column(
                    children: <Widget>[
                      for (var index = 0; index < contactElements.length; index++)
                        ContactListContent(
                          contactElement: contactElements[index],
                          hasHeader: false,
                        )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: listItemPaddingSmall),
                    child: Divider(height: 1),
                  ),
                ],
              );
            } else if (state is! ContactListStateFailure) {
              return StateInfo(showLoading: true);
            } else {
              return AdaptiveIcon(icon: IconSource.error);
            }
          },
        ),
      ),
    );
  }

  _setAvatar(String avatarPath) {
    setState(() {
      _avatar = avatarPath;
    });
  }

  _onSubmit() {
    if (_formKey.currentState.validate()) {
      createChatFromGroup(context, false, _groupNameField.controller.text, widget.selectedContacts, _avatar);
    }
  }
}
