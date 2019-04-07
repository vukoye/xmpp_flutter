import 'dart:async';

import 'package:simple_chat/account/account.dart';
import 'package:bloc/bloc.dart';
import 'package:simple_chat/service_locator/service_locator.dart';
import 'package:simple_chat/settings/settings.dart';
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final settings = sl.get<Settings>();

  @override
  AccountState get initialState => AccountUninitialized();

  @override
  Stream<AccountState> mapEventToState(AccountEvent event) async* {
    if (event is AppStarted) {
      await settings.isInitialized();
      bool shouldStartRegistration =
          settings.getBool(Settings.isAccountSaved) &&
               settings.getBool(Settings.wasLoggedIn);
      if (shouldStartRegistration) {
        var account =  settings.getAccount();
        if (account == null) {
          yield AccountUnregistered();
        } else {
          yield AccountRegistering();
          _registerAccount(account);
        }
      }
    } else if (event is Login) {
      xmpp.XmppAccount account = xmpp.XmppAccount(
          event.username, event.username,
          event.domain,
          event.password, event.port);
      _registerAccount(account);

    } else if (event is Logout) {
      var account = settings.getAccount();
      settings.setBool(Settings.wasLoggedIn, false);
      if (account != null) {
        var connection = xmpp.Connection.getInstance(account);
        connection.close();
      }

    } else if (event is ForgetMe) {
      settings.forgetAccount();
    } else if (event is AccountRegisteredEvent) {
      settings.setBool(Settings.wasLoggedIn, true);
      yield AccountRegistered();
    } else if (event is AccountRegistrationFailedEvent) {
      yield AccountUnregistered(message: event.message);
    }
  }

  void _registerAccount(xmpp.XmppAccount account){
    settings.setAccount(account);
    var connection = xmpp.Connection.getInstance(account);
    connection.connectionStateStream.listen((state) {
      if (state == xmpp.XmppConnectionState.DoneServiceDiscovery) {
        dispatch(AccountRegisteredEvent());
      } else if (state == xmpp.XmppConnectionState.Closed) {
        dispatch(AccountRegistrationFailedEvent(message : "Authentication failure"));
      }
    });
    connection.open();
  }
}
