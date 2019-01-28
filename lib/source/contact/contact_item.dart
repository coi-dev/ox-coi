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
import 'package:ox_talk/source/contact/contact_change.dart';
import 'package:ox_talk/source/contact/contact_item_bloc.dart';
import 'package:ox_talk/source/contact/contact_item_event.dart';
import 'package:ox_talk/source/contact/contact_item_state.dart';
import 'package:ox_talk/source/ui/dimensions.dart';

class ContactItem extends StatefulWidget {
  final int _contactId;

  ContactItem(this._contactId, key) : super(key: Key(key));

  @override
  _ContactItemState createState() => _ContactItemState();
}

class _ContactItemState extends State<ContactItem> {
  ContactItemBloc _contactBloc;

  @override
  void initState() {
    super.initState();
    _contactBloc = ContactItemBloc(widget._contactId);
    _contactBloc.dispatch(RequestContact());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: _contactBloc,
        builder: (context, state) {
          if (state is ContactItemStateSuccess) {
            return buildGestureDetector(state.name, state.email);
          } else if (state is ContactItemStateFailure) {
            return new Text(state.error);
          } else {
            return new Container();
          }
        });
  }

  GestureDetector buildGestureDetector(String name, String email) {
    return GestureDetector(
      onTap: () => onContactTapped(name, email),
      child: Padding(
        padding: const EdgeInsets.only(top: Dimensions.listItemPaddingSmall),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              radius: 24.0,
              child: Text(getInitials(name, email)),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.listItemPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    name != null
                        ? Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),
                          )
                        : Container(),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: Dimensions.listItemPaddingSmall),
                      child: email != null
                          ? Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.black45),
                            )
                          : Container(),
                    ),
                    Divider(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String getInitials(String name, String email) {
    if (name != null && name.isNotEmpty) {
      return name.substring(0, 1);
    }
    if (email != null && email.isNotEmpty) {
      return email.substring(0, 1);
    }
    return "";
  }

  onContactTapped(String name, String email) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ContactChange(
                add: false,
                id: widget._contactId,
                email: email,
                name: name,
              )),
    );
  }
}
