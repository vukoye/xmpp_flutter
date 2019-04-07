import 'package:equatable/equatable.dart';

abstract class AccountState extends Equatable {}

class AccountRegistered extends AccountState {
  @override
  String toString() {
    return 'AccountRegistered';
  }
}

class AccountRegistering extends AccountState {
  @override
  String toString() {
    return "AccountRegistering";
  }
}

class AccountUnregistered extends AccountState {
  final String message;

  AccountUnregistered({this.message});
  @override
  String toString() {
    return "AccountUnregistered";
  }
}

class AccountUninitialized extends AccountState {
  @override
  String toString() {
    return "AccountUninitialized";
  }
}
