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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/key_generator.dart';
import 'package:ox_coi/src/widgets/state_info.dart';

import 'message_item.dart';
import 'message_list_bloc.dart';
import 'message_list_event_state.dart';

class MessageList extends StatelessWidget {
  final ScrollController scrollController;
  final int chatId;

  MessageList({@required this.scrollController, @required this.chatId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: BlocProvider.of<MessageListBloc>(context),
      builder: (context, state) {
        if (state is MessagesStateSuccess) {
          if (state.messageIds.length > 0) {
            return ListView.custom(
              controller: scrollController,
              padding: const EdgeInsets.only(
                left: chatMessageListPadding,
                top: chatMessageListPadding,
                right: chatMessageListPadding,
                bottom: chatComposerPadding,
              ),
              reverse: true,
              childrenDelegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final messageId = state.messageIds[index];
                    int nextMessageId;
                    if (index < (state.messageIds.length - 1)) {
                      nextMessageId = state.messageIds[index + 1];
                    }
                    final hasDateMarker = state.dateMarkerIds.contains(messageId);
                    return MessageItem(
                      key: ValueKey(messageId),
                      chatId: chatId,
                      messageId: messageId,
                      nextMessageId: nextMessageId,
                      hasDateMarker: hasDateMarker,
                    );
                  },
                  childCount: state.messageIds.length,
                  findChildIndexCallback: (Key key) {
                    final ValueKey valueKey = key;
                    final id = extractId(valueKey);
                    return state.messageIds.indexOf(id);
                  }),
            );
          } else {
            return StateInfo(title: L10n.get(L.chatNewPlaceholder));
          }
        } else {
          return StateInfo(showLoading: true);
        }
      },
    );
  }
}
