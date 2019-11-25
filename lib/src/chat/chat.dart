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
import 'package:ox_coi/src/adaptiveWidgets/adaptive_app_bar.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon_button.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_ink_well.dart';
import 'package:ox_coi/src/background/background_bloc.dart';
import 'package:ox_coi/src/background/background_event_state.dart';
import 'package:ox_coi/src/chat/chat_bloc.dart';
import 'package:ox_coi/src/chat/chat_change_bloc.dart';
import 'package:ox_coi/src/chat/chat_change_event_state.dart';
import 'package:ox_coi/src/chat/chat_composer_bloc.dart';
import 'package:ox_coi/src/chat/chat_composer_event_state.dart';
import 'package:ox_coi/src/chat/chat_composer_mixin.dart';
import 'package:ox_coi/src/chat/chat_event_state.dart';
import 'package:ox_coi/src/chat/chat_profile.dart';
import 'package:ox_coi/src/contact/contact_change_bloc.dart';
import 'package:ox_coi/src/contact/contact_change_event_state.dart';
import 'package:ox_coi/src/data/contact_extension.dart';
import 'package:ox_coi/src/invite/invite_mixin.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/message/message_item.dart';
import 'package:ox_coi/src/message/message_list_bloc.dart';
import 'package:ox_coi/src/message/message_list_event_state.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/share/shared_data.dart';
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/ui/strings.dart';
import 'package:ox_coi/src/utils/dialog_builder.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/utils/key_generator.dart';
import 'package:ox_coi/src/utils/toast.dart';
import 'package:ox_coi/src/widgets/avatar.dart';
import 'package:ox_coi/src/widgets/state_info.dart';
import 'package:path/path.dart' as Path;
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

import 'chat_create_mixin.dart';

class Chat extends StatefulWidget {
  final int chatId;
  final int messageId;
  final String newMessage;
  final String newPath;
  final int newFileType;
  final SharedData sharedData;
  final bool headlessStart;

  Chat({@required this.chatId, this.messageId, this.newMessage, this.newPath, this.newFileType, this.sharedData, this.headlessStart = false});

  @override
  _ChatState createState() => new _ChatState();
}

class _ChatState extends State<Chat> with ChatComposer, ChatCreateMixin, InviteMixin {
  Navigation navigation = Navigation();
  ChatBloc _chatBloc = ChatBloc();
  MessageListBloc _messageListBloc = MessageListBloc();
  ChatComposerBloc _chatComposerBloc = ChatComposerBloc();
  ChatChangeBloc _chatChangeBloc = ChatChangeBloc();
  BackgroundBloc _backgroundBloc;

  final TextEditingController _textController = new TextEditingController();
  bool _isComposingText = false;
  String _composingAudioTimer;
  String _filePath = "";
  int _knownType;
  FileType _selectedFileType;
  String _selectedExtension = "";
  String _fileName = "";
  String _phoneNumbers;
  var _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    navigation.current = Navigatable(Type.chat, params: [widget.chatId]);
    _chatBloc.add(RequestChat(chatId: widget.chatId, isHeadless: widget.headlessStart, messageId: widget.messageId));
    final chatObservable = new Observable<ChatState>(_chatBloc);
    chatObservable.listen((state) {
      if (state is ChatStateSuccess) {
        _phoneNumbers = state.phoneNumbers;
        _messageListBloc.add(RequestMessages(chatId: widget.chatId, messageId: widget.messageId));
        if (widget.newMessage != null || widget.newPath != null) {
          if (widget.newPath.isEmpty) {
            _messageListBloc.add(SendMessage(text: widget.newMessage));
          } else {
            _messageListBloc.add(SendMessage(path: widget.newPath, fileType: widget.newFileType, text: widget.newMessage));
          }
        }
      }
    });
    final chatComposerObservable = new Observable<ChatComposerState>(_chatComposerBloc);
    chatComposerObservable.listen((state) => handleChatComposer(state));
    final messagesObservable = new Observable<MessageListState>(_messageListBloc);
    messagesObservable.listen((state) {
      if (state is MessagesStateSuccess) {
        if (_backgroundBloc.currentBackgroundState == AppLifecycleState.paused.toString()) {
          return;
        }
        _chatChangeBloc.add(ChatMarkMessagesSeen(messageIds: state.messageIds));
      }
    });

    if (widget.sharedData != null) {
      if (widget.sharedData.mimeType.contains("text/")) {
        _textController.text = widget.sharedData.text;
        setState(() {
          _isComposingText = true;
        });
      } else {
        setFileData();
        if (widget.sharedData.text.isNotEmpty) {
          _textController.text = widget.sharedData.text;
          setState(() {
            _isComposingText = true;
          });
        }
      }
    }
  }

  void setFileData() {
    var path = widget.sharedData.path;
    FileType type;
    switch (widget.sharedData.mimeType) {
      case "image/*":
        type = FileType.IMAGE;
        break;
      case "audio/*":
        type = FileType.AUDIO;
        break;
      case "video/*":
        type = FileType.VIDEO;
        break;
      default:
        type = FileType.ANY;
        break;
    }
    setState(() {
      _filePath = path;
      _selectedFileType = type;
      _fileName = widget.sharedData.fileName;
      _isComposingText = true;
    });
  }

  void handleChatComposer(ChatComposerState state) {
    if (state is ChatComposerRecordingAudio) {
      setState(() {
        _composingAudioTimer = state.timer;
      });
    } else if (state is ChatComposerRecordingAudioStopped) {
      if (state.filePath != null && state.shouldSend) {
        _filePath = state.filePath;
        _knownType = ChatMsg.typeVoice;
        _onPrepareMessageSend();
      }
      setState(() {
        _composingAudioTimer = null;
      });
    } else if (state is ChatComposerRecordingImageOrVideoStopped) {
      if (state.type != 0 && state.filePath != null) {
        _filePath = state.filePath;
        _knownType = state.type;
        _onPrepareMessageSend();
      }
    } else if (state is ChatComposerRecordingAborted) {
      _composingAudioTimer = null;
      String chatComposeAborted;
      if (state.error == ChatComposerStateError.missingMicrophonePermission) {
        chatComposeAborted = L10n.get(L.chatAudioRecordingFailed);
      } else if (state.error == ChatComposerStateError.missingCameraPermission) {
        chatComposeAborted = L10n.get(L.chatVideoRecordingFailed);
      }
      showToast(chatComposeAborted);
    }
  }

  @override
  void dispose() {
    _chatBloc.close();
    _messageListBloc.close();
    _chatComposerBloc.close();
    _chatChangeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _backgroundBloc = BlocProvider.of<BackgroundBloc>(context);
    return BlocListener(
      bloc: _backgroundBloc,
      listener: (context, state){
        if(state is BackgroundStateSuccess){
          if(state.state == AppLifecycleState.resumed.toString()){
            _messageListBloc.add(RequestMessages(chatId: widget.chatId, messageId: widget.messageId));
          }
        }
      },
      child: BlocBuilder(
        bloc: _chatBloc,
        builder: (context, state) {
          String name;
          String subTitle;
          Color color;
          bool isVerified = false;
          String imagePath = "";
          bool isGroup = false;
          if (state is ChatStateSuccess) {
            name = state.name;
            subTitle = state.subTitle;
            color = state.color;
            isVerified = state.isVerified;
            imagePath = state.avatarPath;
            isGroup = state.isGroupChat;
          } else {
            name = "";
            subTitle = "";
          }
          return Scaffold(
            appBar: AdaptiveAppBar(
              title: isInviteChat(widget.chatId)
                  ? buildRow(imagePath, name, subTitle, color, context, isVerified)
                  : AdaptiveInkWell(
                      onTap: () => _chatTitleTapped(),
                      child: buildRow(imagePath, name, subTitle, color, context, isVerified),
                    ),
              actions: <Widget>[
                if (!isGroup)
                  AdaptiveIconButton(
                    icon: AdaptiveIcon(icon: IconSource.phone),
                    key: Key(keyChatIconButtonIconPhone),
                    onPressed: onPhonePressed,
                    color: onPrimary,
                  ),
              ],
            ),
            body: new Column(
              children: <Widget>[
                new Flexible(
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider<MessageListBloc>.value(
                        value: _messageListBloc,
                      ),
                      BlocProvider<ChatBloc>.value(
                        value: _chatBloc,
                      ),
                    ],
                    child: MessageList(scrollController: _scrollController, chatId: widget.chatId),
                  ),
                ),
                if (isInviteChat(widget.chatId)) buildInviteChoice(),
                if (_filePath.isNotEmpty) buildPreview(),
                Divider(height: dividerHeight),
                if (state is ChatStateSuccess && !state.isRemoved)
                  new Container(
                    decoration: new BoxDecoration(color: Theme.of(context).cardColor),
                    child: SafeArea(child: _buildTextComposer()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildInviteChoice() {
    return Column(
      children: <Widget>[
        Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(L10n.get(L.chatCreateText), style: Theme.of(context).textTheme.subhead),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 16.0, bottom: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ButtonTheme(
                minWidth: 120.0,
                child: OutlineButton(
                  highlightedBorderColor: error,
                  onPressed: _blockContact,
                  child: Text(
                    L10n.get(L.block).toUpperCase(),
                    style: TextStyle(color: error),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
                ),
              ),
              ButtonTheme(
                minWidth: 120.0,
                child: OutlineButton(
                  highlightedBorderColor: primary,
                  onPressed: _createChat,
                  child: Text(
                    L10n.get(L.ok).toUpperCase(),
                    style: TextStyle(color: primary),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  _blockContact() {
    _messageListBloc.close();
    // Ignoring false positive https://github.com/felangel/bloc/issues/587
    // ignore: close_sinks
    ContactChangeBloc contactChangeBloc = ContactChangeBloc();
    contactChangeBloc.add(BlockContact(messageId: widget.messageId, chatId: widget.chatId));
    navigation.popUntil(context, ModalRoute.withName(Navigation.root));
  }

  _createChat() {
    _messageListBloc.close();
    createChatFromMessage(context, widget.messageId, widget.chatId);
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
                      child: AdaptiveIcon(
                        icon: IconSource.insertDriveFile,
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
                    child: AdaptiveIcon(
                      icon: IconSource.close,
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

  Row buildRow(String imagePath, String name, String subTitle, Color color, BuildContext context, bool isVerified) {
    return Row(
      children: <Widget>[
        Avatar(
          imagePath: imagePath,
          textPrimary: name,
          textSecondary: subTitle,
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
                style: Theme.of(context).textTheme.title.apply(color: onPrimary),
                key: Key(keyChatNameText),
              ),
              Row(
                children: <Widget>[
                  Visibility(
                    visible: _chatBloc.isGroup,
                    child: Padding(
                        padding: const EdgeInsets.only(right: iconTextPadding),
                        child: AdaptiveIcon(
                          icon: IconSource.group,
                          size: iconSize,
                        )),
                  ),
                  Visibility(
                    visible: isVerified,
                    child: Padding(
                        padding: const EdgeInsets.only(right: iconTextPadding),
                        child: AdaptiveIcon(
                          icon: IconSource.verifiedUser,
                          size: iconSize,
                        )),
                  ),
                  Expanded(
                    child: Text(
                      subTitle,
                      style: Theme.of(context).textTheme.subtitle.apply(color: onPrimary),
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
      onCaptureImagePressed: _onCaptureImagePressed,
      type: _getComposerType(),
      onSendText: _onPrepareMessageSend,
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

  void _onPrepareMessageSend() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
    }
    if (isInviteChat(widget.chatId)) {
      _messageListBloc.close();
      createChatFromMessage(context, widget.messageId, widget.chatId, _handleCreateChatSuccess);
    } else {
      _onMessageSend();
    }
  }

  _handleCreateChatSuccess(int chatId) {
    navigation.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => Chat(
          chatId: chatId,
          newMessage: _textController.text,
          newPath: _filePath,
          newFileType: getType(),
        ),
      ),
      ModalRoute.withName(Navigation.root),
      Navigatable(Type.chatList),
    );
  }

  void _onMessageSend() {
    String text = _textController.text;
    _textController.clear();
    if (_filePath.isEmpty) {
      _messageListBloc.add(SendMessage(text: text));
    } else {
      int type = getType();
      _messageListBloc.add(SendMessage(path: _filePath, fileType: type, text: text, isShared: widget.sharedData != null));
    }

    _closePreview();
    setState(() {
      _knownType = null;
      _isComposingText = false;
    });
  }

  int getType() {
    int type = 0;
    if (_knownType == null) {
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
      type = _knownType;
    }
    return type;
  }

  _onRecordAudioPressed() async {
    if (ComposerModeType.isVoiceRecording != _getComposerType()) {
      _chatComposerBloc.add(StartAudioRecording());
    } else {
      _chatComposerBloc.add(StopAudioRecording(shouldSend: true));
    }
  }

  _onAudioRecordingAbort() {
    _chatComposerBloc.add(StopAudioRecording(shouldSend: false));
  }

  _onCaptureImagePressed() {
    _chatComposerBloc.add(StartImageOrVideoRecording(pickImage: true));
  }

  _onRecordVideoPressed() {
    _chatComposerBloc.add(StartImageOrVideoRecording(pickImage: false));
  }

  void _showAttachmentChooser() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: AdaptiveIcon(icon: IconSource.image),
                title: Text(L10n.get(L.image)),
                onTap: () => _getFilePath(FileType.IMAGE),
              ),
              ListTile(
                leading: AdaptiveIcon(icon: IconSource.videoLibrary),
                title: Text(L10n.get(L.video)),
                onTap: () => _getFilePath(FileType.VIDEO),
              ),
              ListTile(
                leading: AdaptiveIcon(icon: IconSource.pictureAsPdf),
                title: Text(pdf),
                onTap: () => _getFilePath(FileType.CUSTOM, "pdf"),
              ),
              ListTile(
                leading: AdaptiveIcon(icon: IconSource.gif),
                title: Text(gif),
                onTap: () => _getFilePath(FileType.CUSTOM, "gif"),
              ),
              ListTile(
                leading: AdaptiveIcon(icon: IconSource.insertDriveFile),
                title: Text(L10n.get(L.file)),
                onTap: () => _getFilePath(FileType.ANY),
              ),
            ],
          );
        });
  }

  _getFilePath(FileType fileType, [String extension]) async {
    navigation.pop(context);
    String filePath = await FilePicker.getFilePath(type: fileType, fileExtension: extension);
    if (filePath == null) {
      return;
    }
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
      if (widget.sharedData != null) {
        _messageListBloc.add(DeleteCacheFile(path: _filePath));
      }
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
      MaterialPageRoute(builder: (context) {
        return BlocProvider.value(
          value: _chatBloc,
          child: ChatProfile(chatId: widget.chatId, messageId: widget.messageId),
        );
      }),
    );
  }

  void onPhonePressed() {
    if (_phoneNumbers == null || _phoneNumbers.isEmpty) {
      showInformationDialog(
        context: context,
        title: L10n.get(L.contactNoPhoneNumber),
        content: L10n.get(L.contactNoPhoneNumberText),
        navigatable: Navigatable(Type.contactNoNumberDialog),
      );
    } else {
      var phoneNumberList = ContactExtension.getPhoneNumberList(_phoneNumbers);
      if (phoneNumberList.length == 1) {
        callNumber(phoneNumberList.first);
      } else {
        var phoneNumberWidgetList = List<Widget>();
        phoneNumberList.forEach((phoneNumber) {
          phoneNumberWidgetList.add(SimpleDialogOption(
            child: Text(phoneNumber),
            onPressed: () {
              navigation.pop(context);
              callNumber(phoneNumber);
            },
          ));
        });
        showNavigatableDialog(
          context: context,
          navigatable: Navigatable(Type.contactStartCallDialog),
          dialog: SimpleDialog(
            title: new Text(L10n.get(L.chatChooseCallNumber)),
            children: phoneNumberWidgetList,
          ),
        );
      }
    }
  }

  Future<bool> callNumber(String phoneNumber) => launch("tel://$phoneNumber");
}

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
              padding: new EdgeInsets.all(8.0),
              reverse: true,
              childrenDelegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    int messageId = state.messageIds[index];
                    int nextMessageId;
                    if (index < (state.messageIds.length - 1)) {
                      nextMessageId = state.messageIds[index + 1];
                    }
                    bool hasDateMarker = state.dateMarkerIds.contains(messageId);
                    var key = createKey(messageId);
                    return ChatMessageItem(
                      chatId: chatId,
                      messageId: messageId,
                      isGroupChat: BlocProvider.of<ChatBloc>(context).isGroup,
                      hasDateMarker: hasDateMarker,
                      nextMessageId: nextMessageId,
                      key: key,
                    );
                  },
                  childCount: state.messageIds.length,
                  findChildIndexCallback: (Key key) {
                    final ValueKey valueKey = key;
                    var id = extractId(valueKey);
                    var indexOf = state.messageIds.indexOf(id);
                    return indexOf;
                  }),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(listItemPaddingBig),
              child: Center(
                child: Text(
                  L10n.get(L.chatNewPlaceholder),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
        } else {
          return StateInfo(showLoading: true);
        }
      },
    );
  }
}
