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
import 'package:ox_coi/src/extensions/string_apis.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/widgets/button.dart';

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
                padding: const EdgeInsets.only(top: listStateInfoVerticalPadding),
              ),
              if (showLoading != null && showLoading) CircularProgressIndicator(),
              if (!imagePath.isNullOrEmpty()) Image.asset(imagePath),
              if (!title.isNullOrEmpty())
                Padding(
                  padding: buildEdgeInsets(),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headline,
                    textAlign: TextAlign.center,
                  ),
                ),
              if (!subTitle.isNullOrEmpty())
                Padding(
                  padding: buildEdgeInsets(),
                  child: Text(
                    subTitle,
                    style: Theme.of(context).textTheme.body1,
                    textAlign: TextAlign.center,
                  ),
                ),
              if (!actionTitle.isNullOrEmpty() && action != null)
                Padding(
                  padding: buildEdgeInsets(),
                  child: ButtonImportanceHigh(
                    child: Text(actionTitle),
                    onPressed: action,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: listStateInfoVerticalPadding),
              )
            ],
          ),
        ),
      ),
    );
  }

  EdgeInsets buildEdgeInsets() =>
      const EdgeInsets.only(top: listStateInfoVerticalPadding, left: listStateInfoHorizontalPadding, right: listStateInfoHorizontalPadding);
}

class EmptyListInfo extends StatelessWidget {
  final String infoText;
  final String imagePath;

  EmptyListInfo({Key key, this.infoText, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: dimension32dp, left: listEmptyHorizontalPadding, right: listEmptyHorizontalPadding),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(child: Image.asset(imagePath)),
          Padding(
            padding: const EdgeInsets.only(top: dimension16dp),
            child: Text(
              infoText,
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
