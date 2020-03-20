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
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/chat/chat_create_mixin.dart';
import 'package:ox_coi/src/contact/contact_import_bloc.dart';
import 'package:ox_coi/src/contact/contact_import_event_state.dart';
import 'package:ox_coi/src/contact/contact_item.dart';
import 'package:ox_coi/src/contact/contact_list_bloc.dart';
import 'package:ox_coi/src/contact/contact_list_event_state.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/extensions/color_apis.dart';
import 'package:ox_coi/src/extensions/string_ui.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/main/root_child.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/utils/key_generator.dart';
import 'package:ox_coi/src/widgets/dialog_builder.dart';
import 'package:ox_coi/src/widgets/dynamic_appbar.dart';
import 'package:ox_coi/src/widgets/fullscreen_progress.dart';
import 'package:ox_coi/src/widgets/state_info.dart';
import 'package:ox_coi/src/widgets/superellipse_icon.dart';
import 'package:provider/provider.dart';

_showAddContactView(BuildContext context, Navigation navigation) {
  navigation.pushNamed(context, Navigation.contactsAdd);
}

class ContactList extends RootChild {
  final _navigation = Navigation();

  @override
  _ContactListState createState() => _ContactListState();

  @override
  Color getColor(BuildContext context) => CustomTheme.of(context).onSurface;

  @override
  FloatingActionButton getFloatingActionButton(BuildContext context) {
    return Platform.isAndroid
        ? FloatingActionButton(
            key: Key(keyContactListAddContactButton),
            child: new AdaptiveIcon(icon: IconSource.personAdd),
            onPressed: () {
              _showAddContactView(context, _navigation);
            },
          )
        : null;
  }

  @override
  String getBottomNavigationText() => L10n.get(L.contactP, count: L10n.plural);

  @override
  IconSource getBottomNavigationIcon() => IconSource.contacts;

  @override
  DynamicAppBar getAppBar(BuildContext context, StreamController<AppBarAction> appBarActionsStream) {
    return DynamicAppBar(
      title: L10n.get(L.contactP, count: L10n.plural),
      trailingList: [
        IconButton(
          key: Key(keyContactListImportButton),
          icon: SuperellipseIcon(
            icon: IconSource.importContacts,
            iconColor: CustomTheme.of(context).accent,
            color: CustomTheme.of(context).onSurface.barely(),
          ),
          onPressed: () => appBarActionsStream.add(AppBarAction.importContacts),
        ),
        if (Platform.isIOS)
          IconButton(
            key: Key(keyContactListAddContactButton),
            icon: SuperellipseIcon(
              icon: IconSource.personAdd,
              iconColor: CustomTheme.of(context).onAccent,
              color: CustomTheme.of(context).accent,
            ),
            onPressed: () => appBarActionsStream.add(AppBarAction.addContact),
          )
      ],
    );
  }
}

class _ContactListState extends State<ContactList> with ChatCreateMixin {
  final _contactListBloc = ContactListBloc();
  final _contactImportBloc = ContactImportBloc();
  final _scrollController = ScrollController();
  DynamicSearchBar _searchBar;

  OverlayEntry _progressOverlayEntry;
  StreamSubscription _appBarActionsSubscription;

  @override
  void initState() {
    super.initState();
    widget._navigation.current = Navigatable(Type.contactList);
    requestValidContacts();
    setupContactImport();
    _appBarActionsSubscription = Provider.of<StreamController<AppBarAction>>(context, listen: false).stream.listen((data) {
      if (data == AppBarAction.importContacts) {
        _actionImport();
      } else if (data == AppBarAction.addContact) {
        _showAddContactView(context, widget._navigation);
      }
    });
    _searchBar = DynamicSearchBar(
      content: DynamicSearchBarContent(
        onSearch: (text) {
          _contactListBloc.add(SearchContacts(query: text));
        },
      ),
    );
  }

  @override
  void dispose() {
    _contactImportBloc.close();
    _contactListBloc.close();
    _appBarActionsSubscription.cancel();
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
      contactImportSuccess.showToast();
    } else if (state is ContactsImportFailure) {
      String contactImportFailure = L10n.get(L.contactImportFailed);
      contactImportFailure.showToast();
    } else if (state is GooglemailContactsDetected) {
      showConfirmationDialog(
        context: context,
        title: L10n.get(L.contactGooglemailDialogTitle),
        content: L10n.get(L.contactGooglemailDialogContent),
        positiveButton: L10n.get(L.contactGooglemailDialogPositiveButton),
        positiveAction: () => _googleMailMailAddressAction(true),
        negativeButton: L10n.get(L.contactGooglemailDialogNegativeButton),
        negativeAction: () => _googleMailMailAddressAction(false),
        navigatable: Navigatable(Type.contactGooglemailDetectedDialog),
        barrierDismissible: false,
        onWillPop: _onGoogleMailDialogWillPop,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _contactListBloc,
      builder: (context, state) {
        if (state is ContactListStateSuccess) {
          final contactIds = state.contactIds;
          final contactLastUpdateValues = state.contactLastUpdateValues;

          return CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              _searchBar,
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final contactId = contactIds[index];
                    final int previousContactId = (index > 0) ? contactIds[index - 1] : null;
                    final key = createKeyFromId(contactId, [contactLastUpdateValues[index]]);
                    final contactItem = ContactItem(contactId: contactId, previousContactId: previousContactId, key: key);
                    final chatIcon = AdaptiveIcon(icon: IconSource.chat, color: CustomTheme.of(context).white);

                    return Dismissible(
                      key: key,
                      confirmDismiss: (direction) {
                        createChatFromContact(context, contactId);
                        return Future.value(false);
                      },
                      background: Container(
                        color: CustomTheme.of(context).chatIcon,
                        padding: const EdgeInsets.only(right: dimension20dp),
                        alignment: Alignment.centerRight,
                        child: chatIcon,
                      ),
                      direction: DismissDirection.endToStart,
                      child: contactItem,
                    );
                  },
                  childCount: contactIds.length,
                  findChildIndexCallback: (Key key) {
                    final ValueKey valueKey = key;
                    final id = extractId(valueKey);
                    return (contactIds.contains(id) ? contactIds.indexOf(id) : null);
                  },
                ),
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

  void _actionImport() {
    _showImportDialog(false, context);
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

  _googleMailMailAddressAction(bool changeEmail) {
    _contactImportBloc.add(ImportGooglemailContacts(changeEmails: changeEmail));
  }
}
