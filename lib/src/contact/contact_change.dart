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

import 'package:delta_chat_core/delta_chat_core.dart' as dcc;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/chat/chat.dart';
import 'package:ox_coi/src/data/contact_extension.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/extensions/color_apis.dart';
import 'package:ox_coi/src/extensions/string_ui.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/qr/qr.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/widgets/dynamic_appbar.dart';
import 'package:ox_coi/src/widgets/list_group_header.dart';
import 'package:ox_coi/src/widgets/modal_builder.dart';
import 'package:ox_coi/src/widgets/settings_item.dart';
import 'package:ox_coi/src/widgets/validatable_text_form_field.dart';

import 'contact_item_bloc.dart';
import 'contact_item_event_state.dart';

enum ContactAction {
  add,
  edit,
}

class ContactChange extends StatefulWidget {
  static get editViewTitle => L10n.get(L.contactEdit);
  static get addViewTitle => L10n.get(L.contactAdd);
  static get createViewTitle => L10n.get(L.chatCreate);

  final ContactAction contactAction;
  final int id;
  final bool createChat;

  ContactChange({@required this.contactAction, this.id, this.createChat = false});

  @override
  _ContactChangeState createState() => _ContactChangeState();
}

class _ContactChangeState extends State<ContactChange> {
  Navigation _navigation = Navigation();
  GlobalKey<FormState> _formKey = GlobalKey();
  ValidatableTextFormField _nameField = ValidatableTextFormField(
    (context) => L10n.get(L.name),
    key: Key(keyContactChangeNameValidatableTextFormField),
    hintText: (context) => L10n.get(L.contactName),
    icon: AdaptiveIcon(icon: IconSource.person),
  );
  ValidatableTextFormField _emailField;

  String title;
  String changeToast;
  ContactStateData _contactData;

  ContactItemBloc _contactItemBloc = ContactItemBloc();

  Repository<dcc.Chat> chatRepository;

  @override
  void initState() {
    super.initState();
    _navigation.current = Navigatable(Type.contactChange);

    if (widget.contactAction == ContactAction.add) {
      _emailField = ValidatableTextFormField(
        (context) => L10n.get(L.emailAddress),
        key: Key(keyContactChangeEmailValidatableTextFormField),
        textType: TextType.email,
        inputType: TextInputType.emailAddress,
        icon: AdaptiveIcon(icon: IconSource.mail),
        needValidation: true,
        validationHint: (context) => L10n.get(L.loginCheckMail),
      );
    } else {
      _contactItemBloc.add(RequestContact(id: widget.id, typeOrChatId: validContacts));
    }

    chatRepository = RepositoryManager.get(RepositoryType.chat);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.contactAction == ContactAction.add) {
      title = widget.createChat ? ContactChange.createViewTitle : ContactChange.addViewTitle;
      changeToast = L10n.get(L.contactAddedSuccess);
    } else {
      title = ContactChange.editViewTitle;
      changeToast = L10n.get(L.contactEditedSuccess);
    }
    return Scaffold(
        appBar: DynamicAppBar(
          title: title,
          leading: AppBarCloseButton(context: context),
          trailingList: [
            IconButton(
              key: Key(keyContactChangeCheckIconButton),
              icon: AdaptiveIcon(icon: IconSource.check),
              onPressed: _onSubmit,
            )
          ],
        ),
        body: SingleChildScrollView(
          child: BlocListener(
            bloc: _contactItemBloc,
            listener: (context, state) async {
              if (state is ContactItemStateSuccess) {
                setState(() {
                  _contactData = state.contactStateData;
                });
                _nameField.controller.text = _contactData.name != null ? _contactData.name : "";
                if (state.contactHasChanged) {
                  if (!widget.createChat) {
                    changeToast.showToast();
                    _navigation.pop(context);
                  } else {
                    if (state.contactStateData.id != null) {
                      dcc.Context coreContext = dcc.Context();
                      var chatId = await coreContext.createChatByContactId(state.contactStateData.id);
                      chatRepository.putIfAbsent(id: chatId);
                      _navigation.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Chat(chatId: chatId)),
                        ModalRoute.withName(Navigation.root),
                        Navigatable(Type.rootChildren),
                      );
                    }
                  }
                }
              } else if (state is GoogleContactDetected) {
                showConfirmationDialog(
                  context: context,
                  title: L10n.get(L.contactGooglemailDialogTitle),
                  contentText: L10n.get(L.contactGooglemailDialogContent),
                  positiveButton: L10n.get(L.contactGooglemailDialogPositiveButton),
                  positiveAction: () => _googlemailMailAddressAction(true),
                  negativeButton: L10n.get(L.contactGooglemailDialogNegativeButton),
                  negativeAction: () => _googlemailMailAddressAction(false),
                  navigatable: Navigatable(Type.contactGooglemailDetectedDialog),
                  barrierDismissible: false,
                  onWillPop: _onGoogleMailDialogWillPop,
                );
              } else if (state is ContactItemStateFailure) {
                L10n.get(L.contactAddFailedAlreadyExists).showToast();
              }
            },
            child: Builder(
              builder: (BuildContext context) {
                return Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Visibility(
                        visible: widget.contactAction != ContactAction.add,
                        child: Padding(
                          padding: const EdgeInsets.only(top: changeContactTopPadding),
                          child: Container(
                            color: CustomTheme.of(context).surface,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: formHorizontalPadding, vertical: formVerticalPadding),
                              child: Row(
                                children: <Widget>[
                                  AdaptiveIcon(icon: IconSource.mail),
                                  Padding(
                                    padding: const EdgeInsets.only(right: iconFormPadding),
                                  ),
                                  Text(
                                    _contactData?.email ?? "",
                                    style: Theme.of(context).textTheme.subhead,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: widget.contactAction == ContactAction.add
                            ? const EdgeInsets.only(top: changeContactTopPadding)
                            : const EdgeInsets.all(zero),
                        child: Container(
                          color: CustomTheme.of(context).surface,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: formHorizontalPadding),
                            child: _nameField,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: widget.contactAction == ContactAction.add,
                        child: Container(
                          color: CustomTheme.of(context).surface,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: formHorizontalPadding),
                            child: _emailField,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: widget.contactAction != ContactAction.add && _contactData?.phoneNumbers != null,
                        child: Container(
                          color: CustomTheme.of(context).surface,
                          child: Column(
                            children: <Widget>[
                              for (var phoneNumber in ContactExtension.getPhoneNumberList(_contactData?.phoneNumbers))
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: formHorizontalPadding, vertical: formVerticalPadding),
                                  child: Row(
                                    children: <Widget>[
                                      AdaptiveIcon(icon: IconSource.phone),
                                      Padding(
                                        padding: const EdgeInsets.only(right: iconFormPadding),
                                      ),
                                      Text(
                                        phoneNumber,
                                        style: Theme.of(context).textTheme.subhead,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: dimension32dp, bottom: dimension72dp, left: formVerticalPadding, right: formVerticalPadding),
                        child: Text(
                          L10n.get(L.contactEditPhoneNumberText),
                          style: Theme.of(context).textTheme.caption.apply(color: CustomTheme.of(context).onBackground.half()),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Visibility(
                        visible: widget.contactAction == ContactAction.add,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ListGroupHeader(
                            text: L10n.get(L.qrAddContactHeader),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: widget.contactAction == ContactAction.add,
                        child: SettingsItem(
                          pushesNewScreen: true,
                          icon: IconSource.qr,
                          text: L10n.get(L.qrScan),
                          iconBackground: CustomTheme.of(context).qrIcon,
                          onTap: () => _navigation.push(
                            context,
                            MaterialPageRoute(builder: (context) => QrCode(chatId: 0, initialIndex: 1)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ));
  }

  _onSubmit() {
    if (_formKey.currentState.validate()) {
      _contactItemBloc.add(ChangeContact(
        name: _getName(),
        email: _getEmail(),
        contactAction: widget.contactAction,
      ));
    }
  }

  Future<bool> _onGoogleMailDialogWillPop() {
    return Future.value(false);
  }

  _googlemailMailAddressAction(bool changeEmail) {
    _contactItemBloc.add(AddGoogleContact(name: _getName(), email: _getEmail(), changeEmail: changeEmail));
  }

  String _getName() => _nameField.controller.text;

  String _getEmail() => widget.contactAction == ContactAction.add ? _emailField.controller.text : _contactData?.email;
}
