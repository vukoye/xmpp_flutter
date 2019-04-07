// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:bloc/bloc.dart' as bloc;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat/account/account.dart';
import 'package:simple_chat/chat_list.dart';
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;
import 'package:simple_chat/const.dart';
import 'package:simple_chat/service_locator/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_chat/login/login_page.dart';

void main() {
  setupServiceLocator();
  bloc.BlocSupervisor().delegate = SimpleBlocDelegate();
  runApp(MyApp());
}

class SimpleBlocDelegate extends bloc.BlocDelegate {
  @override
  void onTransition(bloc.Transition transition) {
    print(transition);
  }

  @override
  void onError(Object error, StackTrace stacktrace) {
    print(error);
  }
}
class _AppState extends State<MyApp> {
  AccountBloc _accountBloc;

  @override
  void initState() {
    _accountBloc = AccountBloc();
    _accountBloc.dispatch(AppStarted());
    super.initState();
  }

  @override
  void dispose() {
    _accountBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccountBloc>(
      bloc: _accountBloc,
      child: MaterialApp(
        home: BlocBuilder<AccountEvent, AccountState>(
          bloc: _accountBloc,
          builder: (BuildContext context, AccountState state) {
            if (state is AccountUninitialized) {
              return LoginPage();
            }
            if (state is AccountRegistered) {
              return ChatList();
            }
            if (state is AccountUnregistered) {
              return LoginPage();
            }
            if (state is AccountRegistering) {
              return LoginPage();
            }
          },
        ),
      ),
    );
  }
}
class MyApp extends StatefulWidget {
  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) => LoginPage(),
  };

  MyApp({Key key}) : super(key: key);

  @override
  State<MyApp> createState() => _AppState();
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      title: 'Kodeversitas',
//      debugShowCheckedModeBanner: false,
//      theme: ThemeData(
//        primarySwatch: Colors.lightBlue,
//        fontFamily: 'Nunito',
//      ),
//      home: LoginPage(),
//      routes: routes,
//      onGenerateRoute: _getGeneratedRoute,
//    );
//  }

  Route _getGeneratedRoute(RouteSettings routeSettings) {
    final List<String> path = routeSettings.name.split('/');
    if (path[0] == '') return null;
    if (path[0] == ChatList.tag && path[1] != null && path[1].isNotEmpty) {
      return new MaterialPageRoute(
        builder: (BuildContext context) => ChatList(),
        settings: routeSettings,
      );
    }
  }
}
