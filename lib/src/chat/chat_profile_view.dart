import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_talk/src/chat/chat_bloc.dart';
import 'package:ox_talk/src/chat/chat_event.dart';
import 'package:ox_talk/src/chat/chat_state.dart';
import 'package:ox_talk/src/contact/contact_change_bloc.dart';
import 'package:ox_talk/src/contact/contact_change_event.dart';
import 'package:ox_talk/src/contact/contact_item_bloc.dart';
import 'package:ox_talk/src/contact/contact_item_event.dart';
import 'package:ox_talk/src/contact/contact_item_state.dart';
import 'package:ox_talk/src/contact/contact_list_bloc.dart';
import 'package:ox_talk/src/contact/contact_list_event.dart';
import 'package:ox_talk/src/contact/contact_list_state.dart';
import 'package:ox_talk/src/navigation/navigation.dart';

class ChatProfileView extends StatefulWidget {
  final int _chatId;

  ChatProfileView(this._chatId);

  @override
  _ChatProfileViewState createState() => _ChatProfileViewState();
}

class _ChatProfileViewState extends State<ChatProfileView> {
  ChatBloc _chatBloc = ChatBloc();
  ContactListBloc _contactListBloc = ContactListBloc();
  final Navigation navigation = Navigation();

  @override
  void initState() {
    super.initState();
    _chatBloc.dispatch(RequestChat(widget._chatId));
    _contactListBloc.dispatch(RequestChatContacts(widget._chatId));
  }

  @override
  void dispose() {
    _chatBloc.dispose();
    _contactListBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder(
        bloc: _chatBloc,
        builder: (context, state){
          if(state is ChatStateSuccess){
            return _buildContactInfo();
          } else {
            return Container();
          }
        }
      )
    );
  }

  Widget _buildContactInfo() {
    return BlocBuilder(
      bloc: _contactListBloc,
      builder: (context, state){
        if(state is ContactListStateSuccess){
          if(state.contactIds.length == 1){
            var contactId = state.contactIds[0];
            var key = "$contactId-${state.contactLastUpdateValues[0]}";
            return ChatProfileSingleContact(state.contactIds[0], widget._chatId, key);
          }else{
            var contactId = state.contactIds[0];
            var key = "$contactId-${state.contactLastUpdateValues[0]}";
            return ChatProfileSingleContact(state.contactIds[0], widget._chatId, key);
          }
        }else {
          return Container();
        }
      }
    );
  }
}

class ChatProfileSingleContact extends StatefulWidget {
  final int _contactId;
  final int _chatId;

  ChatProfileSingleContact(this._contactId, this._chatId, key) : super(key: Key(key));

  @override
  _ChatProfileSingleContactState createState() => _ChatProfileSingleContactState();
}

class _ChatProfileSingleContactState extends State<ChatProfileSingleContact> {
  ContactItemBloc _contactItemBloc = ContactItemBloc();

  Navigation navigation = Navigation();

  @override
  void initState() {
    super.initState();
    _contactItemBloc.dispatch(RequestContact(widget._contactId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _contactItemBloc, 
      builder: (context, state){
        if(state is ContactItemStateSuccess){
          return Column(
            children: <Widget>[
              Text(state.email),
              RaisedButton(onPressed: () => _blockContact(), child: Text("Block contact"))
            ],
          );
        }
        else{
          return Container();
        }
      }
    );
  }

  _blockContact() {
    ContactChangeBloc contactChangeBloc = ContactChangeBloc();
    contactChangeBloc.dispatch(BlockContact(widget._contactId, widget._chatId));
    navigation.popUntil(context, ModalRoute.withName(Navigation.ROUTES_ROOT), "ChatProfileSingleContact");
  }
}
