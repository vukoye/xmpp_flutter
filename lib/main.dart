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

import 'main_page/main_page_widget.dart';

void main() {
  setupServiceLocator();
  bloc
      .BlocSupervisor()
      .delegate = SimpleBlocDelegate();
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
  AccountBloc accountBloc;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator");

  @override
  void initState() {
    accountBloc = AccountBloc();
    accountBloc.dispatch(AppStarted());
    super.initState();
  }

  @override
  void dispose() {
    accountBloc.dispose();
    super.dispose();
  }

  Route _getGeneratedRoute(RouteSettings routeSettings) {
    final List<String> path = routeSettings.name.split('/');
    if (path[0] == '') return null;
//    if (path[0] == 'login') {
//      return new MaterialPageRoute(
//        builder: (BuildContext context) => LoginPage(),
//        settings: routeSettings,
//      );
//    }
//    if (path[0] == Chats.tag && path[1] != null && path[1].isNotEmpty) {
//      return new MaterialPageRoute(
//        builder: (BuildContext context) => ChatList(),
//        settings: routeSettings,
//      );
//    }
  }

  //  @override
  Widget build(BuildContext context) {
    accountBloc.state.listen((state)  {
      if (state is AccountUninitialized) {
        navigatorKey.currentState.pushNamed(LoginPage.tag);
      }
      if (state is AccountRegistered) {
        navigatorKey.currentState.pushNamed(MainPage.TAG);
      }
      if (state is AccountUnregistered) {
        navigatorKey.currentState.pushNamed(LoginPage.tag);
      }
      if (state is AccountRegistering) {
        navigatorKey.currentState.popUntil(ModalRoute.withName(LoginPage.tag));
        navigatorKey.currentState.pushNamed(LoginPage.tag);
      }

    });
    final routes = <String, WidgetBuilder>{
      LoginPage.tag: (context) => LoginPage(accountBloc),
      MainPage.TAG: (context) => MainPage(accountBloc)
    };



    return MaterialApp(
      navigatorKey: navigatorKey,
      initialRoute: LoginPage.tag,
      debugShowCheckedModeBanner: false,

      home: LoginPage(accountBloc),
      routes: routes,
      onGenerateRoute: _getGeneratedRoute,

    );
//    return BlocProvider<AccountBloc>(
//      bloc: _accountBloc,
//      child: MaterialApp(
//        home: BlocBuilder<AccountEvent, AccountState>(
//          bloc: _accountBloc,
//          builder: (BuildContext context, AccountState state) {
//            if (state is AccountUninitialized) {
//              return LoginPage();
//            }
//            if (state is AccountRegistered) {
//              return MainPage();
//            }
//            if (state is AccountUnregistered) {
//              return LoginPage();
//            }
//            if (state is AccountRegistering) {
//              return LoginPage();
//            }
//          },
//        ),
//      ),
//    );
  }
}

class MatApp extends MaterialApp {

}

class MyApp extends StatefulWidget {

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


}
