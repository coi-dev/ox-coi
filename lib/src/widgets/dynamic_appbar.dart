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

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/main/root_child.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/ui/custom_theme.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/text_field_handling.dart';
import 'package:provider/provider.dart';

StreamController<AppBarAction> _getAppBarActionStream(BuildContext context) {
  try {
    return Provider.of<StreamController<AppBarAction>>(context, listen: false);
  } catch (_) {
    return null;
  }
}

class DynamicAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Widget titleWidget;
  final IconButton leading;
  final List<Widget> trailingList;

  const DynamicAppBar({Key key, this.title, this.titleWidget, this.leading, this.trailingList})
      : assert(title != null || titleWidget != null),
        super(key: key);

  @override
  _DynamicAppBarState createState() => _DynamicAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(105); // Max size of the large appbar + MediaQuery scale factor of 2
}

class _DynamicAppBarState extends State<DynamicAppBar> {
  StreamSubscription appBarActionsSubscription;
  var visible = true;

  @override
  void initState() {
    super.initState();
    appBarActionsSubscription = _getAppBarActionStream(context)?.stream?.listen((data) {
      if (data == AppBarAction.toggleAppBarVisibility) {
        setState(() => visible = !visible);
      }
    });
  }

  @override
  void dispose() {
    appBarActionsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final large = widget.leading == null;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final textScaleFactor = Platform.isIOS && MediaQuery.of(context).textScaleFactor > 1.0 ? 1.0 : MediaQuery.of(context).textScaleFactor;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: textScaleFactor),
      child: Container(
        padding: EdgeInsets.only(top: statusBarHeight, bottom: 1.0), // The bottom padding fixes a gap between the appbar and the content
        color: CustomTheme.of(context).background,
        child: AnimatedCrossFade(
          crossFadeState: visible ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: Duration(milliseconds: 200),
          firstChild: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: large ? CrossAxisAlignment.end : CrossAxisAlignment.center,
                children: <Widget>[
                  if (!large)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: widget.leading,
                    ),
                  Expanded(
                    child: widget.titleWidget != null
                        ? widget.titleWidget
                        : _AppBarTitle(
                            large: large,
                            text: widget.title,
                          ),
                  ),
                  if (widget.trailingList != null && widget.trailingList.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        for (var action in widget.trailingList)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: action,
                          )
                      ],
                    ),
                ],
              ),
            ],
          ),
          secondChild: Container(
            height: zero,
          ),
        ),
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  final bool large;
  final String text;

  const _AppBarTitle({Key key, @required this.large, @required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titlePadding =
        large ? const EdgeInsets.only(left: 16.0, top: 40.0, bottom: 8.0) : Platform.isIOS ? EdgeInsets.zero : const EdgeInsets.only(left: 16.0);
    final titleStyle = large
        ? Theme.of(context).textTheme.headline.copyWith(fontWeight: FontWeight.bold, color: CustomTheme.of(context).onBackground)
        : Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.bold, color: CustomTheme.of(context).onBackground);
    final titleAlignment = (!large && Platform.isIOS) ? TextAlign.center : TextAlign.start;
    return Padding(
      padding: titlePadding,
      child: Text(
        text,
        style: titleStyle,
        textAlign: titleAlignment,
      ),
    );
  }
}

class AppBarBackButton extends IconButton {
  AppBarBackButton({Key key, @required context})
      : super(
          key: key,
          icon: AdaptiveIcon(icon: IconSource.arrowBack),
          onPressed: () => Navigation().pop(context),
        );
}

class AppBarCloseButton extends IconButton {
  AppBarCloseButton({Key key, @required context})
      : super(
          key: key,
          icon: AdaptiveIcon(icon: IconSource.close),
          onPressed: () => Navigation().pop(context),
        );
}

class DynamicSearchBar extends StatelessWidget {
  final DynamicSearchBarContent content;
  final bool scrollable;

  const DynamicSearchBar({Key key, @required this.content, this.scrollable = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return scrollable
        ? SliverPersistentHeader(
            floating: true,
            pinned: false,
            delegate: _SearchBarDelegate(dynamicSearchBarContent: content),
          )
        : content;
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  static const _height = 60.0;

  final DynamicSearchBarContent dynamicSearchBarContent;

  _SearchBarDelegate({@required this.dynamicSearchBarContent});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return dynamicSearchBarContent;
  }

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class DynamicSearchBarContent extends StatefulWidget {
  final Function onSearch;
  final Function onFocus;
  final Function isSearchingCallback;

  const DynamicSearchBarContent({Key key, @required this.onSearch, this.onFocus, this.isSearchingCallback}) : super(key: key);

  @override
  _DynamicSearchBarContentState createState() => _DynamicSearchBarContentState();
}

class _DynamicSearchBarContentState extends State<DynamicSearchBarContent> {
  final _focusNode = FocusNode();
  final _controller = TextEditingController();

  var _isActive = false;
  var _canHideAppBar = false;

  @override
  void initState() {
    super.initState();
    createFocusListener();
    createIsSearchingListener();
  }

  void createFocusListener() {
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && widget.onFocus != null) {
        widget.onFocus();
      }
      setState(() {
        _isActive = _focusNode.hasFocus || _isSearching();
        _canHideAppBar = _getAppBarActionStream(context) != null;
      });
      _getAppBarActionStream(context)?.add(AppBarAction.toggleAppBarVisibility);
    });
  }

  void createIsSearchingListener() {
    if (widget.isSearchingCallback != null) {
      _controller.addListener(() {
        widget.isSearchingCallback(_isSearching());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      color: CustomTheme.of(context).background,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: (text) => widget.onSearch(text),
        decoration: InputDecoration(
          prefixIcon: _canHideAppBar && _isActive
              ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => _resetSearch(context),
                )
              : Icon(Icons.search),
          suffixIcon: _isActive
              ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: _clearSearch,
                )
              : null,
          contentPadding: const EdgeInsets.only(left: zero, top: zero, right: 8.0, bottom: 0.0),
          hintText: L10n.get(L.search),
          hintStyle: Theme.of(context).textTheme.body1.apply(color: CustomTheme.of(context).onSurface.half()),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: CustomTheme.of(context).onSurface.barely()),
            borderRadius: BorderRadius.all(Radius.circular(composeTextBorderRadius)),
          ),
        ),
      ),
    );
  }

  bool _isSearching() => _controller.text.isNotEmpty;

  void _clearSearch() {
    widget.onSearch("");
    safeControllerClear(_controller);
  }

  void _resetSearch(BuildContext context) {
    widget.onSearch(null);
    resetGlobalFocus(context);
    safeControllerClear(_controller);
  }
}
