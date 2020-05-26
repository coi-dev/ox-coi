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

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:ox_coi/src/customer/model/customer_chat.dart';
import 'package:ox_coi/src/customer/model/customer_config.dart';
import 'package:ox_coi/src/dynamic_screen/model/dynamic_screen.dart';
import 'package:ox_coi/src/platform/preferences.dart';
import 'package:ox_coi/src/utils/constants.dart';

class Customer {

  CustomerConfig _config;
  DynamicScreenModel _onboardingModel;
  bool _needsOnboarding;

  final _logger = Logger("customer");

  static Customer _instance;
  factory Customer() => _instance ??= Customer._internal();
  Customer._internal();

  Future<void> configureAsync() async {
    await _configureCustomerAsync();
  }

  Future<void> configureOnboardingAsync() async {
    try {
      Map<String, dynamic> jsonFile = await rootBundle.loadString(customerOnboardingConfigPath).then((jsonStr) => jsonDecode(jsonStr));
      _onboardingModel = DynamicScreenModel.fromJson(jsonFile);
    } catch (error) {
      _logger.shout("[Configure Onboarding] ** ERROR **: ${error.toString()}");
      throw(error.toString());
    }
  }

  Future<void> _configureCustomerAsync() async {
    try {
      Map<String, dynamic> jsonFile = await rootBundle.loadString(customerConfigPath).then((jsonStr) => jsonDecode(jsonStr));
      _config = CustomerConfig.fromJson(jsonFile);
      _needsOnboarding = await getPreference(preferenceNeedsOnboarding) as bool ?? true;

    } catch (error) {
      _logger.shout("[Configure Customer] ** ERROR **: ${error.toString()}");
      throw(error.toString());
    }
  }

  // Customer Config

  static CustomerConfig get config {
    return Customer()._config;
  }

  static String get name {
    return Customer.config.name;
  }

  static List<CustomerChat> get chats {
    return Customer.config.chats;
  }

  static List<String> get icons {
    return Customer.config.icons;
  }

  // Onboarding

  static DynamicScreenModel get onboardingModel {
    return Customer()._onboardingModel;
  }

  static bool get hasOnboarding {
    return Customer.onboardingModel != null;
  }

  static bool get needsOnboarding {
    return Customer()._needsOnboarding;
  }
  static set needsOnboarding(bool value) {
    setPreference(preferenceNeedsOnboarding, value);
    Customer()._needsOnboarding = value;
  }

}