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
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ox_coi/src/adaptive_widgets/adaptive_bottom_sheet.dart';
import 'package:ox_coi/src/adaptive_widgets/adaptive_bottom_sheet_action.dart';
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/contact/contact_list_bloc.dart';
import 'package:ox_coi/src/contact/contact_list_event_state.dart';
import 'package:ox_coi/src/customer/customer.dart';
import 'package:ox_coi/src/customer/customer_delegate_change_notifier.dart';
import 'package:ox_coi/src/data/config.dart';
import 'package:ox_coi/src/dynamic_screen/delegates/dynamic_screen_action_delegate.dart';
import 'package:ox_coi/src/dynamic_screen/dynamic_screen.dart';
import 'package:ox_coi/src/dynamic_screen/dynamic_screen_model.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/main/main_bloc.dart';
import 'package:ox_coi/src/main/main_event_state.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/platform/preferences.dart';
import 'package:ox_coi/src/platform/system_interaction.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/widgets/modal_builder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

const _kIsCoiEnabled = "isCoiEnabled";
const _kIsCoiSupported = "isCoiSupported";
const _kContactsImportButtonPressed = "contactsImportButtonPressed";
const _kChatSettingsRadioChanged = "chatSettingsRadioChanged";
const _kNotificationsAllowButtonPressed = "notificationsAllowButtonPressed";
const _kNotificationsAllowLaterButtonPressed = "notificationsAllowLaterButtonPressed";
const _kAppbarSkipButtonPressed = "appbarSkipButtonPressed";
const _kReadyButtonPressed = "readyButtonPressed";

class CustomerDelegate with DynamicScreenCustomerDelegate {
  final changeNotifier = CustomerDelegateChangeNotifier();
  final _config = Config();

  MainBloc _mainBloc;

  void dispose() {
    _mainBloc.close();
  }

  @override
  Future<void> buttonPressedAsync({BuildContext context, data}) async {
    // TODO: NEEDS TO BE DISCUSSED!
    // TODO: Check, if data is of type String, List or Map. All these three types should be possible.
    debugPrint("[Button] => Data: $data");

    if (data is String) {
      switch (data) {
        case _kContactsImportButtonPressed:
          _importContacts(context: context);
          break;

        case _kNotificationsAllowButtonPressed:
          if (await Permission.notification.request().isGranted) {
            if (_config.coiSupported) {
              await setPreference(preferenceNotificationsPull, false);
            } else {
              await setPreference(preferenceNotificationsPull, true);
            }
          }
          navigateToNextPage(context: context);
          break;

        case _kNotificationsAllowLaterButtonPressed:
          navigateToNextPage(context: context);
          break;

        case _kAppbarSkipButtonPressed:
        case _kReadyButtonPressed:
          finishOnboarding(context: context);
          break;
      }
    }
  }

  @override
  Future<void> radioGroupValueChangedAsync({BuildContext context, DynamicScreenRadioListModel model, dynamic newValue}) async {
    debugPrint("[Radio Button] => Value: $newValue, GroupKey: ${model.groupKey}");

    switch (model.groupKey) {
      case _kChatSettingsRadioChanged:
        await _setConfigShowEmailsAsync(value: newValue as int);
        break;
    }
  }

  @override
  void avatarPressedCallback({BuildContext context, data}) {
    debugPrint("[Avatar] => Data: $data");
    unFocus(context);

    showNavigatableBottomSheet(
      context: context,
      navigatable: Navigatable(Type.changeProfilePhotoModal),
      bottomSheet: AdaptiveBottomSheet(
        actions: <Widget>[
          AdaptiveBottomSheetAction(
            key: Key(keyAdaptiveBottomSheetGallery),
            title: Text(L10n.get(L.gallery)),
            leading: AdaptiveIcon(icon: IconSource.photo),
            onPressed: () => _getNewAvatarPathAsync(context, ImageSource.gallery),
          ),
          AdaptiveBottomSheetAction(
            key: Key(keyAdaptiveBottomSheetCamera),
            title: Text(L10n.get(L.camera)),
            leading: AdaptiveIcon(icon: IconSource.cameraAlt),
            onPressed: () => _getNewAvatarPathAsync(context, ImageSource.camera),
          ),
        ],
      ),
    );
  }

  @override
  Future<void> textfieldEditingCompleteAsync({BuildContext context, String value}) async {
    debugPrint("[Textfield Edit Complete] Value: $value");
    await _config.setValue(Context.configDisplayName, value);
    changeNotifier.userName = value;
  }

  @override
  bool isNavigationNextAvailable({BuildContext context}) {
    final pageNavigator = Provider.of<DynamicScreenPageNavigator>(context);
    return pageNavigator.currentPageIndex < pageNavigator.pageCount - 1 && pageNavigator.nextIsVisible;
  }

  @override
  bool isPageAvailable({List<Map<String, bool>> availabilities}) {
    bool result = true;
    availabilities?.forEach((item) {
      result &= (item[_kIsCoiEnabled] != null ? _config.coiEnabled == item[_kIsCoiEnabled] : true);
      result &= (item[_kIsCoiSupported] != null ? _config.coiSupported == item[_kIsCoiSupported] : true);
    });
    return result;
  }

  @override
  void finishOnboarding({BuildContext context}) {
    Customer.needsOnboarding = false;
    Navigation().popUntilRoot(context);

    _mainBloc = BlocProvider.of<MainBloc>(context);
    _mainBloc.add(AppLoaded());
  }
}

extension CustomerDelegatePrivateHelper on CustomerDelegate {
  void navigateToNextPage({BuildContext context}) {
    final pageNavigator = Provider.of<DynamicScreenPageNavigator>(context, listen: false);
    pageNavigator.animateToPage(
      pageNavigator.currentPageIndex + 1,
      duration: Duration(milliseconds: 350),
      curve: Curves.easeInOutQuint,
    );
  }

  Future<void> _getNewAvatarPathAsync(BuildContext context, ImageSource source) async {
    Navigation().pop(context);
    File newAvatar = await ImagePicker.pickImage(source: source);

    if (newAvatar != null) {
      File croppedAvatar = await ImageCropper.cropImage(
        sourcePath: newAvatar.path,
        aspectRatio: CropAspectRatio(ratioX: editUserAvatarRatio, ratioY: editUserAvatarRatio),
        maxWidth: editUserAvatarImageMaxSize,
        maxHeight: editUserAvatarImageMaxSize,
      );

      if (croppedAvatar != null) {
        await _config.setValue(Context.configSelfAvatar, croppedAvatar.path);
        changeNotifier.avatarPath = croppedAvatar.path;
      }
    }
  }

  void _importContacts({BuildContext context}) async {
    bool hasContactPermission = await Permission.contacts.request().isGranted;
    if (hasContactPermission) {
      // ignore: close_sinks
      final contactListBloc = ContactListBloc();
      contactListBloc.add(PerformImport(shouldUpdateUi: false));
      contactListBloc.add(MarkContactsAsInitiallyLoaded());
      navigateToNextPage(context: context);
    }
  }

  Future<void> _setConfigShowEmailsAsync({int value}) async {
    await _config.setValue(Context.configShowEmails, value);
  }
}
