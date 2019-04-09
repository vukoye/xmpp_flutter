import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:xmpp_stone/xmpp_stone.dart';

abstract class AccountState extends Equatable {}

class AccountRegistered extends AccountState {
  XmppAccount account;

  AccountRegistered({@required this.account});
  @override
  String toString() {
    return 'AccountRegistered';
  }
}

class AccountRegistering extends AccountState {
  XmppAccount account;

  AccountRegistering({@required this.account});
  @override
  String toString() {
    return "AccountRegistering";
  }
}

class AccountUnregistered extends AccountState {
  XmppAccount account;
  final String message;

  AccountUnregistered({@required this.account, @required this.message});
  @override
  String toString() {
    return "AccountUnregistered";
  }
}

class AccountUninitialized extends AccountState {
  XmppAccount account;

  AccountUninitialized({@required this.account});
  @override
  String toString() {
    return "AccountUninitialized";
  }
}
