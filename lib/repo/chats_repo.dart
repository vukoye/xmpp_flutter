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

//probably will have concurrency issues
class ChatsRepoImpl implements ChatsRepo {
  final _settings = sl.get<Settings>();
  final _accountRepo = sl.get<AccountRepo>();

  List<UiChat> _chats = List<UiChat>();
  final _chatsSubject = new BehaviorSubject<List<UiChat>>();

  @override
  Stream<List<UiChat>> get chatsStream => _chatsSubject.stream;

  Map<UiAccount, StreamSubscription> _accounts =
      Map<UiAccount, StreamSubscription>();
  Map<UiAccount, xmpp.ChatManager> _chatManagers =
      Map<UiAccount, xmpp.ChatManager>();

  Map<xmpp.ChatManager, StreamSubscription> _chatManagerStreams =
      Map<xmpp.ChatManager, StreamSubscription>();

  DatabaseHelper _db = DatabaseHelper();

  ChatsRepoImpl() {
    _db.initDatabase();
    _accountRepo.accounts.listen((accounts) =>
        //when multiple accounts reimplement this.
        _accountListChanged(accounts));
  }

  _loadChatsFromDb(UiAccount account) {
    _db.getAllDbChatsForAccountId(account.id).then((accList) {
      accList.forEach((dbChatMap) {
        var dbChat = DbChat.fromMap(dbChatMap);
        //possible conc issue.
        var existing = _chats.firstWhere(
            (uiChat) =>
                dbChat.jid == uiChat.jid.fullJid &&
                account.id == uiChat.account.id,
            orElse: () => null);
        if (existing == null) {
          var tempChat = UiChat.fromDbChat(dbChat, account);
          var xmppChat = _chatManagers[account]?.getChat(tempChat.jid);
          if (xmppChat != null) tempChat.xmppChat = xmppChat;
          _chats.add(tempChat);
        }
      });
    });
  }

  _accountListChanged(List<UiAccount> accounts) {
    accounts.forEach((acc) {
      if (!_accounts.keys.contains(acc)) {
        // ignore: cancel_subscriptions
        var sub = acc.accountStateStream.listen((state) {
          if (state is AccountRegistered) {
            _addChatManager(acc);
            _loadChatsFromDb(acc);
          }
        });
        _accounts[acc] = sub;
      }
    });
    List<UiAccount> toRemove = List<UiAccount>();
    _accounts.keys.forEach((oldAcc) {
      if (!accounts.contains(oldAcc)) {
        toRemove.add(oldAcc);
      }
    });
    toRemove.forEach((acc) {
      _accounts[acc].cancel();
      _accounts.remove(acc);
      _removeChatManager(acc);
    });
  }

  _addChatManager(UiAccount acc) {
    if (!_chatManagers.containsKey(acc)) {
      xmpp.Connection connection = xmpp.Connection.getInstance(acc.account);
      xmpp.ChatManager manager = xmpp.ChatManager.getInstance(connection);
      _chatManagers[acc] = manager;
      if (manager.chats.isNotEmpty) {
        _chatListChangedForManager(acc, manager, manager.chats);
      }
      manager.chatListStream.listen((chats) {
        _chatListChangedForManager(acc, manager, chats);
      });
    }
  }

  _removeChatManager(UiAccount acc) {
    _chatManagers.remove(acc);
    //remove chats from manager
  }

  void _chatListChangedForManager(
      UiAccount account, xmpp.ChatManager manager, List<xmpp.Chat> chats) {
    chats.forEach((xmppChat) {
      //var tempChat = UiChat.fromXmppChat(xmppChat, account);
      var existing = _chats.firstWhere(
          (uichat) =>
              xmppChat.jid == uichat.jid && account.id == uichat.account.id,
          orElse: () => null);
      if (existing == null) {
        var tempChat = UiChat.fromXmppChat(xmppChat, account);
        _db.insert(tempChat.getDbChat).then((insertedChat) {
          tempChat.dbId = insertedChat.uuid;
          _chats.add(tempChat);
          _chatsSubject.add(_chats);
        });
      } else {
        if (existing.xmppChat == null) {
          existing.xmppChat = xmppChat;
        }
      }
    });
  }
}

abstract class ChatsRepo {
  @override
  Stream<List<UiChat>> get chatsStream;
}
