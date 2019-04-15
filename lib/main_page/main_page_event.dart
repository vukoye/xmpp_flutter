import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class MainPageEvent extends Equatable {
  MainPageEvent([List props = const []]) : super(props);
}

class MainPageChatListTabActive extends MainPageEvent {
  @override
  String toString() {
    // TODO: implement toString
    return 'MainPageChatListTabClicked';
  }
}

class MainPageRosterTabActive extends MainPageEvent {
  @override
  String toString() {
    // TODO: implement toString
    return 'MainPageRosterTabClicked';
  }
}
