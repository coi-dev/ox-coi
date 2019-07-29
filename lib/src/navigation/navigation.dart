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

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:ox_coi/main.dart';
import 'package:ox_coi/src/antiMobbing/anti_mobbing_list.dart';
import 'package:ox_coi/src/chat/chat_create.dart';
import 'package:ox_coi/src/contact/contact_blocked_list.dart';
import 'package:ox_coi/src/contact/contact_change.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/settings/settings.dart';
import 'package:ox_coi/src/settings/settings_about.dart';
import 'package:ox_coi/src/settings/settings_anti_mobbing.dart';
import 'package:ox_coi/src/settings/settings_chat.dart';
import 'package:ox_coi/src/settings/settings_debug.dart';
import 'package:ox_coi/src/settings/settings_security.dart';
import 'package:ox_coi/src/user/user_account_settings.dart';

class Navigation {
  final Logger _logger = Logger("navigation");

  static const String root = '/';
  static const String contactsAdd = '/contacts/add';
  static const String settings = '/settings';
  static const String settingsAccount = '/settings/account';
  static const String settingsSecurity = '/settings/security';
  static const String settingsAbout = '/settings/about';
  static const String settingsChat = '/settings/chat';
  static const String settingsAntiMobbing = '/settings/antiMobbing';
  static const String settingsAntiMobbingList = '/settings/antiMobbingList';
  static const String settingsDebug = '/settings/debug';
  static const String chatCreate = '/chat/create';
  static const String contactsBlocked = '/contacts/blocked';

  final Map<String, WidgetBuilder> routeMapping = {
    root: (context) => OxCoi(),
    contactsAdd: (context) => ContactChange(
          contactAction: ContactAction.add,
        ),
    settings: (context) => Settings(),
    settingsAccount: (context) => UserAccountSettings(),
    settingsSecurity: (context) => SettingsSecurity(),
    settingsAbout: (context) => SettingsAbout(),
    settingsChat: (context) => SettingsChat(),
    settingsAntiMobbing: (context) => SettingsAntiMobbing(),
    settingsAntiMobbingList: (context) => AntiMobbingList(),
    settingsDebug: (context) => SettingsDebug(),
    chatCreate: (context) => ChatCreate(),
    contactsBlocked: (context) => ContactBlockedList(),
  };

  static Navigation _instance;

  Queue<Navigatable> _navigationStack = Queue();

  Navigatable get current => _navigationStack.last;

  set current(Navigatable navigatable) {
    _logger.info("Set current: ${navigatable.tag}");
    _navigationStack.add(navigatable);
  }

  factory Navigation() => _instance ??= new Navigation._internal();

  Navigation._internal();

  Future push(BuildContext context, MaterialPageRoute route) {
    _logger.info("Push");
    Navigatable savedNavigatable = _navigationStack.last;
    return Navigator.push(context, route).then((value) {
      current = savedNavigatable;
    });
  }

  void pushNamed(BuildContext context, String routeName, {Object arguments}) {
    _logger.info("Push named");
    Navigatable savedNavigatable = _navigationStack.last;
    Navigator.pushNamed(context, routeName, arguments: arguments).then((value) {
      current = savedNavigatable;
    });
  }

  void pushAndRemoveUntil(BuildContext context, Route newRoute, RoutePredicate predicate, Navigatable newParent) {
    _logger.info("Push and pop multiple");
    Navigator.pushAndRemoveUntil(context, newRoute, predicate).then((value) {
      current = newParent;
    });
  }

  void pushReplacement(BuildContext context, Route newRoute) {
    _logger.info("Push and replace");
    var previousIndex = _navigationStack.length - 2;
    Navigatable savedNavigatable = _navigationStack.elementAt(previousIndex);
    Navigator.pushReplacement(context, newRoute).then((value) {
      current = savedNavigatable;
    });
  }

  void pop(BuildContext context, {Object result}) {
    _logger.info("Pop latest");
    Navigator.pop(context, result);
  }

  void popUntil(BuildContext context, RoutePredicate predicate) {
    _logger.info("Pop multiple");
    Navigator.popUntil(context, predicate);
  }
}
