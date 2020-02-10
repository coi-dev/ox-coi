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
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/material.dart';
import 'package:ox_coi/src/contact/contact_item_event_state.dart';
import 'package:ox_coi/src/data/contact_extension.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/utils/text.dart';

class ContactItemBloc extends Bloc<ContactItemEvent, ContactItemState> {
  Repository<Contact> _contactRepository = RepositoryManager.get(RepositoryType.contact);

  ContactItemBloc();

  @override
  ContactItemState get initialState => ContactItemStateInitial();

  @override
  Stream<ContactItemState> mapEventToState(ContactItemEvent event) async* {
    if (event is RequestContact) {
      yield ContactItemStateLoading();

      try {
        _setupContact(contactId: event.contactId, previousContactId: event.previousContactId);

      } catch (error) {
        yield ContactItemStateFailure(error: error.toString());
      }

    } else if (event is ContactLoaded) {
      yield ContactItemStateSuccess(
          name: event.name,
          email: event.email,
          color: event.color,
          isVerified: event.isVerified,
          imagePath: event.imagePath,
          phoneNumbers: event.phoneNumbers,
          headerText: event.headerText);
    }
  }

  void _setupContact({@required int contactId, @required int previousContactId}) async {
    final Contact contact = _contactRepository.get(contactId);
    final String name = await contact.getName();
    final String email = await contact.getAddress();
    final int colorValue = await contact.getColor();
    final bool isVerified = await contact.isVerified();
    final String phoneNumbers = contact.get(ContactExtension.contactPhoneNumber);
    final Color color = rgbColorFromInt(colorValue);

    String headerText = name.getFirstCharacter()?.toUpperCase();
    if (previousContactId != null) {
      final String previousName = await _contactRepository.get(previousContactId).getName();
      headerText = headerText == previousName.getFirstCharacter()?.toUpperCase() ? null : headerText;
    }

    String imagePath;
    if (Contact.idSelf == contact.id) {
      headerText = L10n.get(L.contactOwnCardGroupHeaderText);
      imagePath = await contact.getProfileImage();
    } else {
      imagePath = contact.get(ContactExtension.contactAvatar);
    }

    add(ContactLoaded(
      name: name,
      email: email,
      color: color,
      isVerified: isVerified,
      imagePath: imagePath,
      phoneNumbers: phoneNumbers,
      headerText: headerText,
    ));
  }

}
