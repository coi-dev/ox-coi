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

import 'package:bloc/bloc.dart';
import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:ox_coi/src/data/push_metadata.dart';
import 'package:ox_coi/src/data/push_resource.dart';
import 'package:ox_coi/src/platform/app_information.dart';
import 'package:ox_coi/src/platform/preferences.dart';
import 'package:ox_coi/src/platform/system_information.dart';
import 'package:ox_coi/src/push/push_event_state.dart';
import 'package:ox_coi/src/push/push_manager.dart';
import 'package:ox_coi/src/security/security_generator.dart';
import 'package:ox_coi/src/security/security_manager.dart';
import 'package:ox_coi/src/utils/http.dart';
import 'package:rxdart/rxdart.dart';

import 'push_service.dart';

enum PushSetupState {
  initial,
  resourceRegistered,
  sendMetadataSubscribe,
  metadataSubscribed,
  sendMetadataValidate,
  metadataValidated,
  unchanged,
}

class PushBloc extends Bloc<PushEvent, PushState> {
  static const _subscribeListenerId = 1001;
  static const _validateListenerId = 1002;

  final _logger = Logger("push_bloc");
  final _pushManager = PushManager();
  final pushService = PushService();
  final _core = DeltaChatCore();
  final _context = Context();
  final _pushSubject = PublishSubject<Event>();

  bool _listenersRegistered = false;

  @override
  PushState get initialState => PushStateInitial();

  @override
  Stream<PushState> mapEventToState(PushEvent event) async* {
    final pushAvailable = await _isWebPushAvailableAsync();
    if (!pushAvailable) {
      yield PushStateSuccess(pushAvailable: false, pushSetupState: PushSetupState.initial);
      _setNotificationPushStatusAsync(PushSetupState.initial);
      return;
    }
    if (event is RegisterPushResource) {
      yield* _registerPushResource();
    } else if (event is GetPushResource) {
      yield* _getPushResource();
    } else if (event is PatchPushResource) {
      yield* _patchPushResource(event);
    } else if (event is DeletePushResource) {
      yield* _deletePushResource();
    } else if (event is SubscribeMetadata) {
      yield* _subscribeMetadata(event);
    } else if (event is ValidateMetadata) {
      yield* _validateMetadata(event);
    }
  }

  @override
  Future<void> close() {
    _unregisterListeners();
    return super.close();
  }

  Stream<PushState> _registerPushResource() async* {
    try {
      final requestPushRegistration = await _createRegistrationRequestAsync();
      final response = await pushService.registerPush(requestPushRegistration);
      final valid = isHttpResponseValid(response);
      if (valid) {
        final pushResource = _createPushResource(response);
        await _persistPushResourceAsync(pushResource);
        yield PushStateSuccess(
          pushAvailable: true,
          pushSetupState: PushSetupState.resourceRegistered,
        );
        _setNotificationPushStatusAsync(PushSetupState.resourceRegistered);
        add(SubscribeMetadata(pushResource: pushResource));
      }
    } catch (error) {
      yield PushStateFailure(error: error.toString());
    }
  }

  Stream<PushState> _getPushResource() async* {
    try {
      final id = await _getIdAsync();
      final response = await pushService.getPush(id);
      final valid = isHttpResponseValid(response);
      if (valid) {
        yield PushStateSuccess(
          pushAvailable: true,
          pushSetupState: PushSetupState.unchanged,
        );
      }
    } catch (error) {
      yield PushStateFailure(error: error.toString());
    }
  }

  Stream<PushState> _patchPushResource(PatchPushResource event) async* {
    try {
      final id = await _getIdAsync();
      final requestPushPatch = _createPatchRequest(event.pushToken);
      final response = await pushService.patchPush(id, requestPushPatch);
      final valid = isHttpResponseValid(response);
      if (valid) {
        final pushResource = _createPushResource(response);
        await _persistPushResourceAsync(pushResource);
        yield PushStateSuccess(
          pushAvailable: true,
          pushSetupState: PushSetupState.resourceRegistered,
        );
        _setNotificationPushStatusAsync(PushSetupState.resourceRegistered);
        add(SubscribeMetadata(pushResource: pushResource));
      }
    } catch (error) {
      yield PushStateFailure(error: error.toString());
    }
  }

  Stream<PushState> _deletePushResource() async* {
    try {
      final id = await _getIdAsync();
      final response = await pushService.deletePush(id);
      final valid = isHttpResponseValid(response);
      if (valid) {
        _removePushResourceAsync();
        yield PushStateSuccess(
          pushAvailable: true,
          pushSetupState: PushSetupState.initial,
        );
        _setNotificationPushStatusAsync(PushSetupState.initial);
      }
    } catch (error) {
      yield PushStateFailure(error: error.toString());
    }
  }

  Stream<PushState> _subscribeMetadata(SubscribeMetadata event) async* {
    await _subscribeMetaDataAsync(event.pushResource);
    yield PushStateSuccess(
      pushAvailable: true,
      pushSetupState: PushSetupState.sendMetadataSubscribe,
    );
    _setNotificationPushStatusAsync(PushSetupState.sendMetadataSubscribe);
  }

  Stream<PushState> _validateMetadata(ValidateMetadata event) async* {
    await _confirmValidationAsync(event.validation);
    yield PushStateSuccess(
      pushAvailable: true,
      pushSetupState: PushSetupState.sendMetadataValidate,
    );
    _setNotificationPushStatusAsync(PushSetupState.sendMetadataValidate);
  }

  Future<RequestPushRegistration> _createRegistrationRequestAsync() async {
    final appId = await getPackageName();
    final pushToken = await _pushManager.getPushTokenAsync();
    var publicKey = await _getCoiServerPublicKeyAsync();
    publicKey = publicKey.replaceAll("\n", "");
    return RequestPushRegistration(appId, publicKey, pushToken);
  }

  RequestPushPatch _createPatchRequest(String pushToken) => RequestPushPatch(pushToken);

  Future<String> _getIdAsync() async {
    final pushResourceJsonString = await getPreference(preferenceNotificationsPush);
    final pushResourceJsonMap = jsonDecode(pushResourceJsonString);
    final pushResource = ResponsePushResource.fromJson(pushResourceJsonMap);
    return pushResource.id;
  }

  ResponsePushResource _createPushResource(Response response) {
    var pushResource;
    if (response.body != null && response.body.isNotEmpty) {
      final responseMap = jsonDecode(response.body);
      pushResource = ResponsePushResource.fromJson(responseMap);
    }
    return pushResource;
  }

  Future<void> _persistPushResourceAsync(ResponsePushResource pushResource) async {
    if (pushResource != null) {
      await setPreference(preferenceNotificationsPush, jsonEncode(pushResource));
    }
  }

  Future<void> _removePushResourceAsync() async {
    await removePreference(preferenceNotificationsPush);
  }

  Future<bool> _isWebPushAvailableAsync() async {
    return await _context.isWebPushSupported() == 1;
  }

  Future<String> _getCoiServerPublicKeyAsync() async {
    return await _context.getWebPushVapidKey();
  }

  Future<void> _subscribeMetaDataAsync(ResponsePushResource responsePushResource) async {
    await generateAndPersistPushKeyPairAsync();
    final publicKey = await getPushPublicKeyAsync();
    await generateAndPersistPushAuthAsync();
    final auth = await getPushAuthAsync();
    final clientEndpoint = generateUuid();
    await setPreference(preferenceNotificationsEndpoint, clientEndpoint);

    final client = await getAppName();
    final device = await getDeviceName();
    final pushSubscribeMetaData = PushSubscribeMetaData(
      client: client,
      device: device,
      resource: PushSubscribeMetaDataResource(
        keys: PushSubscribeMetaDataResourceKeys(
          p256dh: publicKey,
          auth: auth,
        ),
        endpoint: responsePushResource.endpoint,
      ),
    );
    _registerListeners();
    final encodedBody = json.encode(pushSubscribeMetaData);
    await _context.subscribeWebPush(clientEndpoint, encodedBody, _subscribeListenerId);
  }

  Future<void> _confirmValidationAsync(String message) async {
    final clientEndpoint = await getPreference(preferenceNotificationsEndpoint);
    await _context.validateWebPush(clientEndpoint, message, _validateListenerId);
  }

  void _registerListeners() {
    if (!_listenersRegistered) {
      _listenersRegistered = true;
      _pushSubject.listen(_metadataSuccessCallbackAsync, onError: _errorCallback);
      _core.addListener(eventIdList: [Event.setMetaDataDone, Event.webPushSubscription], streamController: _pushSubject);
    }
  }

  void _unregisterListeners() {
    if (_listenersRegistered) {
      _core.removeListener(_pushSubject);
      _listenersRegistered = false;
    }
  }

  Future<void> _metadataSuccessCallbackAsync(Event event) async {
    final listenerId = event.data1;
    if (listenerId == _subscribeListenerId) {
      await _setNotificationPushStatusAsync(PushSetupState.metadataSubscribed);
    } else if (listenerId == _validateListenerId) {
      await _setNotificationPushStatusAsync(PushSetupState.metadataValidated);
    }
  }

  _errorCallback(error) {
    _logger.warning("An error occured while listening: $error");
  }

  Future<void> _setNotificationPushStatusAsync(PushSetupState state) async {
    await setPreference(preferenceNotificationsPushStatus, describeEnum(state));
  }

}
