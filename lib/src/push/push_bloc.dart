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
import 'package:http/http.dart';
import 'package:ox_coi/src/data/push_resource.dart';
import 'package:ox_coi/src/platform/app_information.dart';
import 'package:ox_coi/src/platform/preferences.dart';
import 'package:ox_coi/src/push/push_event_state.dart';
import 'package:ox_coi/src/push/push_manager.dart';
import 'package:ox_coi/src/secure/generator.dart';

import 'push_service.dart';

class PushBloc extends Bloc<PushEvent, PushState> {
  static String publicKey = "-----BEGIN PUBLIC KEY-----MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEX9kaIRaLRIMAsJBkMGns2oOg8Rj9gb9ofeYpbZkFxGrWUMM4xFA0EjmzwnnOLwIcmA+6SDmyimKVEz1r3szOFQ==-----END PUBLIC KEY-----"; //TODO use real key

  PushService _pushService;
  var _pushManager = PushManager();

  @override
  PushState get initialState {
    _pushService = PushService();
    return PushStateInitial();
  }

  @override
  Stream<PushState> mapEventToState(PushEvent event) async* {
    if (event is RegisterPush) {
      yield PushStateLoading();
      try {
        await generateSecrets();
        RequestPushRegistration requestPushRegistration = await createRegistrationRequest();
        var response = await _pushService.registerPush(requestPushRegistration);
        validateResponse(response);
      } catch (error) {
        yield PushStateFailure(error: error.toString());
      }
    } else if (event is GetPush) {
      yield PushStateLoading();
      try {
        String id = await getId();
        var response = await _pushService.getPush(id);
        validateResponse(response);
      } catch (error) {
        yield PushStateFailure(error: error.toString());
      }
    } else if (event is PatchPush) {
      yield PushStateLoading();
      try {
        String id = await getId();
        RequestPushPatch requestPushPatch = createPatchRequest(event.pushToken);
        var response = await _pushService.patchPush(id, requestPushPatch);
        validateResponse(response);
      } catch (error) {
        yield PushStateFailure(error: error.toString());
      }
    } else if (event is DeletePush) {
      yield PushStateLoading();
      try {
        String id = await getId();
        var response = await _pushService.deletePush(id);
        validateResponse(response);
      } catch (error) {
        yield PushStateFailure(error: error.toString());
      }
    } else if (event is PushActionDone) {
      var pushResource = event.responsePushResource;
      if (pushResource == null) {
        await removePreference(preferenceNotificationsPush);
      } else {
        await setPreference(preferenceNotificationsPush, jsonEncode(pushResource));
      }
      yield PushStateSuccess(responsePushResource: pushResource);
    } else if (event is PushActionFailed) {
      yield PushStateFailure(error: event.error);
    }
  }

  Future<RequestPushRegistration> createRegistrationRequest() async {
    var appId = await getPackageName();
    var pushToken = await _pushManager.getPushToken();
    var requestPushRegistration = RequestPushRegistration(appId, publicKey, pushToken);
    return requestPushRegistration;
  }

  RequestPushPatch createPatchRequest(String pushToken) {
    var requestPushRegistration = RequestPushPatch(pushToken);
    return requestPushRegistration;
  }

  Future<String> getId() async {
    var pushResourceString = await getPreference(preferenceNotificationsPush);
    var jsonDecode2 = jsonDecode(pushResourceString);
    var pushResource = ResponsePushResource.fromJson(jsonDecode2);

    return pushResource.id;
  }

  Future<void> generateSecrets() async {

    var keyPair = generateEcKeyPair();
    String publicKey = getPublicEcKey(keyPair);
    String privateKey = getPrivateEcKey(keyPair);
    String uuid = generateUuid();
    await setPreference(preferenceNotificationsP256dhPublic, publicKey);
    await setPreference(preferenceNotificationsP256dhPrivate, privateKey);
    await setPreference(preferenceNotificationsAuth, uuid);
  }

  void validateResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      var pushResource;
      if (response.body != null && response.body.isNotEmpty) {
        Map responseMap = jsonDecode(response.body);
        pushResource = ResponsePushResource.fromJson(responseMap);
      }
      dispatch(PushActionDone(responsePushResource: pushResource));
    } else {
      dispatch(PushActionFailed(error: response.body));
    }
  }
}
