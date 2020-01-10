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
import 'package:ox_coi/src/platform/preferences.dart';

import 'branded_theme.dart';

enum ThemeKey {
  LIGHT,
  DARK,
}

class CustomerThemes {
  static final BrandedTheme lightTheme = BrandedTheme(
    accent: const Color(0xFF0076FF),
    onAccent: Colors.white,
    info: const Color(0xFFFFF1DB),
    onInfo: const Color(0xFF1F1F1F),
    warning: Colors.yellow,
    onWarning: Colors.white,
    brightness: Brightness.light,
    background: const Color(0xFFF7F9FA),
    onBackground: const Color(0xFF1F1F1F),
    surface: Colors.white,
    onSurface: const Color(0xFF1F1F1F),
    secondary: const Color(0xFFE3F5FF),
    onSecondary: const Color(0xFF1F1F1F),
    error: Colors.red,
    onError: Colors.white,
    primary: const Color(0xFF0E7BCC),
    onPrimary: Colors.white,
  );

  static final BrandedTheme darkTheme = BrandedTheme(
    accent: const Color(0xFF0076FF),
    onAccent: const Color(0xFFF3F3F3),
    info: const Color(0xFF4E4E4E),
    onInfo: Colors.white,
    warning: const Color(0xFFFFA000),
    onWarning: Colors.white,
    brightness: Brightness.dark,
    background: Colors.black,
    onBackground: const Color(0xFFF3F3F3),
    surface: const Color(0xFF1F1F1F),
    onSurface: const Color(0xFFF3F3F3),
    secondary: const Color(0xFF0D47A1),
    onSecondary: const Color(0xFFF3F3F3),
    error: const Color(0xFFE53935),
    onError: Colors.white,
    primary: const Color(0xFF052D4B),
    onPrimary: const Color(0xFFF3F3F3),
  );

  static BrandedTheme getThemeFromKey(ThemeKey themeKey) {
    switch (themeKey) {
      case ThemeKey.LIGHT:
        return lightTheme;
      case ThemeKey.DARK:
        return darkTheme;
      default:
        return lightTheme;
    }
  }
}

class _CustomTheme extends InheritedWidget {
  final CustomThemeState data;

  _CustomTheme({
    this.data,
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_CustomTheme oldWidget) {
    return true;
  }
}

class CustomTheme extends StatefulWidget {
  final Widget child;
  final ThemeKey initialThemeKey;

  const CustomTheme({
    Key key,
    this.initialThemeKey,
    @required this.child,
  }) : super(key: key);

  @override
  CustomThemeState createState() => new CustomThemeState();

  static BrandedTheme of(BuildContext context) {
    _CustomTheme inherited = (context.dependOnInheritedWidgetOfExactType<_CustomTheme>());
    return inherited.data.theme;
  }

  static CustomThemeState instanceOf(BuildContext context) {
    _CustomTheme inherited = (context.dependOnInheritedWidgetOfExactType<_CustomTheme>());
    return inherited.data;
  }
}

class CustomThemeState extends State<CustomTheme> with WidgetsBindingObserver {
  ThemeKey _actualThemeKey;
  BrandedTheme _theme;

  ThemeKey get actualThemeKey => _actualThemeKey;
  BrandedTheme get theme => _theme;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _actualThemeKey = widget.initialThemeKey;
    _theme = CustomerThemes.getThemeFromKey(widget.initialThemeKey);
    _checkSavedTheme();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    _checkSavedTheme();
  }

  void _checkSavedTheme() async{
    var newThemeKey;
    String savedThemeKey = await getPreference(preferenceAppThemeKey);
    if(savedThemeKey == null){
      final Brightness brightness = WidgetsBinding.instance.window.platformBrightness;
      newThemeKey = brightness == Brightness.light ? ThemeKey.LIGHT : ThemeKey.DARK;
    }else{
      newThemeKey = savedThemeKey.compareTo(ThemeKey.LIGHT.toString()) == 0 ? ThemeKey.LIGHT : ThemeKey.DARK;
    }
    changeTheme(newThemeKey);
  }

  void changeTheme(ThemeKey themeKey) {
    setState(() {
      _actualThemeKey = themeKey;
      _theme = CustomerThemes.getThemeFromKey(themeKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _CustomTheme(
      data: this,
      child: widget.child,
    );
  }
}
