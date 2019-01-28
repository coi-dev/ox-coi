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
import 'package:ox_talk/source/data/chat_message_repository.dart';
import 'chat_message_item.dart';

class ChatScreen extends StatefulWidget {
  final Chat _chat;

  ChatScreen(this._chat);

  @override
  _ChatScreenState createState() => new _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  Context _context = Context();
  List<int> messageIds = <int>[];
  ChatMessageRepository messageRepository;
  final TextEditingController _textController = new TextEditingController();
  bool _isComposing = false;
  int _id;
  String _name;
  String _subtitle;
  int _chatMessageListenerId;

  @override
  void initState() {
    super.initState();
    setupChat();
    setupChatListener();
  }

  void setupChat() async {
    _id = widget._chat.getId();
    _name = await widget._chat.getName();
    _subtitle = await widget._chat.getSubtitle();

    setState(() {});
    setupMessages();
  }

  void setupMessages() async {
    messageIds = List.from(await _context.getChatMessages(_id));
    messageRepository = ChatMessageRepository(ChatMsg.getCreator());
    messageRepository.putIfAbsent(ids: messageIds);
    messageIds = messageIds.reversed.toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 24.0,
                //TODO: Add avatar if available
                child: Text(getInitial()),
              ),
              Padding(padding: EdgeInsets.only(left: 8.0)),
              Flexible(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _name != null
                      ? Text(
                          _name,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        )
                      : Container(),
                  _subtitle != null ? Text(_subtitle, style: TextStyle(fontSize: 14)) : Container(),
                ],
              ))
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.videocam),
              onPressed: _handleVideoCall(),
              color: Colors.white,
            ),
            IconButton(icon: Icon(Icons.phone), onPressed: _handleVoiceCall(), color: Colors.white)
          ],
          elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        body: new Column(children: <Widget>[
          new Flexible(
              child: new ListView.builder(
            padding: new EdgeInsets.all(8.0),
            reverse: true,
            itemCount: messageIds.length,
            itemBuilder: (BuildContext context, int index) {
              var messageId = messageIds[index];
              var _message = messageRepository.get(messageId);
              return ChatMessageItem(
                _message,
              );
            },
          )),
          new Divider(height: 1.0),
          new Container(
            decoration: new BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ]));
  }

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new Row(children: <Widget>[
            new IconButton(
              icon: new Icon(Icons.add, color: Theme.of(context).accentColor),
              onPressed: _handleAttachments(),
            ),
            new Flexible(
                child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.all(Radius.circular(50.0))),
              child: new TextField(
                controller: _textController,
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                onSubmitted: _isComposing ? _handleSubmitted : null,
                decoration: new InputDecoration.collapsed(
                  hintText: "Type something...",
                ),
              ),
            )),
            new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: _isComposing
                    ? new IconButton(
                        icon: new Icon(Icons.send),
                        onPressed: () => _handleSubmitted(_textController.text),
                      )
                    : new IconButton(
                        icon: new Icon(Icons.keyboard_voice),
                        onPressed: () => _handleVoiceMessage(),
                      )),
            new IconButton(
              icon: new Icon(Icons.camera_alt),
              onPressed: () => _handleCamera(),
            )
          ]),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? new BoxDecoration(border: new Border(top: new BorderSide(color: Colors.grey[200])))
              : null),
    );
  }

  String getInitial() {
    if (_name != null && _name.isNotEmpty) {
      return _name.substring(0, 1);
    }
    return "";
  }

  void _handleSubmitted(String text) async {
    _textController.clear();
    int id = await _context.createChatMessage(_id, text);
    messageIds.clear();
    setState(() {
      _isComposing = false;
      FocusScope.of(context).requestFocus(new FocusNode());
    });
    await Future.delayed(const Duration(milliseconds: 200));
    setupMessages();
  }

  _handleAttachments() {}

  _handleVoiceMessage() {}

  _handleCamera() {}

  _handleVideoCall() {}

  _handleVoiceCall() {}

  void setupChatListener() async {
    DeltaChatCore core = DeltaChatCore();
    _chatMessageListenerId = await core.listen(Dc.eventIncomingMsg, _success);
  }

  void _success(Event event) {
    debugPrint("fhaar: SUCCESS!!!");

    messageIds.clear();
    setState(() {});
    reload();
  }

  @override
  void dispose() {
    super.dispose();
    tearDownChatListener();
  }

  void tearDownChatListener() {
    DeltaChatCore core = DeltaChatCore();
    core.removeListener(Dc.eventIncomingMsg, _chatMessageListenerId);
  }

  void reload() async {
    await Future.delayed(const Duration(milliseconds: 200));
    setupMessages();
  }
}
