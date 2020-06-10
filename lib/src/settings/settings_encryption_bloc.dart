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

import 'package:bloc/bloc.dart';
import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:ox_coi/src/platform/files.dart';
import 'package:ox_coi/src/settings/settings_encryption_event_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

enum SettingsEncryptionType {
  exportKeys,
  importKeys,
  initiateKeyTransfer,
}

class SettingsEncryptionBloc extends Bloc<SettingsEncryptionEvent, SettingsEncryptionState> {
  PublishSubject<Event> _keyActionSubject = new PublishSubject();
  DeltaChatCore _core = DeltaChatCore();
  bool _listenersRegistered = false;

  @override
  SettingsEncryptionState get initialState => SettingsEncryptionStateInitial();

  @override
  Stream<SettingsEncryptionState> mapEventToState(SettingsEncryptionEvent event) async* {
    if (event is ExportKeys) {
      yield SettingsEncryptionStateLoading(type: SettingsEncryptionType.exportKeys);
      try {
        if (await _checkPermissions()) {
          _exportImportKeys(SettingsEncryptionType.exportKeys);
        }
      } catch (error) {
        yield SettingsEncryptionStateFailure(error: error);
      }
    } else if (event is ImportKeys) {
      yield SettingsEncryptionStateLoading(type: SettingsEncryptionType.importKeys);
      try {
        if (await _checkPermissions()) {
          _exportImportKeys(SettingsEncryptionType.importKeys);
        }
      } catch (error) {
        yield SettingsEncryptionStateFailure(error: error);
      }
    } else if (event is InitiateKeyTransfer) {
      yield SettingsEncryptionStateLoading(type: SettingsEncryptionType.initiateKeyTransfer);
      _initiateKeyTransfer();
    } else if (event is ActionSuccess) {
      yield SettingsEncryptionStateSuccess(setupCode: event.setupCode);
    } else if (event is ActionFailed) {
      yield SettingsEncryptionStateFailure(error: event.error);
    }
  }

  @override
  Future<void> close() {
    _unregisterListeners();
    return super.close();
  }

  Future<bool> _checkPermissions() async {
    bool hasFilesPermission = await Permission.storage.request().isGranted;
    if (!hasFilesPermission) {
      add(ActionFailed(error: SettingsEncryptionStateError.missingStoragePermission));
    }
    return hasFilesPermission;
  }

  void _exportImportKeys(SettingsEncryptionType type) async {
    if (!_listenersRegistered) {
      _listenersRegistered = true;
      await _registerListeners();
    }
    var context = Context();
    String path = await getUserVisibleDirectoryPathAsync();
    if (type == SettingsEncryptionType.exportKeys) {
      context.exportKeysAsync(path);
    } else if (type == SettingsEncryptionType.importKeys) {
      context.importKeysAsync(path);
    }
  }

  void _initiateKeyTransfer() async {
    var context = Context();
    String setupCode = await context.initiateKeyTransferAsync();
    add(ActionSuccess(setupCode: setupCode));
  }

  Future<void> _registerListeners() async {
    _keyActionSubject.listen(_successCallback, onError: _errorCallback);
   _core.addListener(eventId: Event.imexProgress, streamController: _keyActionSubject);
  }

  void _unregisterListeners() {
    if (_listenersRegistered) {
      _core.removeListener( _keyActionSubject);
      _listenersRegistered = false;
    }
  }

  _successCallback(Event event) {
    if (_actionSuccess(event.data1)) {
      add(ActionSuccess());
    } else if (_actionFailed(event.data1)) {
      add(ActionFailed(error: null));
    }
  }

  _errorCallback(error) {
    add(ActionFailed(error: error));
  }

  bool _actionSuccess(int progress) {
    return progress == 1000;
  }

  bool _actionFailed(int progress) {
    return progress == 0;
  }
}
