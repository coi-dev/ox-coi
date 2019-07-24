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
import 'package:ox_coi/src/chatlist/chat_list.dart';
import 'package:ox_coi/src/contact/contact_list.dart';
import 'package:ox_coi/src/main/root_child.dart';
import 'package:ox_coi/src/user/user_profile.dart';
import 'package:ox_coi/src/widgets/view_switcher.dart';

class Root extends StatefulWidget {
  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  int _selectedIndex = 0;
  var childList = List<RootChild>();

  _RootState() {
    childList.addAll([new ChatList(state: this), new ContactList(state: this), new UserProfile(state: this)]);
  }

  @override
  Widget build(BuildContext context) {
    RootChild child = childList[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: child.getColor(),
        title: Text(child.getTitle(context)),
        actions: child.getActions(context),
        elevation: child.getElevation(),
      ),
      body: WillPopScope(
        child: ViewSwitcher(child),
        onWillPop: _onWillPop,
      ),
      bottomNavigationBar: _buildBottomBar(),
      floatingActionButton: child.getFloatingActionButton(context),
    );
  }

  Future<bool> _onWillPop() {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: getBottomBarItems(),
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }

  List<BottomNavigationBarItem> getBottomBarItems() {
    var bottomBarItems = List<BottomNavigationBarItem>();
    childList.forEach((item) => bottomBarItems.add(BottomNavigationBarItem(
          icon: Icon(item.getNavigationIcon()),
          title: Text(item.getNavigationText(context)),
        )));
    return bottomBarItems;
  }

  _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
