import 'package:rxdart/rxdart.dart';
import 'package:simple_chat/account/account_state.dart';
import 'package:xmpp_stone/xmpp_stone.dart';

class AccountRepoImpl implements AccountRepo{
  final _accountSubject = new BehaviorSubject<List<UiAccount>>();

  @override
  Stream<List<UiAccount>> get accounts => _accountSubject.stream;

  List<UiAccount> _accountsList = List<UiAccount>();

  @override
  UiAccount register(XmppAccount account) {
    UiAccount uiAccount = UiAccount(account);
    _accountsList.retainWhere((item) => item == uiAccount);
    _accountsList.add(uiAccount);
    _accountSubject.add(_accountsList);
    var connection = Connection.getInstance(account);
    connection.connectionStateStream.listen((state) {
      if (state == XmppConnectionState.DoneServiceDiscovery) {
        uiAccount.accountState = AccountRegistered(account: account);
      } else if (state == XmppConnectionState.Closed) {
        uiAccount.accountState = AccountUnregistered(account: account,
            message: "Registration Failed"); //nvtd probably should read error
      }
    });
    connection.open();
    uiAccount.accountState = AccountRegistering(account: account);
    return uiAccount;
  }

  close() {
    _accountSubject.close();
  }

  @override
  void unregister(XmppAccount account) {
    var connection = Connection.getInstance(account);
    _accountsList.removeWhere((item) => UiAccount(account) == item);
    _accountSubject.add(_accountsList);
    connection.close();
  }


}

abstract class AccountRepo {
  Stream<List<UiAccount>> get accounts;

  UiAccount register(XmppAccount account);

  void unregister(XmppAccount account) {}
}

class UiAccount {
  XmppAccount account;
  final _accountStateSubject = new BehaviorSubject<AccountState>();
  Stream<AccountState> get accountStateStream => _accountStateSubject.stream;

  set accountState(AccountState state) {
    _accountStateSubject.add(state);
  }

  @override
  bool operator ==(other) {
    return other is UiAccount &&
        account.username == other.account.username &&
        account.domain == other.account.domain;
  }

  UiAccount(this.account);
}


enum UiAccountState {
  UNINITIALIZED, REGISTERING, REGISTERED, REGISTRATION_FAILED
}
