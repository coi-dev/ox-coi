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
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/chat/chat_create_mixin.dart';
import 'package:ox_coi/src/chat/chat_profile_group_contact_item.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/key_generator.dart';
import 'package:ox_coi/src/widgets/list_group_header.dart';

import 'contact_item.dart';
import 'contact_item_selectable.dart';

class ContactListContent extends StatelessWidget with ChatCreateMixin {
  final dynamic contactElement;
  final bool hasHeader;
  final bool isDismissible;
  final bool isSelectable;
  final bool isGroupMember;
  final bool showMoreButton;
  final int chatId;
  final ContactItemType contactItemType;
  final List<int> selectedContacts;
  final Function callback;

  ContactListContent({
    @required this.contactElement,
    this.hasHeader = false,
    this.isDismissible = false,
    this.isSelectable = false,
    this.isGroupMember = false,
    this.showMoreButton,
    this.chatId,
    this.contactItemType,
    this.selectedContacts,
    this.callback,
  });

  @override
  Widget build(BuildContext context) {
    final key = getKeyFromContactElement(contactElement);
    final idOrHeader = extractId(key);
    final isId = idOrHeader is int;

    if (isDismissible && isId) {
      final contactItem = ContactItem(contactId: idOrHeader, key: key);
      final chatIcon = AdaptiveIcon(icon: IconSource.chat, color: CustomTheme.of(context).white);

      return Dismissible(
        key: key,
        confirmDismiss: (direction) {
          createChatFromContact(context, idOrHeader);
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
    } else if (isSelectable && isId) {
      final bool isSelected = selectedContacts.contains(idOrHeader);
      return ContactItemSelectable(
        contactId: idOrHeader,
        onTap: _onContactTapped,
        isSelected: isSelected,
        key: key,
      );
    } else if (isId && isGroupMember) {
      return ChatProfileGroupContactItem(
        chatId: chatId,
        contactId: idOrHeader,
        showMoreButton: showMoreButton,
        key: key,
      );
    } else if (isId) {
      return ContactItem(
        contactId: idOrHeader,
        contactItemType: contactItemType,
        onTap: _onContactTapped,
        key: key,
      );
    } else if (hasHeader && idOrHeader is String) {
      return ListGroupHeader(
        key: key,
        text: idOrHeader,
        padding: const EdgeInsets.only(
            top: dimension24dp, bottom: groupHeaderBottomPadding, left: groupHeaderHorizontalPadding, right: groupHeaderHorizontalPadding),
        fontWeightDelta: 2,
        fontSizeDelta: 3,
      );
    } else {
      return Container();
    }
  }

  _onContactTapped(int id) {
    callback(id);
  }
}
