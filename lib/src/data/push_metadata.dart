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

import 'package:flutter/widgets.dart';

class PushSubscribeMetaData {
  String client;
  String device;
  String msgtype;
  PushSubscribeMetaDataResource resource;

  PushSubscribeMetaData({@required this.client, @required this.device, this.msgtype = "chat", @required this.resource});

  PushSubscribeMetaData.fromJson(Map<String, dynamic> json)
      : client = json['client'],
        device = json['device'],
        msgtype = json['msgtype'],
        resource = json['resource'] != null ? PushSubscribeMetaDataResource.fromJson(json['resource']) : null;

  Map<String, dynamic> toJson() => {
        'client': client,
        'device': device,
        'msgtype': msgtype,
        'resource': resource.toJson(),
      };

  @override
  String toString() {
    return toJson().toString();
  }
}

class PushSubscribeMetaDataResource {
  String endpoint;
  PushSubscribeMetaDataResourceKeys keys;

  PushSubscribeMetaDataResource({@required this.endpoint, @required this.keys});

  PushSubscribeMetaDataResource.fromJson(Map<String, dynamic> json)
      : endpoint = json['endpoint'],
        keys = json['keys'] != null ? PushSubscribeMetaDataResourceKeys.fromJson(json['keys']) : null;

  Map<String, dynamic> toJson() => {
        'endpoint': endpoint,
        'keys': keys.toJson(),
      };

  @override
  String toString() {
    return toJson().toString();
  }
}

class PushSubscribeMetaDataResourceKeys {
  String p256dh;
  String auth;

  PushSubscribeMetaDataResourceKeys({@required this.p256dh, @required this.auth});

  PushSubscribeMetaDataResourceKeys.fromJson(Map<String, dynamic> json)
      : p256dh = json['p256dh'],
        auth = json['auth'];

  Map<String, dynamic> toJson() => {
        'p256dh': p256dh,
        'auth': auth,
      };

  @override
  String toString() {
    return toJson().toString();
  }
}
