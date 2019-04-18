import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_chat/repo/ui_chat.dart';
import 'package:simple_chat/roster/roster_repo.dart';

import 'main_page.dart';




class MainPageTabBar extends StatelessWidget {

  MainPageBloc _mainPageBloc = MainPageBloc();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Persistent Tab Demo'),
        ),
        body: TabBarView(
          children: [
            RosterPage(mainPageBloc: _mainPageBloc),
            ChatListPage(mainPageBloc: _mainPageBloc),
          ],
        ),
      ),
    );
  }
}

class RosterPage extends StatefulWidget {
  final MainPageBloc mainPageBloc;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _RosterPageState();
  }

  RosterPage({
    Key key,
    @required this.mainPageBloc,
  });
}

class _RosterPageState extends State<RosterPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainPageEvent, MainPageState>(
      bloc: widget.mainPageBloc,
      builder: (BuildContext context, MainPageState state) {
        if (state is MainPageRosterList) {
          return ListView.builder(
              padding: EdgeInsets.all(1.0),
              itemBuilder: (context, index) =>
                  buildItem(context, state.activeList[index]),
              itemCount: state.activeList.length);
        } else {
          return Container();
        }
      },
    );
  }

  Widget buildItem(BuildContext context, UiBuddy buddy) {
    Widget image;
    if (buddy.vCard?.imageData == null) {
      image = CircleAvatar(
          radius: 25,
          child: buddy.name != null && buddy.name.isNotEmpty
          ? Text(buddy.name[0])
          : Text("X", style: TextStyle(color: Colors.black87)));
    } else {
      image = CircleAvatar(
        radius: 25,
          backgroundImage: MemoryImage(
        buddy.vCard.imageData,
      ));
//      image = new Container(
//        height: 30.0,
//        width: 30.0,
//        decoration: new BoxDecoration(
//          color: const Color(0xff7c94b6),
//          borderRadius: BorderRadius.all(const Radius.circular(50.0)),
//          border: Border.all(color: const Color(0xFF28324E)),
//          // image: new Image.asset(_image.)
//        ),
//        child: Image.memory(
//        buddy.vCard.imageData,
//      ),
//      );
    }

    return Container(
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left:8.0),
            child: image,
          ),
          Flexible(
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    child: Text(
                      '${buddy.name ?? 'No Info'}',
                      style: TextStyle(fontWeight: FontWeight.bold, color:
                      Colors
                          .black87),
                    ),
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 4.0),
                  ),
                  Container(
                    child: Text(
                      '${buddy.jid.fullJid}',
                      style: TextStyle(color: Colors.black87),
                    ),
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                  )
                ],
              ),
              margin: EdgeInsets.only(left: 8.0),
            ),
          ),
        ],
      ),
      margin: EdgeInsets.only(bottom: 8.0, left: 4.0, right: 4.0),
    );
  }
}

class ChatListPage extends StatefulWidget {
  final MainPageBloc mainPageBloc;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ChatListPageState();
  }

  ChatListPage({
    Key key,
    @required this.mainPageBloc,
  });
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  Widget build(BuildContext context) {
    print('build _ChatListPageState');
    // TODO: implement build
    return BlocBuilder<MainPageEvent, MainPageState>(
      bloc: widget.mainPageBloc,
      builder: (BuildContext context, MainPageState state) {
        if (state is MainPageChatList) {
          return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) =>
                  buildItem(context, state.activeList[index]),
              itemCount: state.activeList.length);
        } else {
          return Container();
        }
      },
    );
  }

  Widget buildItem(BuildContext context, UiChat chatItem) {
    Widget image;
    //if (buddy.vCard?.imageData == null) {
    image = chatItem.name != null && chatItem.name.isNotEmpty
        ? Text(chatItem.name[0])
        : Text("X", style: TextStyle(color: Colors.black87));
    //} else {
    //image = Image.memory(buddy.vCard.imageData, width: 25, height: 25,);
    //}

    return Container(
      child: FlatButton(
        child: Row(
          children: <Widget>[
            Material(
              child: CircleAvatar(
                minRadius: 25,
                maxRadius: 25,
                child: image,
              ),
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              clipBehavior: Clip.hardEdge,
            ),
            Flexible(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        'Name: ${chatItem.name ?? 'No Info'}',
                        style: TextStyle(color: Colors.black87),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    ),
                    Container(
                      child: Text(
                        'Jid: ${chatItem.jid.fullJid}',
                        style: TextStyle(color: Colors.black87),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                    )
                  ],
                ),
                margin: EdgeInsets.only(left: 20.0),
              ),
            ),
          ],
        ),
        onPressed: () {
          //todo handle press
//          Navigator.push(
//              context,
//              MaterialPageRoute(
//                  builder: (context) =>
//                      Chat(
//                        buddy : buddy
//                      )));
        },
        color: Colors.grey,
        padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
    );
  }
}
