import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  LoginState([List props = const []]) : super(props);
}

class LoginDataLoaded extends LoginState {
  String username;
  String password;
  String domain;
  int port;
  bool wasExtended;
  bool rememberMe;
  String authMessage;

  @override
  String toString() => 'LoginDataLoaded';

  LoginDataLoaded(
      {this.username,
      this.password,
      this.domain,
      this.port,
      this.wasExtended,
      this.rememberMe,
      this.authMessage});
}

class LoginInitial extends LoginState {
  @override
  String toString() => 'LoginInitial';
}

class LoginLoading extends LoginState {
  @override
  String toString() => 'LoginLoading';
}

class LoginExtendedChanged extends LoginState {
  bool loginExtendValue;

  LoginExtendedChanged({@required this.loginExtendValue})
      : super([loginExtendValue]);

  @override
  String toString() => 'LoginLoading';
}

class RememberMeChanged extends LoginState {
  bool loginExtendValue;
  bool rememberMeValue;

  RememberMeChanged({@required this.rememberMeValue})
      : super([rememberMeValue]);

  @override
  String toString() => 'LoginLoading';
}

class LoginFailureState extends LoginState {
  final String error;

  LoginFailureState({@required this.error}) : super([error]);

  @override
  String toString() => 'LoginFailure { error: $error }';
}
