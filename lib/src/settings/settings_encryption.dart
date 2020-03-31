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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_coi/src/extensions/string_apis.dart';
import 'package:ox_coi/src/extensions/string_ui.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/platform/files.dart';
import 'package:ox_coi/src/settings/settings_encryption_bloc.dart';
import 'package:ox_coi/src/settings/settings_encryption_event_state.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/widgets/dialog_builder.dart';
import 'package:ox_coi/src/widgets/dynamic_appbar.dart';
import 'package:ox_coi/src/widgets/fullscreen_progress.dart';

class SettingsEncryption extends StatefulWidget {
  @override
  _SettingsEncryptionState createState() => _SettingsEncryptionState();
}

class _SettingsEncryptionState extends State<SettingsEncryption> {
  final Navigation _navigation = Navigation();
  OverlayEntry _progressOverlayEntry;
  SettingsEncryptionBloc _settingsEncryptionBloc = SettingsEncryptionBloc();

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.settingsSecurity);
    _settingsEncryptionBloc.listen((state) => _settingsEncryptionStateChange(state));
  }

  @override
  void dispose() {
    _settingsEncryptionBloc.close();
    super.dispose();
  }

  void _settingsEncryptionStateChange(SettingsEncryptionState state) {
    if (state is SettingsEncryptionStateLoading) {
      String text;
      if (state.type == SettingsEncryptionType.importKeys) {
        text = L10n.get(L.settingKeyImportRunning);
      } else if (state.type == SettingsEncryptionType.exportKeys) {
        text = L10n.get(L.settingKeyExportRunning);
      } else if (state.type == SettingsEncryptionType.initiateKeyTransfer) {
        text = L10n.get(L.settingKeyTransferRunning);
      }
      _progressOverlayEntry = FullscreenOverlay(
        fullscreenProgress: FullscreenProgress(
          bloc: _settingsEncryptionBloc,
          text: text,
          showProgressValues: false,
        ),
      );
      Overlay.of(context).insert(_progressOverlayEntry);
    } else if (state is SettingsEncryptionStateSuccess || state is SettingsEncryptionStateFailure) {
      _progressOverlayEntry?.remove();
      if (state is SettingsEncryptionStateSuccess) {
        if (!state.setupCode.isNullOrEmpty()) {
          showNavigatableDialog(
            context: context,
            navigatable: Navigatable(Type.settingsKeyTransferDoneDialog),
            dialog: AlertDialog(
              title: Text(L10n.get(L.autocryptMessageCreated)),
              content: new Text(L10n.getFormatted(L.autocryptMessageSentX, [state.setupCode])),
              actions: <Widget>[
                new FlatButton(
                  child: new Text(L10n.get(L.settingCopyCode)),
                  onPressed: () {
                    var toastText = L10n.getFormatted(L.clipboardCopiedX, [L10n.get(L.code)]);
                    state.setupCode.copyToClipboardWithToast(toastText: toastText);
                    _navigation.pop(context);
                  },
                ),
                new FlatButton(
                  child: new Text(L10n.get(L.ok)),
                  onPressed: () {
                    _navigation.pop(context);
                  },
                ),
              ],
            ),
          );
        } else {
          L10n.get(L.settingKeyTransferSuccess).showToast();
        }
      }
      if (state is SettingsEncryptionStateFailure) {
        if (state.error == null) {
          L10n.get(L.settingKeyTransferFailed).showToast();
        } else {
          switch (state.error) {
            case SettingsEncryptionStateError.missingStoragePermission:
              L10n.get(L.settingKeyTransferPermissionFailed).showToast();
              break;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _navigation.allowBackNavigation,
      child: Scaffold(
          appBar: DynamicAppBar(
            title: L10n.get(L.settingItemEncryptionTitle),
            leading: AppBarBackButton(context: context),
          ),
          body: _buildPreferenceList(context)),
    );
  }

  ListView _buildPreferenceList(BuildContext context) {
    return ListView(
      children: ListTile.divideTiles(context: context, tiles: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: listItemPadding, horizontal: listItemPadding),
          title: Text(L10n.get(L.settingExportKeys)),
          subtitle: Text(L10n.get(L.settingEncryptionExportText)),
          onTap: () => _onPressed(context, SettingsEncryptionType.exportKeys),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: listItemPadding, horizontal: listItemPadding),
          title: Text(L10n.get(L.settingImportKeys)),
          subtitle: Text(L10n.get(L.settingImportKeysText)),
          onTap: () => _onPressed(context, SettingsEncryptionType.importKeys),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: listItemPadding, horizontal: listItemPadding),
          title: Text(L10n.get(L.settingKeyTransferStart)),
          subtitle: Text(L10n.get(L.autocryptCreateMessageText)),
          onTap: () => _onPressed(context, SettingsEncryptionType.initiateKeyTransfer),
        ),
      ]).toList(),
    );
  }

  void _onPressed(BuildContext context, SettingsEncryptionType type) {
    switch (type) {
      case SettingsEncryptionType.exportKeys:
        _showExportImportDialog(type);
        break;
      case SettingsEncryptionType.importKeys:
        _showExportImportDialog(type);
        break;
      case SettingsEncryptionType.initiateKeyTransfer:
        _showKeyTransferDialog();
        break;
    }
  }

  void _showExportImportDialog(SettingsEncryptionType type) async {
    String title;
    String text;
    String path = await getUserVisibleDirectoryPath();
    if (Platform.isAndroid) {
      path = path.substring(path.getIndexAfterLastOf('0'));
    }
    Type navigationType;
    if (type == SettingsEncryptionType.exportKeys) {
      title = L10n.get(L.settingExportKeys);
      text = Platform.isAndroid ? L10n.getFormatted(L.settingSecurityExportKeysAndroidTextX, [path]) : L10n.get(L.settingSecurityExportKeysIOSText);
      navigationType = Type.settingsExportKeysDialog;
    } else if (type == SettingsEncryptionType.importKeys) {
      title = L10n.get(L.settingImportKeys);
      text = Platform.isAndroid ? L10n.get(L.settingSecurityImportKeysAndroidText) : L10n.get(L.settingSecurityImportKeysIOSText);
      navigationType = Type.settingsImportKeysDialog;
    }
    showConfirmationDialog(
      context: context,
      title: title,
      content: text,
      positiveButton: L10n.get(L.ok),
      positiveAction: () => _exportImport(type),
      navigatable: Navigatable(navigationType),
    );
  }

  void _exportImport(SettingsEncryptionType type) {
    if (type == SettingsEncryptionType.exportKeys) {
      _settingsEncryptionBloc.add(ExportKeys());
    } else if (type == SettingsEncryptionType.importKeys) {
      _settingsEncryptionBloc.add(ImportKeys());
    }
  }

  void _showKeyTransferDialog() {
    showConfirmationDialog(
      context: context,
      title: L10n.get(L.settingKeyTransferStart),
      content: L10n.get(L.autocryptText),
      positiveButton: L10n.get(L.ok),
      positiveAction: _keyTransfer,
      navigatable: Navigatable(Type.settingsKeyTransferDialog),
    );
  }

  void _keyTransfer() {
    _settingsEncryptionBloc.add(InitiateKeyTransfer());
  }
}
