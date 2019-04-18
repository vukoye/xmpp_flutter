import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_chat/account/account_bloc.dart';
import 'package:simple_chat/const.dart';
import 'package:simple_chat/chat_list.dart';
import 'package:simple_chat/login/login.dart';
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login';
  AccountBloc accountBloc;
  LoginPage(this.accountBloc);

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginBloc _loginBloc ;

  @override
  void initState() {
    print("init State");
    _loginBloc = LoginBloc(
      accountBloc: widget.accountBloc,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    print("build");
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: LoginForm(loginBloc: _loginBloc),
      ),
    );
  }

  @override
  void dispose() {
    _loginBloc.dispose();
    super.dispose();
  }
}
