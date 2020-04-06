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
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/extensions/color_apis.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/main/root_child.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/utils/text_field_handling.dart';
import 'package:ox_coi/src/widgets/button.dart';
import 'package:provider/provider.dart';

StreamController<AppBarAction> _getAppBarActionStream(BuildContext context) {
  try {
    return Provider.of<StreamController<AppBarAction>>(context, listen: false);
  } catch (_) {
    return null;
  }
}

Border dividerLine(BuildContext context) {
  return Border(bottom: BorderSide(width: dividerHeight, color: Theme.of(context).dividerColor));
}

class DynamicAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Widget titleWidget;
  final IconButton leading;
  final List<Widget> trailingList;
  final showDivider;

  const DynamicAppBar({Key key, this.title, this.titleWidget, this.leading, this.trailingList, this.showDivider = true})
      : assert(title == null || titleWidget == null),
        super(key: key);

  @override
  _DynamicAppBarState createState() => _DynamicAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(appBarPreferredSize); // Max size of the large appbar + MediaQuery scale factor of 2
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
    final textScaleFactor =
        Platform.isIOS && MediaQuery.of(context).textScaleFactor > textScaleDefault ? textScaleDefault : MediaQuery.of(context).textScaleFactor;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: textScaleFactor),
      child: Container(
        decoration: BoxDecoration(
          color: CustomTheme.of(context).background,
          border: widget.showDivider ? dividerLine(context) : null,
        ),
        padding: EdgeInsets.only(top: statusBarHeight, bottom: appBarBottomOverflowFix),
        // The bottom padding fixes a gap between the appbar and the content
        child: AnimatedCrossFade(
          crossFadeState: visible ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: Duration(milliseconds: appBarAnimationDuration),
          firstChild: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: large ? CrossAxisAlignment.end : CrossAxisAlignment.center,
                children: <Widget>[
                  if (!large)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: dimension4dp),
                      child: widget.leading,
                    ),
                  Expanded(
                    child: widget.titleWidget != null
                        ? widget.titleWidget
                        : _AppBarTitle(
                            large: large,
                            text: widget.title,
                            trailingCount: widget.trailingList != null ? widget.trailingList.length : 0,
                          ),
                  ),
                  if (widget.trailingList != null && widget.trailingList.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        for (var action in widget.trailingList)
                          Padding(
                            padding: const EdgeInsets.only(right: dimension8dp),
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
  final trailingCount;

  const _AppBarTitle({Key key, @required this.large, @required this.text, @required this.trailingCount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titlePadding = _getTitlePadding(large);
    final titleStyle = large
        ? Theme.of(context).textTheme.headline.copyWith(fontWeight: FontWeight.bold, color: CustomTheme.of(context).onBackground)
        : Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.bold, color: CustomTheme.of(context).onBackground);
    final titleAlignment = (!large && Platform.isIOS) ? TextAlign.center : TextAlign.start;
    return Padding(
      padding: titlePadding,
      child: Text(
        text ?? "",
        style: titleStyle,
        textAlign: titleAlignment,
      ),
    );
  }

  EdgeInsets _getTitlePadding(bool large) {
    if (large) {
      return const EdgeInsets.only(left: dimension16dp, top: dimension40dp, bottom: dimension8dp);
    } else {
      if (Platform.isIOS) {
        var padding = appBarTrailingIconSize;
        if (trailingCount == 0) {
          return EdgeInsets.only(right: padding);
        } else if (trailingCount == 1) {
          return EdgeInsets.zero;
        } else {
          return EdgeInsets.only(left: padding * (trailingCount - 1));
        }
      } else {
        return const EdgeInsets.only(left: dimension16dp);
      }
    }
  }
}

class AppBarBackButton extends IconButton {
  AppBarBackButton({@required context})
      : super(
          key: ValueKey(keyBackOrCloseButton),
          icon: AdaptiveIcon(icon: IconSource.arrowBack),
          onPressed: () => Navigation().pop(context),
        );
}

class AppBarCloseButton extends IconButton {
  AppBarCloseButton({@required context})
      : super(
          key: ValueKey(keyBackOrCloseButton),
          icon: AdaptiveIcon(icon: IconSource.close),
          onPressed: () => Navigation().pop(context),
        );
}

class DynamicSearchBar extends StatelessWidget {
  final DynamicSearchBarContent content;
  final bool scrollable;

  DynamicSearchBar({Key key, @required this.content, this.scrollable = true}) : super(key: key);

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
  static const _height = searchBarHeight;

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
  var _isSearchingState = false;
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
      decoration: BoxDecoration(
        color: CustomTheme.of(context).background,
        border: dividerLine(context),
      ),
      padding: const EdgeInsets.symmetric(horizontal: dimension16dp, vertical: searchBarVerticalPadding),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              key: ValueKey(keySearchBarInput),
              controller: _controller,
              focusNode: _focusNode,
              onChanged: (text) {
                widget.onSearch(text);
                _setSearchingState();
              },
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(dimension24dp)),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(dimension24dp)),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                filled: true,
                fillColor: CustomTheme.of(context).onSurface.barely(),
                prefixIcon: _canHideAppBar && _isActive ? null : Icon(Icons.search),
                suffixIcon: Visibility(
                  visible: _isSearchingState,
                  child: IconButton(
                    key: ValueKey(keySearchBarClearButton),
                    icon: Icon(Icons.cancel),
                    color: CustomTheme.of(context).onSurface.slightly(),
                    onPressed: _clearSearch,
                  ),
                ),
                contentPadding: const EdgeInsets.only(left: dimension16dp, top: zero, right: dimension8dp, bottom: zero),
                hintText: _isActive ? "" : L10n.get(L.search),
                hintStyle: Theme.of(context).textTheme.body1.apply(color: CustomTheme.of(context).onSurface.half()),
              ),
            ),
          ),
          Visibility(
            visible: _isActive,
            child: ButtonImportanceNone(
              key: ValueKey(keySearchBarClearButton),
              child: Text('Cancel'),
              onPressed: () => _resetSearch(context),
            ),
          ),
        ],
      ),
    );
  }

  void _setSearchingState([bool isSearching]) {
    setState(() {
      _isSearchingState = isSearching ?? _isSearching();
    });
  }

  bool _isSearching() => _controller.text.isNotEmpty;

  void _clearSearch() {
    _setSearchingState(false);
    widget.onSearch("");
    safeControllerClear(_controller);
  }

  void _resetSearch(BuildContext context) {
    widget.onSearch(null);
    resetGlobalFocus(context);
    safeControllerClear(_controller);
  }
}
