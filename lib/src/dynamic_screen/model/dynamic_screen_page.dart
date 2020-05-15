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

import 'package:json_annotation/json_annotation.dart';
import 'package:ox_coi/src/dynamic_screen/dynamic_screen_model.dart';
import 'package:ox_coi/src/dynamic_screen/model/dynamic_screen_avatar.dart';

part 'dynamic_screen_page.g.dart';

@JsonSerializable()
class DynamicScreenPageModel {
  @JsonKey(defaultValue: true)
  bool skipable;

  @JsonKey(nullable: true, defaultValue: [{}])
  final List<Map<String, bool>> availabilities;

  @JsonKey(nullable: true, defaultValue: [32.0, 0, 32.0, 0])
  final List<double> padding;

  @JsonKey(fromJson: _componentsFromJson)
  final List<dynamic> components;

  DynamicScreenPageModel(this.skipable, this.availabilities, this.components, this.padding);

  factory DynamicScreenPageModel.fromJson(Map<String, dynamic> json) => _$DynamicScreenPageModelFromJson(json);
  Map<String, dynamic> toJson() => _$DynamicScreenPageModelToJson(this);

  static List<dynamic> _componentsFromJson(List<dynamic> jsonComponents) {
    List<dynamic> pageComponents = [];

    try {
      for (Map<String, dynamic> jsonComponent in jsonComponents) {
        final type = jsonComponent.keys.first.dynamicScreenComponentType;
        final json = jsonComponent[type.stringValue];

        var model;
        switch (type) {
          case DynamicScreenComponentType.avatar:
            model = DynamicScreenAvatarModel.fromJson(json);
            break;
          case DynamicScreenComponentType.button:
            model = DynamicScreenButtonModel.fromJson(json);
            break;
          case DynamicScreenComponentType.image:
            model = DynamicScreenImageModel.fromJson(json);
            break;
          case DynamicScreenComponentType.radio:
            model = DynamicScreenRadioModel.fromJson(json);
            break;
          case DynamicScreenComponentType.radiolist:
            model = DynamicScreenRadioListModel.fromJson(json);
            break;
          case DynamicScreenComponentType.text:
            model = DynamicScreenTextModel.fromJson(json);
            break;
          case DynamicScreenComponentType.textfield:
            model = DynamicScreenTextfieldModel.fromJson(json);
            break;
        }
        pageComponents.add(model);
      }
    } catch (error) {
      print("** Deserialization ERROR: ${error.toString()}");
    }

    return pageComponents;
  }
}
