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
import 'dart:math';
import 'dart:typed_data';

import 'package:ox_coi/src/security/security_generator.dart';
import 'package:pointycastle/export.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

void main() {
  test("secure randoms", () {
    final bytes = generateRandomBytes();
    print("Bytes size (16): ${bytes.length}");
    final bytes32 = generateRandomBytes(32);
    print("Bytes size (32): ${bytes32.length}");
  });

  test('p256dh', () {
    var domainParameters = ECCurve_secp256r1();
    var params = ECKeyGeneratorParameters(domainParameters);
    var generator = ECKeyGenerator();
    generator.init(ParametersWithRandom(params, getSecureRandom()));
    var generateKeyPair = generator.generateKeyPair();
    ECPublicKey publicKey = generateKeyPair.publicKey;
    print("Public Point: ${publicKey.Q}");
    var bytes = utf8.encode(publicKey.Q.toString());
    var base64Str = base64UrlEncode(bytes);
    ECPrivateKey privateKey = generateKeyPair.privateKey;
    print("Base64: $base64Str");
    print("Private Point: ${privateKey.d}");
  });

  test('UUID', () {
    var uuid = new Uuid();
    print("UUID ${uuid.v4()}");
  });
}

SecureRandom getSecureRandom() {
  var secureRandom = FortunaRandom();
  var random = Random.secure();
  List<int> seeds = [];
  for (int i = 0; i < 32; i++) {
    seeds.add(random.nextInt(255));
  }
  secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
  return secureRandom;
}