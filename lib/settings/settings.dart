import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;

abstract class Settings {

  static const String shouldSaveAccount = "shouldSaveAccount";
  static const String isAccountSaved = "isAccountSaved";
  static const String wasExtended = "wasShort";
  static const String username = "username";
  static const String password = "password";
  static const String domain = "domain";
  static const String port = "port";
  static const String rememberMe = "rememberMe";
  static const String wasLoggedIn = "wasLoggedIn";

  setAccount(xmpp.XmppAccount account);
  xmpp.XmppAccount getAccount();

  setBool(String setting, bool value);

  bool getBool(String setting);

  setString(String setting, String value);

  String getString(String setting);

  setInt(String setting, int value);

  int getInt(String setting);

  remove(String setting);

  int getDefaultPort();

  void forgetAccount();

  init();

  Future isInitialized();
}

class SettingsImpl implements Settings {

  Completer<bool> _initialized = Completer();

  xmpp.XmppAccount _account;
  var _prefs;

  SettingsImpl() {
    init();
  }

  @override
  init() {
    var future = SharedPreferences.getInstance();
    future.then((prefs) {
      _prefs = prefs;
      _initialized.complete(true);
    });
  }

  @override
  xmpp.XmppAccount getAccount()  {
    if (_account != null) {
      return _account;
    }
    bool isSaved = _prefs.getBool(Settings.isAccountSaved);
    if (isSaved != null && isSaved) {
      String username = _prefs.getString(Settings.username);
      String password = _prefs.getString(Settings.password);
      String domain = _prefs.getString(Settings.domain);
      int port = _prefs.getInt(Settings.port);
      _account = xmpp.XmppAccount(username, username, domain, password, port);
      return _account;
    } else {
      return null;
    }
  }

  @override
  setAccount(xmpp.XmppAccount account)  {
    if (account != null) {
      _account = account;
      if (getBool(Settings.rememberMe) == true) {
        _prefs.setString(Settings.username, account.username);
        _prefs.setString(Settings.password, account.password);
        _prefs.setString(Settings.domain, account.domain);
        _prefs.setInt(Settings.port, account.port);
        _prefs.setBool(Settings.isAccountSaved, true);
      }
    }
  }

  @override
  bool getBool(String setting) {
    var result = _prefs.getBool(setting);
    if (result == null) result = false;
    return result;
  }

  @override
  setBool(String setting, bool value)  {
    _prefs.setBool(setting, value);
  }

  @override
  remove(String setting) {
    _prefs.remove(setting);
  }

  @override
  void forgetAccount()  {
    remove(Settings.isAccountSaved);
    remove(Settings.username);
    remove(Settings.password);
    remove(Settings.domain);
    remove(Settings.port);
    remove(Settings.isAccountSaved);
  }

  @override
  int getInt(String setting)  {
    return _prefs.getInt(setting);
  }

  @override
  String getString(String setting)  {
    return _prefs.getString(setting);
  }

  @override
  setInt(String setting, int value)  {
    _prefs.setInt(setting, value);
  }


  @override
  setString(String setting, String value)  {
    _prefs.setString(setting, value);
  }

  @override
  int getDefaultPort() {
    return 5222;
  }

  @override
  Future isInitialized() {
    return _initialized.future;
  }

}

