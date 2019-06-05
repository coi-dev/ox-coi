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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/chat/chat_create_group_participants.dart';
import 'package:ox_coi/src/contact/contact_change.dart';
import 'package:ox_coi/src/contact/contact_item.dart';
import 'package:ox_coi/src/contact/contact_list_bloc.dart';
import 'package:ox_coi/src/contact/contact_list_event_state.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/l10n/localizations.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/utils/colors.dart';
import 'package:ox_coi/src/utils/dimensions.dart';
import 'package:ox_coi/src/utils/styles.dart';
import 'package:ox_coi/src/widgets/search.dart';
import 'package:ox_coi/src/widgets/state_info.dart';

class ChatCreate extends StatefulWidget {
  @override
  _ChatCreateState createState() => _ChatCreateState();
}

class _ChatCreateState extends State<ChatCreate> {
  ContactListBloc _contactListBloc = ContactListBloc();
  Navigation navigation = Navigation();

  @override
  void initState() {
    super.initState();
    navigation.current = Navigatable(Type.chatCreate);
    _contactListBloc.dispatch(RequestContacts(listTypeOrChatId: ContactRepository.validContacts));
  }

  @override
  void dispose() {
    _contactListBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).createChatTitle),
          actions: <Widget>[getSearchAction()],
        ),
        body: buildList(true));
  }

  Widget getSearchAction() {
    Search search = Search(
      onBuildResults: onBuildResultOrSuggestion,
      onBuildSuggestion: onBuildResultOrSuggestion,
      onClose: onSearchClose,
    );
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: () => search.show(context),
    );
  }

  Widget onBuildResultOrSuggestion(String query) {
    _contactListBloc.dispatch(FilterContacts(query: query));
    return buildList(false);
  }

  void onSearchClose() {
    _contactListBloc.dispatch(RequestContacts(listTypeOrChatId: ContactRepository.validContacts));
  }

  Widget buildList(bool showNewContactAndAddGroup) {
    return BlocBuilder(
      bloc: _contactListBloc,
      builder: (context, state) {
        if (state is ContactListStateSuccess) {
          int offset = showNewContactAndAddGroup ? 1 : 0;
          return buildListItems(showNewContactAndAddGroup, state, offset);
        } else if (state is! ContactListStateFailure) {
          return StateInfo(showLoading: true);
        } else {
          return Icon(Icons.error);
        }
      },
    );
  }

  ListView buildListItems(bool showNewContactAndAddGroup, ContactListStateSuccess state, int offset) {
    return ListView.builder(
        padding: showNewContactAndAddGroup ? null : EdgeInsets.only(top: listItemPadding),
        itemCount: state.contactIds.length + offset,
        itemBuilder: (BuildContext context, int index) {
          if (showNewContactAndAddGroup && index == 0) {
            return buildNewContactAndAddGroup();
          } else {
            int adjustedIndex = index - offset;
            var contactId = state.contactIds[adjustedIndex];
            var key = "$contactId-${state.contactLastUpdateValues[adjustedIndex]}";
            return ContactItem(contactId, key, ContactItemType.createChat);
          }
        });
  }

  Column buildNewContactAndAddGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          leading: Icon(
            Icons.person_add,
            color: accent,
          ),
          title: Text(
            AppLocalizations.of(context).createChatNewContactButtonText,
            style: createChatTitle,
          ),
          onTap: newContactTapped,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(),
            ),
          ),
          child: ListTile(
            leading: Icon(
              Icons.group_add,
              color: accent,
            ),
            title: Text(
              AppLocalizations.of(context).createGroupButtonText,
              style: createChatTitle,
            ),
            onTap: createGroupTapped,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: listItemPadding),
        )
      ],
    );
  }

  newContactTapped() {
    navigation.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactChange(
              contactAction: ContactAction.add,
              createChat: true,
            ),
      ),
    );
  }

  createGroupTapped() {
    navigation.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatCreateGroupParticipants(),
      ),
    );
  }
}
