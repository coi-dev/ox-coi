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
import 'dart:io';

import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_talk/source/l10n/localizations.dart';
import 'package:ox_talk/source/profile/user.dart';
import 'package:ox_talk/source/profile/user_bloc.dart';
import 'package:ox_talk/source/profile/user_event.dart';
import 'package:ox_talk/source/profile/user_state.dart';
import 'package:ox_talk/source/ui/default_colors.dart';
import 'package:image_picker_ui/image_picker_handler.dart';
import 'package:ox_talk/source/ui/dimensions.dart';
import 'package:path_provider/path_provider.dart';

class EditUserSettings extends StatefulWidget {
//  static const String USERNAME_RESULT = "username_result";
//  static const String STATUS_RESULT = "status_result";
  final String username;
  final String avatarPath;
  final String status;

  EditUserSettings({@required this.avatarPath, @required this.username, @required this.status});

  @override
  _EditUserSettingsState createState() => _EditUserSettingsState();
}

class _EditUserSettingsState extends State<EditUserSettings> with TickerProviderStateMixin, ImagePickerListener {
  UserBloc _userBloc = UserBloc();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _statusController = TextEditingController();

  File _image;
  AnimationController _controller;
  ImagePickerHandler _imagePicker;
  String _path = "";

  @override
  void initState(){
    super.initState();
    _userBloc.dispatch(RequestUser());
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _imagePicker = new ImagePickerHandler(this, _controller);
    _imagePicker.init();

    _usernameController.text = widget.username != null ? widget.username : "";
    _statusController.text = widget.status != null ? widget.status : "";
    _path = widget.avatarPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: DefaultColors.contactColor,
          title: Text(AppLocalizations.of(context).editUserSettingsTitle),
          actions: <Widget>[IconButton(icon: Icon(Icons.check), onPressed: saveChanges)],
        ),
        body: buildForm());
  }

  Widget buildForm(){
    return BlocBuilder(
        bloc: _userBloc,
        builder: (context, state){
          if(state is UserStateSuccess){
            return buildEditUserDataView(state.user);
          }else if (state is UserStateFailure) {
            return new Text(state.error);
          } else {
            return new Container();
          }
        }
    );
  }

  Widget buildEditUserDataView(User user) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 24.0)),
            new GestureDetector(
              onTap: () => _imagePicker.showDialog(context),
              child: Stack(
                children: <Widget>[
                  _path.isNotEmpty ?
                  CircleAvatar(
                    maxRadius: Dimensions.profileAvatarMaxRadius,
                    backgroundImage: FileImage(File('$_path')),
                  ) :
                  CircleAvatar(
                    maxRadius: Dimensions.profileAvatarMaxRadius,
                    child: Icon(
                      Icons.person,
                      size: 60.0,
                    ),
                  ),
                  CircleAvatar(
                    maxRadius: Dimensions.profileAvatarMaxRadius,
                    backgroundColor: Colors.black26,
                    child: Icon(
                      Icons.edit,
                      size: Dimensions.editAvatarIconSize,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            ),
            Padding(
              padding: EdgeInsets.only(left: Dimensions.defaultBorderPadding, right: Dimensions.defaultBorderPadding),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    maxLines: 1,
                    controller: _usernameController,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).editUserSettingsUsernameLabel
                    )
                  ),
                  TextFormField(
                    maxLines: 1,
                    controller: _statusController,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).editUserSettingsStatusLabel
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  userImage(File _newImage) {
    setState(() {
      _image = _newImage;
      _path = _newImage.path;
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> saveImage(File image) async {
    final path = await _localPath;
    File newImage = await image.copy('$path/userAvatar.jpg');
    return newImage.path;
  }

  void saveChanges() async {
    if(_image != null) {
      _path = await saveImage(_image);
    }

  _userBloc.dispatch(UserPersonalDataChanged(username: _usernameController.text, status: _statusController.text, avatarPath: _path));

    Navigator.pop(context);
  }
}
