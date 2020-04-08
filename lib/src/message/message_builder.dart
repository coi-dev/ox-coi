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
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/extensions/color_apis.dart';
import 'package:ox_coi/src/extensions/numbers_apis.dart';
import 'package:ox_coi/src/extensions/string_apis.dart';
import 'package:ox_coi/src/extensions/string_markdown.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/message/message_attachment_bloc.dart';
import 'package:ox_coi/src/message/message_attachment_event_state.dart';
import 'package:ox_coi/src/message/message_item_bloc.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'message_item_event_state.dart';

class MessageData extends InheritedWidget {
  final Color backgroundColor;
  final Color textColor;
  final AdaptiveIcon icon;
  final BorderRadius borderRadius;
  final MessageStateData messageStateData;
  final Color secondaryTextColor;
  final bool useInformationText;

  MessageData({
    Key key,
    @required this.backgroundColor,
    @required this.textColor,
    @required this.borderRadius,
    @required this.messageStateData,
    this.icon,
    this.secondaryTextColor,
    this.useInformationText = false,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static MessageData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MessageData>();
  }
}

class MessageMaterial extends StatelessWidget {
  final Widget child;
  final double elevation;

  const MessageMaterial({Key key, @required this.child, this.elevation = messagesElevation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      borderRadius: MessageData.of(context).borderRadius,
      color: MessageData.of(context).backgroundColor,
      textStyle: TextStyle(color: MessageData.of(context).textColor),
      child: child,
    );
  }
}

class MessageText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final markdown = _getText(context).markdownValue;
    return Padding(
      padding: getNamePaddingForGroups(context),
      child: MarkdownBody(
        data: markdown,
        onTapLink: (url) {
          _launch(url: url);
        },
        ),
    );
  }
}

Future<void> _launch({@required String url}) async {
  if (await canLaunch(url)) {
    await launch(url);
  }
}

class MessagePartForwarded extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var messageStateData = _getMessageStateData(context);
    Color color = messageStateData.isOutgoing ? CustomTheme.of(context).onSecondary.half() : CustomTheme.of(context).onSurface.half();
    double verticalPadding = messageStateData.isGroup && !messageStateData.isOutgoing ? dimension2dp : dimension8dp;
    return Padding(
      padding: EdgeInsets.only(top: verticalPadding, left: messagesHorizontalInnerPadding, right: messagesHorizontalInnerPadding, bottom: messageStateData.hasFile ? verticalPadding : zero),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AdaptiveIcon(
            icon: IconSource.forward,
            color: color,
            size: dimension16dp,
          ),
          Text(
            L10n.get(L.forwarded),
            style: Theme.of(context).textTheme.caption.apply(color: color),
          ),
        ],
      ),
    );
  }
}


String _getText(BuildContext context) {
  return MessageData.of(context).useInformationText ? _getMessageStateData(context).informationText : _getMessageStateData(context).text;
}

MessageStateData _getMessageStateData(BuildContext context) => MessageData.of(context).messageStateData;

class MessageStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final icon = MessageData.of(context).icon;

    if (icon != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: messagesVerticalInnerPadding, horizontal: messagesHorizontalInnerPadding),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: iconTextPadding),
              child: icon,
            ),
            Flexible(
              child: Text(
                _getText(context),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: messagesVerticalInnerPadding, horizontal: messagesHorizontalInnerPadding),
        child: Text(
          _getMessageStateData(context).text,
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}

class MessageAttachment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (isImageOrGif(context)) {
      return MessagePartImageVideoAttachment();
    } else if (isAudioOrVoice(context)) {
      return MessagePartAudioAttachment();
    } else if (isVideo(context)) {
      return MessagePartImageVideoAttachment(
        isVideo: true,
      );
    } else {
      return MessagePartGenericAttachment();
    }
  }
}

bool isImageOrGif(BuildContext context) {
  final attachment = _getMessageStateData(context).attachmentStateData;
  return attachment != null && attachment.type == ChatMsg.typeImage || attachment.type == ChatMsg.typeGif;
}

bool isAudioOrVoice(BuildContext context) {
  final attachment = _getMessageStateData(context).attachmentStateData;
  return attachment != null && attachment.type == ChatMsg.typeAudio || attachment.type == ChatMsg.typeVoice;
}

bool isVideo(BuildContext context) {
  final attachment = _getMessageStateData(context).attachmentStateData;
  return attachment != null && attachment.type == ChatMsg.typeVideo;
}

class MessagePartAudioAttachment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: getNamePaddingForGroups(context),
        child: Image.asset(
          "assets/images/img_audio_waves.png",
          width: messageAudioImageWidth,
          color: CustomTheme.of(context).onSurface,
        ));
  }
}

class MessagePartImageVideoAttachment extends StatefulWidget {
  final bool isVideo;

  MessagePartImageVideoAttachment({this.isVideo = false});

  @override
  _MessagePartImageVideoAttachmentState createState() => _MessagePartImageVideoAttachmentState();
}

class _MessagePartImageVideoAttachmentState extends State<MessagePartImageVideoAttachment> {
  ImageProvider imageProvider;
  String thumbnailPath = "";
  String durationString = "";

  // ignore: close_sinks
  MessageAttachmentBloc _messageAttachmentBloc = MessageAttachmentBloc();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.isVideo) {
      File file = File(_getMessageStateData(context).attachmentStateData.path);
      imageProvider = FileImage(file);
    } else {
      if (imageProvider == null) {
        imageProvider = MemoryImage(kTransparentImage);
        _messageAttachmentBloc.add(LoadThumbnailAndDuration(
            path: _getMessageStateData(context).attachmentStateData.path, duration: _getMessageStateData(context).attachmentStateData.duration));
      }
    }
    precacheImage(imageProvider, context, onError: (error, stacktrace) {
      setState(() {
        imageProvider = MemoryImage(kTransparentImage);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var text = _getMessageStateData(context).text;
    BorderRadius imageBorderRadius = getImageBorderRadius(context, text);
    return BlocListener(
      bloc: _messageAttachmentBloc,
      listener: (context, state) {
        if (state is MessageAttachmentStateSuccess) {
          setState(() {
            if (state.path.isNotEmpty) {
              File file = File(state.path);
              imageProvider = FileImage(file);
            }
            if (!state.duration.isNullOrEmpty()) {
              durationString = state.duration;
            }
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Stack(
            children: <Widget>[
              AspectRatio(
                child: ClipRRect(
                  borderRadius: imageBorderRadius,
                  child: Image(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                aspectRatio: 4 / 3,
              ),
              Visibility(
                visible: widget.isVideo,
                child: Positioned.fill(
                  child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: dimension48dp,
                        width: dimension48dp,
                        decoration: ShapeDecoration(
                          shape: CircleBorder(),
                          color: CustomTheme.of(context).black.fade(),
                        ),
                        child: AdaptiveIcon(
                          icon: IconSource.play,
                          size: dimension24dp,
                          color: CustomTheme.of(context).white,
                        ),
                      )),
                ),
              ),
              Visibility(
                visible: widget.isVideo && durationString.isNotEmpty,
                child: Positioned(
                  bottom: dimension8dp,
                  left: dimension12dp,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(dimension24dp),
                      color: CustomTheme.of(context).black.fade(),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: dimension2dp, horizontal: dimension8dp),
                      child: Text(
                        durationString,
                        style: Theme.of(context).textTheme.caption.apply(color: CustomTheme.of(context).white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Visibility(
            visible: text.isNotEmpty,
            child: Flexible(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: messagesVerticalPadding,
                    bottom: messagesVerticalInnerPadding,
                    left: messagesHorizontalInnerPadding,
                    right: messagesHorizontalInnerPadding),
                child: Text(text),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BorderRadius getImageBorderRadius(BuildContext context, String text) {
    var messageBorderRadius = MessageData.of(context).borderRadius;
    var messageStateData = _getMessageStateData(context);
    if (messageStateData.isGroup && !messageStateData.isOutgoing && text.isNotEmpty) {
      messageBorderRadius = BorderRadius.zero;
    } else if (messageStateData.isGroup && !messageStateData.isOutgoing && text.isEmpty) {
      messageBorderRadius = BorderRadius.only(bottomLeft: messageBorderRadius.bottomLeft, bottomRight: messageBorderRadius.bottomRight);
    } else if (text.isNotEmpty) {
      messageBorderRadius = BorderRadius.only(topLeft: messageBorderRadius.topLeft, topRight: messageBorderRadius.topRight);
    }
    return messageBorderRadius;
  }
}

class MessagePartGenericAttachment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var text = _getMessageStateData(context).text;
    AttachmentStateData attachment = _getMessageStateData(context).attachmentStateData;
    return Padding(
      padding: getNamePaddingForGroups(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: iconTextPadding),
                child: AdaptiveIcon(
                  icon: IconSource.attachFile,
                  size: messagesFileIconSize,
                  color: MessageData.of(context).textColor,
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      attachment.filename,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(attachment.size.byteToPrintableSize()),
                  ],
                ),
              ),
            ],
          ),
          Visibility(
            visible: text.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.only(top: messagesVerticalInnerPadding),
              child: Text(text),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageDateTime extends StatelessWidget {
  final int timestamp;
  final bool hasDateMarker;
  final bool showTime;

  const MessageDateTime({Key key, @required this.timestamp, this.hasDateMarker = false, this.showTime = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String date;
    if (hasDateMarker && showTime) {
      date = "${timestamp.getDateFromTimestamp(true, true)} - ${timestamp.getTimeFormTimestamp()}";
    } else if (hasDateMarker) {
      date = timestamp.getDateFromTimestamp(true, true);
    } else {
      date = timestamp.getTimeFormTimestamp();
    }
    return Center(
      child: Text(
        date,
        style: TextStyle(
          color: CustomTheme.of(context).onSurface.fade(),
        ),
      ),
    );
  }
}

class MessagePartTime extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String time = _getMessageStateData(context).timestamp.getTimeFormTimestamp();
    return Text(
      time,
      style: TextStyle(color: MessageData.of(context).secondaryTextColor),
    );
  }
}

class MessagePartState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageItemBloc, MessageItemState>(
      builder: (context, state) {
        if (state is MessageItemStateSuccess) {
          var messageState = state.messageStateData.state;
          if (messageState == ChatMsg.messageStateDelivered ||
              messageState == ChatMsg.messageStateReceived ||
              messageState == ChatMsg.messageStatePending ||
              messageState == ChatMsg.messageStateFailed) {
            IconSource icon;
            Color color;
            switch (messageState) {
              case ChatMsg.messageStateDelivered:
                icon = IconSource.done;
                color = MessageData.of(context).secondaryTextColor;
                break;
              case ChatMsg.messageStateReceived:
                icon = IconSource.doneAll;
                color = MessageData.of(context).secondaryTextColor;
                break;
              case ChatMsg.messageStatePending:
                icon = IconSource.pending;
                color = MessageData.of(context).secondaryTextColor;
                break;
              case ChatMsg.messageStateFailed:
                icon = IconSource.error;
                color = CustomTheme.of(context).error;
                break;
            }
            return Padding(
              padding: const EdgeInsets.only(top: iconTextTopPadding, left: iconTextPadding),
              child: AdaptiveIcon(
                icon: icon,
                size: dimension16dp,
                color: color,
              ),
            );
          }
        }
        return Container();
      },
    );
  }
}

class MessagePartFlag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageItemBloc, MessageItemState>(
      builder: (context, state) {
        return Visibility(
          visible: state is MessageItemStateSuccess && state.messageStateData.isFlagged,
          child: Padding(
            padding: const EdgeInsets.only(top: dimension8dp, right: dimension4dp, left: dimension4dp),
            child: AdaptiveIcon(
              icon: IconSource.flag,
              color: Colors.yellow, // TODO remove Colors.xyz call as soon as possible
            ),
          ),
        );
      },
    );
  }
}

EdgeInsetsGeometry getNamePaddingForGroups(BuildContext context) {
  var messageStateData = _getMessageStateData(context);
  if (messageStateData.isGroup && !messageStateData.isOutgoing || messageStateData.isForwarded) {
    return EdgeInsets.only(
      top: dimension2dp,
      bottom: messagesVerticalInnerPadding,
      left: messagesHorizontalInnerPadding,
      right: messagesHorizontalInnerPadding,
    );
  } else {
    return EdgeInsets.symmetric(vertical: messagesVerticalInnerPadding, horizontal: messagesHorizontalInnerPadding);
  }
}
