import 'dart:async';

import 'package:simple_chat/account/account.dart';
import 'package:bloc/bloc.dart';
import 'package:simple_chat/service_locator/service_locator.dart';
import 'package:simple_chat/settings/settings.dart';
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final settings = sl.get<Settings>();

  @override
  // TODO: implement initialState
  AccountState get initialState => AccountUninitialized();

  @override
  Stream<AccountState> mapEventToState(AccountEvent event) async* {
    if (event is AppStarted) {
      await settings.isInitialized();
      bool shouldStartRegistration =
          settings.getBool(Settings.isAccountSaved) &&
              await settings.getBool(Settings.shouldAutoLogin);
      if (shouldStartRegistration) {
        var account = await settings.getAccount();
        if (account == null) {
          yield AccountUnregistered();
        } else {
          yield AccountRegistering();
          yield* _registerAccount(account);
        }
      }
    } else if (event is Login) {
      xmpp.XmppAccount account = xmpp.XmppAccount(
          event.username, event.username,
          event.domain,
          event.password, event.port);
      yield* _registerAccount(account);

    } else if (event is Logout) {
      var account = await settings.getAccount();
      if (account != null) {
        var connection = xmpp.Connection.getInstance(account);
        connection.close();
      }

    } else if (event is ForgetMe) {
      settings.forgetAccount();
    }
  }

  Stream<AccountState> _registerAccount(xmpp.XmppAccount account) async* {

    var connection = xmpp.Connection.getInstance(account);
    await for (var state in connection.connectionStateStream) {
      if (state == xmpp.XmppConnectionState.DoneServiceDiscovery) {
        yield AccountRegistered();
      } else if (state == xmpp.XmppConnectionState.Closed) {
        yield AccountUnregistered(message: "Authentication failure");
      }
    }
    connection.open();
  }
}
