import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:simple_chat/account/account.dart';
import 'package:simple_chat/login/login.dart';
import 'package:simple_chat/service_locator/service_locator.dart';
import 'package:simple_chat/settings/settings.dart';
import 'package:xmpp_stone/xmpp_stone.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  AccountBloc accountBloc;

  Settings _settings = sl.get<Settings>();

  bool _extended = false;

  bool _rememberMe = false;

  LoginBloc({@required this.accountBloc}) {
    _initData();
    accountBloc.state.listen((accountState) {
      if (accountState is AccountUnregistered) {
        dispatch(LoginFailureEvent(message: accountState.message));
      }
      print("state $accountState");
    });
  }

  @override
  LoginState get initialState {
    return LoginInitial();
  }

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      String username;
      String password;
      String domain;
      int port;
      if (_extended) {
        username = event.username;
        password = event.password;
        domain = event.domain;
        port = event.port;
      } else {
        var jid = Jid.fromFullJid(event.username);
        username = jid.local;
        password = event.password;
        domain = jid.domain;
        port = _settings.getDefaultPort();
      }
      if (_rememberMe) {
        _settings.setString(Settings.username, username);
        _settings.setString(Settings.domain, domain);
        _settings.setString(Settings.password, password);
        _settings.setInt(Settings.port, port);
      }
      accountBloc.dispatch(Login(
          username: username,
          password: password,
          domain: domain,
          port: port));
      yield LoginLoading();
    } else if (event is ExtendPressed) {
      _extended = !_extended;
      _settings.setBool(Settings.wasExtended, _extended);
      yield LoginExtendedChanged(loginExtendValue: _extended);
    } else if (event is RememberMePressed) {
      _settings.setBool(Settings.rememberMe, event.rememberMeValue);
      _rememberMe = event.rememberMeValue;
      if (!event.rememberMeValue) {
        accountBloc.dispatch(ForgetMe());
      }
      yield RememberMeChanged(rememberMeValue: _rememberMe);
    } else if (event is LoginDataLoadedEvent) {
      _rememberMe = event.rememberMe;
      yield LoginDataLoaded(
          username: event.username,
          password: event.password,
          domain: event.domain,
          port: event.port,
          wasExtended: event.wasExtended,
          rememberMe: _rememberMe
      );
    }
  }

  void _initData() {
    _settings.isInitialized().then((_) {
      if (_settings.getBool(Settings.rememberMe) == true) {
        var username = _settings.getString(Settings.username);
        var password = _settings.getString(Settings.password);
        var domain = _settings.getString(Settings.domain);
        var port = _settings.getInt(Settings.port);
        if (port == null) port = _settings.getDefaultPort();
        var wasExtended = _settings.getBool(Settings.wasExtended);
        _extended = wasExtended;
        if (wasExtended == null) wasExtended = false;
        dispatch(LoginDataLoadedEvent(
            username: username,
            password: password,
            domain: domain,
            port: port,
            wasExtended: wasExtended,
            rememberMe: _settings.getBool(Settings.rememberMe) == true
        ));
      } else {
        dispatch(LoginDataLoadedEvent(
            username: "",
            password: "",
            domain: "",
            port: _settings.getDefaultPort(),
            wasExtended: _settings.getBool(Settings.wasExtended) == true,
            rememberMe: _settings.getBool(Settings.rememberMe) == true
        ));
      }
    });
  }
}
