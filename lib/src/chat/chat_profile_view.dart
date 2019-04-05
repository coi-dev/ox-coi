import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_talk/src/chat/chat_bloc.dart';
import 'package:ox_talk/src/chat/chat_event.dart';
import 'package:ox_talk/src/chat/chat_profile_group_view.dart';
import 'package:ox_talk/src/chat/chat_profile_single_view.dart';
import 'package:ox_talk/src/chat/chat_state.dart';
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
            if(state.isGroupChat){
              return ChatProfileGroupView(widget._chatId, state.name, state.color);
            }else{
              bool _isSelfTalk = state.isSelfTalk;
              return BlocBuilder(
                bloc: _contactListBloc,
                builder: (context, state){
                  if(state is ContactListStateSuccess){
                    var key = "${state.contactIds[0]}-${state.contactLastUpdateValues[0]}";
                    return ChatProfileSingleView(widget._chatId, _isSelfTalk, state.contactIds[0], key);
                  }else{
                    return Container();
                  }
                }
              );
            }
          } else {
            return Container();
          }
        }
      )
    );
  }
}
