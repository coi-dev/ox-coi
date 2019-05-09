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
import 'package:ox_talk/src/l10n/localizations.dart';

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
  final bool autoFocus;
  final TextInputType inputType;
  final TextEditingController controller = TextEditingController();
  final bool needValidation;
  final bool enabled;

  ValidatableTextFormField(
    this.labelText, {
    this.hintText,
    Key key,
    this.textFormType = TextFormType.normal,
    this.inputType = TextInputType.text,
    this.autoFocus = false,
    this.needValidation = true,
    this.enabled = true,
  }) : super(key: key);

  @override
  _ValidatableTextFormFieldState createState() => _ValidatableTextFormFieldState();
}

class _ValidatableTextFormFieldState extends State<ValidatableTextFormField> {
  bool _passwordIsVisible = false;

  @override
  Widget build(BuildContext context) {
    return widget.textFormType != TextFormType.password ? buildPasswordTextField() : buildTextField();
  }

  TextFormField buildPasswordTextField() {
    return TextFormField(
        autofocus: widget.autoFocus,
        maxLines: 1,
        controller: widget.controller,
        keyboardType: widget.inputType,
        enabled: widget.enabled,
        validator: (value) {
          if (widget.needValidation) {
            if (widget.textFormType == TextFormType.email && !isEmail(value)) {
              return AppLocalizations.of(context).validatableTextFormFieldHintInvalidEmail;
            } else if (widget.textFormType == TextFormType.port) {
              if (!isValidPort(value)) {
                return AppLocalizations.of(context).validatableTextFormFieldHintInvalidPort;
              }
            }
          }
        },
        decoration: InputDecoration(
          labelText: widget.labelText(context),
          hintText: widget.hintText != null ? widget.hintText(context) : "",
        ));
  }

  TextFormField buildTextField() {
    return TextFormField(
        obscureText: !_passwordIsVisible ? true : false,
        autofocus: false,
        maxLines: 1,
        controller: widget.controller,
        validator: (value) {
          if (widget.needValidation) {
            if (value.isEmpty) {
              return AppLocalizations.of(context).validatableTextFormFieldHintInvalidPassword;
            }
          }
        },
        decoration: InputDecoration(
          labelText: widget.labelText(context),
          hintText: widget.hintText != null ? widget.hintText(context) : "",
          suffixIcon: IconButton(icon: Icon(!_passwordIsVisible ? Icons.visibility_off : Icons.visibility), onPressed: _togglePasswordVisibility),
        ));
  }

  void _togglePasswordVisibility() {
    setState(() {
      if (_passwordIsVisible) {
        _passwordIsVisible = false;
      } else {
        _passwordIsVisible = true;
      }
    });
  }

  bool isEmail(String email) {
    String source =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(source);
    return regExp.hasMatch(email);
  }

  bool isValidPort(String portString) {
    if (portString.isEmpty) {
      return true;
    }
    int port = int.tryParse(portString);
    if (port == null || port < 1 || port >= 65535) {
      return false;
    }
    return true;
  }
}
