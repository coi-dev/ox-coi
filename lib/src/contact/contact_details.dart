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
import 'package:ox_coi/src/chat/chat_create_mixin.dart';
import 'package:ox_coi/src/contact/contact_change_bloc.dart';
import 'package:ox_coi/src/contact/contact_item_bloc.dart';
import 'package:ox_coi/src/contact/contact_item_event_state.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/l10n/localizations.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/utils/colors.dart';
import 'package:ox_coi/src/utils/dialog_builder.dart';
import 'package:ox_coi/src/utils/error.dart';
import 'package:ox_coi/src/utils/toast.dart';
import 'package:ox_coi/src/widgets/avatar.dart';
import 'package:ox_coi/src/widgets/profile_header.dart';
import 'package:rxdart/rxdart.dart';

import 'contact_change.dart';
import 'contact_change_event_state.dart';
import 'contact_profile_mixin.dart';

class ContactDetailsView extends StatelessWidget with ContactProfileMixin, CreateChatMixin {
  final _contactItemBloc = ContactItemBloc();
  final _contactChangeBloc = ContactChangeBloc();
  final _navigation = Navigation();
  final int _contactId;

  ContactDetailsView(this._contactId) {
    print("[ContactDetailsView.ContactDetailsView] dboehrs - BLAA!");
    _navigation.current = Navigatable(Type.contactProfile);
    _contactItemBloc.dispatch(RequestContact(contactId: _contactId, listType: ContactRepository.validContacts));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).profileTitle),
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
                  ProfileHeader(
                    dynamicChildren: [
                      buildHeaderText(context, state.name, state.isVerified ? Icons.verified_user : null),
                      buildCopyableText(context, state.email, AppLocalizations.of(context).chatProfileClipboardToastMessage),
                    ],
                    color: state.color,
                    initialsString: Avatar.getInitials(state.name, state.email),
                  ),
                  buildActionList(context, [
                    ListTile(
                      leading: Icon(
                        Icons.chat,
                        color: accent,
                      ),
                      title: Text(
                        AppLocalizations.of(context).contactsOpenChat,
                      ),
                      onTap: () => createChatFromContact(context, _contactId),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.edit,
                        color: accent,
                      ),
                      title: Text(
                        AppLocalizations.of(context).contactChangeEditTitle,
                      ),
                      onTap: () {
                        _navigation.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactChange(
                                  contactAction: ContactAction.edit,
                                  id: _contactId,
                                  name: state.name,
                                  email: state.email,
                                ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.delete,
                        color: accent,
                      ),
                      title: Text(
                        AppLocalizations.of(context).contactChangeDeleteTitle,
                      ),
                      onTap: () {
                        _onDelete(context, state.name, state.email);
                      },
                    ),
                  ]),
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

  _onDelete(BuildContext context, String name, String email) {
    showConfirmationDialog(
      context: context,
      title: AppLocalizations.of(context).contactChangeDeleteTitle,
      content: (AppLocalizations.of(context).contactChangeDeleteDialogContent(email, name)),
      positiveButton: AppLocalizations.of(context).delete,
      positiveAction: () {
        final contactAddedObservable = new Observable<ContactChangeState>(_contactChangeBloc.state);
        contactAddedObservable.listen((state) => _handleContactChanged(context, state));
        _contactChangeBloc.dispatch(DeleteContact(_contactId));
      },
      navigatable: Navigatable(Type.contactDeleteDialog),
    );
  }

  _handleContactChanged(BuildContext context, ContactChangeState state) {
    if (state is ContactChangeStateSuccess) {
      if (state.delete) {
        showToast(_getDeleteToastString(context));
        _navigation.pop(context);
      }
    } else if (state is ContactChangeStateFailure && state.error == contactDelete) {
      showToast(getDeleteFailedToastString(context));
    }
  }

  String _getDeleteToastString(BuildContext context) {
    return AppLocalizations.of(context).contactChangeDeleteToast;
  }

  String getDeleteFailedToastString(BuildContext context) {
    return AppLocalizations.of(context).contactChangeDeleteFailedToast;
  }
}
