import 'dart:async';

import 'package:simple_chat/account/account.dart';
import 'package:bloc/bloc.dart';
import 'package:simple_chat/account/account_repo.dart';
import 'package:simple_chat/service_locator/service_locator.dart';
import 'package:simple_chat/settings/settings.dart';
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;

//We should probably remove this
class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final settings = sl.get<Settings>();
  final accountRepo = sl.get<AccountRepo>();

  @override
  AccountState get initialState => AccountUninitialized(account: null);

  @override
  Stream<AccountState> mapEventToState(AccountEvent event) async* {
    print("account bloc event: ${event.toString()}");
    if (event is AppStarted) {
      await settings.isInitialized();
      bool shouldStartRegistration =
          settings.getBool(Settings.isAccountSaved) &&
              settings.getBool(Settings.wasLoggedIn);
      if (shouldStartRegistration) {
        var account = settings.getAccountData();
        if (account == null) {
          yield AccountUnregistered(account: null, message: null); // think of
          // some other event
        } else {
          yield AccountRegistering(account: account);
          _registerAccount(account);
        }
      }
    } else if (event is Login) {
      xmpp.XmppAccountSettings account = xmpp.XmppAccountSettings(
          event.username,
          event.username,
          event.domain,
          event.password,
          event.port);
      _registerAccount(account);
    } else if (event is Logout) {
      var account = settings.getAccountData();
      settings.setBool(Settings.wasLoggedIn, false);
      if (account != null) {
        accountRepo.unregister(account);
      }
      yield AccountUnregistered(account: account, message: "");
    } else if (event is ForgetMe) {
      settings.forgetAccount();
    } else if (event is AccountRegisteredEvent) {
      settings.setBool(Settings.wasLoggedIn, true);
      yield AccountRegistered(account: event.account);
    } else if (event is AccountRegistrationFailedEvent) {
      yield AccountUnregistered(account: event.account, message: event.message);
    }
  }

  void _registerAccount(xmpp.XmppAccountSettings account) {
    settings.setAccountData(account);
    accountRepo.register(account).accountStateStream.listen((state) {
      if (state is AccountUnregistered) {
        dispatch(AccountRegistrationFailedEvent(message: state.message));
      } else if (state is AccountRegistering) {
      } else if (state is AccountRegistered) {
        dispatch(AccountRegisteredEvent());
      }
    });
  }
}
