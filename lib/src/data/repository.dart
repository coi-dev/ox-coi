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
import 'dart:collection';

import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:ox_coi/src/data/repository_stream_handler.dart';

typedef T RepositoryItemCreator<T extends Base>(int id);

abstract class Repository<T extends Base> {
  final RepositoryItemCreator<T> _creator;
  final int id;
  final LinkedHashMap<int, T> _items = LinkedHashMap();
  DeltaChatCore _core = DeltaChatCore();

  Repository(this._creator, [this.id]);

  T get(int id) {
    return _items[id];
  }

  List<T> getAll() {
    return _items.values.toList();
  }

  List<int> getAllIds() {
    return _items.keys.toList();
  }

  List<int> getAllLastUpdateValues() {
    return _items.values.map<int>((Base item) => item.lastUpdate).toList();
  }

  void _set(int id, T value) {
    _items[id] = value;
  }

  update({int id, List<int> ids}) {
    if (id != null && id > 0) {
      _update(id);
    } else if (ids != null && ids.isNotEmpty) {
      ids.forEach((id) {
        _update(id);
      });
    }
  }

  void _update(int id) {
    Base item = _items[id];
    if (item == null) {
      _items[id] = _creator(id);
    } else {
      _items
        ..remove(id)
        ..[id] = item;
    }
  }

  putIfAbsent({int id, List<int> ids}) {
    if (id != null && id > 0) {
      _putIfAbsent(id);
    } else if (ids != null && ids.isNotEmpty) {
      ids.forEach((id) {
        _putIfAbsent(id);
      });
    }
  }

  void _putIfAbsent(int id) {
    _items.putIfAbsent(id, () => _creator(id));
  }

  remove({int id, List<int> ids}) {
    if (id != null && id > 0) {
      _items.remove(id);
    } else if (ids != null && ids.isNotEmpty) {
      ids.forEach((id) {
        _items.remove(id);
      });
    }
  }

  clear() {
    _items.clear();
  }

  int length() {
    return _items.length;
  }

  bool contains(int id) {
    return _items.containsKey(id);
  }

  Future<void> addListener(BaseRepositoryEventStreamHandler streamHandler) async {
    if (streamHandler is RepositoryEventStreamHandler) {
      await _setupCoreListener(streamHandler, streamHandler.eventId);
    } else if (streamHandler is RepositoryMultiEventStreamHandler) {
      for (int eventId in streamHandler.eventIds) {
        await _setupCoreListener(streamHandler, eventId);
      }
    }
    streamHandler.streamController.stream.listen((event) async {
      await onData(event);
      streamHandler.onData();
    }).onError((error) {
      error(error);
      if (streamHandler.onError != null) {
        onError(error);
      }
    });
  }

  Future _setupCoreListener(BaseRepositoryEventStreamHandler streamHandler, int eventId) async {
    int listenerId = await _core.listen(eventId, streamHandler.streamController);
    if (streamHandler is RepositoryEventStreamHandler) {
      streamHandler.listenerId = listenerId;
    } else if (streamHandler is RepositoryMultiEventStreamHandler) {
      streamHandler.listenerIds.add(listenerId);
    }
  }

  void removeListener(BaseRepositoryEventStreamHandler streamHandler) {
    if (streamHandler is RepositoryEventStreamHandler) {
      tearDownCoreListener(streamHandler.eventId, streamHandler.listenerId);
    } else if (streamHandler is RepositoryMultiEventStreamHandler) {
      for (int index = 0; index < streamHandler.listenerIds.length; index++) {
        tearDownCoreListener(streamHandler.eventIds[index], streamHandler.listenerIds[index]);
      }
    }
  }

  void tearDownCoreListener(int eventId, int listenerId) {
    _core.removeListener(eventId, listenerId);
  }
  
  void transferTo(Repository<T> repository, int id) {
    var value = _items[id];
    if (value != null) {
      repository._set(id, value);
      _items.remove(id);
    }
  }

  onData(Event event) {}

  onError(dynamic error) {}
}
