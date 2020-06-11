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
import 'package:ox_coi/src/contact/contact_item_chip.dart';
import 'package:ox_coi/src/contact/contact_list_bloc.dart';
import 'package:ox_coi/src/contact/contact_list_content.dart';
import 'package:ox_coi/src/contact/contact_list_event_state.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/extensions/string_ui.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/widgets/dynamic_appbar.dart';
import 'package:ox_coi/src/widgets/state_info.dart';

import 'chat_change_bloc.dart';
import 'chat_change_event_state.dart';

class ChatAddGroupParticipants extends StatefulWidget {
  static get viewTitle => L10n.get(L.participantAdd);
  final int chatId;
  final List<dynamic> contactIds;

  ChatAddGroupParticipants({@required this.chatId, @required this.contactIds});

  @override
  _ChatAddGroupParticipantsState createState() => _ChatAddGroupParticipantsState();
}

class _ChatAddGroupParticipantsState extends State<ChatAddGroupParticipants> {
  final _contactListBloc = ContactListBloc();
  final _chatChangeBloc = ChatChangeBloc();
  final navigation = Navigation();

  DynamicSearchBar _searchBar;
  var _isSearching = false;

  @override
  void initState() {
    super.initState();
    navigation.current = Navigatable(Type.chatAddGroupParticipants);
    _contactListBloc.add(RequestContacts(typeOrChatId: validContacts, chatId: widget.chatId));
    _searchBar = DynamicSearchBar(
      scrollable: false,
      content: DynamicSearchBarContent(
        onSearch: (text) => _contactListBloc.add(SearchContacts(query: text, chatId: widget.chatId)),
        isSearchingCallback: (bool isSearching) => setState(() => _isSearching = isSearching),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        showDivider: false,
        title: ChatAddGroupParticipants.viewTitle,
        leading: AppBarCloseButton(context: context),
        trailingList: [
          IconButton(
            key: Key(keyChatAddGroupParticipantsCheckIcon),
            icon: AdaptiveIcon(
              icon: IconSource.check,
            ),
            onPressed: () => _onSubmit(),
          )
        ],
      ),
      body: BlocBuilder(
        bloc: _contactListBloc,
        builder: (context, state) {
          if (state is ContactListStateSuccess) {
            if (_isSearching || (state.contactElements.length != widget.contactIds.length)) {
              final selectedContacts = state.contactsSelected;

              return Column(
                children: <Widget>[
                  _searchBar,
                  Column(
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
                        padding: EdgeInsets.only(bottom: 4.0),
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
                  ),
                  Flexible(
                    child: _buildListItems(state),
                  ),
                ],
              );
            } else {
              return Center(
                child: Text(L10n.get(L.groupAddContactsAlreadyIn)),
              );
            }
          } else if (state is! ContactListStateFailure) {
            return StateInfo(showLoading: true);
          } else {
            return AdaptiveIcon(icon: IconSource.error);
          }
        },
      ),
    );
  }

  ListView _buildListItems(ContactListStateSuccess state) {
    return ListView.builder(
      padding: EdgeInsets.only(top: listItemPadding),
      itemCount: state.contactElements.length,
      itemBuilder: (BuildContext context, int index) {
        final contactIds = state.contactElements;
        if (!widget.contactIds.contains(contactIds[index])) {
          final contentElement = contactIds[index];

          return ContactListContent(
            contactElement: contentElement,
            hasHeader: true,
            isSelectable: true,
            selectedContacts: state.contactsSelected,
            callback: _itemTapped,
          );
        } else {
          return Container();
        }
      },
    );
  }

  _itemTapped(int id) {
    _contactListBloc.add(ContactsSelectionChanged(id: id, chatId: widget.chatId));
  }

  _onSubmit() async {
    if (_contactListBloc.contactsSelectedCount > 0) {
      _chatChangeBloc.add(ChatAddParticipants(chatId: widget.chatId, contactIds: _contactListBloc.contactsSelected));
      navigation.pop(context);
    } else {
      L10n.get(L.groupAddNoParticipants).showToast();
    }
  }
}
