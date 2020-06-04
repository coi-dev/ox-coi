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
import 'package:ox_coi/src/contact/contact_item.dart';
import 'package:ox_coi/src/contact/contact_list_bloc.dart';
import 'package:ox_coi/src/contact/contact_list_content.dart';
import 'package:ox_coi/src/contact/contact_list_event_state.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/utils/key_generator.dart';
import 'package:ox_coi/src/widgets/dynamic_appbar.dart';
import 'package:ox_coi/src/widgets/state_info.dart';

class ContactBlockedList extends StatefulWidget {
  @override
  _ContactBlockedListState createState() => _ContactBlockedListState();
}

class _ContactBlockedListState extends State<ContactBlockedList> {
  ContactListBloc _contactListBloc = ContactListBloc();
  Navigation navigation = Navigation();
  var _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    navigation.current = Navigatable(Type.contactListBlocked);
    _contactListBloc.add(RequestContacts(typeOrChatId: blockedContacts));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: DynamicAppBar(
          title: L10n.get(L.contactBlocked),
          leading: AppBarCloseButton(context: context),
        ),
        body: buildForm());
  }

  Widget buildForm() {
    return BlocBuilder(
      bloc: _contactListBloc,
      builder: (context, state) {
        if (state is ContactListStateSuccess) {
          var contactIds = state.contactElements;
          if (contactIds.length > 0) {
            return ListView.custom(
                controller: _scrollController,
                childrenDelegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final contactElement = contactIds[index];
                      return ContactListContent(
                        contactElement: contactElement,
                        hasHeader: true,
                        contactItemType: ContactItemType.blocked,
                      );
                    },
                    childCount: contactIds.length,
                    findChildIndexCallback: (Key key) {
                      final ValueKey valueKey = key;
                      var id = extractId(valueKey);
                      var indexOf = contactIds.indexOf(id);
                      return indexOf;
                    }));
          } else {
            return EmptyListInfo(
              infoText: L10n.get(L.contactNoBlocked),
              imagePath: "assets/images/empty_blocked_list.png",
            );
          }
        } else if (state is! ContactListStateFailure) {
          return StateInfo(showLoading: true);
        } else {
          return AdaptiveIcon(icon: IconSource.error);
        }
      },
    );
  }
}
