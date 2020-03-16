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
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon.dart';
import 'package:ox_coi/src/chat/chat_create_group_participants.dart';
import 'package:ox_coi/src/contact/contact_change.dart';
import 'package:ox_coi/src/contact/contact_item.dart';
import 'package:ox_coi/src/contact/contact_list_bloc.dart';
import 'package:ox_coi/src/contact/contact_list_event_state.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/custom_theme.dart';
import 'package:ox_coi/src/ui/text_styles.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/utils/key_generator.dart';
import 'package:ox_coi/src/widgets/dynamic_appbar.dart';
import 'package:ox_coi/src/widgets/state_info.dart';

class ChatCreate extends StatefulWidget {
  @override
  _ChatCreateState createState() => _ChatCreateState();
}

class _ChatCreateState extends State<ChatCreate> {
  final _contactListBloc = ContactListBloc();
  final _navigation = Navigation();

  var _isSearching = false;

  DynamicSearchBar _searchBar;

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.chatCreate);
    _contactListBloc.add(RequestContacts(typeOrChatId: validContacts));
    _searchBar = DynamicSearchBar(
      content: DynamicSearchBarContent(
        onSearch: (text) => _contactListBloc.add(SearchContacts(query: text)),
        isSearchingCallback: (bool isSearching) => setState(() => _isSearching = isSearching),
      ),
    );
  }

  @override
  void dispose() {
    _contactListBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: DynamicAppBar(
          title: L10n.get(L.chatCreate),
          leading: AppBarBackButton(context: context),
        ),
        body: buildList());
  }

  Widget buildList() {
    return BlocBuilder(
      bloc: _contactListBloc,
      builder: (context, state) {
        if (state is ContactListStateSuccess) {
          int offset = !_isSearching ? 1 : 0;
          return buildListItems(!_isSearching, state, offset);
        } else if (state is! ContactListStateFailure) {
          return StateInfo(showLoading: true);
        } else {
          return AdaptiveIcon(icon: IconSource.error);
        }
      },
    );
  }

  Widget buildListItems(bool showNewContactAndAddGroup, ContactListStateSuccess state, int offset) {
    return CustomScrollView(
      slivers: <Widget>[
        _searchBar,
        SliverList(
          delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
            if (showNewContactAndAddGroup && index == 0) {
              return buildNewContactAndAddGroup();
            } else {
              int adjustedIndex = index - offset;
              final contactId = state.contactIds[adjustedIndex];
              final int previousContactId = (adjustedIndex > 0) ? state.contactIds[adjustedIndex - 1] : null;
              final key = createKeyFromId(contactId, [state.contactLastUpdateValues[adjustedIndex]]);
              return ContactItem(contactId: contactId, previousContactId: previousContactId, contactItemType: ContactItemType.createChat, key: key);
            }
          }, childCount: state.contactIds.length + offset),
        )
      ],
    );
  }

  Column buildNewContactAndAddGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          leading: AdaptiveIcon(
            icon: IconSource.personAdd,
            color: CustomTheme.of(context).accent,
          ),
          title: Text(
            L10n.get(L.contactNew),
            style: Theme.of(context).textTheme.subhead.merge(getAccentW500TextStyle(context)),
          ),
          onTap: newContactTapped,
          key: Key(keyChatCreatePersonAddIcon),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(),
            ),
          ),
          child: ListTile(
            leading: AdaptiveIcon(
              icon: IconSource.groupAdd,
              color: CustomTheme.of(context).accent,
            ),
            title: Text(
              L10n.get(L.groupCreate),
              style: Theme.of(context).textTheme.subhead.merge(getAccentW500TextStyle(context)),
            ),
            onTap: createGroupTapped,
            key: Key(keyChatCreateGroupAddIcon),
          ),
        ),
      ],
    );
  }

  newContactTapped() {
    _navigation.push(
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
    _navigation.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatCreateGroupParticipants(),
      ),
    );
  }
}
