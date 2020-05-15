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
import 'package:ox_coi/src/dynamic_screen/dynamic_screen.dart';

class PageTextComponent extends PageBaseComponent {
  final DynamicScreenTextModel model;

  PageTextComponent({Key key, this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle style;
    switch (model.textStyle) {
      case DynamicScreenTextStyle.display4: style = Theme.of(context).textTheme.display4; break;
      case DynamicScreenTextStyle.display3: style = Theme.of(context).textTheme.display3; break;
      case DynamicScreenTextStyle.display2: style = Theme.of(context).textTheme.display2; break;
      case DynamicScreenTextStyle.display1: style = Theme.of(context).textTheme.display1; break;
      case DynamicScreenTextStyle.headline: style = Theme.of(context).textTheme.headline; break;
      case DynamicScreenTextStyle.title: style = Theme.of(context).textTheme.title; break;
      case DynamicScreenTextStyle.subhead: style = Theme.of(context).textTheme.subhead; break;
      case DynamicScreenTextStyle.body2: style = Theme.of(context).textTheme.body2; break;
      case DynamicScreenTextStyle.body1: style = Theme.of(context).textTheme.body1; break;
      case DynamicScreenTextStyle.caption: style = Theme.of(context).textTheme.caption; break;
      case DynamicScreenTextStyle.button: style = Theme.of(context).textTheme.button; break;
      case DynamicScreenTextStyle.subtitle: style = Theme.of(context).textTheme.subtitle; break;
      case DynamicScreenTextStyle.overline: style = Theme.of(context).textTheme.overline; break;
    }

    return Container(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: model.padding.edgeInsetsValue,
        child: Text(
          model.stringValue,
          style: style,
        ),
      ),
    );
  }
}