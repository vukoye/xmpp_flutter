import 'dart:async';
import 'package:quiver/core.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simple_chat/account/account_repo.dart';
import 'package:simple_chat/repo/db/db_chat.dart';
import 'package:simple_chat/repo/ui_message.dart';
import 'package:xmpp_stone/xmpp_stone.dart';

//call unsubscribe
class UiChat {
  int dbId;
  String _name = "";
  UiAccount account;
  Jid jid;
  UiChatStatus status = UiChatStatus.ACTIVE;
  UiChatType type = UiChatType.SINGLE;
  DateTime created;
  List<UiMessage> _messages = List<UiMessage>();
  final _messagesSubject = new BehaviorSubject<List<UiMessage>>();
  Chat _xmppChat;

  StreamSubscription<Message> _sub;

  Chat get xmppChat => _xmppChat;

  set xmppChat(Chat value) {
    if (_xmppChat != null) {
      _sub.cancel();
    }
    _xmppChat = value;
    _subscribeToMessageStream();
  }

  @override
  bool operator ==(other) {
    return other is UiChat && this.jid == other.jid && account == account;
  }

  @override
  int get hashCode => hash2(jid, account);

  Future<bool> sendMessage(String message) {
    Completer<bool> completer = Completer();
    if (_xmppChat == null) completer.complete(false);
    _xmppChat.sendMessage(message);
    completer.complete(true);
    return completer.future;
  }

  Stream<List<UiMessage>> get uiMessages => _messagesSubject.stream;

  UiChat.fromXmppChat(this._xmppChat, this.account) {
    jid = _xmppChat.jid;
    _subscribeToMessageStream();
    created = DateTime.now();
    _name = jid.fullJid;
  }

  UiChat.fromDbChat(DbChat dbChat, this.account) {
    this.jid = Jid.fromFullJid(dbChat.jid);
    this.dbId = dbChat.uuid;
    this._name = dbChat.name;
    this.status = _statusFromInt(dbChat.status);
    this.type = _typeFromInt(dbChat.type);
  }

  UiChatStatus _statusFromInt(int statusInt) {
    switch (statusInt) {
      case 0: return UiChatStatus.ACTIVE;
      case 1: return UiChatStatus.INACTIVE;
      case 2: return UiChatStatus.ARCHIVED;
    }
    return UiChatStatus.ACTIVE;
  }

  UiChatType _typeFromInt(int type) {
    switch (type) {
      case 0: return UiChatType.SINGLE;
      case 1: return UiChatType.MUC;
    }
    return UiChatType.SINGLE;
  }

  void _subscribeToMessageStream() {
    _sub = this._xmppChat.newMessageStream.listen((xmppMessage) {
      _messages.add(UiMessage.fromXmppMessage(xmppMessage));
      _messagesSubject.add(_messages);
    });
  }

  String get name => _name != null ? _name : jid.userAtDomain;

  DbChat get getDbChat {
    return DbChat(
        name: name,
        account_id: account.id,
        jid: jid.fullJid,
        since: created.millisecondsSinceEpoch,
        type: type.index,
        status: status.index);
  }


}

enum UiChatType { SINGLE, MUC }

enum UiChatStatus { ACTIVE, INACTIVE, ARCHIVED }
