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
import 'package:ox_coi/src/adaptive_widgets/adaptive_bottom_sheet.dart';
import 'package:ox_coi/src/adaptive_widgets/adaptive_bottom_sheet_action.dart';
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/chat/chat_bloc.dart';
import 'package:ox_coi/src/chat/chat_change_bloc.dart';
import 'package:ox_coi/src/chat/chat_change_event_state.dart';
import 'package:ox_coi/src/chat/chat_composer_bloc.dart';
import 'package:ox_coi/src/chat/chat_composer_event_state.dart';
import 'package:ox_coi/src/chat/chat_composer_mixin.dart';
import 'package:ox_coi/src/chat/chat_event_state.dart';
import 'package:ox_coi/src/chat/chat_profile.dart';
import 'package:ox_coi/src/contact/contact_item_bloc.dart';
import 'package:ox_coi/src/contact/contact_item_event_state.dart';
import 'package:ox_coi/src/data/contact_extension.dart';
import 'package:ox_coi/src/extensions/color_apis.dart';
import 'package:ox_coi/src/extensions/string_apis.dart';
import 'package:ox_coi/src/extensions/string_ui.dart';
import 'package:ox_coi/src/invite/invite_mixin.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/lifecycle/lifecycle_bloc.dart';
import 'package:ox_coi/src/lifecycle/lifecycle_event_state.dart';
import 'package:ox_coi/src/message_list/message_list.dart';
import 'package:ox_coi/src/message_list/message_list_bloc.dart';
import 'package:ox_coi/src/message_list/message_list_event_state.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/share/incoming_shared_data.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/image.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/utils/vibration.dart';
import 'package:ox_coi/src/widgets/avatar.dart';
import 'package:ox_coi/src/widgets/button.dart';
import 'package:ox_coi/src/widgets/modal_builder.dart';
import 'package:ox_coi/src/widgets/dynamic_appbar.dart';
import 'package:ox_coi/src/widgets/superellipse_icon.dart';
import 'package:path/path.dart' as Path;
import 'package:url_launcher/url_launcher.dart';

import 'chat_create_mixin.dart';

class Chat extends StatefulWidget {
  final int chatId;
  final int messageId;
  final String newMessage;
  final String newPath;
  final int newFileType;
  final IncomingSharedData sharedData;
  final bool headlessStart;

  Chat({@required this.chatId, this.messageId, this.newMessage, this.newPath, this.newFileType, this.sharedData, this.headlessStart = false});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> with ChatComposer, ChatCreateMixin, InviteMixin {
  final _navigation = Navigation();
  final _chatBloc = ChatBloc();
  final _messageListBloc = MessageListBloc();
  final _chatComposerBloc = ChatComposerBloc();
  final _chatChangeBloc = ChatChangeBloc();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isComposingText = false;
  bool _isLocked = false;
  bool _isStopped = false;
  bool _isPlaying = false;
  bool _hasPermissions = false;
  String _composingAudioTimer;
  List<double> _dbPeakList;
  int _replayTime = 0;
  String _filePath = "";
  int _knownType;
  FileType _selectedFileType;
  String _selectedExtension = "";
  String _fileName = "";

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.chat, params: [widget.chatId]);
    _chatBloc.add(RequestChat(chatId: widget.chatId, isHeadless: widget.headlessStart, messageId: widget.messageId));
    _chatBloc.add(ClearNotifications());
    _chatComposerBloc.listen((state) => handleChatComposer(state));
    if (widget.sharedData != null) {
      if (widget.sharedData.path.isEmpty && widget.sharedData.mimeType.contains("text/")) {
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
    final path = widget.sharedData.path;
    FileType type;
    if (widget.sharedData.mimeType.startsWith("image/")) {
      type = FileType.image;
    } else if (widget.sharedData.mimeType.startsWith("audio/")) {
      type = FileType.audio;
    } else if (widget.sharedData.mimeType.startsWith("video/")) {
      type = FileType.video;
    } else {
      type = FileType.any;
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
    } else if (state is ChatComposerDBPeakUpdated) {
      setState(() {
        _dbPeakList = state.dbPeakList;
      });
    } else if (state is ChatComposerPermissionsAccepted) {
      setState(() {
        _hasPermissions = true;
      });
    } else if (state is ChatComposerRecordingAudioStopped) {
      if (state.filePath != null) {
        _filePath = state.filePath;
        _knownType = ChatMsg.typeVoice;
      }
      setState(() {
        _dbPeakList = state.dbPeakList;
        _isStopped = true;
      });

      if (state.sendAudio) {
        _onPrepareMessageSend();
      }
    } else if (state is ChatComposerRecordingAudioAborted) {
      _clearAudioComposer();
    } else if (state is ChatComposerReplayStopped) {
      setState(() {
        _isPlaying = false;
        _replayTime = 0;
      });
    } else if (state is ChatComposerReplayTimeUpdated) {
      setState(() {
        _dbPeakList = state.dbPeakList;
        _replayTime = state.replayTime;
      });
    } else if (state is ChatComposerRecordingImageOrVideoStopped) {
      if (state.type != 0 && state.filePath != null) {
        _filePath = state.filePath;
        _knownType = state.type;
        _onPrepareMessageSend();
      }
    } else if (state is ChatComposerRecordingFailed) {
      _composingAudioTimer = null;
      _dbPeakList = null;
      String chatComposeFailed;
      if (state.error == ChatComposerStateError.missingMicrophonePermission) {
        setState(() {
          _hasPermissions = false;
        });
        chatComposeFailed = L10n.get(L.chatAudioRecordingFailed);
      } else if (state.error == ChatComposerStateError.missingCameraPermission) {
        chatComposeFailed = L10n.get(L.chatVideoRecordingFailed);
      }
      chatComposeFailed.showToast();
    }
  }

  _clearAudioComposer() async {
    await Future.delayed(Duration(microseconds: 100));
    setState(() {
      _dbPeakList?.clear();
      _composingAudioTimer = null;
      _isStopped = false;
      _isLocked = false;
      _isPlaying = false;
      _replayTime = 0;
    });
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
    return MultiBlocListener(
      listeners: [
        BlocListener<LifecycleBloc, LifecycleState>(
          listener: (context, state) {
            if (state is LifecycleStateSuccess) {
              if (state.state == AppLifecycleState.resumed.toString()) {
                _messageListBloc.add(RequestMessageList(chatId: widget.chatId, messageId: widget.messageId));
              }
            }
          },
        ),
        BlocListener(
          bloc: _chatBloc,
          listener: (context, state) {
            if (state is ChatStateSuccess) {
              _messageListBloc.add(RequestMessageList(chatId: widget.chatId, messageId: widget.messageId));
              if (!widget.newPath.isNullOrEmpty()) {
                _messageListBloc.add(SendMessage(path: widget.newPath, fileType: widget.newFileType, text: widget.newMessage));
              } else if (!widget.newMessage.isNullOrEmpty()) {
                _messageListBloc.add(SendMessage(text: widget.newMessage));
              }
            }
          },
        ),
        BlocListener(
          bloc: _messageListBloc,
          listener: (context, state) {
            if (BlocProvider.of<LifecycleBloc>(context).currentBackgroundState == AppLifecycleState.paused.toString()) {
              return;
            }
            if (state is MessageListStateSuccess) {
              _chatChangeBloc.add(ChatMarkMessagesSeen(messageIds: state.messageIds));
            }
          },
        )
      ],
      child: BlocBuilder(
        bloc: _chatBloc,
        builder: (context, state) {
          String name = "";
          String subTitle = "";
          bool isVerified = false;
          bool isGroupChat = false;
          String imagePath = "";
          Color color;
          String phoneNumbers;

          if (state is ChatStateSuccess) {
            name = state.name;
            subTitle = state.subTitle;
            color = state.color;
            isVerified = state.isVerified;
            imagePath = state.avatarPath;
            isGroupChat = state.isGroupChat;
            phoneNumbers = state.phoneNumbers;
          }

          return Scaffold(
            appBar: DynamicAppBar(
              titleWidget: isInviteChat(widget.chatId)
                  ? ChatAppBar(
                      imagePath: imagePath,
                      name: name,
                      subTitle: subTitle,
                      color: color,
                      isVerified: isVerified,
                      isGroup: isGroupChat,
                    )
                  : GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _chatTitleTapped,
                      key: Key(keyChatIconTitleText),
                      child: ChatAppBar(
                        imagePath: imagePath,
                        name: name,
                        subTitle: subTitle,
                        color: color,
                        isVerified: isVerified,
                        isGroup: isGroupChat,
                      ),
                    ),
              leading: AppBarBackButton(context: context),
              trailingList: [
                if (phoneNumbers != null)
                  IconButton(
                    key: Key(keyChatIconButtonIconPhone),
                    icon: AdaptiveIcon(icon: IconSource.phone),
                    onPressed: () => _onPhonePressed(phoneNumbers),
                  ),
              ],
            ),
            body: Column(
              children: <Widget>[
                Flexible(
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider<ChatBloc>.value(value: _chatBloc),
                      BlocProvider<MessageListBloc>.value(value: _messageListBloc),
                    ],
                    child: Stack(children: <Widget>[
                      MessageList(
                        scrollController: _scrollController,
                        chatId: widget.chatId,
                        emptyListTextTranslation: L.chatNewPlaceholder,
                      ),
                      Visibility(
                        visible: _composingAudioTimer != null,
                        child: Positioned(
                          bottom: dimension8dp,
                          right: dimension8dp,
                          child: Container(
                            decoration: ShapeDecoration(
                              shape: getSuperEllipseShape(dimension32dp),
                              color: CustomTheme.of(context).surface,
                            ),
                            child: IconButton(
                              icon: SuperellipseIcon(
                                icon: IconSource.send,
                                iconSize: dimension20dp,
                                color: CustomTheme.of(context).accent,
                                iconColor: CustomTheme.of(context).white,
                              ),
                              onPressed: () => _isLocked ? _chatComposerBloc.add(StopAudioRecording(sendAudio: true)) : _onPrepareMessageSend(),
                            ),
                            key: Key(KeyChatOnSendTextIcon),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
                if (isInviteChat(widget.chatId))
                  ChatInviteChoice(
                    chatId: widget.chatId,
                    messageId: widget.messageId,
                  ),
                if (_filePath.isNotEmpty && _knownType != ChatMsg.typeVoice)
                  ChatAttachmentPreview(
                    filePath: _filePath,
                    fileType: _selectedFileType,
                    onClose: _closePreview,
                    extension: _selectedExtension,
                    fileName: _fileName,
                  ),
                Divider(height: dividerHeight),
                if (state is ChatStateSuccess && !state.isRemoved)
                  Container(
                    decoration: BoxDecoration(color: CustomTheme.of(context).surface),
                    child: SafeArea(child: _buildTextComposer()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextComposer() {
    final List<Widget> widgets = List();
    if (_getComposerType() != ComposerModeType.isVoiceRecording) {
      widgets.add(buildLeftComposerPart(
        context: context,
        type: _getComposerType(),
        onShowAttachmentChooser: _showAttachmentChooser,
        onAudioRecordingAbort: _onAudioRecordingAbort,
      ));
    } else if (_isLocked || _isStopped) {
      widgets.add(buildLeftComposerPart(
        context: context,
        type: _getComposerType(),
        onShowAttachmentChooser: _showAttachmentChooser,
        onAudioRecordingAbort: _onAudioRecordingAbort,
      ));
    } else {
      widgets.add(Padding(
        padding: const EdgeInsets.only(left: dimension48dp),
      ));
    }
    widgets.add(buildCenterComposerPart(
      context: context,
      type: _getComposerType(),
      textController: _textController,
      onTextChanged: _onInputTextChanged,
      dbPeakList: _dbPeakList,
      replayTime: _replayTime,
      isStopped: _isStopped,
      isPlaying: _isPlaying,
    ));
    widgets.addAll(buildRightComposerPart(
      context: context,
      onRecordAudioPressed: _onRecordAudioPressed,
      onRecordAudioStopped: _onAudioRecordingStopped,
      onRecordAudioStoppedLongPress: _onAudioRecordingStoppedLongPress,
      onRecordAudioLocked: _onAudioRecordingLocked,
      onAudioPlaying: _onAudioPlaying,
      onAudioPlayingStopped: _onAudioPlayingStopped,
      onRecordVideoPressed: _onRecordVideoPressed,
      onCaptureImagePressed: _onCaptureImagePressed,
      onMicTapDown: _onMicTapDown,
      type: _getComposerType(),
      onSendText: _onPrepareMessageSend,
      text: _composingAudioTimer,
      isLocked: _isLocked,
      isStopped: _isStopped,
      isPlaying: _isPlaying,
    ));

    return IconTheme(
      data: IconThemeData(color: CustomTheme.of(context).accent),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: dimension8dp),
        child: BlocProvider.value(
          value: _chatComposerBloc,
          child: Row(
            children: widgets,
          ),
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
      _isComposingText = isComposingText();
    });
  }

  bool isComposingText() {
    return _textController.text.trim().length > 0;
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
    _navigation.pushAndRemoveUntil(
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
      Navigatable(Type.rootChildren),
    );
  }

  void _onMessageSend() {
    final String text = _textController.text;
    _textController.clear();
    if (_filePath.isEmpty) {
      if (text.isNotEmpty) {
        _messageListBloc.add(SendMessage(text: text));
      }
    } else {
      int type = getType();
      if (type == ChatMsg.typeVoice) _onAudioRecordingAbort();
      _messageListBloc.add(SendMessage(path: _filePath, fileType: type, text: text, isShared: widget.sharedData != null));
    }

    _closePreview();
    _clearAudioComposer();
    setState(() {
      _knownType = null;
      _isComposingText = false;
    });
  }

  int getType() {
    int type = 0;
    if (_knownType == null) {
      switch (_selectedFileType) {
        case FileType.image:
          type = ChatMsg.typeImage;
          break;
        case FileType.video:
          type = ChatMsg.typeVideo;
          break;
        case FileType.audio:
          type = ChatMsg.typeAudio;
          break;
        case FileType.custom:
          if (_selectedExtension == "gif") {
            type = ChatMsg.typeGif;
          } else {
            type = ChatMsg.typeFile;
          }
          break;
        case FileType.any:
          type = ChatMsg.typeFile;
          break;
      }
    } else {
      type = _knownType;
    }
    return type;
  }

  double startLongPressDx;
  double startLongPressDy;

  _onRecordAudioPressed(LongPressStartDetails details) async {
    if (!_hasPermissions) return;

    startLongPressDx = details.localPosition.dx;
    startLongPressDy = details.localPosition.dy;

    if (!_isStopped) {
      _chatComposerBloc.add(StartAudioRecording());
      setState(() {
        _isStopped = false;
        _isPlaying = false;
      });
    }
  }

  _onAudioRecordingStoppedLongPress(LongPressEndDetails details) {
    if (!_hasPermissions) return;

    double dxDifference = startLongPressDx - details.localPosition.dx;
    double dyDifference = startLongPressDy - details.localPosition.dy;

    if (dyDifference > 50.0) {
      if (_dbPeakList != null && _dbPeakList.length > 0) {
        _chatComposerBloc.add(StopAudioRecording(sendAudio: true));
      }
    } else if (dxDifference > 45.0) {
      setState(() {
        _isLocked = true;
      });
    } else {
      _chatComposerBloc.add(StopAudioRecording());
    }
  }

  _onMicTapDown(TapDownDetails details) {
    vibrateMedium();
    _chatComposerBloc.add(CheckPermissions());
  }

  _onAudioRecordingStopped() {
    _chatComposerBloc.add(StopAudioRecording());
  }

  _onAudioRecordingLocked() {
    setState(() {
      _isLocked = true;
    });
  }

  _onAudioPlaying() {
    setState(() {
      _isPlaying = true;
    });
    _chatComposerBloc.add(ReplayAudio());
  }

  _onAudioPlayingStopped() {
    setState(() {
      _replayTime = 0;
      _isPlaying = false;
    });
    _chatComposerBloc.add(StopAudioReplay());
  }

  _onAudioRecordingAbort() {
    _chatComposerBloc.add(AbortAudioRecording());
  }

  _onCaptureImagePressed() {
    _chatComposerBloc.add(StartImageOrVideoRecording(pickImage: true));
  }

  _onRecordVideoPressed() {
    _chatComposerBloc.add(StartImageOrVideoRecording(pickImage: false));
  }

  void _showAttachmentChooser() {
    showNavigatableBottomSheet(
        context: context,
        navigatable: Navigatable(Type.addAttachmentModal),
        bottomSheet: AdaptiveBottomSheet(
          actions: <Widget>[
            AdaptiveBottomSheetAction(
              key: Key(keyAttachmentAddImage),
              title: Text(L10n.get(L.image)),
              leading: AdaptiveIcon(icon: IconSource.image),
              onPressed: () => _getFilePath(FileType.image),
            ),
            AdaptiveBottomSheetAction(
              key: Key(keyAttachmentAddVideo),
              title: Text(L10n.get(L.video)),
              leading: AdaptiveIcon(icon: IconSource.videoLibrary),
              onPressed: () => _getFilePath(FileType.video),
            ),
            AdaptiveBottomSheetAction(
              key: Key(keyAttachmentAddPdf),
              title: Text(pdf),
              leading: AdaptiveIcon(icon: IconSource.pictureAsPdf),
              onPressed: () => _getFilePath(FileType.custom, "pdf"),
            ),
            AdaptiveBottomSheetAction(
              key: Key(keyAttachmentAddFile),
              title: Text(L10n.get(L.file)),
              leading: AdaptiveIcon(icon: IconSource.insertDriveFile),
              onPressed: () => _getFilePath(FileType.any),
            ),
          ],
        ));
  }

  _getFilePath(FileType fileType, [String extension]) async {
    _navigation.pop(context);

    String filePath = await FilePicker.getFilePath(type: fileType, fileExtension: extension);
    if (filePath == null) {
      return;
    }

    if (fileType == FileType.video && Platform.isIOS) {
      final ext = Path.extension(filePath);
      final videoFileName = "${filePath.hashCode}$ext";
      final videoFileDir = Path.dirname(filePath);
      final videoFilePath = "$videoFileDir${Platform.pathSeparator}$videoFileName";
      final videoFile = File(filePath);
      await videoFile.rename(videoFilePath);
      filePath = videoFilePath;
    }

    _fileName = Path.basename(filePath);

    _selectedFileType = fileType;
    _selectedExtension = extension;
    setState(() {
      _filePath = filePath != null ? filePath : "";
      _isComposingText = _filePath.isNotEmpty;
    });
  }

  void _closePreview() {
    setState(() {
      if (widget.sharedData != null) {
        _messageListBloc.add(DeleteCacheFile(path: _filePath));
      }
      _filePath = "";
      _selectedExtension = "";
      _isComposingText = isComposingText();
    });
  }

  _chatTitleTapped() {
    _navigation.push(
      context,
      MaterialPageRoute(builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<ChatBloc>.value(value: _chatBloc),
          ],
          child: ChatProfile(chatId: widget.chatId, messageId: widget.messageId),
        );
      }),
    );
  }

  void _onPhonePressed(String phoneNumbers) {
    if (phoneNumbers == null || phoneNumbers.isEmpty) {
      showInformationDialog(
        context: context,
        title: L10n.get(L.contactNoPhoneNumber),
        contentText: L10n.get(L.contactNoPhoneNumberText),
        navigatable: Navigatable(Type.contactNoNumberDialog),
      );
    } else {
      final phoneNumberList = ContactExtension.getPhoneNumberList(phoneNumbers);
      if (phoneNumberList.length == 1) {
        _callNumber(phoneNumberList.first);
      } else {
        final phoneNumberWidgetList = List<Widget>();
        phoneNumberList.forEach((phoneNumber) {
          phoneNumberWidgetList.add(SimpleDialogOption(
            child: Text(phoneNumber),
            onPressed: () {
              _navigation.pop(context);
              _callNumber(phoneNumber);
            },
          ));
        });
        showNavigatableDialog(
          context: context,
          navigatable: Navigatable(Type.contactStartCallDialog),
          dialog: SimpleDialog(
            title: Text(L10n.get(L.chatChooseCallNumber)),
            children: phoneNumberWidgetList,
          ),
        );
      }
    }
  }

  void _callNumber(String phoneNumber) {
    final String parsedPhoneNumber = phoneNumber.getPhoneNumberFromString();
    launch("tel://$parsedPhoneNumber");
  }
}

class ChatAppBar extends StatelessWidget {
  final String imagePath;
  final String name;
  final String subTitle;
  final Color color;
  final bool isVerified;
  final bool isGroup;

  const ChatAppBar({
    Key key,
    @required this.imagePath,
    @required this.name,
    @required this.subTitle,
    @required this.color,
    @required this.isVerified,
    @required this.isGroup,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Avatar(
          imagePath: imagePath,
          textPrimary: name,
          textSecondary: subTitle,
          color: color,
        ),
        Padding(padding: const EdgeInsets.only(left: dimension16dp)),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                name,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.title.apply(color: CustomTheme.of(context).onSurface),
                key: Key(keyChatNameText),
              ),
              Row(
                children: <Widget>[
                  Visibility(
                    visible: isGroup,
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
                      style: Theme.of(context).textTheme.subtitle.apply(color: CustomTheme.of(context).onSurface),
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
}

class ChatInviteChoice extends StatelessWidget with ChatCreateMixin {
  final _navigation = Navigation();
  final int chatId;
  final int messageId;

  ChatInviteChoice({Key key, @required this.chatId, @required this.messageId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Divider(),
        Padding(
          padding: const EdgeInsets.all(dimension16dp),
          child: Text(L10n.get(L.chatCreateText), style: Theme.of(context).textTheme.subhead),
        ),
        Padding(
          padding: const EdgeInsets.only(right: dimension16dp, left: dimension16dp, bottom: dimension16dp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ButtonImportanceMedium(
                minimumWidth: inviteChoiceButtonSize,
                isDestructive: true,
                child: Text(L10n.get(L.block)),
                onPressed: () {
                  ContactItemBloc().add(BlockContact(messageId: messageId, chatId: chatId));
                  _navigation.popUntilRoot(context);
                },
              ),
              ButtonImportanceHigh(
                minimumWidth: inviteChoiceButtonSize,
                child: Text(L10n.get(L.ok)),
                onPressed: () => createChatFromMessage(context, messageId, chatId),
              )
            ],
          ),
        )
      ],
    );
  }
}

class ChatAttachmentPreview extends StatelessWidget {
  final FileType fileType;
  final String filePath;
  final Function onClose;
  final String extension;
  final String fileName;

  const ChatAttachmentPreview({Key key, @required this.fileType, @required this.filePath, @required this.onClose, this.extension, this.fileName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Divider(height: dividerHeight),
        Padding(padding: EdgeInsets.only(top: dimension4dp)),
        SizedBox(
          height: previewMaxSize,
          width: double.infinity,
          child: Stack(
            children: <Widget>[
              Center(
                child: fileType == FileType.image || extension == "gif"
                    ? Image.file(File(filePath))
                    : AdaptiveIcon(
                        icon: IconSource.insertDriveFile,
                        size: previewDefaultIconSize,
                        color: CustomTheme.of(context).onBackground.slightly(),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(iconTextPadding),
                child: GestureDetector(
                  onTap: onClose,
                  child: Container(
                    decoration: BoxDecoration(
                      color: CustomTheme.of(context).onBackground.half(),
                      borderRadius: BorderRadiusDirectional.circular(dimension20dp),
                    ),
                    child: AdaptiveIcon(
                      icon: IconSource.close,
                      size: previewCloseIconSize,
                      color: CustomTheme.of(context).white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(dimension4dp),
          child: Text(fileName),
        )
      ],
    );
  }
}
