/*
 * open-xchange legal information
 *
 * all intellectual property rights in the software are protected by
 * international copyright laws.
 *
 *
 * in some countries ox, ox open-xchange and open xchange
 * as well as the corresponding logos ox open-xchange and ox are registered
 * trademarks of the ox software gmbh group of companies.
 * the use of the logos is not covered by the mozilla public license 2.0 (mpl 2.0).
 * instead, you are allowed to use these logos according to the terms and
 * conditions of the creative commons license, version 2.5, attribution,
 * non-commercial, sharealike, and the interpretation of the term
 * non-commercial applicable to the aforementioned license is published
 * on the web site https://www.open-xchange.com/terms-and-conditions/.
 *
 * please make sure that third-party modules and libraries are used
 * according to their respective licenses.
 *
 * any modifications to this package must retain all copyright notices
 * of the original copyright holder(s) for the original code used.
 *
 * after any such modifications, the original and derivative code shall remain
 * under the copyright of the copyright holder(s) and/or original author(s) as stated here:
 * https://www.open-xchange.com/legal/. the contributing author shall be
 * given attribution for the derivative code and a license granting use.
 *
 * copyright (c) 2016-2020 ox software gmbh
 * mail: info@open-xchange.com
 *
 *
 * this source code form is subject to the terms of the mozilla public
 * license, v. 2.0. if a copy of the mpl was not distributed with this
 * file, you can obtain one at http://mozilla.org/mpl/2.0/.
 *
 * this program is distributed in the hope that it will be useful, but
 * without any warranty; without even the implied warranty of merchantability
 * or fitness for a particular purpose. see the mozilla public license 2.0
 * for more details.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_talk/src/chat/create_group_chat_participants.dart';
import 'package:ox_talk/src/contact/contact_change.dart';
import 'package:ox_talk/src/contact/contact_item.dart';
import 'package:ox_talk/src/contact/contact_list_bloc.dart';
import 'package:ox_talk/src/contact/contact_list_event.dart';
import 'package:ox_talk/src/contact/contact_list_state.dart';
import 'package:ox_talk/src/contact/contact_search_controller_mixin.dart';
import 'package:ox_talk/src/data/contact_repository.dart';
import 'package:ox_talk/src/l10n/localizations.dart';
import 'package:ox_talk/src/navigation/navigation.dart';
import 'package:ox_talk/src/utils/colors.dart';
import 'package:ox_talk/src/utils/dimensions.dart';
import 'package:ox_talk/src/utils/styles.dart';
import 'package:ox_talk/src/widgets/search_field.dart';

class CreateChat extends StatefulWidget {
  @override
  _CreateChatState createState() => _CreateChatState();
}

class _CreateChatState extends State<CreateChat> with ContactSearchController {
  ContactListBloc _contactListBloc = ContactListBloc();
  Navigation navigation = Navigation();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
        "ContactChange");
  }

  createGroupTapped() {
    navigation.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateGroupChatParticipants(),
        ),
        "CreateGroupChatParticipants");
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
