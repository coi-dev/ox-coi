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
import 'package:ox_coi/src/adaptiveWidgets/adaptive_ink_well.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/ui/custom_theme.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/clipboard.dart';
import 'package:ox_coi/src/utils/text.dart';
import 'package:ox_coi/src/widgets/avatar.dart';
import 'package:superellipse_shape/superellipse_shape.dart';
import 'package:transparent_image/transparent_image.dart';

class ProfileData extends InheritedWidget {
  final Color color;
  final String text;
  final IconSource iconData;
  final TextStyle textStyle;
  final Function imageActionCallback;

  const ProfileData({
    Key key,
    @required Widget child,
    this.color,
    this.text,
    this.iconData,
    this.textStyle,
    this.imageActionCallback,
  })  : assert(child != null),
        super(key: key, child: child);

  static ProfileData of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(ProfileData) as ProfileData;
  }

  @override
  bool updateShouldNotify(ProfileData old) {
    return true;
  }
}

class ProfileAvatar extends StatelessWidget {
  final String imagePath;

  ProfileAvatar({this.imagePath});

  @override
  Widget build(BuildContext context) {
    double avatarSize = profileAvatarSize;
    ImageProvider avatarImage;
    if (isNullOrEmpty(imagePath)) {
      avatarImage = MemoryImage(kTransparentImage);
    } else {
      avatarImage = FileImage(File(imagePath));
    }

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
      ProfileData.of(context).imageActionCallback("");
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

    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: chatProfileVerticalPadding),
          child: Avatar(
            imagePath: imagePath,
            color: ProfileData.of(context).color,
            size: avatarSize,
            textPrimary: ProfileData.of(context).text,
          ),
        ),
        Visibility(
          visible: ProfileData.of(context).imageActionCallback != null,
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: chatProfileVerticalPadding),
              child: Container(
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                    shape: SuperellipseShape(
                      borderRadius: BorderRadius.circular(avatarSize * avatarBorderRadiusMultiplier),
                    ),
                    gradient: LinearGradient(begin: FractionalOffset.topCenter, end: FractionalOffset.bottomCenter, colors: [
                      CustomTheme.of(context).black.withOpacity(transparent),
                      CustomTheme.of(context).black.withOpacity(half),
                    ], stops: [
                      0.7,
                      1.0
                    ])),
                height: avatarSize,
                width: avatarSize,
              )),
        ),
        Visibility(
            visible: ProfileData.of(context).imageActionCallback != null,
            child: Positioned(
                bottom: profileEditPhotoButtonBottomPosition,
                right: profileEditPhotoButtonRightPosition,
                child: AdaptiveInkWell(
                  child: AdaptiveIcon(
                    icon: IconSource.addAPhoto,
                    color: CustomTheme.of(context).onPrimary,
                  ),
                  onTap: _editPhoto,
                )))
      ],
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
      style: ProfileData.of(context).textStyle,
    );
    return Flexible(
        child: ProfileData.of(context).iconData != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AdaptiveIcon(icon: ProfileData.of(context).iconData),
                  Padding(
                    padding: const EdgeInsets.only(left: iconTextPadding),
                    child: content,
                  ),
                ],
              )
            : content);
  }
}

class ProfileMemberHeaderText extends StatelessWidget {
  const ProfileMemberHeaderText({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      ProfileData.of(context).text,
      style: Theme.of(context).textTheme.subtitle,
    );
  }
}

class ProfileCopyableHeaderText extends StatelessWidget {
  final String toastMessage;

  const ProfileCopyableHeaderText({Key key, @required this.toastMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdaptiveInkWell(
      onTap: () {
        copyToClipboardWithToast(text: ProfileData.of(context).text, toastText: toastMessage);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ProfileHeaderText(),
          Padding(padding: EdgeInsets.all(iconTextPadding)),
          AdaptiveIcon(icon: IconSource.contentCopy),
        ],
      ),
    );
  }
}
