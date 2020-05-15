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
import 'package:ox_coi/src/anti_mobbing/anti_mobbing_list.dart';
import 'package:ox_coi/src/chat/chat_create.dart';
import 'package:ox_coi/src/contact/contact_blocked_list.dart';
import 'package:ox_coi/src/contact/contact_change.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/dynamic_screen/widgets/dynamic_screen.dart';
import 'package:ox_coi/src/settings/settings.dart';
import 'package:ox_coi/src/settings/settings_about.dart';
import 'package:ox_coi/src/settings/settings_anti_mobbing.dart';
import 'package:ox_coi/src/settings/settings_appearance.dart';
import 'package:ox_coi/src/settings/settings_chat.dart';
import 'package:ox_coi/src/settings/settings_debug.dart';
import 'package:ox_coi/src/settings/settings_encryption.dart';
import 'package:ox_coi/src/settings/settings_notifications.dart';
import 'package:ox_coi/src/user/user_account_settings.dart';

class Navigation {
  final Logger _logger = Logger("navigation");

  static const String root = '/';
  static const String contactsAdd = '/contacts/add';
  static const String settings = '/settings';
  static const String settingsAccount = '/settings/account';
  static const String settingsEncryption = '/settings/encryption';
  static const String settingsAbout = '/settings/about';
  static const String settingsChat = '/settings/chat';
  static const String settingsAntiMobbing = '/settings/antiMobbing';
  static const String settingsAppearance = '/settings/appearance';
  static const String settingsNotifications = '/settings/notifications';
  static const String settingsAntiMobbingList = '/settings/antiMobbingList';
  static const String settingsDebug = '/settings/debug';
  static const String chatCreate = '/chat/create';
  static const String contactsBlocked = '/contacts/blocked';

  final Map<String, WidgetBuilder> routesMapping = {
    root: (context) => OxCoi(),
    contactsAdd: (context) => ContactChange(contactAction: ContactAction.add),
    settings: (context) => Settings(),
    settingsAccount: (context) => UserAccountSettings(),
    settingsEncryption: (context) => SettingsEncryption(),
    settingsAbout: (context) => SettingsAbout(),
    settingsChat: (context) => SettingsChat(),
    settingsAntiMobbing: (context) => SettingsAntiMobbing(),
    settingsAntiMobbingList: (context) => AntiMobbingList(),
    settingsAppearance: (context) => SettingsAppearance(),
    settingsNotifications: (context) => SettingsNotifications(),
    settingsDebug: (context) => SettingsDebug(),
    chatCreate: (context) => ChatCreate(),
    contactsBlocked: (context) => ContactBlockedList(),
  };

  static Navigation _instance;

  Queue<Navigatable> _navigationStack = Queue();

  Navigatable get current => _navigationStack.isEmpty ? null : _navigationStack.last;

  bool allowBackNavigation = true;

  set current(Navigatable navigatable) {
    _logger.info("Set current: ${navigatable.tag}");
    _navigationStack.add(navigatable);
  }

  factory Navigation() => _instance ??= new Navigation._internal();

  Navigation._internal();

  Future push(BuildContext context, MaterialPageRoute route) {
    _logger.info("Push");
    if (context == null) {
      logActionAbort();
      return null;
    }
    Navigatable savedNavigatable = _navigationStack.last;
    return Navigator.push(context, route).then((value) {
      current = savedNavigatable;
    });
  }

  void pushNamed(BuildContext context, String routeName, {Object arguments}) {
    _logger.info("Push named");
    if (context == null) {
      logActionAbort();
      return null;
    }
    Navigatable savedNavigatable = _navigationStack.last;
    Navigator.pushNamed(context, routeName, arguments: arguments).then((value) {
      current = savedNavigatable;
    });
  }

  void pushAndRemoveUntil(BuildContext context, Route newRoute, RoutePredicate predicate, Navigatable newParent) {
    _logger.info("Push and pop multiple");
    if (context == null) {
      logActionAbort();
      return null;
    }
    Navigator.pushAndRemoveUntil(context, newRoute, predicate).then((value) {
      var newCurrent = _navigationStack.lastWhere((navigatable) {
        if (newParent.type == Type.rootChildren) {
          return navigatable.type == Type.chatList || navigatable.type == Type.contactList || navigatable.type == Type.profile;
        } else {
          return false;
        }
      }, orElse: () {
        return newParent;
      });
      current = newCurrent;
    });
  }

  void pushReplacement(BuildContext context, Route newRoute) {
    _logger.info("Push and replace");
    if (context == null) {
      logActionAbort();
      return null;
    }
    var previousIndex = _navigationStack.length - 2;
    Navigatable savedNavigatable = _navigationStack.elementAt(previousIndex);
    Navigator.pushReplacement(context, newRoute).then((value) {
      current = savedNavigatable;
    });
  }

  void pop(BuildContext context, {Object result}) {
    _logger.info("Pop latest");
    if (context == null) {
      logActionAbort();
      return null;
    }
    Navigator.pop(context, result);
  }

  void popUntil(BuildContext context, RoutePredicate predicate) {
    _logger.info("Pop multiple");
    if (context == null) {
      logActionAbort();
      return null;
    }
    Navigator.popUntil(context, predicate);
  }

  void popUntilRoot(BuildContext context) {
    popUntil(context, ModalRoute.withName(Navigation.root));
  }

  bool hasElements() {
    return _navigationStack.isNotEmpty;
  }

  void logActionAbort() {
    _logger.info("No context. Aborting");
  }
}
