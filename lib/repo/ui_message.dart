import 'package:image/image.dart' as img;
import 'package:xmpp_stone/xmpp_stone.dart';

class UiMessage {
  String fromName;
  String fromJid;
  int dbId;
  String externalId;
  String chatExternalId;
  int chatDbId;
  String messageBody;
  img.Image avatar;
  UiMessageType type;
  Message _xmppMessage;

  UiMessage.fromXmppMessage(this._xmppMessage);


}

enum UiMessageType {
  TEXT, DATE
}
