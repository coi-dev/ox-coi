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

import 'dart:async';

import 'package:rxdart/rxdart.dart';

enum Type {
  publish,
  behavior,
  replay,
}

abstract class BaseRepositoryEventStreamHandler {
  final Type type;

  final Function onData;

  Function onError;

  // ignore: close_sinks
  StreamController _streamController; // Closed by flutter-deltachat-core/lib/delta_chat_core.dart

  get streamController => _streamController;

  BaseRepositoryEventStreamHandler(this.type, this.onData, [this.onError]) {
    switch (type) {
      case Type.publish:
        _streamController = PublishSubject();
        break;
      case Type.behavior:
        _streamController = BehaviorSubject();
        break;
      case Type.replay:
        _streamController = ReplaySubject();
        break;
    }
  }
}

class RepositoryEventStreamHandler extends BaseRepositoryEventStreamHandler {
  final int eventId;

  RepositoryEventStreamHandler(Type type, this.eventId, onData, [onError]) : super(type, onData, onError);

}

class RepositoryMultiEventStreamHandler extends BaseRepositoryEventStreamHandler {
  final List<int> eventIds;

  RepositoryMultiEventStreamHandler(Type type, this.eventIds, onData, [onError]) : super(type, onData, onError);
}
