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
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon.dart';
import 'package:ox_coi/src/chat/chat.dart';
import 'package:ox_coi/src/chatlist/chat_list.dart';
import 'package:ox_coi/src/contact/contact_list.dart';
import 'package:ox_coi/src/data/invite_service_resource.dart';
import 'package:ox_coi/src/invite/invite_bloc.dart';
import 'package:ox_coi/src/invite/invite_event_state.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/lifecycle/lifecycle_bloc.dart';
import 'package:ox_coi/src/lifecycle/lifecycle_event_state.dart';
import 'package:ox_coi/src/main/root_child.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/ui/custom_theme.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/user/user_profile.dart';
import 'package:ox_coi/src/utils/dialog_builder.dart';
import 'package:ox_coi/src/utils/text_field_handling.dart';
import 'package:ox_coi/src/widgets/view_switcher.dart';
import 'package:provider/provider.dart';

class Root extends StatefulWidget {
  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  int _selectedIndex = 0;
  List<RootChild> childList;
  var _inviteBloc = InviteBloc();
  var _navigation = Navigation();
  var _appBarActionsStream = StreamController<AppBarAction>.broadcast();

  @override
  void initState() {
    super.initState();
    childList = [
      ChatList(),
      ContactList(),
      UserProfile(),
    ];
  }

  @override
  void dispose() {
    _appBarActionsStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    RootChild child = childList[_selectedIndex];

    return Provider.value(
      value: _appBarActionsStream,
      child: Scaffold(
        appBar: child.getAppBar(context, _appBarActionsStream),
        backgroundColor: CustomTheme.of(context).background,
        body: WillPopScope(
          onWillPop: _onWillPop,
          child: MultiBlocListener(
            listeners: [
              BlocListener<LifecycleBloc, LifecycleState>(
                listener: (context, state) {
                  if (state is LifecycleStateSuccess) {
                    if (state.state == AppLifecycleState.resumed.toString()) {
                      _inviteBloc.add(HandleSharedInviteLink());
                    }
                  }
                },
              ),
              BlocListener<InviteBloc, InviteState>(
                bloc: _inviteBloc,
                listener: (context, state) {
                  if (state is InviteStateSuccess) {
                    if (state.inviteServiceResponse != null) {
                      InviteServiceResponse inviteServiceResponse = state.inviteServiceResponse;
                      String name = inviteServiceResponse.sender.name;
                      String email = inviteServiceResponse.sender.email;
                      String chatListInviteDialogXYText = L10n.getFormatted(L.chatListInviteDialogXY, [name, email]);
                      String chatListInviteDialogXText = L10n.getFormatted(L.chatListInviteDialogX, [email]);
                      Uint8List imageBytes = state.base64Image != null ? base64Decode(state.base64Image) : Uint8List(0);
                      showNavigatableDialog(
                        context: context,
                        navigatable: Navigatable(Type.chatListInviteDialog),
                        dialog: AlertDialog(
                          content: Row(
                            children: <Widget>[
                              Visibility(
                                visible: imageBytes.length > 0,
                                child: Image.memory(
                                  imageBytes,
                                  height: listAvatarDiameter,
                                  width: listAvatarDiameter,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(verticalPaddingSmall),
                              ),
                              Flexible(
                                child: Text(name == email ? chatListInviteDialogXText : chatListInviteDialogXYText),
                              )
                            ],
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Text(L10n.get(L.cancel)),
                              onPressed: () {
                                _navigation.pop(context);
                              },
                            ),
                            FlatButton(
                              child: Text(L10n.get(L.chatStart)),
                              onPressed: () {
                                _navigation.pop(context);
                                _inviteBloc.add(AcceptInvite(inviteServiceResponse: inviteServiceResponse));
                              },
                            ),
                          ],
                        ),
                      );
                    }
                  } else if (state is InviteStateFailure) {
                    showNavigatableDialog(
                      context: context,
                      navigatable: Navigatable(Type.chatListInviteErrorDialog),
                      dialog: AlertDialog(
                        title: Text(L10n.get(L.error)),
                        content: Text(state.errorMessage),
                        actions: <Widget>[
                          FlatButton(
                            child: Text(L10n.get(L.ok)),
                            onPressed: () {
                              _navigation.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  } else if (state is CreateInviteChatSuccess) {
                    _navigation.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Chat(
                                  chatId: state.chatId,
                                )));
                  }
                },
              ),
            ],
            child: ViewSwitcher(child),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: childList.map((child) {
            return BottomNavigationBarItem(
              icon: AdaptiveIcon(
                icon: child.getBottomNavigationIcon(),
                key: Key(child.getBottomNavigationText()),
              ),
              title: Text(child.getBottomNavigationText()),
            );
          }).toList(),
          currentIndex: _selectedIndex,
          backgroundColor: CustomTheme.of(context).surface,
          unselectedIconTheme: IconThemeData(color: CustomTheme.of(context).onSurface.fade()),
          unselectedItemColor: CustomTheme.of(context).onSurface.fade(),
          onTap: _onItemTapped,
        ),
        floatingActionButton: child.getFloatingActionButton(context),
      ),
    );
  }

  Future<bool> _onWillPop() {
    if (!_navigation.allowBackNavigation) {
      return Future.value(false);
    }
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  _onItemTapped(int index) {
    resetGlobalFocus(context);
    setState(() {
      _selectedIndex = index;
    });
  }
}
