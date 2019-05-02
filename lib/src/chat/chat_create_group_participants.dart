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

import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_talk/src/chat/chat_create_group_settings.dart';
import 'package:ox_talk/src/contact/contact_item_chip.dart';
import 'package:ox_talk/src/contact/contact_list_bloc.dart';
import 'package:ox_talk/src/contact/contact_list_event.dart';
import 'package:ox_talk/src/contact/contact_list_state.dart';
import 'package:ox_talk/src/contact/contact_search_controller_mixin.dart';
import 'package:ox_talk/src/contact/contact_item_selectable.dart';
import 'package:ox_talk/src/data/contact_repository.dart';
import 'package:ox_talk/src/data/repository.dart';
import 'package:ox_talk/src/data/repository_manager.dart';
import 'package:ox_talk/src/l10n/localizations.dart';
import 'package:ox_talk/src/navigation/navigation.dart';
import 'package:ox_talk/src/utils/dimensions.dart';
import 'package:ox_talk/src/utils/toast.dart';
import 'package:ox_talk/src/widgets/search_field.dart';

class ChatCreateGroupParticipants extends StatefulWidget {
  @override
  _ChatCreateGroupParticipantsState createState() => _ChatCreateGroupParticipantsState();
}

class _ChatCreateGroupParticipantsState extends State<ChatCreateGroupParticipants> with ContactSearchController {
  ContactListBloc _contactListBloc = ContactListBloc();
  List<int> _selectedContacts = List();
  Repository<Chat> chatRepository;
  Navigation navigation = Navigation();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _contactListBloc.dispatch(RequestContacts(listTypeOrChatId: ContactRepository.validContacts));
    chatRepository = RepositoryManager.get(RepositoryType.chat);
    addSearchListener(_contactListBloc, _searchController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.close),
          onPressed: () => navigation.pop(context, "CreateGroupChatParticipants"),
        ),
        title: Text(AppLocalizations.of(context).createGroupTitle),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () => _onSubmit(),
          )
        ],
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return BlocBuilder(
      bloc: _contactListBloc,
      builder: (context, state) {
        if (state is ContactListStateSuccess) {
          return buildForm(state.contactIds, state.contactLastUpdateValues);
        } else if (state is! ContactListStateFailure) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Icon(Icons.error);
        }
      },
    );
  }

  Widget buildForm(List<int> contactIds, List<int> contactLastUpdateValues) {
    return Column(
      children: <Widget>[
        SearchView(
          controller: _searchController,
        ),
        _buildSelectedParticipantList(),
        Flexible(
            child: ListView.builder(
                padding: EdgeInsets.only(top: listItemPadding),
                itemCount: contactIds.length,
                itemBuilder: (BuildContext context, int index) {
                  var contactId = contactIds[index];
                  var key = "$contactId-${contactLastUpdateValues[index]}";
                  return ContactItemSelectable(contactId, _itemTapped, isSelected(contactId), key);
                }))
      ],
    );
  }

  Widget _buildSelectedParticipantList() {
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
          child: Text("${_selectedContacts.length} ${AppLocalizations.of(context).participants}"),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 4.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(),
            ),
          ),
          width: double.infinity,
          height: 40.0,
          child: _selectedContacts.isNotEmpty
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedContacts.length,
                  itemBuilder: (BuildContext context, int index) {
                    var selectedContactId = _selectedContacts[index];
                    return ContactItemChip(selectedContactId, () => _itemTapped(selectedContactId));
                  })
              : Container(
                  padding: EdgeInsets.only(
                    left: listItemPadding,
                    right: listItemPadding,
                    top: listItemPadding,
                  ),
                  child: Text(AppLocalizations.of(context).createGroupNoParticipantsHint),
                ),
        ),
      ],
    );
  }

  bool isSelected(int id) => _selectedContacts.contains(id);

  _itemTapped(int id) {
    setState(() {
      if (isSelected(id)) {
        _selectedContacts.remove(id);
      } else {
        _selectedContacts.add(id);
      }
    });
  }

  _onSubmit() async {
    if (_selectedContacts.length > 0) {
      navigation.push(context, MaterialPageRoute(builder: (context) => ChatCreateGroupSettings(_selectedContacts)), "CreateGroupChatSettings");
    } else {
      showToast(AppLocalizations.of(context).createGroupNoParticipantsSelected);
    }
  }
}
