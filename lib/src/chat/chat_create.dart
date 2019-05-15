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
import 'package:ox_talk/src/chat/chat_create_group_participants.dart';
import 'package:ox_talk/src/contact/contact_change.dart';
import 'package:ox_talk/src/contact/contact_item.dart';
import 'package:ox_talk/src/contact/contact_list_bloc.dart';
import 'package:ox_talk/src/contact/contact_list_event.dart';
import 'package:ox_talk/src/contact/contact_list_state.dart';
import 'package:ox_talk/src/contact/contact_search_controller_mixin.dart';
import 'package:ox_talk/src/data/contact_repository.dart';
import 'package:ox_talk/src/l10n/localizations.dart';
import 'package:ox_talk/src/navigation/navigatable.dart';
import 'package:ox_talk/src/navigation/navigation.dart';
import 'package:ox_talk/src/utils/colors.dart';
import 'package:ox_talk/src/utils/dimensions.dart';
import 'package:ox_talk/src/utils/styles.dart';
import 'package:ox_talk/src/widgets/search_field.dart';

class ChatCreate extends StatefulWidget {
  @override
  _ChatCreateState createState() => _ChatCreateState();
}

class _ChatCreateState extends State<ChatCreate> with ContactSearchController {
  ContactListBloc _contactListBloc = ContactListBloc();
  Navigation navigation = Navigation();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    navigation.current = Navigatable(Type.chatCreate);
    _contactListBloc.dispatch(RequestContacts(listTypeOrChatId: ContactRepository.validContacts));
    addSearchListener(_contactListBloc, _searchController);
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
        ),
        body: buildForm());
  }

  Widget buildForm() {
    return BlocBuilder(
      bloc: _contactListBloc,
      builder: (context, state) {
        if (state is ContactListStateSuccess) {
          return buildListViewItems(state.contactIds, state.contactLastUpdateValues);
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

  Widget buildListViewItems(List<int> contactIds, List<int> contactLastUpdateValues) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SearchView(
          controller: _searchController,
        ),
        Flexible(
          child: ListView.builder(
              itemCount: contactIds.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return buildNewContactAddGroup();
                } else {
                  int adjustedIndex = index - 1;
                  var contactId = contactIds[adjustedIndex];
                  var key = "$contactId-${contactLastUpdateValues[adjustedIndex]}";
                  return ContactItem(contactId, key, ContactItemType.createChat);
                }
              }),
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

  Column buildNewContactAddGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Visibility(
          visible: _searchController.text.isEmpty,
          child: ListTile(
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
        ),
        Visibility(
          visible: _searchController.text.isEmpty,
          child: Container(
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
        ),
        Padding(
          padding: EdgeInsets.only(bottom: listItemPadding),
        )
      ],
    );
  }
}
