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

import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon_button.dart';
import 'package:ox_coi/src/lifecycle/lifecycle_bloc.dart';
import 'package:ox_coi/src/lifecycle/lifecycle_event_state.dart';
import 'package:ox_coi/src/chat/chat_change_bloc.dart';
import 'package:ox_coi/src/chat/chat_change_event_state.dart';
import 'package:ox_coi/src/chatlist/chat_list_bloc.dart';
import 'package:ox_coi/src/chatlist/chat_list_event_state.dart';
import 'package:ox_coi/src/chatlist/chat_list_item.dart';
import 'package:ox_coi/src/chatlist/invite_item.dart';
import 'package:ox_coi/src/flagged/flagged.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/main/root_child.dart';
import 'package:ox_coi/src/message/message_action.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/share/share.dart';
import 'package:ox_coi/src/share/share_bloc.dart';
import 'package:ox_coi/src/share/share_event_state.dart';
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/utils/key_generator.dart';
import 'package:ox_coi/src/widgets/search.dart';
import 'package:ox_coi/src/widgets/state_info.dart';
import 'package:rxdart/rxdart.dart';

enum ChatListItemType {
  chat,
  message,
}

class ChatList extends RootChild {
  final Navigation navigation = Navigation();

  ChatList({State<StatefulWidget> state}) : super(state: state);

  @override
  _ChatListState createState() {
    final state = _ChatListState();
    setActions([state.getFlaggedAction(), state.getSearchAction()]);
    return state;
  }

  @override
  Color getColor() {
    return primary;
  }

  @override
  FloatingActionButton getFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      child: new AdaptiveIcon(
          icon: IconSource.chat
      ),
      key: Key(keyChatListChatFloatingActionButton),
      onPressed: () {
        _showCreateChatView(context);
      },
    );
  }

  _showCreateChatView(BuildContext context) {
    navigation.pushNamed(context, Navigation.chatCreate);
  }

  @override
  String getTitle(BuildContext context) {
    return L10n.get(L.chatP, count: L10n.plural);
  }

  @override
  String getNavigationText(BuildContext context) {
    return L10n.get(L.chatP, count: L10n.plural);
  }

  @override
  IconSource getNavigationIcon() {
    return IconSource.chat;
  }
}

class _ChatListState extends State<ChatList> {
  ChatListBloc _chatListBloc = ChatListBloc();
  ChatListBloc _chatListSearchBloc = ChatListBloc();
  ShareBloc shareBloc = ShareBloc();
  Navigation _navigation = Navigation();

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.chatList);
    _chatListBloc.add(RequestChatList(showInvites: true));
    final shareObservable = Observable<ShareState>(shareBloc);
    shareObservable.listen((state) => handleShareStateChange(state));
    shareBloc.add(LoadSharedData());
  }

  handleShareStateChange(ShareState state) {
    if (state is ShareStateSuccess) {
      if (state.sharedData != null) {
        _navigation.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => Share(
                    messageActionTag: MessageActionTag.share,
                    sharedData: state.sharedData,
                  )),
          ModalRoute.withName(Navigation.root),
          Navigatable(Type.chatList),
        );
      }
    }
  }

  @override
  void dispose() {
    _chatListBloc.close();
    _chatListSearchBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LifecycleBloc, LifecycleState>(
      listener: (context, state) {
        if (state is LifecycleStateSuccess) {
          if (state.state == AppLifecycleState.resumed.toString()) {
            shareBloc.add(LoadSharedData());
          }
        }
      },
      child: BlocBuilder(
        bloc: _chatListBloc,
        builder: (context, state) {
          if (state is ChatListStateSuccess) {
            if (state.chatListItemWrapper.ids.length > 0) {
              return buildListItems(state);
            } else {
              return EmptyListInfo(
                infoText: L10n.get(L.chatListPlaceholder),
                imagePath: "assets/images/empty_chatlist.png",
              );
            }
          } else if (state is! ChatListStateFailure) {
            return StateInfo(showLoading: true);
          } else {
            return AdaptiveIcon(
                icon: IconSource.error
            );
          }
        },
      ),
    );
  }

  ListView buildListItems(ChatListStateSuccess state) {
    var chatListItemWrapper = state.chatListItemWrapper;
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(
        height: dividerHeight,
        color: onBackground.withOpacity(barely),
      ),
      itemCount: chatListItemWrapper.ids.length,
      itemBuilder: (BuildContext context, int index) {
        var id = chatListItemWrapper.ids[index];
        var key =
            createKeyString(id, chatListItemWrapper.lastUpdateValues[index]);
        if (chatListItemWrapper.types[index] == ChatListItemType.chat) {
          return Slidable.builder(
              key: Key(key),
              actionPane: SlidableBehindActionPane(),
              actionExtentRatio: 0.2,
              secondaryActionDelegate: SlideActionBuilderDelegate(
                  actionCount: 1,
                  builder: (context, index, animation, renderingMode) {
                    // for more than one slide action we need take care of `index`
                    return IconSlideAction(
                      caption: L10n.get(L.delete),
                      color: error,
                      iconWidget: AdaptiveIcon(
                        icon: IconSource.delete,
                        color: onError,
                      ),
                      onTap: () {
                        var state = Slidable.of(context);
                        state.dismiss();
                      },
                    );
                  }),
              dismissal: SlidableDismissal(
                child: SlidableDrawerDismissal(),
                onDismissed: (actionType) {
                  _deleteChat(chatId: id);
                },
              ),
              child: ChatListItem(
                chatId: id,
                onTap: multiSelectItemTapped,
                switchMultiSelect: switchMultiSelect,
                isMultiSelect: false,
                isShareItem: false,
                key: key,
              ));
        } else {
          return InviteItem(
            chatId: Chat.typeInvite,
            messageId: id,
            key: key,
          );
        }
      },
    );
  }

  multiSelectItemTapped(int id) {}

  switchMultiSelect(int id) {}

  Widget getSearchAction() {
    Search search = Search(
      onBuildResults: onBuildResultOrSuggestion,
      onBuildSuggestion: onBuildResultOrSuggestion,
    );
    return AdaptiveIconButton(
      icon: AdaptiveIcon(
        icon: IconSource.search,
      ),
      onPressed: () => search.show(context),
      key: Key(keyChatListSearchIconButton),
    );
  }

  Widget getFlaggedAction() {
    return AdaptiveIconButton(
        icon: AdaptiveIcon(
            icon: IconSource.flag,
        ),
        key: Key(keyChatListGetFlaggedActionIconButton),
        onPressed: () => _navigation.push(
            context,
            MaterialPageRoute(
              builder: (context) => Flagged(),
            )));
  }

  Widget onBuildResultOrSuggestion(String query) {
    _chatListSearchBloc.add(SearchChatList(query: query, showInvites: false));
    return buildSearchResults();
  }

  Widget buildSearchResults() {
    return BlocBuilder(
      bloc: _chatListSearchBloc,
      builder: (context, state) {
        if (state is ChatListStateSuccess) {
          if (state.chatListItemWrapper.ids.length > 0) {
            return buildListItems(state);
          } else {
            return Center(
              child: Text(L10n.get(L.noResultsFound)),
              key: Key(L.getKey(L.noResultsFound)),
            );
          }
        } else if (state is! ChatListStateFailure) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return AdaptiveIcon(
              icon: IconSource.error
          );
        }
      },
    );
  }

  // Slide Actions

  _deleteChat({@required int chatId}) {
    ChatChangeBloc chatChangeBloc = ChatChangeBloc();
    chatChangeBloc.add(DeleteChat(chatId: chatId));
    chatChangeBloc.close();
  }

}
