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

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

final String _tableContactExtension = 'contact_extension';
final String _columnId = 'id';
final String _columnContactId = 'contactId';
final String _columnPhoneNumbers = 'phoneNumbers';
final String _columnAvatar = 'avatar';

class ContactExtension {
  static const String contactPhoneNumber = "contact_extension_phoneNumber";
  static const String contactAvatar = "contact_extentions_avatar";

  int id;
  int contactId;
  String phoneNumbers;
  String avatar;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      _columnContactId: contactId,
      _columnPhoneNumbers: phoneNumbers,
      _columnAvatar: avatar,
    };
    if (id != null) {
      map[_columnId] = id;
    }
    return map;
  }

  ContactExtension(this.contactId, {this.phoneNumbers, this.avatar});

  ContactExtension.fromMap(Map<String, dynamic> map) {
    id = map[_columnId];
    contactId = map[_columnContactId];
    phoneNumbers = map[_columnPhoneNumbers];
    avatar = map[_columnAvatar];
  }

  static List<String> getPhoneNumberList(String phoneNumbers) {
    if (phoneNumbers == null) {
      return List<String>();
    }
    return phoneNumbers.trim().split("\n");
  }
}

class ContactExtensionProvider {
  static ContactExtensionProvider _instance;

  Database _db;

  String get path => _db.path;

  factory ContactExtensionProvider() => _instance ??= new ContactExtensionProvider._internal();

  ContactExtensionProvider._internal();

  Future<void> open(String name) async {
    final applicationSupportDir = await getApplicationSupportDirectory();
    final dbPath = "${applicationSupportDir.path}/$name";
    _db = await openDatabase(dbPath);
  }

  Future createTable() async {
    await _db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableContactExtension ( 
          $_columnId INTEGER PRIMARY KEY, 
          $_columnContactId INTEGER NOT NULL,
          $_columnPhoneNumbers TEXT,
          $_columnAvatar TEXT);
        ''');
  }

  Future<ContactExtension> insert(ContactExtension contactExtension) async {
    contactExtension.id = await _db.insert(_tableContactExtension, contactExtension.toMap());
    return contactExtension;
  }

  Future<int> update(ContactExtension contactExtension) async {
    return await _db.update(
      _tableContactExtension,
      contactExtension.toMap(),
      where: '$_columnId = ?',
      whereArgs: [contactExtension.id],
    );
  }

  Future<int> delete({int id = -1, int contactId = -1}) async {
    final whereColumn = _getWhereColumn(id, contactId);
    final whereId = _getWhereId(id, contactId);
    if (whereId <= 0) {
      throw ArgumentError("Either id or contactId must be set to a value > 0");
    }
    return await _db.delete(_tableContactExtension, where: '$whereColumn = ?', whereArgs: [whereId]);
  }

  Future<ContactExtension> get({int id = -1, int contactId = -1}) async {
    final whereColumn = _getWhereColumn(id, contactId);
    final whereId = _getWhereId(id, contactId);
    if (whereId <= 0) {
      throw ArgumentError("Either id or contactId must be set to a value > 0");
    }

    List<Map> maps = await _db.query(
      _tableContactExtension,
      columns: [_columnId, _columnContactId, _columnPhoneNumbers, _columnAvatar],
      where: '$whereColumn = ?',
      whereArgs: [whereId],
    );
    if (maps.length > 0) {
      return ContactExtension.fromMap(maps.first);
    }
    return null;
  }

  String _getWhereColumn(int id, int contactId) {
    return contactId > 0 ? _columnContactId : _columnId;
  }

  int _getWhereId(int id, int contactId) {
    return contactId > 0 ? contactId : id;
  }

  Future close() async => _db.close();
}
