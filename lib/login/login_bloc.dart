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
    accountBloc.state.listen((state) {
      print("state $state");
//      if (state is AccountUnregistered) {
//        dispatch(LoginFailureEvent(message: state.message));
//      }
    });
  }

  @override
  LoginState get initialState {
    return LoginInitial();
  }

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      if (_extended) {
        accountBloc.dispatch(Login(
            username: event.username,
            password: event.password,
            domain: event.domain,
            port: event.port));
      } else {
        var jid = Jid.fromFullJid(event.username);
        accountBloc.dispatch(Login(
            username: jid.local,
            password: event.password,
            domain: jid.domain,
            port: _settings.getDefaultPort()));
      }
      yield LoginLoading();
    } else if (event is ExtendPressed) {
      _extended = !_extended;
      _settings.setBool(Settings.wasExtended, _extended);
      yield CheckedChanged(loginExtendValue: _extended, rememberMeValue: _rememberMe);
    } else if (event is RememberMePressed) {
      _settings.setBool(Settings.rememberMe, event.rememberMeValue);
      _rememberMe = event.rememberMeValue;
      if (!event.rememberMeValue) {
        accountBloc.dispatch(ForgetMe());
      }
      yield CheckedChanged(loginExtendValue: _extended, rememberMeValue: _rememberMe);
    } else if (event is LoginDataLoadedEvent) {
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
        var wasExtended = _settings.getBool(Settings.wasExtended);
        _extended = wasExtended;
        if (wasExtended == null) wasExtended = false;
        dispatch(LoginDataLoadedEvent(
            username: username,
            password: password,
            domain: domain,
            port: port,
            wasExtended: wasExtended,
          rememberMe: true
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
