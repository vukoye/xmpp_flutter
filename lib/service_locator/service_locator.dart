import 'package:get_it/get_it.dart';
import 'package:simple_chat/account/account_repo.dart';
import 'package:simple_chat/settings/settings.dart';
//import 'package:simple_chat/repo/chats_repo.dart'

GetIt sl = new GetIt();

void setupServiceLocator() {
  sl.registerSingleton<Settings>(SettingsImpl());
  sl.registerSingleton<AccountRepo>(AccountRepoImpl());
  //sl.registerSingleton<ChatRepo>(ChatRepoImpl());
}
