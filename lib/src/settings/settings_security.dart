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

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/platform/files.dart';
import 'package:ox_coi/src/settings/settings_security_bloc.dart';
import 'package:ox_coi/src/settings/settings_security_event_state.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/clipboard.dart';
import 'package:ox_coi/src/utils/dialog_builder.dart';
import 'package:ox_coi/src/utils/text.dart';
import 'package:ox_coi/src/utils/toast.dart';
import 'package:ox_coi/src/widgets/fullscreen_progress.dart';
import 'package:rxdart/rxdart.dart';

import 'package:ox_coi/src/adaptiveWidgets/adaptive_app_bar.dart';

class SettingsSecurity extends StatefulWidget {
  @override
  _SettingsSecurityState createState() => _SettingsSecurityState();
}

class _SettingsSecurityState extends State<SettingsSecurity> {
  final Navigation navigation = Navigation();
  OverlayEntry _progressOverlayEntry;
  SettingsSecurityBloc _settingsSecurityBloc = SettingsSecurityBloc();
  bool _enableBack = true;

  @override
  void initState() {
    super.initState();
    navigation.current = Navigatable(Type.settingsSecurity);
    final settingsSecurityObservable = new Observable<SettingsSecurityState>(_settingsSecurityBloc.state);
    settingsSecurityObservable.listen((state) => _settingsSecurityStateChange(state));
  }

  @override
  void dispose() {
    _settingsSecurityBloc.dispose();
    super.dispose();
  }

  void _settingsSecurityStateChange(SettingsSecurityState state) {
    if (state is SettingsSecurityStateLoading) {
      _enableBack = false;
      String text;
      if (state.type == SettingsSecurityType.importKeys) {
        text = L10n.get(L.settingKeyImportRunning);
      } else if (state.type == SettingsSecurityType.exportKeys) {
        text = L10n.get(L.settingKeyExportRunning);
      } else if (state.type == SettingsSecurityType.initiateKeyTransfer) {
        text = L10n.get(L.settingKeyTransferRunning);
      }
      _progressOverlayEntry = OverlayEntry(
        builder: (context) => FullscreenProgress(
          bloc: _settingsSecurityBloc,
          text: text,
          showProgressValues: false,
          showCancelButton: false,
        ),
      );
      Overlay.of(context).insert(_progressOverlayEntry);
    } else if (state is SettingsSecurityStateSuccess || state is SettingsSecurityStateFailure) {
      _enableBack = true;
      if (_progressOverlayEntry != null) {
        _progressOverlayEntry.remove();
        _progressOverlayEntry = null;
      }
      if (state is SettingsSecurityStateSuccess) {
        if (!isNullOrEmpty(state.setupCode)) {
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
                    var toastText = L10n.getFormatted(L.clipboardCopiedX, [L.code]);
                    copyToClipboardWithToast(text: state.setupCode, toastText: toastText);
                    navigation.pop(context);
                  },
                ),
                new FlatButton(
                  child: new Text(L10n.get(L.ok)),
                  onPressed: () {
                    navigation.pop(context);
                  },
                ),
              ],
            ),
          );
        } else {
          showToast(L10n.get(L.settingKeyTransferSuccess));
        }
      }
      if (state is SettingsSecurityStateFailure) {
        if (state.error == null) {
          showToast(L10n.get(L.settingKeyTransferFailed));
        } else {
          switch (state.error) {
            case SettingsSecurityStateError.missingStoragePermission:
              showToast(L10n.get(L.settingKeyTransferPermissionFailed));
              break;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _enableBack,
      child: Scaffold(
          appBar: AdaptiveAppBar(
            title: Text(L10n.get(L.security)),
          ),
          body: _buildPreferenceList(context)),
    );
  }

  ListView _buildPreferenceList(BuildContext context) {
    return ListView(
      children: ListTile.divideTiles(context: context, tiles: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: listItemPadding, horizontal: listItemPaddingBig),
          title: Text(L10n.get(L.settingExportKey)),
          subtitle: Text(L10n.get(L.settingSecurityExportText)),
          onTap: () => _onPressed(context, SettingsSecurityType.exportKeys),
        ),
        ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: listItemPadding, horizontal: listItemPaddingBig),
          title: Text(L10n.get(L.settingImportKeys)),
          subtitle: Text(L10n.get(L.settingImportKeysText)),
          onTap: () => _onPressed(context, SettingsSecurityType.importKeys),
        ),
        ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: listItemPadding, horizontal: listItemPaddingBig),
          title: Text(L10n.get(L.settingKeyTransferStart)),
          subtitle: Text(L10n.get(L.autocryptCreateMessageText)),
          onTap: () => _onPressed(context, SettingsSecurityType.initiateKeyTransfer),
        ),
      ]).toList(),
    );
  }

  void _onPressed(BuildContext context, SettingsSecurityType type) {
    switch (type) {
      case SettingsSecurityType.exportKeys:
        _showExportImportDialog(type);
        break;
      case SettingsSecurityType.importKeys:
        _showExportImportDialog(type);
        break;
      case SettingsSecurityType.initiateKeyTransfer:
        _showKeyTransferDialog();
        break;
    }
  }

  void _showExportImportDialog(SettingsSecurityType type) async {
    String title;
    String text;
    String path = await getExportImportPath();
    Type navigationType;
    if (type == SettingsSecurityType.exportKeys) {
      title = L10n.get(L.settingExportKey);
      text = L10n.getFormatted(L.settingSecurityExportKeysTextX, [path]);
      navigationType = Type.settingsExportKeysDialog;
    } else if (type == SettingsSecurityType.importKeys) {
      title = L10n.get(L.settingImportKeys);
      text = L10n.getFormatted(L.settingSecurityImportKeysTextX, [path]);
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

  void _exportImport(SettingsSecurityType type) {
    if (type == SettingsSecurityType.exportKeys) {
      _settingsSecurityBloc.dispatch(ExportKeys());
    } else if (type == SettingsSecurityType.importKeys) {
      _settingsSecurityBloc.dispatch(ImportKeys());
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
    _settingsSecurityBloc.dispatch(InitiateKeyTransfer());
  }
}
