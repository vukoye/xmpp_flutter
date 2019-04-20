import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat/account/account.dart';

import '../main.dart';
import 'main_page_bloc.dart';
import 'main_page_content.dart';
import 'main_page_event.dart';

class MainPage extends StatefulWidget {

  static String TAG = 'main';
  AccountBloc accountBloc;
  MainPage(this.accountBloc);

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin{

  TabController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: 2);
    _controller.addListener(_handleTabSelection);
  }

  List<Choice> choices = const <Choice>[
    const Choice(title: 'Settings', icon: Icons.settings),
    const Choice(title: 'Log out', icon: Icons.exit_to_app),
  ];

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Null> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: Colors.orangeAccent,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Exit app',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: Colors.black87,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'CANCEL',
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.black87,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'YES',
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
        break;
    }
  }

  MainPageBloc _mainPageBloc = MainPageBloc();

  @override
  Widget build(BuildContext context) {
    print('build defaultTabController');
    return Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            controller: _controller,
            tabs: [
              Tab(
                    text: "Roster",),
              Tab(text: "Chat"),
            ],
          ),
          title: Text(
            'Simple Chat',
            style:
                TextStyle(color: Colors.white24, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: <Widget>[
            PopupMenuButton<Choice>(
              onSelected: onItemMenuPress,
              itemBuilder: (BuildContext context) {
                return choices.map((Choice choice) {
                  return PopupMenuItem<Choice>(
                      value: choice,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            choice.icon,
                            color: Colors.black87,
                          ),
                          Container(
                            width: 10.0,
                          ),
                          Text(
                            choice.title,
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ));
                }).toList();
              },
            ),
          ],
        ),
        body: WillPopScope(
          child: Stack(
            children: <Widget>[
              // List
              TabBarView(
                  controller: _controller,
                  children: [
                RosterPage(mainPageBloc: _mainPageBloc),
                ChatListPage(mainPageBloc: _mainPageBloc),
              ]),
              // Loading
              Positioned(
                child: false
                    ? Container(
                        child: Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black87)),
                        ),
                        color: Colors.white.withOpacity(0.8),
                      )
                    : Container(),
              )
            ],
          ),
          onWillPop: onBackPress,
        ),
    );
  }

  void onItemMenuPress(Choice choice) {
    if (choice.title == 'Log out') {
      handleSignOut();
    } else {
      //Navigator.push(context, MaterialPageRoute(builder: (context) =>Settings()));
    }
  }

  Future<Null> handleSignOut() async {
    widget.accountBloc.dispatch(Logout());
//    Navigator.of(context).pushAndRemoveUntil(
//        MaterialPageRoute(builder: (context) => MyApp()),
//        (Route<dynamic> route) => false);
  }

  void _handleTabSelection() {
    setState(() {
      _currentIndex = _controller.index;
      if (_currentIndex == 1) {
        _mainPageBloc.dispatch(MainPageChatListTabActive());
      } else {
        _mainPageBloc.dispatch(MainPageRosterTabActive());
      }
    });
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}
