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
import 'package:ox_coi/src/chat/chat_create_group_settings.dart';
import 'package:ox_coi/src/contact/contact_item_chip.dart';
import 'package:ox_coi/src/contact/contact_item_selectable.dart';
import 'package:ox_coi/src/contact/contact_list_bloc.dart';
import 'package:ox_coi/src/contact/contact_list_event_state.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/utils/key_generator.dart';
import 'package:ox_coi/src/widgets/dynamic_appbar.dart';
import 'package:ox_coi/src/widgets/state_info.dart';
import 'package:ox_coi/src/extensions/string_apis.dart';

class ChatCreateGroupParticipants extends StatefulWidget {
  @override
  _ChatCreateGroupParticipantsState createState() => _ChatCreateGroupParticipantsState();
}

class _ChatCreateGroupParticipantsState extends State<ChatCreateGroupParticipants> {
  final _contactListBloc = ContactListBloc();
  final _navigation = Navigation();
  final _scrollController = ScrollController();

  DynamicSearchBar _searchBar;

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.chatCreateGroupParticipants);
    _contactListBloc.add(RequestContacts(typeOrChatId: validContacts));
    _searchBar = DynamicSearchBar(
      scrollable: false,
      content: DynamicSearchBarContent(
        onSearch: (text) => _contactListBloc.add(SearchContacts(query: text)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: L10n.get(L.groupCreate),
        leading: AppBarCloseButton(
          key: Key(keyChatCreateGroupParticipantsCloseIconButton),
          context: context,
        ),
        trailingList: [
          IconButton(
            key: Key(keyChatCreateGroupParticipantsSummitIconButton),
            icon: AdaptiveIcon(
              icon: IconSource.arrowForward,
            ),
            onPressed: () => _onSubmit(),
          )
        ],
      ),
      body: buildList(),
    );
  }

  Widget buildList() {
    return BlocBuilder(
      bloc: _contactListBloc,
      builder: (context, state) {
        if (state is ContactListStateSuccess) {
          return Column(
            children: <Widget>[
              _searchBar,
              _buildSelectedParticipantList(state.contactsSelected),
              Flexible(
                child: buildListItems(state),
              ),
            ],
          );
        } else if (state is! ContactListStateFailure) {
          return StateInfo(showLoading: true);
        } else {
          return AdaptiveIcon(icon: IconSource.error);
        }
      },
    );
  }

  ListView buildListItems(ContactListStateSuccess state) {
    var contactIds = state.contactIds;
    var contactLastUpdateValues = state.contactLastUpdateValues;
    return ListView.custom(
      controller: _scrollController,
      childrenDelegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final contactId = state.contactIds[index];
          final int previousContactId = (index > 0) ? state.contactIds[index - 1] : null;
          final key = createKeyFromId(contactId, [contactLastUpdateValues[index]]);
          final bool isSelected = state.contactsSelected.contains(contactId);

          return ContactItemSelectable(
            contactId: contactId,
            previousContactId: previousContactId,
            onTap: _itemTapped,
            isSelected: isSelected,
            key: key,
          );
        },
        childCount: contactIds.length,
        findChildIndexCallback: (Key key) {
          final ValueKey valueKey = key;
          final id = extractId(valueKey);
          return (contactIds.contains(id) ? contactIds.indexOf(id) : null);
        },
      ),
    );
  }

  Widget _buildSelectedParticipantList(List<int> selectedContacts) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            left: listItemPadding,
            right: listItemPadding,
            top: listItemPadding,
            bottom: listItemPaddingSmall,
          ),
          child: Text("${selectedContacts.length} ${L10n.get(L.participantP, count: L10n.plural)}"),
        ),
        Container(
          padding: EdgeInsets.only(bottom: dimension4dp),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(),
            ),
          ),
          width: double.infinity,
          height: dimension40dp,
          child: selectedContacts.isNotEmpty
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedContacts.length,
                  itemBuilder: (BuildContext context, int index) {
                    var selectedContactId = selectedContacts[index];
                    return ContactItemChip(contactId: selectedContactId, itemTapped: () => _itemTapped(selectedContactId));
                  })
              : Container(
                  padding: EdgeInsets.only(
                    left: listItemPadding,
                    right: listItemPadding,
                    top: listItemPadding,
                  ),
                  child: Text(L10n.get(L.groupAddContactAdd)),
                ),
        ),
      ],
    );
  }

  _itemTapped(int id) {
    _contactListBloc.add(ContactsSelectionChanged(id: id));
  }

  _onSubmit() async {
    if (_contactListBloc.contactsSelectedCount > 0) {
      _navigation.push(
        context,
        MaterialPageRoute(builder: (context) => ChatCreateGroupSettings(selectedContacts: _contactListBloc.contactsSelected)),
      );
    } else {
      L10n.get(L.groupAddNoParticipants).showToast();
    }
  }
}
