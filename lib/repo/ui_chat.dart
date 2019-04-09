import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:simple_chat/account/account_repo.dart';
import 'package:simple_chat/repo/ui_message.dart';
import 'package:xmpp_stone/xmpp_stone.dart';


//call unsubscribe
class UiChat {
  int dbId;
  String name;
  UiAccount account;
  Jid jid;
  UiChatStatus status;
  UiChatType type;
  DateTime created;
  List<UiMessage> _messages = List<UiMessage>();
  final _messagesSubject = new BehaviorSubject<List<UiMessage>>();
  Chat xmppChat;


  @override
  bool operator ==(other) {
    return this.jid == other.jid;
  }

  @override
  int get hashCode => jid.hashCode;

  Future<bool> sendMessage(String message) {
    Completer<bool> completer = Completer();
    if (xmppChat == null) completer.complete(false);
    xmppChat.sendMessage(message);
    completer.complete(true);
    return completer.future;
  }
  Stream<List<UiMessage>> get uiMessages => _messagesSubject.stream;

  UiChat.fromXmppChat(this.xmppChat, this.account) {
    jid = xmppChat.jid;
    this.xmppChat.newMessageStream.listen((xmppMessage) {
      _messages.add(UiMessage.fromXmppMessage(xmppMessage));
      _messagesSubject.add(_messages);
    });
  }
}


enum UiChatType {
  SINGLE, MUC
}

enum UiChatStatus {
  ACTIVE, INACTIVE, ARCHIVED
}
