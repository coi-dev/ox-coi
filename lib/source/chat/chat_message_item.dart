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
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';

class ChatMessageItem extends StatefulWidget {
  final ChatMsg _msg;

  ChatMessageItem(this._msg);

  @override
  _ChatMessageItemState createState() => _ChatMessageItemState();
}

class _ChatMessageItemState extends State<ChatMessageItem>  with TickerProviderStateMixin{
  final double textMaxWidth = 200.0;
  AnimationController animationController;
  String _text;
  String _timestamp;
  bool _isOutgoing;

  @override
  void initState() {
    super.initState();
//    animationController = AnimationController(duration: new Duration(milliseconds: 700), vsync: this, );
    setupMessage();
  }

  void setupMessage() async{
    if(widget._msg != null) {
      _text = await widget._msg.getText();
      var timestamp = await widget._msg.getTimestamp();
      _timestamp = formatDate(
          DateTime.fromMillisecondsSinceEpoch(timestamp), [HH, ':', nn]);
      _isOutgoing = await widget._msg.isOutgoing();

      setState(() {});
//      if (animationController != null) {
//        animationController.forward();
//      }
    }
    else{
      debugPrint("fhaar: MSG IS NULL!!!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: new Row(
        children:
        _isOutgoing != null ? (_isOutgoing ? getSentMessageLayout() : getReceivedMessageLayout()) : <Widget>[],
      ),
    );
//    return new SizeTransition(
//      sizeFactor: new CurvedAnimation(
//        parent: animationController, curve: Curves.easeOut),
//        axisAlignment: 0.0,
//        child: new Container(
//          margin: const EdgeInsets.symmetric(vertical: 10.0),
//          child: new Row(
//            children:
//             _isOutgoing != null ? (_isOutgoing ? getSentMessageLayout() : getReceivedMessageLayout()) : <Widget>[],
//        ),
//      ),
//    );
  }

  List<Widget> getSentMessageLayout() {
    return <Widget>[
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: 4.0, right: 4.0),
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              LimitedBox(
                  maxWidth: 260,
                  child:Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        boxShadow: [
                          new BoxShadow(
                            color: Colors.grey,
                            blurRadius: 2.0,
                          ),
                        ],
                        color: Colors.cyanAccent,
                        borderRadius: BorderRadius.all(Radius.circular(8.0))
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
//                    SizedBox(
//                      width: 260,
//                      child: Image.network("https://images.pexels.com/photos/40541/christmas-snow-snowman-decoration-40541.jpeg", fit: BoxFit.cover,   ),
////                      width: 255,
//                    ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: new Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              LimitedBox(
                                maxWidth: textMaxWidth,
                                child: _text != null ? new Text(
                                  _text,
                                ): Container(),
                              ),
                              Padding(padding: EdgeInsets.only(left: 8.0)),
                              _timestamp != null ? new Text(
                                  _timestamp,
                                  style: TextStyle(
                                    fontSize: 12,
                                  )
                              ): Container(),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
              )
            ],
          ),
        ),
      )
    ];
  }

  List<Widget> getReceivedMessageLayout() {
    return <Widget>[
      Container(
          padding: EdgeInsets.only(left: 4.0, right: 4.0),
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              LimitedBox(
                  maxWidth: 260,
                  child:Container(
                    decoration: BoxDecoration(shape: BoxShape.rectangle, boxShadow: [new BoxShadow(
                      color: Colors.grey,
                      blurRadius: 2.0,
                    ),], color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
//                    SizedBox(
//                      width: 260,
//                      child: Image.network("https://images.pexels.com/photos/40541/christmas-snow-snowman-decoration-40541.jpeg", fit: BoxFit.cover,   ),
////                      width: 255,
//                    ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: new Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              LimitedBox(
                                maxWidth: textMaxWidth,
                                child: _text != null ? new Text(
                                  _text,
                                ):Container(),
                              ),
                              Padding(padding: EdgeInsets.only(left: 8.0)),
                              _timestamp != null ? new Text(
                                  _timestamp,
                                  style: TextStyle(
                                    fontSize: 12,
                                  )
                              ): Container(),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
              )
            ],
          )
      )
    ];
  }

  @override
  void dispose() {
    if(animationController != null) {
      animationController.dispose();
    }
    super.dispose();
  }
}
//Image.network("https://images.pexels.com/photos/40541/christmas-snow-snowman-decoration-40541.jpeg", width: 200, height: 150,),