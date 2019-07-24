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
import 'package:ox_coi/src/l10n/localizations.dart';
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
import 'package:ox_coi/src/widgets/progress_handler.dart';
import 'package:rxdart/rxdart.dart';

class SettingsSecurity extends StatefulWidget {
  @override
  _SettingsSecurityState createState() => _SettingsSecurityState();
}

class _SettingsSecurityState extends State<SettingsSecurity> {
  final Navigation navigation = Navigation();
  OverlayEntry _progressOverlayEntry;
  FullscreenProgress _progress;
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
        text = AppLocalizations.of(context).securitySettingsImportKeysPerforming;
      } else if (state.type == SettingsSecurityType.exportKeys) {
        text = AppLocalizations.of(context).securitySettingsExportKeysPerforming;
      } else if (state.type == SettingsSecurityType.initiateKeyTransfer) {
        text = AppLocalizations.of(context).securitySettingsInitiateKeyTransferPerforming;
      }
      _progress = FullscreenProgress(
        bloc: _settingsSecurityBloc,
        text: text,
        showProgressValues: false,
        showCancelButton: false,
      );
      _progressOverlayEntry = OverlayEntry(builder: (context) => _progress);
      OverlayState overlayState = Overlay.of(context);
      overlayState.insert(_progressOverlayEntry);
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
              title: Text(AppLocalizations.of(context).securitySettingsInitiateKeyTransferDone),
              content: new Text(AppLocalizations.of(context).securitySettingsInitiateKeyTransferDoneDialog(state.setupCode)),
              actions: <Widget>[
                new FlatButton(
                  child: new Text(AppLocalizations.of(context).securitySettingsInitiateKeyTransferCopy),
                  onPressed: () {
                    var toastText = AppLocalizations.of(context).securitySettingsInitiateKeyTransferCopyDone;
                    copyToClipboardWithToast(text: state.setupCode, toastText: toastText);
                    navigation.pop(context);
                  },
                ),
                new FlatButton(
                  child: new Text(AppLocalizations.of(context).ok),
                  onPressed: () {
                    navigation.pop(context);
                  },
                ),
              ],
            ),
          );
        } else {
          showToast(AppLocalizations.of(context).securitySettingsKeyActionSuccess);
        }
      }
      if (state is SettingsSecurityStateFailure) {
        if (state.error == null) {
          showToast(AppLocalizations.of(context).securitySettingsKeyActionFailed);
        } else {
          switch (state.error) {
            case SettingsSecurityStateError.missingStoragePermission:
              showToast(AppLocalizations.of(context).securitySettingsKeyActionFailedNoPermission);
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
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).security),
          ),
          body: _buildPreferenceList(context)),
    );
  }

  ListView _buildPreferenceList(BuildContext context) {
    return ListView(
      children: ListTile.divideTiles(context: context, tiles: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: listItemPadding, horizontal: listItemPaddingBig),
          title: Text(AppLocalizations.of(context).securitySettingsExportKeys),
          subtitle: Text(AppLocalizations.of(context).securitySettingsExportKeysText),
          onTap: () => _onPressed(context, SettingsSecurityType.exportKeys),
        ),
        ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: listItemPadding, horizontal: listItemPaddingBig),
          title: Text(AppLocalizations.of(context).securitySettingsImportKeys),
          subtitle: Text(AppLocalizations.of(context).securitySettingsImportKeysText),
          onTap: () => _onPressed(context, SettingsSecurityType.importKeys),
        ),
        ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: listItemPadding, horizontal: listItemPaddingBig),
          title: Text(AppLocalizations.of(context).securitySettingsInitiateKeyTransfer),
          subtitle: Text(AppLocalizations.of(context).securitySettingsInitiateKeyTransferText),
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
      title = AppLocalizations.of(context).securitySettingsExportKeys;
      text = AppLocalizations.of(context).securitySettingsExportKeysDialog(path);
      navigationType = Type.settingsExportKeysDialog;
    } else if (type == SettingsSecurityType.importKeys) {
      title = AppLocalizations.of(context).securitySettingsImportKeys;
      text = AppLocalizations.of(context).securitySettingsImportKeysDialog(path);
      navigationType = Type.settingsImportKeysDialog;
    }
    showConfirmationDialog(
      context: context,
      title: title,
      content: text,
      positiveButton: AppLocalizations.of(context).ok,
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
      title: AppLocalizations.of(context).securitySettingsInitiateKeyTransfer,
      content: AppLocalizations.of(context).securitySettingsInitiateKeyTransferDialog,
      positiveButton: AppLocalizations.of(context).ok,
      positiveAction: _keyTransfer,
      navigatable: Navigatable(Type.settingsKeyTransferDialog),
    );
  }

  void _keyTransfer() {
    _settingsSecurityBloc.dispatch(InitiateKeyTransfer());
  }
}
