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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/chat/chat_create_mixin.dart';
import 'package:ox_coi/src/contact/contact_item_bloc.dart';
import 'package:ox_coi/src/contact/contact_item_event_state.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/extensions/string_ui.dart';
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

class ContactDetails extends StatefulWidget {
  final int contactId;

  ContactDetails({@required this.contactId});

  @override
  _ContactDetailsState createState() => _ContactDetailsState();
}

class _ContactDetailsState extends State<ContactDetails> with ChatCreateMixin {
  final _contactItemBloc = ContactItemBloc();
  final _navigation = Navigation();

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.contactProfile);
    _contactItemBloc.add(RequestContact(id: widget.contactId, typeOrChatId: validContacts));
    _contactItemBloc.listen((state) => _handleContactChanged(context, state));
  }

  _handleContactChanged(BuildContext context, ContactItemState state) {
    if (state is ContactItemStateSuccess) {
      if(state.contactHasChanged){
        if (state.type == ContactChangeType.delete) {
          _getDeleteMessage(context).showToast();
        } else if (state.type == ContactChangeType.block) {
          _getBlockMessage(context).showToast();
        }
        _navigation.popUntilRoot(context);
      }
    } else if (state is ContactItemStateFailure) {
      switch (state.error) {
        case contactDeleteGeneric:
          L10n.get(L.contactDeleteFailed).showToast();
          break;
        case contactDeleteChatExists:
          L10n.get(L.contactDeleteWithActiveChatFailed).showToast();
          break;
      }
      _navigation.popUntilRoot(context);
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
              final contactStateData = state.contactStateData;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ProfileData(
                    text: contactStateData?.name,
                    textStyle: Theme.of(context).textTheme.title,
                    secondaryText: contactStateData?.email,
                    avatarPath: contactStateData?.imagePath,
                    imageBackgroundColor: contactStateData?.color,
                    editActionCallback: () => _editContact(context, contactStateData?.name, contactStateData?.email, contactStateData?.phoneNumbers),
                    iconData: (contactStateData?.isVerified != null && contactStateData.isVerified) ? IconSource.verifiedUser : null,
                    child: ProfileHeader(),
                  ),
                  SettingsItem(
                    pushesNewScreen: true,
                    key: Key(keyContactDetailOpenChatProfileActionIcon),
                    icon: IconSource.chat,
                    text: L10n.get(L.chatOpen),
                    iconBackground: CustomTheme.of(context).chatIcon,
                    onTap: () => createChatFromContact(context, widget.contactId),
                  ),
                  Visibility(
                    visible: widget.contactId != Contact.idSelf,
                    child: SettingsItem(
                      pushesNewScreen: false,
                      key: Key(keyUserProfileBlockIconSource),
                      icon: IconSource.block,
                      text: L10n.get(L.contactBlock),
                      iconBackground: CustomTheme.of(context).serverSettingsIcon,
                      onTap: () => showActionDialog(
                        context,
                        ProfileActionType.block,
                        _blockContact,
                        {
                          ProfileActionParams.name: contactStateData?.name,
                          ProfileActionParams.email: contactStateData?.email,
                        },
                      ),
                    ),
                  ),
                  ListGroupHeader(
                    text: L10n.get(L.settingP),
                  ),
                  SettingsItem(
                    pushesNewScreen: true,
                    icon: IconSource.notifications,
                    text: L10n.get(L.settingItemNotificationsTitle),
                    iconBackground: CustomTheme.of(context).notificationIcon,
                    onTap: () => _navigation.pushNamed(context, Navigation.settingsNotifications),
                  ),
                  ListGroupHeader(
                    text: "",
                  ),
                  Visibility(
                    visible: widget.contactId != Contact.idSelf,
                    child: SettingsItem(
                      pushesNewScreen: false,
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
                          ProfileActionParams.name: contactStateData?.name,
                          ProfileActionParams.email: contactStateData?.email,
                        },
                      ),
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

  void _editContact(BuildContext context, String name, String email, String phoneNumbers) async {
    return await _navigation
        .push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactChange(
          contactAction: ContactAction.edit,
          id: widget.contactId,
        ),
      ),
    )
        .then((value) {
      _contactItemBloc.add(RequestContact(id: widget.contactId, typeOrChatId: validContacts));
    });
  }

  _deleteContact() {
    _navigation.pop(context);
    _contactItemBloc.add(DeleteContact(id: widget.contactId));
  }

  _blockContact() {
    _navigation.pop(context);
    _contactItemBloc.add(BlockContact(id: widget.contactId));
  }

  String _getDeleteMessage(BuildContext context) {
    return L10n.get(L.contactDeletedSuccess);
  }

  String _getBlockMessage(BuildContext context) {
    return L10n.get(L.contactBlockedSuccess);
  }
}
