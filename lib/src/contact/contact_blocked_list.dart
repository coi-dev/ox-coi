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
import 'package:ox_talk/src/contact/contact_item.dart';
import 'package:ox_talk/src/contact/contact_list_bloc.dart';
import 'package:ox_talk/src/contact/contact_list_event.dart';
import 'package:ox_talk/src/contact/contact_list_state.dart';
import 'package:ox_talk/src/l10n/localizations.dart';
import 'package:ox_talk/src/navigation/navigation.dart';
import 'package:ox_talk/src/utils/colors.dart';
import 'package:ox_talk/src/utils/dimensions.dart';

class ContactBlockedList extends StatefulWidget {
   @override
   _ContactBlockedListState createState() => _ContactBlockedListState();
 }
 
 class _ContactBlockedListState extends State<ContactBlockedList> {
   ContactListBloc _contactListBloc = ContactListBloc();
   Navigation navigation = Navigation();

   @override
  void initState() {
    super.initState();
    _contactListBloc.dispatch(RequestBlockedContacts());
  }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         leading: new IconButton(
           icon: new Icon(Icons.close),
           onPressed: () => navigation.pop(context, "ContactBlockedList"),
         ),
         backgroundColor: contactMain,
         title: Text(AppLocalizations.of(context).blockedContactsTitle),
       ),
       body: buildForm());
   }

   Widget buildForm() {
     return BlocBuilder(
       bloc: _contactListBloc,
       builder: (context, state) {
         if (state is ContactListStateSuccess) {
           if(state.contactIds.length > 0) {
             return buildListViewItems(state.contactIds, state.contactLastUpdateValues);
           } else{
             return Center(child: Text(AppLocalizations.of(context).blockedListEmpty),);
           }
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
     return ListView.builder(
       padding: EdgeInsets.all(listItemPadding),
       itemCount: contactIds.length,
       itemBuilder: (BuildContext context, int index) {
         var contactId = contactIds[index];
         var key = "$contactId-${contactLastUpdateValues[index]}";
         return ContactItem(contactId, false, true, key);
       });
   }
 }
 