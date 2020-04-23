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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/extensions/color_apis.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/settings/settings_appearance_bloc.dart';
import 'package:ox_coi/src/settings/settings_appearance_event_state.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/vibration.dart';
import 'package:ox_coi/src/widgets/dynamic_appbar.dart';
import 'package:ox_coi/src/widgets/state_info.dart';

final _themeItemData = {
  ThemeKey.light: L10n.get(L.settingsAppearanceLightTitle),
  ThemeKey.dark: L10n.get(L.settingsAppearanceDarkTitle),
  ThemeKey.system: L10n.get(L.settingsAppearanceSystemTitle),
};

class SettingsAppearance extends StatefulWidget {
  static get viewTitle => L10n.get(L.settingsAppearanceTitle);

  SettingsAppearance();

  @override
  _SettingsAppearanceState createState() => _SettingsAppearanceState();
}

class _SettingsAppearanceState extends State<SettingsAppearance> {
  SettingsAppearanceBloc _settingsAppearanceBloc = SettingsAppearanceBloc();
  Navigation _navigation = Navigation();

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.settingsAppearance);
    _settingsAppearanceBloc.add(LoadAppearance());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: SettingsAppearance.viewTitle,
        leading: AppBarBackButton(context: context),
      ),
      body: BlocBuilder(
          bloc: _settingsAppearanceBloc,
          builder: (context, state) {
            if (state is SettingsAppearanceStateInitial) {
              return StateInfo(showLoading: true);
            } else if (state is SettingsAppearanceStateLoaded) {
              return _AppearanceSelector(
                selectedTheme: state.themeKey,
                onChanged: _appearanceChanged,
              );
            } else {
              return Center(
                child: AdaptiveIcon(icon: IconSource.error),
              );
            }
          }),
    );
  }

  void _appearanceChanged(ThemeKey theme) async {
    vibrateLight();
    CustomTheme.instanceOf(context).changeTheme(themeKey: theme);
    _settingsAppearanceBloc.add(AppearanceChanged(themeKey: theme));
  }
}

class _AppearanceSelector extends StatelessWidget {
  final ThemeKey selectedTheme;
  final ValueChanged<ThemeKey> onChanged;

  const _AppearanceSelector({Key key, @required this.selectedTheme, @required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(dimension32dp),
        color: CustomTheme.of(context).background,
        child: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.only(bottom: dimension32dp),
                child: Text(
                  L10n.getFormatted(L.settingsAppearanceDescription, [L10n.get(L.settingsAppearanceSystemTitle)]),
                )),
            Row(
              children: <Widget>[
                for (var themeKey in _themeItemData.keys)
                  _AppearanceSelectorItem(
                    themeKey: themeKey,
                    onChanged: onChanged,
                    selectedTheme: selectedTheme,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AppearanceSelectorItem extends StatelessWidget {
  final ThemeKey themeKey;
  final ValueChanged<ThemeKey> onChanged;
  final ThemeKey selectedTheme;

  const _AppearanceSelectorItem({Key key, @required this.themeKey, @required this.onChanged, @required this.selectedTheme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(themeKey),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: dimension8dp, right: dimension8dp),
              decoration: BoxDecoration(
                color: selectedTheme == themeKey ? CustomTheme.of(context).surface : CustomTheme.of(context).background,
                borderRadius: BorderRadius.all(Radius.circular(dimension8dp)),
                border: selectedTheme == themeKey ? Border.all(color: CustomTheme.of(context).onBackground.barely()) : null,
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: dimension4dp),
                    child: Container(
                      margin: EdgeInsets.all(dimension8dp),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(settingsAppearanceImageRadius)),
                        border: Border.all(color: CustomTheme.of(context).onBackground.slightly()),
                      ),
                      child: Image(
                        image: AssetImage('assets/images/theme_coi_${themeKey.stringValue}.png'),
                        width: 70.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: dimension12dp),
                    child: Text(
                      _themeItemData[themeKey],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: dimension8dp),
              child: Radio(
                value: themeKey,
                groupValue: selectedTheme,
                onChanged: (value) => onChanged(themeKey),
              ),
            )
          ],
        ),
      ),
    );
  }
}
