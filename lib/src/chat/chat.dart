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
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_talk/src/chat/chat_bloc.dart';
import 'package:ox_talk/src/chat/chat_composer_bloc.dart';
import 'package:ox_talk/src/chat/chat_composer_event.dart';
import 'package:ox_talk/src/chat/chat_composer_mixin.dart';
import 'package:ox_talk/src/chat/chat_composer_state.dart';
import 'package:ox_talk/src/chat/chat_event.dart';
import 'package:ox_talk/src/chat/chat_profile_view.dart';
import 'package:ox_talk/src/chat/chat_state.dart';
import 'package:ox_talk/src/l10n/localizations.dart';
import 'package:ox_talk/src/message/message_item.dart';
import 'package:ox_talk/src/message/message_list_bloc.dart';
import 'package:ox_talk/src/message/message_list_event.dart';
import 'package:ox_talk/src/message/message_list_state.dart';
import 'package:ox_talk/src/navigation/navigatable.dart';
import 'package:ox_talk/src/navigation/navigation.dart';
import 'package:ox_talk/src/utils/colors.dart';
import 'package:ox_talk/src/utils/dimensions.dart';
import 'package:ox_talk/src/utils/styles.dart';
import 'package:ox_talk/src/utils/toast.dart';
import 'package:ox_talk/src/widgets/avatar.dart';
import 'package:path/path.dart' as Path;
import 'package:rxdart/rxdart.dart';

class Chat extends StatefulWidget {
  final int _chatId;

  Chat(this._chatId);

  @override
  _ChatState createState() => new _ChatState();
}

class _ChatState extends State<Chat> with ChatComposer {
  Navigation navigation = Navigation();
  ChatBloc _chatBloc = ChatBloc();
  MessageListBloc _messagesBloc = MessageListBloc();
  ChatComposerBloc _chatComposerBloc = ChatComposerBloc();

  final TextEditingController _textController = new TextEditingController();
  bool _isComposingText = false;
  String _composingAudioTimer;
  String _filePath = "";
  FileType _selectedFileType;
  String _selectedExtension = "";
  String _fileName = "";
  GlobalKey _imageVideoKey = GlobalKey();

  OverlayEntry _overlayEntry;

  @override
  void initState() {
    super.initState();
    navigation.current = Navigatable(Type.chat, params: [widget._chatId]);
    _chatBloc.dispatch(RequestChat(widget._chatId));
    _chatBloc.dispatch(ChatMarkNoticed());
    final chatObservable = new Observable<ChatState>(_chatBloc.state);
    chatObservable.listen((state) {
      if (state is ChatStateSuccess) {
        _messagesBloc.dispatch(RequestMessages(widget._chatId));
      }
    });
    final contactImportObservable = new Observable<ChatComposerState>(_chatComposerBloc.state);
    contactImportObservable.listen((state) => handleChatComposer(state));
  }

  void handleChatComposer(ChatComposerState state) {
    if (state is ChatComposerRecordingAudio) {
      setState(() {
        _composingAudioTimer = state.timer;
      });
    } else if (state is ChatComposerRecordingAudioStopped) {
      if (state.filePath != null && state.shouldSend) {
        _filePath = state.filePath;
        _onMessageSend(ChatMsg.typeVoice);
      }
      setState(() {
        _composingAudioTimer = null;
      });
    } else if (state is ChatComposerRecordingImageOrVideoStopped) {
      if (state.type != 0 && state.filePath != null) {
        _filePath = state.filePath;
        _onMessageSend(state.type);
      }
    } else if (state is ChatComposerRecordingAborted) {
      _composingAudioTimer = null;
      String chatComposeAborted;
      if (state.error == ChatComposerStateError.missingMicrophonePermission) {
        chatComposeAborted = AppLocalizations.of(context).recordingAudioMessageFailure;
      } else if (state.error == ChatComposerStateError.missingCameraPermission) {
        chatComposeAborted = AppLocalizations.of(context).recordingVideoMessageFailure;
      }
      showToast(chatComposeAborted);
    }
  }

  @override
  void dispose() {
    _chatBloc.dispose();
    _messagesBloc.dispose();
    super.dispose();
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
          _filePath.isNotEmpty ? buildPreview() : Container(),
          new Divider(height: dividerHeight),
          new Container(
            decoration: new BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ]));
  }

  Widget buildPreview() {
    return Column(
      children: <Widget>[
        Divider(height: dividerHeight),
        Padding(padding: EdgeInsets.all(attachmentDividerPadding)),
        SizedBox(
          height: previewMaxSize,
          child: Stack(
            fit: StackFit.loose,
            children: <Widget>[
              _selectedFileType == FileType.IMAGE || _selectedExtension == "gif"
                  ? Image.file(
                      File(_filePath),
                    )
                  : Center(
                      child: Icon(
                        Icons.insert_drive_file,
                        size: previewDefaultIconSize,
                        color: Colors.grey,
                      ),
                    ),
              Padding(
                padding: EdgeInsets.all(iconTextPadding),
                child: GestureDetector(
                  onTap: () => _closePreview(),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadiusDirectional.circular(previewCloseIconBorderRadius)),
                    child: Icon(
                      Icons.close,
                      size: previewCloseIconSize,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(previewFileNamePadding),
          child: Text(_fileName),
        )
      ],
    );
  }

  Widget buildTitle() {
    return BlocBuilder(
      bloc: _chatBloc,
      builder: (context, state) {
        String name;
        String subTitle;
        Color color;
        bool isVerified = false;
        if (state is ChatStateSuccess) {
          name = state.name;
          subTitle = state.subTitle;
          color = state.color;
          isVerified = state.isVerified;
        } else {
          name = "";
          subTitle = "";
        }
        return InkWell(
          onTap: () => _chatTitleTapped(),
          child: Row(
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
                        Visibility(
                          visible: _chatBloc.isGroup,
                          child: Padding(
                              padding: const EdgeInsets.only(right: iconTextPadding),
                              child: Icon(
                                Icons.group,
                                size: iconSize,
                              )),
                        ),
                        Visibility(
                          visible: isVerified,
                          child: Padding(
                              padding: const EdgeInsets.only(right: iconTextPadding),
                              child: Icon(
                                Icons.verified_user,
                                size: iconSize,
                              )),
                        ),
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
          ),
        );
      },
    );
  }

  Widget buildListView() {
    return BlocBuilder(
      bloc: _messagesBloc,
      builder: (context, state) {
        if (state is MessagesStateSuccess) {
          _chatBloc.dispatch(ChatMarkNoticed());
          return new ListView.builder(
            padding: new EdgeInsets.all(listItemPadding),
            reverse: true,
            itemCount: state.messageIds.length,
            itemBuilder: (BuildContext context, int index) {
              int messageId = state.messageIds[index];
              bool hasDateMarker = state.dateMarkerIds.contains(messageId);
              var key = "$messageId-${state.messageLastUpdateValues[index]}";
              return ChatMessageItem(widget._chatId, messageId, _chatBloc.isGroup, hasDateMarker, key);
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
    List<Widget> widgets = List();
    widgets.add(buildLeftComposerPart(
      type: _getComposerType(),
      onShowAttachmentChooser: _showAttachmentChooser,
      onAudioRecordingAbort: _onAudioRecordingAbort,
    ));
    widgets.add(buildCenterComposerPart(
      context: context,
      type: _getComposerType(),
      textController: _textController,
      onTextChanged: _onInputTextChanged,
      text: _composingAudioTimer,
    ));
    widgets.addAll(buildRightComposerPart(
      onRecordAudioPressed: _onRecordAudioPressed,
      onRecordVideoPressed: _onRecordVideoPressed,
      type: _getComposerType(),
      onSendText: _onMessageSend,
      imageVideoKey: _imageVideoKey,
    ));
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: composerHorizontalPadding),
        child: Row(
          children: widgets,
        ),
      ),
    );
  }

  ComposerModeType _getComposerType() {
    if (_isComposingText) {
      return ComposerModeType.isComposing;
    } else {
      if (_composingAudioTimer != null) {
        return ComposerModeType.isVoiceRecording;
      }
    }
    return ComposerModeType.compose;
  }

  void _onInputTextChanged(String text) {
    setState(() {
      _isComposingText = text.length > 0;
    });
  }

  void _onMessageSend([int knownType]) {
    String text = _textController.text;
    _textController.clear();
    if (_filePath.isEmpty) {
      _messagesBloc.submitMessage(text);
    } else {
      int type = 0;
      if (knownType == null) {
        switch (_selectedFileType) {
          case FileType.IMAGE:
            type = ChatMsg.typeImage;
            break;
          case FileType.VIDEO:
            type = ChatMsg.typeVideo;
            break;
          case FileType.AUDIO:
            type = ChatMsg.typeAudio;
            break;
          case FileType.CUSTOM:
            if (_selectedExtension == "gif") {
              type = ChatMsg.typeGif;
            } else {
              type = ChatMsg.typeFile;
            }
            break;
          case FileType.ANY:
            type = ChatMsg.typeFile;
            break;
        }
      } else {
        type = knownType;
      }
      _messagesBloc.submitAttachmentMessage(_filePath, type, text);
    }

    _closePreview();
    setState(() {
      _isComposingText = false;
    });
  }

  _onRecordAudioPressed() async {
    if (ComposerModeType.isVoiceRecording != _getComposerType()) {
      _chatComposerBloc.dispatch(StartAudioRecording());
    } else {
      _chatComposerBloc.dispatch(StopAudioRecording(shouldSend: true));
    }
  }

  _onAudioRecordingAbort() {
    _chatComposerBloc.dispatch(StopAudioRecording(shouldSend: false));
  }

  _onRecordVideoPressed() {
    if (hideOverlay()) {
      return;
    }
    _overlayEntry = OverlayEntry(builder: (context) {
      return Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              hideOverlay();
            },
          ),
          buildCameraChooserOverlay(context, _imageVideoKey, _onCameraStateChange),
        ],
      );
    });
    Overlay.of(context).insert(this._overlayEntry);
  }

  bool hideOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry.remove();
      _overlayEntry = null;
      return true;
    }
    return false;
  }

  _onCameraStateChange(bool pickImage) async {
    hideOverlay();
    _chatComposerBloc.dispatch(StartImageOrVideoRecording(pickImage: pickImage));
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

  void _showAttachmentChooser() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.image),
                title: Text(AppLocalizations.of(context).image),
                onTap: () => _getFilePath(FileType.IMAGE),
              ),
              ListTile(
                leading: Icon(Icons.video_library),
                title: Text(AppLocalizations.of(context).video),
                onTap: () => _getFilePath(FileType.VIDEO),
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf),
                title: Text(AppLocalizations.of(context).pdf),
                onTap: () => _getFilePath(FileType.CUSTOM, "pdf"),
              ),
              ListTile(
                leading: Icon(Icons.gif),
                title: Text(AppLocalizations.of(context).gif),
                onTap: () => _getFilePath(FileType.CUSTOM, "gif"),
              ),
              ListTile(
                leading: Icon(Icons.insert_drive_file),
                title: Text(AppLocalizations.of(context).file),
                onTap: () => _getFilePath(FileType.ANY),
              ),
            ],
          );
        });
  }

  _getFilePath(FileType fileType, [String extension]) async {
    navigation.pop(context);
    String filePath = await FilePicker.getFilePath(type: fileType, fileExtension: extension);
    _fileName = Path.basename(filePath);

    _selectedFileType = fileType;
    _selectedExtension = extension;
    setState(() {
      _filePath = filePath != null ? filePath : "";
      _isComposingText = _filePath.isEmpty ? false : true;
    });
  }

  void _closePreview() {
    setState(() {
      _filePath = "";
      _selectedExtension = "";
      if (_textController.text.isEmpty) {
        _isComposingText = false;
      }
    });
  }

  _chatTitleTapped() {
    navigation.push(
      context,
      MaterialPageRoute(builder: (context) => ChatProfile(widget._chatId)),
    );
  }
}
