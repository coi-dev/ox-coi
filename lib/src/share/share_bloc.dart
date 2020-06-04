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

import 'package:bloc/bloc.dart';
import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/services.dart';
import 'package:ox_coi/src/chatlist/chat_list_bloc.dart';
import 'package:ox_coi/src/chatlist/chat_list_event_state.dart';
import 'package:ox_coi/src/contact/contact_list_bloc.dart';
import 'package:ox_coi/src/contact/contact_list_event_state.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/share/share_event_state.dart';
import 'package:ox_coi/src/share/shared_data.dart';

class ShareBloc extends Bloc<ShareEvent, ShareState> {
  ChatListBloc _chatListBloc = ChatListBloc();
  ContactListBloc _contactListBloc = ContactListBloc();
  static const platform = const MethodChannel(SharedData.sharingChannelName);

  @override
  ShareState get initialState => ShareStateInitial();

  @override
  Stream<ShareState> mapEventToState(ShareEvent event) async* {
    if (event is RequestChatsAndContacts) {
      yield ShareStateLoading();
      try {
        createShareList();
      } catch (error) {
        yield ShareStateFailure(error: error.toString());
      }
    } else if (event is ChatsAndContactsLoaded) {
      yield ShareStateSuccess(
        chatAndContactIds: event.chatAndContactList,
        chatIdCount: event.chatListLength,
        contactIdCount: event.contactListLength,
      );
    } else if (event is ForwardMessages) {
      yield ShareStateLoading();
      forwardMessages(event.destinationChatId, event.messageIds);
    } else if (event is LoadSharedData) {
      loadSharedData();
    } else if (event is SharedDataLoaded) {
      yield ShareStateSuccess(sharedData: event.sharedData);
    }
  }

  @override
  Future<void> close() {
    _chatListBloc.close();
    _contactListBloc.close();
    return super.close();
  }

  void createShareList() {
    List<int> _chatIds;
    List<dynamic> _completeList = List();

    _contactListBloc.listen((state) {
      if (state is ContactListStateSuccess) {
        int index = _chatIds.length;
        if (state.contactElements != null) {
          _completeList.insertAll(index, state.contactElements);
        }
        add(ChatsAndContactsLoaded(
          chatAndContactList: _completeList,
          chatListLength: _chatIds.length,
          contactListLength: state.contactElements.length,
        ));
      }
    });

    _chatListBloc.listen((state) {
      if (state is ChatListStateSuccess) {
        _completeList.clear();
        _chatIds = state.chatListItemWrapper.ids;
        if (_chatIds != null) {
          _completeList.insertAll(0, _chatIds);
        }
        _contactListBloc.add(RequestContacts(typeOrChatId: validContacts));
      }
    });
    _chatListBloc.add(RequestChatList(showInvites: false));
  }

  void forwardMessages(int destinationChatId, List<int> messageIds) async {
    Context context = Context();
    await context.forwardMessages(destinationChatId, messageIds);
  }

  void loadSharedData() async {
    var data = await _getSharedData();
    if (data == null) {
      return;
    }
    if (data.length > 0) {
      var sharedData = SharedData(data);
      add(SharedDataLoaded(sharedData: sharedData));
    }
  }

  Future<Map> _getSharedData() async => await platform.invokeMethod('getSharedData');
}
