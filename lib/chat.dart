import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat/const.dart';
import 'package:simple_chat/settings/settings.dart';
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;
import 'package:simple_chat/service_locator/service_locator.dart';

const String _selfName = "Self Name";

class Chat extends StatelessWidget {
  final xmpp.Buddy buddy;

  Chat({Key key, @required this.buddy}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'CHAT',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: new ChatScreen(buddy: this.buddy),
    );
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.animationController, this.from});

  final xmpp.Buddy from;
  final String text;
  final AnimationController animationController;
  bool isIncoming = false;

  @override
  Widget build(BuildContext context) {
    String displayName =
    (from != null) ? (from.name ?? from.jid.userAtDomain) : _selfName;
    String initials = displayName[0] ?? "X";
    List<Widget> children;
    isIncoming = from != null;
    Color contentColor = isIncoming ? greyColor : greyColor2;
    Widget avatar = new Container(
      margin: const EdgeInsets.only(right: 16.0),
      child: new CircleAvatar(child: new Text(initials)),
    );
    Widget nameWidget = new Text(displayName, style: Theme.of(context).textTheme
        .subhead);
    Widget textWidget = new Container(
      margin: const EdgeInsets.only(top: 5.0),
      child: new Text(text),
    );
    List<Widget> messageChildren;
    if (from == null) {
      messageChildren = [textWidget];
    } else {
      messageChildren = [nameWidget, textWidget];
    }
    Widget messageContent = Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(top:10.0, bottom: 10, right: isIncoming ? 10 : 20, left: 10),
      decoration : BoxDecoration(color: contentColor, borderRadius: BorderRadius.circular(8.0)),
      child: new Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: (from == null) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: messageChildren
      ),
    );
    if (from == null) {
      children = [messageContent];
    } else {
      children = [avatar, messageContent];
    }


    return new SizeTransition(
        sizeFactor: new CurvedAnimation(
            parent: animationController, curve: Curves.easeOut),
        axisAlignment: 0.0,
        child: new Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: new Row(
            mainAxisAlignment: isIncoming ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: children,
          ),
        ));
  }
}

class ChatScreen extends StatefulWidget {
  final xmpp.Buddy buddy;

  ChatScreen({Key key, @required this.buddy}) : super(key: key);

  @override
  State createState() => new ChatScreenState(buddy: buddy);
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  ChatScreenState({Key key, @required this.buddy});
  final _settings = sl.get<Settings>();
  xmpp.Buddy buddy;
  xmpp.MessageHandler _messageHandler;

  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = new TextEditingController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _initMessageHandler();
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    _messageHandler.sendMessage(buddy.jid, text);
    ChatMessage message = new ChatMessage(
      text: text,
      animationController: new AnimationController(
        duration: new Duration(milliseconds: 700),
        vsync: this,
      ),
    );
    setState(() {
      _messages.insert(0, message);
    });
    message.animationController.forward();
  }

  void _handleIncoming(xmpp.MessageStanza messageStanza) {
    ChatMessage message = new ChatMessage(
        text: messageStanza.body,
        animationController: new AnimationController(
          duration: new Duration(milliseconds: 700),
          vsync: this,
        ),
        from: buddy);
    setState(() {
      _messages.insert(0, message);
    });
    message.animationController.forward();
  }

  void dispose() {
    for (ChatMessage message in _messages)
      message.animationController.dispose();
    super.dispose();
  }

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new Row(children: <Widget>[
            new Flexible(
              child: new TextField(
                controller: _textController,
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                onSubmitted: _handleSubmitted,
                decoration:
                new InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? new CupertinoButton(
                  child: new Text("Send"),
                  onPressed: _isComposing
                      ? () => _handleSubmitted(_textController.text)
                      : null,
                )
                    : new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: _isComposing
                      ? () => _handleSubmitted(_textController.text)
                      : null,
                )),
          ]),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? new BoxDecoration(
              border:
              new Border(top: new BorderSide(color: Colors.grey[200])))
              : null),
    );
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
          child: new Column(children: <Widget>[
            new Flexible(
                child: new ListView.builder(
                  padding: new EdgeInsets.all(8.0),
                  reverse: true,
                  itemBuilder: (_, int index) => _messages[index],
                  itemCount: _messages.length,
                )),
            new Divider(height: 1.0),
            new Container(
              decoration: new BoxDecoration(color: Theme.of(context).cardColor),
              child: _buildTextComposer(),
            ),
          ]),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? new BoxDecoration(
              border:
              new Border(top: new BorderSide(color: Colors.grey[200])))
              : null), //new
    );
  }

  Future _initMessageHandler() async {
    xmpp.Connection connection =
    xmpp.Connection.getInstance(await _settings.getAccountData());
    _messageHandler = xmpp.MessageHandler.getInstance(connection);
    _messageHandler.messagesStream.listen((message) {
      if (message.fromJid.userAtDomain == buddy.jid.userAtDomain &&
          message.body != null) {
        _handleIncoming(message);
      }
    });
  }
}
