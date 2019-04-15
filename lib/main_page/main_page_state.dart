import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:simple_chat/repo/ui_chat.dart';
import 'package:simple_chat/roster/roster_repo.dart';

abstract class MainPageState extends Equatable {
  MainPageState([List props = const []]) : super(props);
}

class MainPageChatList extends MainPageState {

  String searchString = "";
  int position = 0;
  List<UiChat> activeList = List();

  MainPageChatList({this.searchString, this.position, this.activeList});

  @override
  String toString() => 'MainPageChatList';
}

class MainPageRosterList extends MainPageState {

  String searchString = "";
  int position =0;
  List<UiBuddy> activeList = List();

  MainPageRosterList({this.searchString, this.position,  this.activeList});

  @override
  String toString() => 'MainPageRosterList';
}
