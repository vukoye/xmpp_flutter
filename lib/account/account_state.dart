import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:xmpp_stone/xmpp_stone.dart';

abstract class AccountState extends Equatable {}

class AccountRegistered extends AccountState {
  XmppAccountSettings account;

  AccountRegistered({@required this.account});
  @override
  String toString() {
    return 'AccountRegistered';
  }
}

class AccountRegistering extends AccountState {
  XmppAccountSettings account;

  AccountRegistering({@required this.account});
  @override
  String toString() {
    return "AccountRegistering";
  }
}

class AccountUnregistered extends AccountState {
  XmppAccountSettings account;
  final String message;

  AccountUnregistered({@required this.account, @required this.message});
  @override
  String toString() {
    return "AccountUnregistered";
  }
}

class AccountUninitialized extends AccountState {
  XmppAccountSettings account;

  AccountUninitialized({@required this.account});
  @override
  String toString() {
    return "AccountUninitialized";
  }
}
