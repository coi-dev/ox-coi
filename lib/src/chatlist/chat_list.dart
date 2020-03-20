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
import 'dart:io';

import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/chatlist/chat_list_bloc.dart';
import 'package:ox_coi/src/chatlist/chat_list_event_state.dart';
import 'package:ox_coi/src/chatlist/chat_list_item.dart';
import 'package:ox_coi/src/chatlist/invite_item.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/lifecycle/lifecycle_bloc.dart';
import 'package:ox_coi/src/lifecycle/lifecycle_event_state.dart';
import 'package:ox_coi/src/main/root_child.dart';
import 'package:ox_coi/src/message/message_action.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/share/share.dart';
import 'package:ox_coi/src/share/share_bloc.dart';
import 'package:ox_coi/src/share/share_event_state.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/utils/key_generator.dart';
import 'package:ox_coi/src/widgets/dynamic_appbar.dart';
import 'package:ox_coi/src/widgets/state_info.dart';
import 'package:ox_coi/src/widgets/superellipse_icon.dart';
import 'package:provider/provider.dart';

enum ChatListItemType {
  chat,
  message,
}

_showCreateChatView(BuildContext context, Navigation navigation) => navigation.pushNamed(context, Navigation.chatCreate);

class ChatList extends RootChild {
  final Navigation _navigation = Navigation();

  @override
  _ChatListState createState() => _ChatListState();

  @override
  Color getColor(BuildContext context) => CustomTheme.of(context).onSurface;

  @override
  FloatingActionButton getFloatingActionButton(BuildContext context) {
    return Platform.isAndroid
        ? FloatingActionButton(
            child: new AdaptiveIcon(icon: IconSource.chat),
            key: Key(keyChatListCreateChatButton),
            onPressed: () {
              _showCreateChatView(context, _navigation);
            },
          )
        : null;
  }

  @override
  String getBottomNavigationText() => L10n.get(L.chatP, count: L10n.plural);

  @override
  IconSource getBottomNavigationIcon() => IconSource.chat;

  @override
  DynamicAppBar getAppBar(BuildContext context, StreamController<AppBarAction> appBarActionsStream) {
    return DynamicAppBar(
      title: L10n.get(L.chatP, count: L10n.plural),
      trailingList: [
        if (Platform.isIOS)
          IconButton(
            key: Key(keyChatListCreateChatButton),
            icon: SuperellipseIcon(
              icon: IconSource.create,
              iconColor: CustomTheme.of(context).onAccent,
              color: CustomTheme.of(context).accent,
            ),
            onPressed: () => appBarActionsStream.add(AppBarAction.addChat),
          )
      ],
    );
  }
}

class _ChatListState extends State<ChatList> {
  final _chatListBloc = ChatListBloc();
  final _shareBloc = ShareBloc();
  final _scrollController = ScrollController();

  StreamSubscription<AppBarAction> _appBarActionsSubscription;
  DynamicSearchBar _searchBar;
  var _isSearching = false;

  @override
  void initState() {
    super.initState();
    widget._navigation.current = Navigatable(Type.chatList);
    _chatListBloc.add(RequestChatList(showInvites: true));
    _shareBloc.listen((state) => _handleShareStateChange(state));
    _shareBloc.add(LoadSharedData());
    _appBarActionsSubscription = Provider.of<StreamController<AppBarAction>>(context, listen: false).stream.listen((data) {
      if (data == AppBarAction.addChat) {
        _showCreateChatView(context, widget._navigation);
      }
    });
    _searchBar = DynamicSearchBar(
      content: DynamicSearchBarContent(
        onSearch: (text) {
          if (text == null) {
            _chatListBloc.add(RequestChatList(showInvites: true));
          } else {
            search(text);
          }
        },
        onFocus: () => search(""),
        isSearchingCallback: (bool isSearching) => setState(() => _isSearching = isSearching),
      ),
    );
  }

  void search(text) => _chatListBloc.add(SearchChatList(query: text, showInvites: false));

  @override
  void dispose() {
    _chatListBloc.close();
    _appBarActionsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LifecycleBloc, LifecycleState>(
      listener: (context, state) {
        if (state is LifecycleStateSuccess) {
          if (state.state == AppLifecycleState.resumed.toString()) {
            _shareBloc.add(LoadSharedData());
          }
        }
      },
      child: BlocBuilder(
        bloc: _chatListBloc,
        builder: (context, state) {
          if (state is ChatListStateSuccess) {
            if (state.chatListItemWrapper.ids.length > 0 || _isSearching) {
              var chatListItemWrapper = state.chatListItemWrapper;
              return CustomScrollView(
                controller: _scrollController,
                slivers: <Widget>[
                  _searchBar,
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        var id = chatListItemWrapper.ids[index];
                        var key = createKeyFromId(id, [chatListItemWrapper.lastUpdateValues[index]]);
                        if (chatListItemWrapper.types[index] == ChatListItemType.chat) {
                          return ChatListItem(
                            chatId: id,
                            onTap: _multiSelectItemTapped,
                            switchMultiSelect: _switchMultiSelect,
                            isMultiSelect: false,
                            isShareItem: false,
                            key: key,
                          );
                        } else {
                          return InviteItem(
                            chatId: Chat.typeInvite,
                            messageId: id,
                            key: key,
                          );
                        }
                      },
                      childCount: state.chatListItemWrapper.ids.length,
                      findChildIndexCallback: (Key key) {
                        final ValueKey valueKey = key;
                        var id = extractId(valueKey);
                        if (state.chatListItemWrapper.ids.contains(id)) {
                          var indexOf = state.chatListItemWrapper.ids.indexOf(id);
                          return indexOf;
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                ],
              );
            } else {
              return EmptyListInfo(
                infoText: L10n.get(L.chatListPlaceholder),
                imagePath: "assets/images/empty_chatlist.png",
              );
            }
          } else if (state is! ChatListStateFailure) {
            return StateInfo(showLoading: true);
          } else {
            return AdaptiveIcon(icon: IconSource.error);
          }
        },
      ),
    );
  }

  _handleShareStateChange(ShareState state) {
    if (state is ShareStateSuccess) {
      if (state.sharedData != null) {
        widget._navigation.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => Share(
                    messageActionTag: MessageActionTag.share,
                    sharedData: state.sharedData,
                  )),
          ModalRoute.withName(Navigation.root),
          Navigatable(Type.rootChildren),
        );
      }
    }
  }

  _multiSelectItemTapped(int id) {}

  _switchMultiSelect(int id) {}
}
