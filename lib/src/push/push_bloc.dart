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
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:ox_coi/src/data/push_metadata.dart';
import 'package:ox_coi/src/data/push_resource.dart';
import 'package:ox_coi/src/platform/app_information.dart';
import 'package:ox_coi/src/platform/preferences.dart';
import 'package:ox_coi/src/platform/system_information.dart';
import 'package:ox_coi/src/push/push_event_state.dart';
import 'package:ox_coi/src/push/push_manager.dart';
import 'package:ox_coi/src/secure/generator.dart';
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
  var _logger = Logger("push_bloc");
  var _pushManager = PushManager();
  var pushService = PushService();
  var _core = DeltaChatCore();
  var _context = Context();
  bool _listenersRegistered = false;
  static const _subscribeListenerId = 1001;
  static const _validateListenerId = 1002;

  PublishSubject<Event> pushSubject = new PublishSubject();
  static const securityChannelName = const MethodChannel("oxcoi.security");

  @override
  PushState get initialState => PushStateInitial();

  @override
  Stream<PushState> mapEventToState(PushEvent event) async* {
    bool pushAvailable = await _isWebPushAvailable();
    if (!pushAvailable) {
      yield PushStateSuccess(pushAvailable: false, pushSetupState: PushSetupState.initial);
      _setNotificationPushStatus(PushSetupState.initial);
      return;
    }
    if (event is RegisterPushResource) {
      try {
        RequestPushRegistration requestPushRegistration = await _createRegistrationRequest();
        var response = await pushService.registerPush(requestPushRegistration);
        var valid = validateHttpResponse(response);
        if (valid) {
          ResponsePushResource pushResource = _getPushResource(response);
          await _persistPushResource(pushResource);
          yield PushStateSuccess(
            pushAvailable: true,
            pushSetupState: PushSetupState.resourceRegistered,
          );
          _setNotificationPushStatus(PushSetupState.resourceRegistered);
          add(SubscribeMetadata(pushResource: pushResource));
        }
      } catch (error) {
        yield PushStateFailure(error: error.toString());
      }
    } else if (event is GetPushResource) {
      try {
        String id = await _getId();
        var response = await pushService.getPush(id);
        var valid = validateHttpResponse(response);
        if (valid) {
          yield PushStateSuccess(
            pushAvailable: true,
            pushSetupState: PushSetupState.unchanged,
          );
        }
      } catch (error) {
        yield PushStateFailure(error: error.toString());
      }
    } else if (event is PatchPushResource) {
      try {
        String id = await _getId();
        RequestPushPatch requestPushPatch = _createPatchRequest(event.pushToken);
        var response = await pushService.patchPush(id, requestPushPatch);
        var valid = validateHttpResponse(response);
        if (valid) {
          ResponsePushResource pushResource = _getPushResource(response);
          await _persistPushResource(pushResource);
          yield PushStateSuccess(
            pushAvailable: true,
            pushSetupState: PushSetupState.resourceRegistered,
          );
          _setNotificationPushStatus(PushSetupState.resourceRegistered);
          // TODO is requesting a new metadata subscription actually needed? Does the push resource ID or endpoint changes?
          add(SubscribeMetadata(pushResource: pushResource));
        }
      } catch (error) {
        yield PushStateFailure(error: error.toString());
      }
    } else if (event is DeletePushResource) {
      try {
        String id = await _getId();
        var response = await pushService.deletePush(id);
        var valid = validateHttpResponse(response);
        if (valid) {
          _removePushResource();
          yield PushStateSuccess(
            pushAvailable: true,
            pushSetupState: PushSetupState.initial,
          );
          _setNotificationPushStatus(PushSetupState.initial);
        }
      } catch (error) {
        yield PushStateFailure(error: error.toString());
      }
    } else if (event is SubscribeMetadata) {
      await _subscribeMetaData(event.pushResource);
      yield PushStateSuccess(
        pushAvailable: true,
        pushSetupState: PushSetupState.sendMetadataSubscribe,
      );
      _setNotificationPushStatus(PushSetupState.sendMetadataSubscribe);
    } else if (event is ValidateMetadata) {
      await _confirmValidation(event.validation);
      yield PushStateSuccess(
        pushAvailable: true,
        pushSetupState: PushSetupState.sendMetadataValidate,
      );
      _setNotificationPushStatus(PushSetupState.sendMetadataValidate);
    }
  }

  @override
  void close() {
    _unregisterListeners();
    super.close();
  }

  Future<RequestPushRegistration> _createRegistrationRequest() async {
    var appId = await getPackageName();
    var pushToken = await _pushManager.getPushToken();
    var publicKey = await _getCoiServerPublicKey();
    publicKey = publicKey.replaceAll("\n", "");
    var requestPushRegistration = RequestPushRegistration(appId, publicKey, pushToken);
    return requestPushRegistration;
  }

  RequestPushPatch _createPatchRequest(String pushToken) {
    var requestPushRegistration = RequestPushPatch(pushToken);
    return requestPushRegistration;
  }

  Future<String> _getId() async {
    var pushResourceJsonString = await getPreference(preferenceNotificationsPush);
    var pushResourceJsonMap = jsonDecode(pushResourceJsonString);
    var pushResource = ResponsePushResource.fromJson(pushResourceJsonMap);
    return pushResource.id;
  }

  ResponsePushResource _getPushResource(Response response) {
    var pushResource;
    if (response.body != null && response.body.isNotEmpty) {
      Map responseMap = jsonDecode(response.body);
      pushResource = ResponsePushResource.fromJson(responseMap);
    }
    return pushResource;
  }

  Future<void> _persistPushResource(ResponsePushResource pushResource) async {
    if (pushResource != null) {
      await setPreference(preferenceNotificationsPush, jsonEncode(pushResource));
    }
  }

  Future<void> _removePushResource() async {
    await removePreference(preferenceNotificationsPush);
  }

  Future<bool> _isWebPushAvailable() async {
    _context = Context();
    return await _context.isWebPushSupported() == 1;
  }

  Future<String> _getCoiServerPublicKey() async {
    _context = Context();
    return await _context.getWebPushVapidKey();
  }

  Future<void> _subscribeMetaData(ResponsePushResource responsePushResource) async {
    await _generateSecrets();
    String publicKey = await _getKey();
    //TODO decide where to get / load / generate all keys, we should prefer Dart if possible
    String auth = await _getAuthSecret();
    String clientEndpoint = generateUuid();
    await setPreference(preferenceNotificationsEndpoint, clientEndpoint);

    String client = await getAppName();
    String device = await getDeviceName();
    var pushSubscribeMetaData = PushSubscribeMetaData(
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
    _context = Context();
    String encodedBody = json.encode(pushSubscribeMetaData);
    await _context.subscribeWebPush(clientEndpoint, encodedBody, _subscribeListenerId);
  }

  Future<void> _confirmValidation(String message) async {
    String clientEndpoint = await getPreference(preferenceNotificationsEndpoint);
    await _context.validateWebPush(clientEndpoint, message, _validateListenerId);
  }

  void _registerListeners() async {
    if (!_listenersRegistered) {
      _listenersRegistered = true;
      pushSubject.listen(_metadataSuccessCallback, onError: _errorCallback);
      await _core.listen(Event.setMetaDataDone, pushSubject);
      await _core.listen(Event.webPushSubscription, pushSubject);
      await _core.listen(Event.error, pushSubject);
    }
  }

  void _unregisterListeners() {
    if (_listenersRegistered) {
      _core.removeListener(Event.setMetaDataDone, pushSubject);
      _core.removeListener(Event.webPushSubscription, pushSubject);
      _core.removeListener(Event.error, pushSubject);
      _listenersRegistered = false;
    }
  }

  void _metadataSuccessCallback(Event event) {
    var data1 = event.data1;
    if (data1 == _subscribeListenerId) {
      _setNotificationPushStatus(PushSetupState.metadataSubscribed);
    } else if (data1 == _validateListenerId) {
      _setNotificationPushStatus(PushSetupState.metadataValidated);
    }
  }

  _errorCallback(error) {
    _logger.info("An error occured while listening: $error");
  }

  _setNotificationPushStatus(PushSetupState state) {
    setPreference(preferenceNotificationsPushStatus, describeEnum(state));
  }

  Future<void> _generateSecrets() async => await securityChannelName.invokeMethod('generateSecrets');

  Future<String> _getKey() async => await securityChannelName.invokeMethod('getKey');

  Future<String> _getAuthSecret() async => await securityChannelName.invokeMethod('getAuthSecret');
}
