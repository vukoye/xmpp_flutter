import 'dart:async';
import 'dart:core';

import 'package:rxdart/rxdart.dart';
import 'package:simple_chat/account/account_repo.dart';
import 'package:simple_chat/account/account_state.dart';
import 'package:simple_chat/repo/db/db.dart';
import 'package:simple_chat/repo/db/db_chat.dart';
import 'package:simple_chat/repo/ui_chat.dart';
import 'package:simple_chat/service_locator/service_locator.dart';
import 'package:simple_chat/settings/settings.dart';
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;

class ChatsRepoImpl implements ChatsRepo {

  final _settings = sl.get<Settings>();
  final _accountRepo = sl.get<AccountRepo>();

  List<UiChat> _chats = List<UiChat>();
  final _chatsSubject = new BehaviorSubject<List<UiChat>>();


  Map<UiAccount, StreamSubscription> _accounts = Map<UiAccount,
      StreamSubscription>();
  Map<UiAccount, xmpp.ChatManager> _chatManagers = Map<UiAccount,
      xmpp.ChatManager>();

  Map<xmpp.ChatManager, StreamSubscription> _chatManagerStreams = Map<xmpp
      .ChatManager, StreamSubscription>();


  DatabaseHelper _db = DatabaseHelper();

  ChatsRepoImpl() {
    _db.initDatabase();
    _accountRepo.accounts.listen((accounts) =>
    //when multiple accounts reimplement this.
    _accountListChanged(accounts)
    );
  }

  //ChatManager

  //List<UiChat> chats = List<UiChat>();

  _loadChats() {

  }

  _accountListChanged(List<UiAccount> accounts) {
    accounts.forEach((acc) {
      if (!_accounts.keys.contains(acc)) {
        // ignore: cancel_subscriptions
        var sub = acc.accountStateStream.listen((state) {
          if (state is AccountRegistered) {
            _addChatManager(acc);
          }
        });
        _accounts[acc] = sub;
      }
    });
    _accounts.keys.forEach((oldAcc) {
      if (!accounts.contains(oldAcc)) {
        _accounts[oldAcc].cancel();
        _accounts.remove(oldAcc);
        _removeChatManager(oldAcc);
      }
    });

  }

  _addChatManager(UiAccount acc) {
    if (!_chatManagers.containsKey(acc)) {
      xmpp.Connection connection = xmpp.Connection.getInstance(acc.account);
      xmpp.ChatManager manager = xmpp.ChatManager.getInstance(connection);
      _chatManagers[acc] = manager;
      _chatListChangedForManager(acc, manager, manager.chats);
    manager.chatListStream.listen((chats) {
      _chatListChangedForManager(acc, manager, chats);
    });
    }
  }

  _removeChatManager(UiAccount acc) {
    _chatManagers.remove(acc);
  }

  void _chatListChangedForManager(UiAccount account, xmpp.ChatManager
  manager, List<xmpp.Chat> chats) {
    chats.forEach((xmppChat) {
      UiChat chat = UiChat.fromXmppChat(xmppChat, account);
      chat.
    });

  }
}

abstract class ChatsRepo {
}
