/*
 *
 *  * OPEN-XCHANGE legal information
 *  *
 *  * All intellectual property rights in the Software are protected by
 *  * international copyright laws.
 *  *
 *  *
 *  * In some countries OX, OX Open-Xchange and open xchange
 *  * as well as the corresponding Logos OX Open-Xchange and OX are registered
 *  * trademarks of the OX Software GmbH group of companies.
 *  * The use of the Logos is not covered by the Mozilla Public License 2.0 (MPL 2.0).
 *  * Instead, you are allowed to use these Logos according to the terms and
 *  * conditions of the Creative Commons License, Version 2.5, Attribution,
 *  * Non-commercial, ShareAlike, and the interpretation of the term
 *  * Non-commercial applicable to the aforementioned license is published
 *  * on the web site https://www.open-xchange.com/terms-and-conditions/.
 *  *
 *  * Please make sure that third-party modules and libraries are used
 *  * according to their respective licenses.
 *  *
 *  * Any modifications to this package must retain all copyright notices
 *  * of the original copyright holder(s) for the original code used.
 *  *
 *  * After any such modifications, the original and derivative code shall remain
 *  * under the copyright of the copyright holder(s) and/or original author(s) as stated here:
 *  * https://www.open-xchange.com/legal/. The contributing author shall be
 *  * given Attribution for the derivative code and a license granting use.
 *  *
 *  * Copyright (C) 2016-2020 OX Software GmbH
 *  * Mail: info@open-xchange.com
 *  *
 *  *
 *  * This Source Code Form is subject to the terms of the Mozilla Public
 *  * License, v. 2.0. If a copy of the MPL was not distributed with this
 *  * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *  *
 *  * This program is distributed in the hope that it will be useful, but
 *  * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  * or FITNESS FOR A PARTICULAR PURPOSE. See the Mozilla Public License 2.0
 *  * for more details.
 *
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
import 'dart:io';

const keyContacts = 'contacts';
const keyId = 'id';
const keyName = 'name';
const keyEmail = 'email';
const keyServer = 'server';
const keyPassword = 'password';
const keyProviders = 'providers';
const keyUsername = 'username';

class Providers {
  List<Provider> providerList;

  Providers({this.providerList});

  Providers.fromJson(Map<String, dynamic> json) {
    if (json[keyProviders] != null) {
      providerList = List<Provider>();
      json[keyProviders].forEach((value) {
        providerList.add(Provider.fromJson(value));
      });
    }
  }
}

class Provider {
  String id;
  String name;
  String email;
  String server;
  String password;
  List<Contact> contacts;

  Provider({this.id, this.name, this.email, this.server, this.password, this.contacts});

  Provider.fromJson(Map<String, dynamic> json) {
    id = json[keyId];
    name = json[keyName];
    email = json[keyEmail];
    server = json[keyServer];
    password = json[keyPassword];

    if (json[keyContacts] != null) {
      contacts = List<Contact>();
      json[keyContacts].forEach((value) {
        contacts.add(Contact.fromJson(value));
      });
    }
  }
}

class Contact {
  String id;
  String username;
  String email;

  Contact({this.id, this.username, this.email});

  Contact.fromJson(Map<String, dynamic> json) {
    id = json[keyId];
    username = json[keyUsername];
    email = json[keyEmail];
  }
}

/// The credential.json file is not part of the repository as it contains login data like emails and passwords. Please lookup the required JSON format
/// under https://github.com/open-xchange/ox-coi/wiki/Testing
Future<List<Provider>> loadTestProviders() async {
  final path = 'test_driver/setup/credential.json';
  Map<String, dynamic> json = await File(path).readAsString().then((jsonStr) => jsonDecode(jsonStr)).catchError((error) => throw FileSystemException("Couldn't load credentials file", path));
  Providers providers = Providers.fromJson(json);
  return providers.providerList;
}
