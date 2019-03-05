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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_talk/src/chat/chat_bloc.dart';
import 'package:ox_talk/src/chat/chat_event.dart';
import 'package:ox_talk/src/chat/chat_state.dart';
import 'package:ox_talk/src/l10n/localizations.dart';
import 'package:ox_talk/src/message/message_item.dart';
import 'package:ox_talk/src/message/messages_bloc.dart';
import 'package:ox_talk/src/message/messages_event.dart';
import 'package:ox_talk/src/message/messages_state.dart';
import 'package:ox_talk/src/utils/colors.dart';
import 'package:ox_talk/src/utils/dimensions.dart';
import 'package:ox_talk/src/utils/styles.dart';
import 'package:ox_talk/src/widgets/avatar.dart';

class ChatScreen extends StatefulWidget {
  final int _chatId;

  ChatScreen(this._chatId);

  @override
  _ChatScreenState createState() => new _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatBloc _chatBloc = ChatBloc();
  MessagesBloc _messagesBloc = MessagesBloc();

  final TextEditingController _textController = new TextEditingController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _chatBloc.dispatch(RequestChat(widget._chatId));
    _messagesBloc.dispatch(RequestMessages(widget._chatId));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: buildTitle(),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.videocam),
              onPressed: null,
              color: appBarIcon,
            ),
            IconButton(
              icon: Icon(Icons.phone),
              onPressed: null,
              color: appBarIcon,
            ),
          ],
        ),
        body: new Column(children: <Widget>[
          new Flexible(child: buildListView()),
          new Divider(height: dividerHeight),
          new Container(
            decoration: new BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ]));
  }

  Widget buildTitle() {
    return BlocBuilder(
      bloc: _chatBloc,
      builder: (context, state) {
        String name;
        String subTitle;
        Color color;
        if (state is ChatStateSuccess) {
          name = state.name;
          subTitle = state.subTitle;
          color = state.color;
        } else {
          name = "";
          subTitle = "";
        }
        return Row(
          children: <Widget>[
            Avatar(
              initials: getInitials(name, subTitle),
              color: color,
            ),
            Padding(padding: EdgeInsets.only(left: appBarAvatarTextPadding)),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: twoLineHeaderTitle,
                  ),
                  Row(
                    children: <Widget>[
                      _chatBloc.isGroup
                          ? Padding(
                              padding: const EdgeInsets.only(right: iconTextPadding),
                              child: Icon(
                                Icons.group,
                                size: iconSize,
                              ))
                          : Container(),
                      Expanded(
                        child: Text(
                          subTitle,
                          style: twoLineHeaderSubTitle,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildListView() {
    return BlocBuilder(
      bloc: _messagesBloc,
      builder: (context, state) {
        if (state is MessagesStateSuccess) {
          return new ListView.builder(
            padding: new EdgeInsets.all(listItemPadding),
            reverse: true,
            itemCount: state.messageIds.length,
            itemBuilder: (BuildContext context, int index) {
              int messageId = state.messageIds[index];
              var key = "$messageId-${state.messageLastUpdateValues[index]}";
              return ChatMessageItem(widget._chatId, messageId, _chatBloc.isGroup, key);
            },
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: composerHorizontalPadding),
        child: new Row(children: <Widget>[
          new IconButton(
            icon: new Icon(Icons.add),
            onPressed: null,
          ),
          new Flexible(
              child: Container(
            padding: EdgeInsets.all(composerTextFieldPadding),
            decoration: BoxDecoration(
              border: Border.all(color: chatComposeBorder),
              borderRadius: BorderRadius.all(Radius.circular(composeTextBorderRadius)),
            ),
            child: new TextField(
              controller: _textController,
              onChanged: (String text) {
                setState(() {
                  _isComposing = text.length > 0;
                });
              },
              onSubmitted: _isComposing ? _handleSubmitted : null,
              decoration: new InputDecoration.collapsed(
                hintText: AppLocalizations.of(context).composePlaceholder,
              ),
            ),
          )),
          _isComposing
              ? new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: () => _handleSubmitted(_textController.text),
                )
              : new IconButton(
                  icon: new Icon(Icons.keyboard_voice),
                  onPressed: null,
                ),
          !_isComposing
              ? new IconButton(
                  icon: new Icon(Icons.camera_alt),
                  onPressed: null,
                )
              : Container(),
        ]),
      ),
    );
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    _messagesBloc.submitMessage(text);
    setState(() {
      _isComposing = false;
    });
  }

  String getInitials(String name, String subTitle) {
    if (name != null && name.isNotEmpty) {
      return name.substring(0, 1);
    }
    if (subTitle != null && subTitle.isNotEmpty) {
      return subTitle.substring(0, 1);
    }
    return "";
  }
}
