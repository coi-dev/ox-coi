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
import 'package:ox_talk/src/chat/create_group_chat.dart';
import 'package:ox_talk/src/contact/contact_change.dart';
import 'package:ox_talk/src/contact/contact_item.dart';
import 'package:ox_talk/src/contact/contact_list_bloc.dart';
import 'package:ox_talk/src/contact/contact_list_event.dart';
import 'package:ox_talk/src/contact/contact_list_state.dart';
import 'package:ox_talk/src/data/contact_repository.dart';
import 'package:ox_talk/src/l10n/localizations.dart';
import 'package:ox_talk/src/navigation/navigation.dart';
import 'package:ox_talk/src/utils/dimensions.dart';

class CreateChat extends StatefulWidget {
  @override
  _CreateChatState createState() => _CreateChatState();
}

class _CreateChatState extends State<CreateChat> {
  ContactListBloc _contactListBloc = ContactListBloc();
  Navigation navigation = Navigation();

  @override
  void initState(){
    super.initState();
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
          leading: new IconButton(
            icon: new Icon(Icons.close),
            onPressed: () => navigation.pop(context, "CreateChat"),
          ),
          title: Text(AppLocalizations.of(context).createChatTitle),
        ),
        body: buildForm()
    );
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
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          child: FlatButton(
            onPressed: () => newContactTapped(),
            child: Text(AppLocalizations.of(context).createChatNewContactButtonText)
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: FlatButton(
            onPressed: () => createGroupTapped(),
            child: Text(AppLocalizations.of(context).createChatCreateGroupButtonText)
          ),
        ),
        Flexible(
          child: ListView.builder(
            padding: EdgeInsets.all(listItemPadding),
            itemCount: contactIds.length,
            itemBuilder: (BuildContext context, int index) {
              var contactId = contactIds[index];
              var key = "$contactId-${contactLastUpdateValues[index]}";
              return ContactItem(contactId, true, false, key);
            }
          ),
        )
      ],
    );
  }

  newContactTapped(){
    navigation.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactChange(contactAction: ContactAction.add, createChat: true,),
      ),
      "ContactChange"
    );
  }

  createGroupTapped() {
    navigation.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGroupChat(),
      ),
      "CreateGroupChat"
    );
  }
}
