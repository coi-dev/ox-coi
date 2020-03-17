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
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/widgets/superellipse_icon.dart';
import 'package:ox_coi/src/extensions/string_apis.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/extensions/color_apis.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/ui/text_styles.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
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
          padding: const EdgeInsets.only(top: dimension24dp),
        ),
        Stack(
          children: <Widget>[
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ProfileAvatar(),
                  Padding(padding: const EdgeInsets.only(top: dimension24dp)),
                  Visibility(
                    visible: !ProfileData.of(context).text.isNullOrEmpty(),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: dimension8dp),
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
          padding: const EdgeInsets.only(bottom: profileHeaderBottomPadding),
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
          Visibility(
            visible: ProfileData.of(context).imageActionCallback != null &&
                (ProfileData.of(context).avatarPath == null || ProfileData.of(context).avatarPath.isEmpty),
            child: AdaptiveIcon(
              icon: IconSource.camera,
              color: ProfileData.of(context).showWhiteImageIcon ? CustomTheme.of(context).white : CustomTheme.of(context).accent,
            ),
          ),
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
      right: dimension16dp,
      child: IconButton(
        icon: SuperellipseIcon(
          color: CustomTheme.of(context).onBackground.barely(),
          icon: IconSource.edit,
          iconColor: CustomTheme.of(context).accent,
        ),key: Key(keyProfileHeaderAdaptiveIconButton),
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
      style: getProfileHeaderSecondTextStyle(context),key: Key(keyProfileHeaderText),
    );
    return GestureDetector(
      onTap: () =>  ProfileData.of(context).secondaryText.copyToClipboardWithToast(toastText: getDefaultCopyToastText(context)),
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

class ProfileCopyableHeaderText extends StatelessWidget {
  final String toastMessage;

  const ProfileCopyableHeaderText({Key key, @required this.toastMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ProfileData.of(context).text.copyToClipboardWithToast(toastText: toastMessage);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ProfileHeaderText(),
          Padding(padding: const EdgeInsets.all(iconTextPadding)),
          AdaptiveIcon(icon: IconSource.contentCopy),
        ],
      ),
    );
  }
}

class EditableProfileHeader extends StatelessWidget {
  final Function imageChangedCallback;
  final String avatar;
  final TextEditingController nameController;
  final String placeholder;

  const EditableProfileHeader({
    Key key,
    @required this.imageChangedCallback,
    @required this.avatar,
    @required this.nameController,
    @required this.placeholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(padding: const EdgeInsets.only(top: dimension24dp)),
            Align(
                alignment: Alignment.center,
                child: ProfileData(
                  imageBackgroundColor: CustomTheme.of(context).onBackground.barely(),
                  imageActionCallback: imageChangedCallback,
                  avatarPath: avatar,
                  child: ProfileAvatar(),
                )),
            Padding(
              padding: const EdgeInsets.only(left: listItemPadding, right: listItemPadding),
              child: Column(
                children: <Widget>[
                  TextFormField(
                      key: Key(keyUserSettingsUsernameLabel),
                      maxLines: 1,
                      controller: nameController,
                      decoration: InputDecoration(labelText: placeholder)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
