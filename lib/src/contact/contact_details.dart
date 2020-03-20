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
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/chat/chat_create_mixin.dart';
import 'package:ox_coi/src/contact/contact_change_bloc.dart';
import 'package:ox_coi/src/contact/contact_item_bloc.dart';
import 'package:ox_coi/src/contact/contact_item_event_state.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/extensions/string_ui.dart';
import 'package:ox_coi/src/flagged/flagged.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/utils/constants.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/widgets/dynamic_appbar.dart';
import 'package:ox_coi/src/widgets/list_group_header.dart';
import 'package:ox_coi/src/widgets/profile_body.dart';
import 'package:ox_coi/src/widgets/profile_header.dart';
import 'package:ox_coi/src/widgets/settings_item.dart';

import 'contact_change.dart';
import 'contact_change_event_state.dart';

class ContactDetails extends StatefulWidget {
  final int contactId;

  ContactDetails({@required this.contactId});

  @override
  _ContactDetailsState createState() => _ContactDetailsState();
}

class _ContactDetailsState extends State<ContactDetails> with ChatCreateMixin {
  final _contactItemBloc = ContactItemBloc();
  final _contactChangeBloc = ContactChangeBloc();
  final _navigation = Navigation();

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.contactProfile);
    _contactItemBloc.add(RequestContact(contactId: widget.contactId, typeOrChatId: validContacts));
    _contactChangeBloc.listen((state) => _handleContactChanged(context, state));
  }

  _handleContactChanged(BuildContext context, ContactChangeState state) {
    if (state is ContactChangeStateSuccess) {
      if (state.type == ContactChangeType.delete) {
        _getDeleteMessage(context).showToast();
      } else if (state.type == ContactChangeType.block) {
        _getBlockMessage(context).showToast();
      }
      _navigation.popUntilRoot(context);
    } else if (state is ContactChangeStateFailure) {
      switch (state.error) {
        case contactDeleteGeneric:
          L10n.get(L.contactDeleteFailed).showToast();
          break;
        case contactDeleteChatExists:
          L10n.get(L.contactDeleteWithActiveChatFailed).showToast();
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: L10n.get(L.profile),
        leading: AppBarBackButton(context: context),
      ),
      body: SingleChildScrollView(
        child: BlocBuilder(
          bloc: _contactItemBloc,
          builder: (context, state) {
            if (state is ContactItemStateSuccess) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ProfileData(
                    text: state.name,
                    textStyle: Theme.of(context).textTheme.title,
                    secondaryText: state.email,
                    avatarPath: state.imagePath,
                    imageBackgroundColor: state.color,
                    editActionCallback: () => _editContact(context, state.name, state.email, state.phoneNumbers),
                    iconData: state.isVerified ? IconSource.verifiedUser : null,
                    child: ProfileHeader(),
                  ),
                  SettingsItem(
                    key: Key(keyContactDetailOpenChatProfileActionIcon),
                    icon: IconSource.chat,
                    text: L10n.get(L.chatOpen),
                    iconBackground: CustomTheme.of(context).chatIcon,
                    onTap: () => createChatFromContact(context, widget.contactId),
                  ),
                  SettingsItem(
                    icon: IconSource.flag,
                    text: L10n.get(L.settingItemFlaggedTitle),
                    iconBackground: CustomTheme.of(context).flagIcon,
                    onTap: () => _settingsItemTapped(context, SettingsItemName.flagged),
                  ),
                  SettingsItem(
                    key: Key(keyUserProfileBlockIconSource),
                    icon: IconSource.block,
                    text: L10n.get(L.contactBlock),
                    iconBackground: CustomTheme.of(context).serverSettingsIcon,
                    onTap: () => showActionDialog(
                      context,
                      ProfileActionType.block,
                      _blockContact,
                      {
                        ProfileActionParams.name: state.name,
                        ProfileActionParams.email: state.email,
                      },
                    ),
                  ),
                  ListGroupHeader(
                    text: L10n.get(L.settingP),
                  ),
                  SettingsItem(
                    icon: IconSource.notifications,
                    text: L10n.get(L.settingItemNotificationsTitle),
                    iconBackground: CustomTheme.of(context).notificationIcon,
                    onTap: () => _settingsItemTapped(context, SettingsItemName.notification),
                  ),
                  ListGroupHeader(
                    text: "",
                  ),
                  SettingsItem(
                    key: Key(keyContactDetailDeleteContactProfileActionIcon),
                    icon: IconSource.delete,
                    text: L10n.get(L.contactDelete),
                    textColor: CustomTheme.of(context).error,
                    iconBackground: CustomTheme.of(context).blockIcon,
                    onTap: () => showActionDialog(
                      context,
                      ProfileActionType.deleteContact,
                      _deleteContact,
                      {
                        ProfileActionParams.name: state.name,
                        ProfileActionParams.email: state.email,
                      },
                    ),
                  ),
                ],
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  _settingsItemTapped(BuildContext context, SettingsItemName settingsItemName) {
    switch (settingsItemName) {
      case SettingsItemName.flagged:
        _navigation.push(
          context,
          MaterialPageRoute(builder: (context) => Flagged()),
        );
        break;
      case SettingsItemName.notification:
        _navigation.pushNamed(context, Navigation.settingsNotifications);
        break;
      default:
        break;
    }
  }

  void _editContact(BuildContext context, String name, String email, String phoneNumbers) async {
    return await _navigation
        .push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactChange(
          contactAction: ContactAction.edit,
          id: widget.contactId,
          name: name,
          email: email,
          phoneNumbers: phoneNumbers,
        ),
      ),
    )
        .then((value) {
      _contactItemBloc.add(RequestContact(contactId: widget.contactId, typeOrChatId: validContacts));
    });
  }

  _deleteContact() {
    _navigation.pop(context);
    _contactChangeBloc.add(DeleteContact(id: widget.contactId));
  }

  _blockContact() {
    _navigation.pop(context);
    _contactChangeBloc.add(BlockContact(contactId: widget.contactId));
  }

  String _getDeleteMessage(BuildContext context) {
    return L10n.get(L.contactDeletedSuccess);
  }

  String _getBlockMessage(BuildContext context) {
    return L10n.get(L.contactBlockedSuccess);
  }
}
