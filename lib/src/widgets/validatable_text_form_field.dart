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
import 'package:ox_coi/src/utils/text.dart';

enum TextFormType {
  normal,
  email,
  password,
  port,
}

class ValidatableTextFormField extends StatefulWidget {
  final TextFormType textFormType;
  final Function labelText;
  final Function hintText;
  final TextInputType inputType;
  final bool needValidation;
  final Function validationHint;
  final bool enabled;
  final int maxLines;
  final bool showIcon;
  final TextEditingController controller = TextEditingController();

  ValidatableTextFormField(
    this.labelText, {
    this.hintText,
    Key key,
    this.textFormType = TextFormType.normal,
    this.inputType = TextInputType.text,
    this.needValidation = false,
    this.validationHint,
    this.enabled = true,
    this.maxLines = 1,
    this.showIcon = false
  }) : super(key: key);

  @override
  _ValidatableTextFormFieldState createState() => _ValidatableTextFormFieldState();
}

class _ValidatableTextFormFieldState extends State<ValidatableTextFormField> {
  bool _showReadablePassword = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        obscureText: widget.textFormType == TextFormType.password && !_showReadablePassword,
        maxLines: widget.maxLines,
        controller: widget.controller,
        keyboardType: widget.inputType,
        enabled: widget.enabled,
        autocorrect: false,
        validator: (value) => _validate(value),
        decoration: _getInputDecoration());
  }

  InputDecoration _getInputDecoration() {
    if (widget.textFormType == TextFormType.password) {
      return InputDecoration(
        labelText: widget.labelText(context),
        hintText: widget.hintText != null ? widget.hintText(context) : "",
        prefixIcon: widget.showIcon ? Icon(Icons.lock) : null,
        suffixIcon: IconButton(icon: Icon(_showReadablePassword ? Icons.visibility : Icons.visibility_off), onPressed: _togglePasswordVisibility),
      );
    } else {
      return InputDecoration(
        labelText: widget.labelText(context),
        hintText: widget.hintText != null ? widget.hintText(context) : "",
        prefixIcon: widget.textFormType == TextFormType.email && widget.showIcon ? Icon(Icons.person) : null,
      );
    }
  }

  String _validate(String value) {
    var valid = true;
    if (widget.needValidation) {
      if (widget.textFormType == TextFormType.normal) {
        valid = value.isNotEmpty;
      } else if (widget.textFormType == TextFormType.email) {
        valid = isEmail(value);
      } else if (widget.textFormType == TextFormType.port) {
        valid = isPort(value);
      }
    }
    if (!valid) {
      return widget.validationHint(context);
    }
    return null;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _showReadablePassword = !_showReadablePassword;
    });
  }
}
