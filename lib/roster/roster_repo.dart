import 'dart:async';

import 'package:image/image.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simple_chat/account/account.dart';
import 'package:simple_chat/account/account_repo.dart';
import 'package:simple_chat/repo/ui_chat.dart';
import 'package:simple_chat/service_locator/service_locator.dart';
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;

abstract class RosterRepo {
  Stream<List<UiBuddy>> get rosterStream;

  close();
}

class UiBuddy {
  UiAccount account;
  xmpp.Buddy xmppBuddy;
  xmpp.VCard vCard;
  bool vCardRequested = false;

  String get name => xmppBuddy.name;

  xmpp.Jid get jid => xmppBuddy.jid;

  Image get avatar => vCard?.image;

  UiBuddy({@required this.xmppBuddy, @required this.account});
}

class RosterVcardManager {
  xmpp.RosterManager rosterManager;
  xmpp.VCardManager vCardManager;

  RosterVcardManager(this.rosterManager, this.vCardManager);
}

class RosterRepoImpl implements RosterRepo {
  final _accountRepo = sl.get<AccountRepo>();
  List<UiBuddy> _rosterList = List<UiBuddy>();

  final _rosterSubject = new BehaviorSubject<List<UiBuddy>>();
  Map<UiAccount, StreamSubscription> _accounts =
      Map<UiAccount, StreamSubscription>();
  Map<UiAccount, RosterVcardManager> _managers =
      Map<UiAccount, RosterVcardManager>();

  Map<xmpp.ChatManager, StreamSubscription> _rosterManagerStreams =
      Map<xmpp.ChatManager, StreamSubscription>();

  RosterRepoImpl() {
    _accountRepo.accounts.listen((accounts) => _accountsListChanged(accounts));
  }

  _accountsListChanged(List<UiAccount> accounts) {
    accounts.forEach((acc) {
      if (!_accounts.keys.contains(acc)) {
        // ignore: cancel_subscriptions
        var sub = acc.accountStateStream.listen((state) {
          if (state is AccountRegistered) {
            _addRosterManager(acc);
          }
        });
        _accounts[acc] = sub;
      }
    });
    _accounts.keys.forEach((oldAcc) {
      if (!accounts.contains(oldAcc)) {
        _accounts[oldAcc].cancel();
        _accounts.remove(oldAcc);
        _removeManagers(oldAcc);
      }
    });
  }

  @override
  close() {
    _rosterSubject.close();
  }

  @override
  // TODO: implement rosterStream
  Stream<List<UiBuddy>> get rosterStream => _rosterSubject.stream;

  void _addRosterManager(UiAccount acc) {
    if (!_managers.containsKey(acc)) {
      xmpp.Connection connection = xmpp.Connection.getInstance(acc.account);
      xmpp.RosterManager rosterManager =
          xmpp.RosterManager.getInstance(connection);
      xmpp.VCardManager vCardManager =
          xmpp.VCardManager.getInstance(connection);
      _managers[acc] = RosterVcardManager(rosterManager, vCardManager);
      if (rosterManager.getRoster().isNotEmpty) {
        _rosterChangedForManager(acc, rosterManager, rosterManager.getRoster());
      }
      rosterManager.rosterStream.listen((roster) {
        _rosterChangedForManager(acc, rosterManager, roster);
      });
    }
  }

  void _rosterChangedForManager(
      UiAccount acc, xmpp.RosterManager manager, List<xmpp.Buddy> roster) {
    roster.forEach((xmppBuddy) {
      var existing = _rosterList.firstWhere(
          (uiBuddy) =>
              xmppBuddy.jid == uiBuddy?.xmppBuddy?.jid &&
              acc.id == uiBuddy.account.id,
          orElse: () => null);
      if (existing == null) {
        var tempBuddy = UiBuddy(xmppBuddy: xmppBuddy, account: acc);
        fetchVcard(acc, xmppBuddy.jid, tempBuddy);
        _rosterList.add(tempBuddy);
        _rosterSubject.add(_rosterList);
      } else if (existing != null &&
          existing.vCard == null &&
          !existing.vCardRequested) {
        fetchVcard(acc, xmppBuddy.jid, existing);
      }
    });
  }

  void fetchVcard(UiAccount acc, xmpp.Jid jid, UiBuddy uiBuddy) {
    _managers[acc].vCardManager?.getVCardFor(jid)?.then((vcard) {
      uiBuddy.vCardRequested = true;
      if (vcard != null) uiBuddy.vCard = vcard;
      _rosterSubject.add(_rosterList);
    });
  }

  void _removeManagers(UiAccount oldAcc) {
    _managers.remove(oldAcc);
  }
}
