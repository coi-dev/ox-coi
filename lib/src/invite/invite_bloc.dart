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
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:mime/mime.dart';
import 'package:ox_coi/src/data/config.dart';
import 'package:ox_coi/src/data/contact_extension.dart';
import 'package:ox_coi/src/data/invite_service_resource.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/invite/invite_service.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/share/shared_data.dart';
import 'package:ox_coi/src/utils/http.dart';
import 'package:ox_coi/src/utils/image.dart';
import 'package:ox_coi/src/utils/text.dart';
import 'package:path_provider/path_provider.dart';

import 'invite_event_state.dart';

class InviteBloc extends Bloc<InviteEvent, InviteState> {
  final Repository<Contact> _contactRepository = RepositoryManager.get(RepositoryType.contact);
  final Repository<Chat> _chatRepository = RepositoryManager.get(RepositoryType.chat);
  static const platform = const MethodChannel(SharedData.sharingChannelName);
  InviteService inviteService = InviteService();

  @override
  InviteState get initialState => InviteStateInitial();

  @override
  Stream<InviteState> mapEventToState(InviteEvent event) async* {
    if (event is CreateInviteUrl) {
      try {
        yield* createInviteUrl(event.message);
      } catch (error) {
        yield InviteStateFailure();
      }
    } else if (event is HandleSharedInviteLink) {
      yield* handleSharedInviteLink();
    } else if (event is AcceptInvite) {
      yield* acceptInvite(event.inviteServiceResponse, event.base64Image);
    }
  }

  Stream<InviteState> createInviteUrl(String message) async* {
    InviteServiceRequest requestInviteService = await _createInviteServiceRequest(message ?? "");
    var response = await inviteService.createInviteUrl(requestInviteService);
    bool valid = validateHttpResponse(response);
    if (valid) {
      InviteServiceResponse responseInviteService = _getInviteResponse(response);
      Map argsMap = <String, String>{
        'title': '',
        'path': '',
        'mimeType': 'text/*',
        'text': '${responseInviteService.endpoint} \n ${L10n.get(L.inviteShareText)}'
      };
      sendSharedData(argsMap);
      yield InviteStateSuccess();
    } else {
      yield InviteStateFailure(errorMessage: response.reasonPhrase);
    }
  }

  Stream<InviteState> handleSharedInviteLink() async* {
    String sharedLink = await _getInitialLink();
    if (sharedLink == null) {
      return;
    }
    int startIndex = getIndexAfterLastOf(sharedLink, '/');
    String id = sharedLink.substring(startIndex);
    if (id.isNotEmpty) {
      Response response = await inviteService.getInvite(id);
      bool valid = validateHttpResponse(response);
      if (valid) {
        InviteServiceResponse responseInviteService = _getInviteResponse(response);
        String imageString = responseInviteService.sender.image;
        String base64Image;
        if (!isNullOrEmpty(imageString)) {
          int imageStartIndex = getIndexAfterLastOf(imageString, ',');
          base64Image = imageString.substring(imageStartIndex);
        }
        yield InviteStateSuccess(inviteServiceResponse: responseInviteService, base64Image: base64Image);
      } else {
        String errorMessage;
        if (response.statusCode == 404) {
          errorMessage = L10n.get(L.inviteGetText404Error);
        } else {
          errorMessage = L10n.getFormatted(L.inviteGetTextGeneralErrorX, [response.reasonPhrase]);
        }
        yield InviteStateFailure(errorMessage: errorMessage);
      }
    }
  }

  Stream<InviteState> acceptInvite(InviteServiceResponse inviteServiceResponse, String image) async* {
    Context context = Context();
    String email = inviteServiceResponse.sender.email;
    int contactId = await context.createContact(inviteServiceResponse.sender.name, email);
    int chatId = await context.createChatByContactId(contactId);
    _chatRepository.putIfAbsent(id: chatId);
    _contactRepository.putIfAbsent(id: contactId);
    if (image != null) {
      var directory = await getApplicationDocumentsDirectory();
      File file = File("${directory.path}/${email}_avatar.png");
      removeImageFromCache(file);
      Uint8List imageBytes = base64Decode(image);
      await file.writeAsBytes(imageBytes);
      var contactExtensionProvider = ContactExtensionProvider();
      var contactExtension = await contactExtensionProvider.getContactExtension(contactId: contactId);
      if (contactExtension == null) {
        contactExtension = ContactExtension(contactId, avatar: file.path);
        contactExtensionProvider.insert(contactExtension);
      } else {
        contactExtension.avatar = file.path;
        contactExtensionProvider.update(contactExtension);
      }
    }

    await inviteService.deleteInvite(inviteServiceResponse.id);
    yield CreateInviteChatSuccess(chatId: chatId);
  }

  Future<InviteServiceRequest> _createInviteServiceRequest(String message) async {
    var sender = await _createInviteServiceSender();
    var requestPushRegistration = InviteServiceRequest(message: "", sender: sender);
    return requestPushRegistration;
  }

  Future<InviteServiceSender> _createInviteServiceSender() async {
    Config config = Config();
    String email = config.email;
    String name = config.username != null && config.username.isNotEmpty ? config.username : config.email;
    String imagePath = config.avatarPath;
    String base64Image;
    if (imagePath != null && imagePath.isNotEmpty) {
      File file = File(imagePath);
      List<int> imageBytes = await file.readAsBytes();
      String mime = lookupMimeType(imagePath) ?? "image/*";
      Uri uri = Uri.dataFromBytes(imageBytes, mimeType: mime);
      base64Image = uri.toString();
    } else {
      base64Image = null;
    }
    // TODO: add user PublicKey when the API makes it possible.
    String publicKey = "";

    var inviteServiceSender = InviteServiceSender(email: email, name: name, image: base64Image, publicKey: publicKey);
    return inviteServiceSender;
  }

  InviteServiceResponse _getInviteResponse(Response response) {
    var inviteResponse;
    if (response.body != null && response.body.isNotEmpty) {
      Map responseMap = jsonDecode(response.body);
      inviteResponse = InviteServiceResponse.fromJson(responseMap);
    }
    return inviteResponse;
  }

  Future<String> _getInitialLink() async => await platform.invokeMethod('getInitialLink');

  void sendSharedData(Map argsMap) async => await platform.invokeMethod('sendSharedData', argsMap);
}
