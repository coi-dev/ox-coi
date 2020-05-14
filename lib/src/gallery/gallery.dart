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

import 'dart:io';

import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/chat/chat_bloc.dart';
import 'package:ox_coi/src/chat/chat_event_state.dart';
import 'package:ox_coi/src/extensions/color_apis.dart';
import 'package:ox_coi/src/extensions/numbers_apis.dart';
import 'package:ox_coi/src/extensions/string_ui.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/message/message_action.dart';
import 'package:ox_coi/src/message/message_attachment_bloc.dart';
import 'package:ox_coi/src/message/message_attachment_event_state.dart';
import 'package:ox_coi/src/message/message_item_bloc.dart';
import 'package:ox_coi/src/message/message_item_event_state.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/share/share.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/widgets/dynamic_appbar.dart';
import 'package:ox_coi/src/widgets/superellipse_icon.dart';
import 'package:video_player/video_player.dart';

import 'gallery_bloc.dart';
import 'gallery_event_state.dart';

class Gallery extends StatefulWidget {
  final int chatId;
  final int messageId;

  Gallery({@required this.chatId, @required this.messageId});

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  // ignore: close_sinks
  MessageItemBloc _messageItemBloc;
  MessageAttachmentBloc _attachmentBloc = MessageAttachmentBloc();

  Navigation _navigation = Navigation();
  ChatBloc _chatBloc = ChatBloc();
  GalleryBloc _galleryBloc = GalleryBloc();
  bool _hideLayout = false;
  bool _isTextExpanded = false;
  String name = "";
  String date = "";
  VideoPlayerController _controller;
  MessageStateData _messageData;
  bool _isImage = false;
  int _videoPosition = 0;
  int _videoDuration = 0;
  int _messageId;
  double _tapDown;
  bool _isPlaying = false;
  double _aspectRatio = 4.0 / 3.0;

  final List<MessageAction> _messageAttachmentActions = <MessageAction>[
    MessageAction(title: L10n.get(L.messageActionForward), icon: IconSource.forward, messageActionTag: MessageActionTag.forward),
    MessageAction(title: L10n.get(L.messageActionDelete), icon: IconSource.delete, messageActionTag: MessageActionTag.delete),
    MessageAction(title: L10n.get(L.messageActionFlagUnflag), icon: IconSource.flag, messageActionTag: MessageActionTag.flag),
    MessageAction(title: L10n.get(L.messageActionShare), icon: IconSource.share, messageActionTag: MessageActionTag.share),
  ];

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.gallery);
    _messageItemBloc = MessageItemBloc();
    _messageId = widget.messageId;
    _chatBloc.add(RequestChat(chatId: widget.chatId, messageId: _messageId));
    _messageItemBloc.add(LoadMessage(chatId: widget.chatId, messageId: _messageId));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener(
          bloc: _chatBloc,
          listener: (context, state) {
            if (state is ChatStateSuccess) {
              setState(() {
                name = state.name;
              });
            }
          },
        ),
        BlocListener(
          bloc: _attachmentBloc,
          listener: (context, state) {
            if (state is MessageAttachmentStateGetNextSuccess) {
              if (state.messageId != null) {
                if (state.messageId == 0) {
                  L10n.get(L.noMoreMedia).showToast();
                } else {
                  _messageId = state.messageId;
                  _messageItemBloc.add(LoadMessage(chatId: widget.chatId, messageId: state.messageId));
                }
              }
            }
          },
        ),
        BlocListener(
          bloc: _messageItemBloc,
          listener: (context, state) {
            if (state is MessageItemStateSuccess) {
              _messageData = state.messageStateData;
              _isImage = _messageData.attachmentStateData.type == ChatMsg.typeImage || _messageData.attachmentStateData.type == ChatMsg.typeGif;
              setState(() {
                date = _messageData?.timestamp?.getGalleryTime();
              });
              if (!_isImage) {
                _galleryBloc.add(InitializeVideoPlayer(path: _messageData.attachmentStateData.path));
              }
            }
          },
        ),
        BlocListener(
          bloc: _galleryBloc,
          listener: (context, state) {
            if (state is VideoPlayerInitialized) {
              setState(() {
                _controller = state.videoPlayerController;
                _aspectRatio = _controller.value.aspectRatio;
                _videoPosition = 0;
                _videoDuration = state.duration;
              });
            } else if (state is VideoPlayerStateSuccess) {
              setState(() {
                _isPlaying = state.isPlaying;
                _videoPosition = state.position;
              });
            } else if (state is VideoPlayerDisposed) {
              setState(() {
                _controller = null;
              });
            }
          },
        )
      ],
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: !_hideLayout
            ? AppBar(
                leading: AppBarBackButton(context: context),
                iconTheme: IconThemeData(color: CustomTheme.of(context).white),
                backgroundColor: CustomTheme.of(context).black.fade(),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.title.apply(color: CustomTheme.of(context).white),
                    ),
                    Text(
                      date,
                      style: Theme.of(context).textTheme.body1.apply(color: CustomTheme.of(context).white),
                    )
                  ],
                ),
                actions: <Widget>[
                  PopupMenuButton(
                    itemBuilder: (BuildContext context) {
                      return _messageAttachmentActions.map((MessageAction choice) {
                        return PopupMenuItem<MessageAction>(
                          value: choice,
                          child: Row(
                            children: <Widget>[
                              AdaptiveIcon(icon: choice.icon),
                              Padding(padding: EdgeInsets.only(right: iconTextPadding)),
                              Text(choice.title),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    onSelected: _onSelected,
                  )
                ],
              )
            : null,
        body: BlocBuilder(
          bloc: _messageItemBloc,
          builder: (context, state) {
            if (state is MessageItemStateSuccess) {
              return Stack(
                children: <Widget>[
                  GestureDetector(
                    onTap: _onTapped,
                    onHorizontalDragUpdate: (details) {
                      _tapDown = details.localPosition.dx;
                    },
                    onHorizontalDragEnd: (details) {
                      setState(() {
                        _isPlaying = false;
                      });
                      if (_tapDown > (details.primaryVelocity + 50)) {
                        _goToNextPrevious(dir: actionNextMessage);
                      } else if (_tapDown < (details.primaryVelocity - 50)) {
                        _goToNextPrevious(dir: actionPreviousMessage);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: CustomTheme.of(context).black,
                        image: _isImage
                            ? DecorationImage(
                                image: FileImage(File(_messageData.attachmentStateData.path)),
                                fit: BoxFit.contain,
                              )
                            : null,
                      ),
                      child: !_isImage
                          ? Center(
                              child: AspectRatio(
                                aspectRatio: _aspectRatio,
                                child: Visibility(visible: _controller != null, child: VideoPlayer(_controller)),
                              ),
                            )
                          : null,
                    ),
                  ),
                  Visibility(
                    visible: !_hideLayout && (_messageData.text.isNotEmpty || !_isImage),
                    child: Positioned(
                      bottom: zero,
                      left: zero,
                      right: zero,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isTextExpanded = !_isTextExpanded;
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(dimension16dp),
                              color: _messageData.text.isNotEmpty ? CustomTheme.of(context).black.fade() : null,
                              child: LayoutBuilder(builder: (context, size) {
                                final span = TextSpan(
                                  text: _messageData.text,
                                  style: Theme.of(context).textTheme.body1.apply(color: CustomTheme.of(context).white),
                                );
                                final textPainter = TextPainter(
                                  text: span,
                                  maxLines: 2,
                                  textDirection: TextDirection.ltr,
                                );
                                textPainter.layout(maxWidth: size.maxWidth);

                                if (textPainter.didExceedMaxLines) {
                                  // The text has more than two lines.
                                  return RichText(
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: _isTextExpanded ? 50 : 2,
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text: _messageData.text,
                                        style: Theme.of(context).textTheme.body1.apply(color: CustomTheme.of(context).white),
                                      ),
                                    ]),
                                  );
                                } else {
                                  return Text(
                                    _messageData.text,
                                    style: Theme.of(context).textTheme.body1.apply(color: CustomTheme.of(context).white),
                                    maxLines: 2,
                                  );
                                }
                              }),
                            ),
                            Visibility(
                              visible: !_isImage,
                              child: Container(
                                color: CustomTheme.of(context).black.fade(),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left: dimension16dp),
                                      child: Text(
                                        _videoPosition.getVideoTimeFromTimestamp(),
                                        style: Theme.of(context).textTheme.body1.apply(color: CustomTheme.of(context).white),
                                      ),
                                    ),
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          trackHeight: dimension4dp,
                                          thumbShape: RoundSliderThumbShape(
                                            disabledThumbRadius: dimension8dp,
                                            enabledThumbRadius: dimension8dp,
                                          ),
                                        ),
                                        child: Slider(
                                          value: _videoPosition.roundToDouble(),
                                          min: zero,
                                          max: _videoDuration.roundToDouble(),
                                          onChanged: _seekVideo,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: dimension16dp),
                                      child: Text(
                                        _videoDuration.getVideoTimeFromTimestamp(),
                                        style: Theme.of(context).textTheme.body1.apply(color: CustomTheme.of(context).white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !_isImage && !_hideLayout,
                    child: Align(
                      alignment: Alignment.center,
                      child: IconButton(
                        iconSize: dimension72dp,
                        icon: SuperellipseIcon(
                          icon: _isPlaying ? IconSource.pause : IconSource.play,
                          iconColor: CustomTheme.of(context).white,
                          color: CustomTheme.of(context).black.fade(),
                          backgroundSize: dimension72dp,
                        ),
                        onPressed: () {
                          if (_isPlaying) {
                            _galleryBloc.add(PauseVideoPlayer());
                          } else {
                            _galleryBloc.add(PlayVideoPlayer());
                          }
                        },
                      ),
                    ),
                  )
                ],
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  void _onTapped() {
    setState(() {
      _hideLayout = !_hideLayout;
    });
  }

  void _onSelected(MessageAction action) {
    switch (action.messageActionTag) {
      case MessageActionTag.forward:
        _navigation.push(
            context,
            MaterialPageRoute(
              builder: (context) => Share(msgIds: [_messageId], messageActionTag: action.messageActionTag),
            ));
        break;
      case MessageActionTag.delete:
        List<int> messageList = List();
        messageList.add(_messageId);
        _messageItemBloc.add(DeleteMessage(id: _messageId));
        break;
      case MessageActionTag.flag:
        _messageItemBloc.add(FlagUnflagMessage(id: _messageId));
        break;
      case MessageActionTag.share:
        _attachmentBloc.add(ShareAttachment(chatId: widget.chatId, messageId: _messageId));
        break;
      default:
        break;
    }
  }

  void _seekVideo(double value) async => _galleryBloc.add(SeekVideoPlayer(position: value, videoStopped: false));

  void _goToNextPrevious({int dir}) => _attachmentBloc.add(GetNextPreviousImage(messageId: _messageId, dir: dir));
}
