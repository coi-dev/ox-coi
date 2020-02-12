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

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon_button.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_superellipse_icon.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/ui/custom_theme.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/ui/text_styles.dart';
import 'package:ox_coi/src/utils/clipboard.dart';
import 'package:ox_coi/src/utils/text.dart';
import 'package:ox_coi/src/widgets/avatar.dart';
import 'package:ox_coi/src/widgets/placeholder_text.dart';

class ProfileData extends InheritedWidget {
  final Color imageBackgroundColor;
  final String text;
  final String secondaryText;
  final String placeholderText;
  final String initialsText;
  final IconSource iconData;
  final TextStyle textStyle;
  final Function imageActionCallback;
  final Function editActionCallback;
  final String avatarPath;
  final bool withPlaceholder;
  final bool showWhiteImageIcon;

  const ProfileData({
    Key key,
    @required Widget child,
    this.imageBackgroundColor,
    this.text,
    this.secondaryText,
    this.placeholderText,
    this.initialsText,
    this.iconData,
    this.textStyle,
    this.imageActionCallback,
    this.editActionCallback,
    this.avatarPath,
    this.withPlaceholder = false,
    this.showWhiteImageIcon = false,
  })  : assert(child != null),
        super(key: key, child: child);

  static ProfileData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ProfileData>();
  }

  @override
  bool updateShouldNotify(ProfileData old) {
    return true;
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
        ),
        Stack(
          children: <Widget>[
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ProfileAvatar(),
                  Padding(padding: EdgeInsets.only(top: 24.0)),
                  Visibility(
                    visible: !ProfileData.of(context).text.isNullOrEmpty(),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: ProfileData.of(context).withPlaceholder
                          ? PlaceholderText(
                              text: ProfileData.of(context).text,
                              style: getProfileHeaderTextStyle(context),
                              align: TextAlign.center,
                              placeholderText: ProfileData.of(context).placeholderText,
                              placeholderStyle: getProfileHeaderPlaceholderTextStyle(context),
                              placeHolderAlign: TextAlign.center,
                            )
                          : ProfileHeaderText(),
                    ),
                  ),
                  Visibility(
                    visible: !ProfileData.of(context).secondaryText.isNullOrEmpty(),
                    child: ProfileHeaderSecondaryText(),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: ProfileData.of(context).editActionCallback != null,
              child: ProfileHeaderEditButton(),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 18.0),
        ),
      ],
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Navigation _navigation = Navigation();

    _getNewAvatarPath(ImageSource source) async {
      _navigation.pop(context);
      File newAvatar = await ImagePicker.pickImage(source: source);
      if (newAvatar != null) {
        File croppedAvatar = await ImageCropper.cropImage(
          sourcePath: newAvatar.path,
          aspectRatio: CropAspectRatio(ratioX: editUserAvatarRatio, ratioY: editUserAvatarRatio),
          maxWidth: editUserAvatarImageMaxSize,
          maxHeight: editUserAvatarImageMaxSize,
        );
        if (croppedAvatar != null) {
          ProfileData.of(context).imageActionCallback(croppedAvatar.path);
        }
      }
    }

    _removeAvatar() {
      _navigation.pop(context);
      ProfileData.of(context).imageActionCallback(null);
    }

    _editPhoto() {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: AdaptiveIcon(icon: IconSource.photo),
                  title: Text(L10n.get(L.gallery)),
                  onTap: () => _getNewAvatarPath(ImageSource.gallery),
                ),
                ListTile(
                  leading: AdaptiveIcon(icon: IconSource.cameraAlt),
                  title: Text(L10n.get(L.camera)),
                  onTap: () => _getNewAvatarPath(ImageSource.camera),
                ),
                ListTile(
                  leading: AdaptiveIcon(icon: IconSource.delete),
                  title: Text(L10n.get(L.groupRemoveImage)),
                  onTap: () => _removeAvatar(),
                )
              ],
            );
          });
    }

    return InkWell(
      onTap: ProfileData.of(context).imageActionCallback != null ? () => _editPhoto() : null,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Avatar(
            imagePath: ProfileData.of(context).avatarPath,
            color: ProfileData.of(context).imageBackgroundColor,
            size: profileAvatarSize,
            textPrimary: ProfileData.of(context).initialsText,
          ),
          Visibility(
            visible: ProfileData.of(context).imageActionCallback != null &&
                (ProfileData.of(context).avatarPath.isNullOrEmpty()),
            child: AdaptiveIcon(
              icon: IconSource.camera,
              color: ProfileData.of(context).showWhiteImageIcon ? CustomTheme.of(context).white : CustomTheme.of(context).accent,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileHeaderEditButton extends StatelessWidget {
  const ProfileHeaderEditButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16.0,
      child: AdaptiveIconButton(
        icon: AdaptiveSuperellipseIcon(
          color: CustomTheme.of(context).onBackground.withOpacity(barely),
          icon: IconSource.edit,
          iconColor: CustomTheme.of(context).accent,
        ),
        onPressed: () => ProfileData.of(context).editActionCallback(),
      ),
    );
  }
}

class ProfileHeaderText extends StatelessWidget {
  const ProfileHeaderText({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var content = Text(
      ProfileData.of(context).text,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: getProfileHeaderTextStyle(context),
    );
    return Container(child: content);
  }
}

class ProfileHeaderSecondaryText extends StatelessWidget {
  const ProfileHeaderSecondaryText({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var content = Text(
      ProfileData.of(context).secondaryText,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: getProfileHeaderSecondTextStyle(context),
    );
    return GestureDetector(
      onTap: () => copyToClipboardWithToast(text: ProfileData.of(context).secondaryText, toastText: getDefaultCopyToastText(context)),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (ProfileData.of(context).iconData != null)
            Padding(
              padding: const EdgeInsets.only(right: iconTextPadding),
              child: AdaptiveIcon(icon: ProfileData.of(context).iconData),
            ),
          content,
          Padding(
            padding: const EdgeInsets.only(left: iconTextPadding),
            child: AdaptiveIcon(icon: IconSource.contentCopy),
          ),
        ],
      ),
    );
  }
}

class ProfileHeaderParticipantsHeader extends StatelessWidget {
  const ProfileHeaderParticipantsHeader({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      ProfileData.of(context).text,
      style: Theme.of(context).textTheme.subtitle,
    );
  }
}
