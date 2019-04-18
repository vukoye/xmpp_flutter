import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:simple_chat/repo/ui_chat.dart';
import 'package:simple_chat/roster/roster_repo.dart';

abstract class MainPageState extends Equatable {
  MainPageState([List props = const []]) : super(props);
}

@immutable
class MainPageChatList extends MainPageState {

  final String searchString;
  final int position;
  final List<UiChat> activeList;

  MainPageChatList({this.searchString, this.position, @required this
      .activeList}) : super([searchString, position, activeList]);

      @override
      String toString() => 'MainPageChatList';
}

class MainPageRosterList extends MainPageState {

  final String searchString;
  final int position;
  final List<UiBuddy> activeList;

  MainPageRosterList(
      {this.searchString, this.position, @required this.activeList})
      : super([searchString, position, activeList]);

      @override
      String toString() => 'MainPageRosterList';
}
