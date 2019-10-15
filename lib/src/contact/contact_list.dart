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
import 'package:ox_coi/src/contact/contact_import_bloc.dart';
import 'package:ox_coi/src/contact/contact_import_event_state.dart';
import 'package:ox_coi/src/contact/contact_item.dart';
import 'package:ox_coi/src/contact/contact_list_bloc.dart';
import 'package:ox_coi/src/contact/contact_list_event_state.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/main/root_child.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/dialog_builder.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/utils/toast.dart';
import 'package:ox_coi/src/widgets/fullscreen_progress.dart';
import 'package:ox_coi/src/widgets/search.dart';
import 'package:ox_coi/src/widgets/state_info.dart';
import 'package:rxdart/rxdart.dart';

class ContactList extends RootChild {
  final Navigation navigation = Navigation();

  ContactList({State<StatefulWidget> state}) : super(state: state);

  @override
  _ContactListState createState() {
    final state = _ContactListState();
    setActions([state.getImportAction(), state.getBlockedUsersAction(), state.getSearchAction()]);
    return state;
  }

  @override
  Color getColor() {
    return primary;
  }

  @override
  FloatingActionButton getFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      key: Key(keyContactListPersonAddFloatingActionButton),
      child: new Icon(Icons.person_add),
      onPressed: () {
        _showAddContactView(context);
      },
    );
  }

  _showAddContactView(BuildContext context) {
    navigation.pushNamed(context, Navigation.contactsAdd);
  }

  @override
  String getTitle(BuildContext context) {
    return L10n.get(L.contactP, count: L10n.plural);
  }

  @override
  String getNavigationText(BuildContext context) {
    return L10n.get(L.contactP, count: L10n.plural);
  }

  @override
  IconData getNavigationIcon() {
    return Icons.contacts;
  }
}

class _ContactListState extends State<ContactList> {
  ContactListBloc _contactListBloc = ContactListBloc();
  ContactImportBloc _contactImportBloc = ContactImportBloc();
  Navigation navigation = Navigation();
  OverlayEntry _progressOverlayEntry;

  @override
  void initState() {
    super.initState();
    navigation.current = Navigatable(Type.contactList);
    requestValidContacts();
    setupContactImport();
  }

  void requestValidContacts() => _contactListBloc.dispatch(RequestContacts(typeOrChatId: validContacts));

  setupContactImport() async {
    if (await _contactImportBloc.isInitialContactsOpening()) {
      _contactImportBloc.dispatch(MarkContactsAsInitiallyLoaded());
      _showImportDialog(true, context);
    }
    final contactImportObservable = new Observable<ContactImportState>(_contactImportBloc.state);
    contactImportObservable.listen((state) => handleContactImport(state));
  }

  handleContactImport(ContactImportState state) {
    if (_progressOverlayEntry != null) {
      _progressOverlayEntry.remove();
      _progressOverlayEntry = null;
    }
    if (state is ContactsImportSuccess) {
      requestValidContacts();
      String contactImportSuccess = L10n.get(L.contactImportSuccessful);
      showToast(contactImportSuccess);
    } else if (state is ContactsImportFailure) {
      String contactImportFailure = L10n.get(L.contactImportFailed);
      showToast(contactImportFailure);
    }
  }

  @override
  void dispose() {
    _contactImportBloc.dispose();
    _contactListBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildList();
  }

  Widget buildList() {
    return BlocBuilder(
      bloc: _contactListBloc,
      builder: (context, state) {
        if (state is ContactListStateSuccess) {
          return buildListViewItems(state.contactIds, state.contactLastUpdateValues);
        } else if (state is! ContactListStateFailure) {
          return StateInfo(showLoading: true);
        } else {
          return Icon(Icons.error);
        }
      },
    );
  }

  Widget getImportAction() {
    return IconButton(
      icon: Icon(Icons.import_contacts),
      key: Key(keyContactListImportContactIconButton),
      onPressed: () => _showImportDialog(false, context),
    );
  }

  Widget getBlockedUsersAction() {
    return IconButton(
      icon: Icon(Icons.block),
      key: Key(keyContactListBlockIconButton),
      onPressed: () => _showBlockedUserList(context),
    );
  }

  Widget getSearchAction() {
    Search search = Search(
      onBuildResults: onBuildResultOrSuggestion,
      onBuildSuggestion: onBuildResultOrSuggestion,
      onClose: onSearchClose,
    );
    return IconButton(
      icon: Icon(Icons.search),
      key: Key(keyContactListSearchIconButton),
      onPressed: () => search.show(context),
    );
  }

  Widget onBuildResultOrSuggestion(String query) {
    _contactListBloc.dispatch(SearchContacts(query: query));
    return buildList();
  }

  void onSearchClose() {
    requestValidContacts();
  }

  _showBlockedUserList(BuildContext context) {
    navigation.pushNamed(context, Navigation.contactsBlocked);
  }

  void _showImportDialog(bool initialImport, BuildContext context) {
    var importTitle = L10n.get(L.contactImport);
    var importText = L10n.get(L.contactSystemImportText);
    var importTextInitial = L10n.get(L.contactInitialImportText);
    var importTextRepeat = L10n.get(L.contactReImportText);
    var content = "$importText ${initialImport ? importTextInitial : importTextRepeat}";
    var importPositive = L10n.get(L.import);
    showConfirmationDialog(
      context: context,
      title: importTitle,
      content: content,
      positiveButton: importPositive,
      positiveAction: () {
        _progressOverlayEntry = OverlayEntry(
          builder: (context) => FullscreenProgress(
            bloc: _contactListBloc,
            text: L10n.get(L.contactImportRunning),
            showProgressValues: false,
            showCancelButton: false,
          ),
        );
        Overlay.of(context).insert(_progressOverlayEntry);
        _contactImportBloc.dispatch(PerformImport());
      },
      navigatable: Navigatable(Type.contactImportDialog),
    );
  }

  Widget buildListViewItems(List<int> contactIds, List<int> contactLastUpdateValues) {
    return ListView.separated(
        separatorBuilder: (context, index) => Divider(
          height: dividerHeight,
          color: onBackground.withOpacity(barely),
        ),
        itemCount: contactIds.length,
        itemBuilder: (BuildContext context, int index) {
          var contactId = contactIds[index];
          var key = "$contactId-${contactLastUpdateValues[index]}";
          return ContactItem(contactId: contactId, contactItemType: ContactItemType.edit, key: key);
        });
  }
}
