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
import 'package:ox_coi/src/adaptive_widgets/adaptive_bottom_sheet.dart';
import 'package:ox_coi/src/adaptive_widgets/adaptive_dialog.dart';
import 'package:ox_coi/src/adaptive_widgets/adaptive_dialog_action.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';

import '../utils/keyMapping.dart';

showNavigatableBottomSheet({
  @required BuildContext context,
  @required AdaptiveBottomSheet bottomSheet,
  @required Navigatable navigatable,
  Navigatable previousNavigatable,
}) {
  Navigation navigation = Navigation();
  previousNavigatable = previousNavigatable ?? navigation.current;
  navigation.current = navigatable;
  if (Platform.isIOS) {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return bottomSheet;
      },
    ).then((value) {
      navigation.current = previousNavigatable;
    });
  } else {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return bottomSheet;
      },
    ).then((value) {
      navigation.current = previousNavigatable;
    });
  }
}

showNavigatableDialog(
    {@required BuildContext context,
    @required Widget dialog,
    @required Navigatable navigatable,
    Navigatable previousNavigatable,
    barrierDismissible = true}) {
  Navigation navigation = Navigation();
  previousNavigatable = previousNavigatable ?? navigation.current;
  navigation.current = navigatable;

  return showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return dialog;
    },
  ).then((value) {
    navigation.current = previousNavigatable;
  });
}

showConfirmationDialog({
  @required BuildContext context,
  @required String title,
  String contentText,
  Widget content,
  @required String positiveButton,
  @required Function positiveAction,
  @required Navigatable navigatable,
  Navigatable previousNavigatable,
  String negativeButton,
  Function negativeAction,
  bool selfClose = true,
  barrierDismissible = true,
  Function onWillPop,
}) {
  Navigation navigation = Navigation();
  assert(content != null || contentText != null);

  return showNavigatableDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    navigatable: navigatable,
    previousNavigatable: previousNavigatable,
    dialog: WillPopScope(
        onWillPop: onWillPop,
        child: AdaptiveDialog(
          title: Text(title),
          content: content ?? Text(contentText),
          actions: <Widget>[
            AdaptiveDialogAction(
              key: Key(keyConfirmationDialogCancelButton),
              child: Text(negativeButton != null && negativeButton.isNotEmpty ? negativeButton : L10n.get(L.cancel)),
              onPressed: () {
                if (negativeAction != null) {
                  negativeAction();
                }
                navigation.pop(context);
              },
            ),
            AdaptiveDialogAction(
              key: Key(keyConfirmationDialogPositiveButton),
              child: Text(positiveButton),
              onPressed: () {
                positiveAction();
                if (selfClose) {
                  navigation.pop(context);
                }
              },
            ),
          ],
        )),
  );
}

showInformationDialog(
    {@required BuildContext context,
    @required String title,
    @required String contentText,
    @required Navigatable navigatable,
    Navigatable previousNavigatable}) {
  Navigation navigation = Navigation();

  return showNavigatableDialog(
      context: context,
      navigatable: navigatable,
      previousNavigatable: previousNavigatable,
      dialog: AdaptiveDialog(
        title: Text(title),
        content: Text(contentText),
        actions: <Widget>[
          AdaptiveDialogAction(
            key: Key(keyInformationDialogPositiveButton),
            child: Text(L10n.get(L.ok)),
            onPressed: () {
              navigation.pop(context);
            },
          ),
        ],
      ));
}
