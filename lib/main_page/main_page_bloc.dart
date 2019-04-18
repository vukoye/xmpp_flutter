import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simple_chat/main_page/main_page_event.dart';
import 'package:simple_chat/main_page/main_page_state.dart';
import 'package:simple_chat/repo/chats_repo.dart';
import 'package:simple_chat/repo/ui_chat.dart';
import 'package:simple_chat/roster/roster_repo.dart';
import 'package:simple_chat/service_locator/service_locator.dart';

class MainPageBloc extends Bloc<MainPageEvent, MainPageState> {

  MainPageTab _activeTab = MainPageTab.ROSTER;
  var _rosterRepo = sl.get<RosterRepo>();
  var _chatListRepo = sl.get<ChatsRepo>();

  var _activeRoster = List<UiBuddy>();
  var _activeChats = List<UiChat>();

  MainPageBloc() {
    _initStreams();
  }

  @override
  // TODO: implement initialState
  MainPageState get initialState => MainPageRosterList(activeList: _activeRoster);

  @override
  Stream<MainPageState> mapEventToState(MainPageEvent event) async* {
    if (event is MainPageChatListTabActive) {
      yield MainPageChatList(activeList: _activeChats);
    } else if (event is MainPageRosterTabActive) {
      print("dispatch Roster2 ${_activeRoster.length}");
      yield MainPageRosterList(activeList: _activeRoster);
    }
  }

  void _initStreams() {
    Observable(_rosterRepo.rosterStream).debounce(Duration(milliseconds: 1000))
        .listen(
            (roster) {
      _activeRoster = roster;
      if (_activeTab == MainPageTab.ROSTER) {
        dispatch(MainPageRosterTabActive());
        print("dispatch Roster");
      }
    });

    Observable(_chatListRepo.chatsStream).debounce(Duration(milliseconds: 1000))
        .listen((chats) {
      _activeChats = chats;
      if(_activeTab == MainPageTab.CHAT_LIST) {
        dispatch(MainPageChatListTabActive());
      }
    });
  }

}

enum MainPageTab {
  CHAT_LIST, ROSTER
}
