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
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/text.dart';

class StateInfo extends StatelessWidget {
  final bool showLoading;
  final String imagePath;
  final String title;
  final String subTitle;
  final String actionTitle;
  final Function action;

  const StateInfo({Key key, this.showLoading, this.imagePath, this.title, this.subTitle, this.actionTitle, this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: listStateInfoVerticalPadding),
              ),
              if (showLoading != null && showLoading) CircularProgressIndicator(),
              if (!isNullOrEmpty(imagePath)) Image.asset(imagePath),
              if (!isNullOrEmpty(title))
                Padding(
                  padding: buildEdgeInsets(),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.title,
                    textAlign: TextAlign.center,
                  ),
                ),
              if (!isNullOrEmpty(subTitle))
                Padding(
                  padding: buildEdgeInsets(),
                  child: Text(
                    subTitle,
                    style: Theme.of(context).textTheme.subtitle,
                    textAlign: TextAlign.center,
                  ),
                ),
              if (!isNullOrEmpty(actionTitle) && action != null)
                Padding(
                  padding: buildEdgeInsets(),
                  child: RaisedButton(
                    color: accent,
                    textColor: onAccent,
                    onPressed: action,
                    child: Text(actionTitle),
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(bottom: listStateInfoVerticalPadding),
              )
            ],
          ),
        ),
      ),
    );
  }

  EdgeInsets buildEdgeInsets() => EdgeInsets.only(top: listStateInfoVerticalPadding, left: listStateInfoHorizontalPadding, right: listStateInfoHorizontalPadding);
}
