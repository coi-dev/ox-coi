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
import 'package:ox_talk/main.dart';
import 'package:ox_talk/src/chat/create_chat.dart';
import 'package:ox_talk/src/contact/contact_change.dart';
import 'package:ox_talk/src/profile/edit_account_settings.dart';

class Navigation {
  static const String ROUTES_ROOT = '/';
  static const String ROUTES_CONTACT_ADD = '/contactAdd';
  static const String ROUTES_PROFILE_EDIT = '/profileEdit';
  static const String ROUTES_CHAT_CREATE = '/chatCreate';

  static Navigation _instance;

  factory Navigation() => _instance ??= new Navigation._internal();

  Navigation._internal();

  final Map<String, WidgetBuilder> routeMapping = {
    ROUTES_ROOT: (context) => OxTalk(),
    ROUTES_CONTACT_ADD: (context) => ContactChange(
          contactAction: ContactAction.add,
        ),
    ROUTES_PROFILE_EDIT: (context) => EditAccountSettings(),
    ROUTES_CHAT_CREATE: (context) => CreateChat(),
  };

  void push(BuildContext context, MaterialPageRoute route, String routeToPage) {
    debugPrint("Navigation.push to $routeToPage");
    Navigator.push(context, route);
  }

  void pushNamed(BuildContext context, String routeName, {Object arguments}) {
    debugPrint("Navigation.pushNamed to $routeName");
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  void pop(BuildContext context, String popFromPage) {
    debugPrint("Navigation.pop from $popFromPage");
    Navigator.pop(context);
  }

  void pushAndRemoveUntil(BuildContext context, Route newRoute, RoutePredicate predicate, String routeToPage) {
    debugPrint("Navigation.pushAndRemoveUntil to $routeToPage until $predicate");
    Navigator.pushAndRemoveUntil(context, newRoute, predicate);
  }

  void pushReplacement(BuildContext context, Route newRoute, String routeToPage) {
    debugPrint("Navigation.pushReplacement to $routeToPage");
    Navigator.pushReplacement(context, newRoute);
  }
}
