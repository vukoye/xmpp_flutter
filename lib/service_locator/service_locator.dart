import 'package:get_it/get_it.dart';
import 'package:simple_chat/settings/settings.dart';

GetIt sl = new GetIt();

void setupServiceLocator() {
  sl.registerSingleton<Settings>(SettingsImpl());
}
