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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_talk/main.dart';
import 'package:ox_talk/source/base/base_root_child.dart';
import 'package:ox_talk/source/l10n/localizations.dart';
import 'package:ox_talk/source/profile/edit_account_settings.dart';
import 'package:ox_talk/source/profile/edit_user_settings.dart';
import 'package:ox_talk/source/profile/user.dart';
import 'package:ox_talk/source/profile/user_bloc.dart';
import 'package:ox_talk/source/profile/user_event.dart';
import 'package:ox_talk/source/profile/user_state.dart';
import 'package:ox_talk/source/ui/default_colors.dart';

class ProfileView extends BaseRootChild {

  _ProfileState createState() => _ProfileState();

  @override
  Color getColor() {
    return DefaultColors.profileColor;
  }

  @override
  FloatingActionButton getFloatingActionButton(BuildContext context) {
    return null;
  }

  @override
  String getTitle(BuildContext context) {
    return AppLocalizations.of(context).profileTitle;
  }

  @override
  String getNavigationText(BuildContext context) {
    return AppLocalizations.of(context).profileTitle;
  }

  @override
  IconData getNavigationIcon() {
    return Icons.account_circle;
  }

}

class _ProfileState extends State<ProfileView> {
  UserBloc _userBloc = UserBloc();

  @override
  void initState(){
    super.initState();
    _userBloc.dispatch(RequestUser());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _userBloc,
      builder: (context, state){
        if(state is UserStateSuccess){
          return buildProfileView(state.user);
        }else if (state is UserStateFailure) {
          return new Text(state.error);
        } else {
          return new Container();
        }
      }
    );
  }

  Widget buildProfileView(User user){
    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 24.0)),
            user.avatarPath.isEmpty ? CircleAvatar(
              maxRadius: 45,
              child: Icon(
                Icons.person,
                size: 60,
              ),
            ):
            CircleAvatar(
              maxRadius: 45,
              backgroundImage: FileImage(File(user.avatarPath)),
            ),
            Padding(padding: EdgeInsets.only(top: 12.0)),
            user.username.isNotEmpty ? Text(
              user.username,
              style: TextStyle(
                  fontSize: 24
              ),
            ) : Container(),
            Padding(padding: EdgeInsets.only(top: 12.0)),
            user.email.isNotEmpty ? Text(
              user.email,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600
              ),
            ) : Container(),
            Padding(padding: EdgeInsets.only(top: 12.0)),
            user.status.isNotEmpty ? Text(
              user.status,
              style: TextStyle(
                fontSize: 16,
              ),
            ) : Text(
              AppLocalizations.of(context).profileStatusPlaceholder,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 16.0)),
            RaisedButton(
              onPressed: () => editUserSettings(user.avatarPath, user.username, user.status),
              child: Text(
                  "Edit user settings" //No translation because design is not ready and maybe there is no button with text
              ),
            ),
            RaisedButton(
              onPressed: () => editAccountSettings(user),
              child: Text(
                  "Edit account settings" //No translation because design is not ready and maybe there is no button with text
              ),
            )
          ],
        ),
      ),
    );
  }

  editUserSettings(String avatarPath, String username, String status) async{
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserSettings(
          avatarPath: avatarPath,
          username: username,
          status: status,
        )
      ),
    );

  }

  //TODO: call editAccountSettings screen
  editAccountSettings(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAccountSettings(
          imapLogin: user.imapLogin,
          imapServer: user.imapServer,
          imapPort: user.imapPort,
          smtpLogin: user.smtpLogin,
          smtpPassword: user.smtpPassword,
          smtpServer: user.smtpServer,
          smtpPort: user.smtpPort,
        )
    ),);
  }

}