import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class ChatListState extends Equatable {
  ChatListState([List props = const []]) : super(props);
}

class ChatListInitial extends ChatListState {

  @override
  String toString() => 'ChatListInitial';

}
