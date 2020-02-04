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

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon_button.dart';
import 'package:ox_coi/src/chat/chat_create_mixin.dart';
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
import 'package:ox_coi/src/ui/custom_theme.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/dialog_builder.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/utils/key_generator.dart';
import 'package:ox_coi/src/utils/toast.dart';
import 'package:ox_coi/src/widgets/fullscreen_progress.dart';
import 'package:ox_coi/src/widgets/search.dart';
import 'package:ox_coi/src/widgets/state_info.dart';

class ContactList extends RootChild {
  final Navigation navigation = Navigation();

  ContactList({appBarActionsStream, Key key}) : super(appBarActionsStream: appBarActionsStream, key: key);

  @override
  _ContactListState createState() => _ContactListState();

  @override
  Color getColor(BuildContext context) {
    return CustomTheme.of(context).onSurface;
  }

  @override
  FloatingActionButton getFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      key: Key(keyContactListPersonAddFloatingActionButton),
      child: new AdaptiveIcon(icon: IconSource.personAdd),
      onPressed: () {
        _showAddContactView(context);
      },
    );
  }

  _showAddContactView(BuildContext context) {
    navigation.pushNamed(context, Navigation.contactsAdd);
  }

  @override
  String getTitle() {
    return L10n.get(L.contactP, count: L10n.plural);
  }

  @override
  String getNavigationText() {
    return L10n.get(L.contactP, count: L10n.plural);
  }

  @override
  IconSource getNavigationIcon() {
    return IconSource.contacts;
  }

  @override
  List<Widget> getActions(BuildContext context) {
    return [
      AdaptiveIconButton(
        icon: AdaptiveIcon(
          icon: IconSource.importContacts,
        ),
        key: Key(keyContactListImportContactIconButton),
        onPressed: () => appBarActionsStream.add(AppBarAction.importContacts),
      ),
      AdaptiveIconButton(
        icon: AdaptiveIcon(
          icon: IconSource.search,
        ),
        key: Key(keyContactListSearchIconButton),
        onPressed: () => appBarActionsStream.add(AppBarAction.searchContacts),
      ),
    ];
  }
}

class _ContactListState extends State<ContactList> with ChatCreateMixin {
  ContactListBloc _contactListBloc = ContactListBloc();
  ContactImportBloc _contactImportBloc = ContactImportBloc();
  Navigation navigation = Navigation();
  OverlayEntry _progressOverlayEntry;
  StreamSubscription appBarActionsSubscription;
  var _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    navigation.current = Navigatable(Type.contactList);
    requestValidContacts();
    setupContactImport();
    appBarActionsSubscription = widget.appBarActionsStream.stream.listen((data) {
      var action = data as AppBarAction;
      if (action == AppBarAction.importContacts) {
        _actionImport();
      } else if (action == AppBarAction.searchContacts) {
        _actionSearch();
      }
    });
  }

  @override
  void dispose() {
    _contactImportBloc.close();
    _contactListBloc.close();
    appBarActionsSubscription.cancel();
    super.dispose();
  }

  void requestValidContacts() => _contactListBloc.add(RequestContacts(typeOrChatId: validContacts));

  setupContactImport() async {
    if (await _contactImportBloc.isInitialContactsOpening()) {
      _contactImportBloc.add(MarkContactsAsInitiallyLoaded());
      _showImportDialog(true, context);
    }
    _contactImportBloc.listen((state) => handleContactImport(state));
  }

  handleContactImport(ContactImportState state) {
    _progressOverlayEntry?.remove();
    if (state is ContactsImportSuccess) {
      requestValidContacts();
      String contactImportSuccess = L10n.get(L.contactImportSuccessful);
      showToast(contactImportSuccess);
    } else if (state is ContactsImportFailure) {
      String contactImportFailure = L10n.get(L.contactImportFailed);
      showToast(contactImportFailure);
    } else if (state is GooglemailContactsDetected) {
      showConfirmationDialog(
        context: context,
        title: L10n.get(L.contactGooglemailDialogTitle),
        content: L10n.get(L.contactGooglemailDialogContent),
        positiveButton: L10n.get(L.contactGooglemailDialogPositiveButton),
        positiveAction: () => _goolemailMailAddressAction(true),
        negativeButton: L10n.get(L.contactGooglemailDialogNegativeButton),
        negativeAction: () => _goolemailMailAddressAction(false),
        navigatable: Navigatable(Type.contactGooglemailDetectedDialog),
        barrierDismissible: false,
        onWillPop: _onGoogleMailDialogWillPop,
      );
    }
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
          var contactIds = state.contactIds;
          var contactLastUpdateValues = state.contactLastUpdateValues;
          return ListView.custom(
              controller: _scrollController,
              childrenDelegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    var contactId = contactIds[index];
                    var key = createKeyFromId(contactId, [contactLastUpdateValues[index]]);
                    return Dismissible(
                      key: key,
                      confirmDismiss: (direction) {
                        createChatFromContact(context, contactId);
                        return Future.value(false);
                      },
                      background: Container(
                        color: CustomTheme.of(context).chatIcon,
                        padding: const EdgeInsets.only(right: iconDismissiblePadding),
                        alignment: Alignment.centerRight,
                        child: AdaptiveIcon(
                          icon: IconSource.chat,
                          color: CustomTheme.of(context).white,
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      child: ContactItem(
                        contactId: contactId,
                        contactItemType: ContactItemType.edit,
                        key: key,
                      ),
                    );
                  },
                  childCount: contactIds.length,
                  findChildIndexCallback: (Key key) {
                    final ValueKey valueKey = key;
                    var id = extractId(valueKey);
                    if (contactIds.contains(id)) {
                      var indexOf = contactIds.indexOf(id);
                      return indexOf;
                    } else {
                      return null;
                    }
                  }));
        } else if (state is! ContactListStateFailure) {
          return StateInfo(showLoading: true);
        } else {
          return AdaptiveIcon(icon: IconSource.error);
        }
      },
    );
  }

  Widget onBuildResultOrSuggestion(String query) {
    _contactListBloc.add(SearchContacts(query: query));
    return buildList();
  }

  void onSearchClose() {
    requestValidContacts();
  }

  void _actionImport() {
    _showImportDialog(false, context);
  }

  void _actionSearch() {
    Search search = Search(
      onBuildResults: onBuildResultOrSuggestion,
      onBuildSuggestion: onBuildResultOrSuggestion,
      onClose: onSearchClose,
    );
    search.show(context);
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
        _progressOverlayEntry = FullscreenOverlay(
            fullscreenProgress: FullscreenProgress(
          bloc: _contactListBloc,
          text: L10n.get(L.contactImportRunning),
        ));
        Overlay.of(context).insert(_progressOverlayEntry);
        _contactImportBloc.add(PerformImport());
      },
      navigatable: Navigatable(Type.contactImportDialog),
    );
  }

  Future<bool> _onGoogleMailDialogWillPop() {
    return Future.value(false);
  }

  _goolemailMailAddressAction(bool changeEmail) {
    _contactImportBloc.add(ImportGooglemailContacts(changeEmails: changeEmail));
  }
}
