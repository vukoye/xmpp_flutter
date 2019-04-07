import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_chat/login/login.dart';

class LoginForm extends StatefulWidget {
  final LoginBloc loginBloc;

  LoginForm({
    Key key,
    @required this.loginBloc,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _usernameFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  final TextEditingController _domainFilter = new TextEditingController();
  final TextEditingController _portFilter = new TextEditingController();

  bool _rememberMe = false;

  String _authMessage;

  bool _isExtended = true;

  Widget _getLogoWidget() {
    return Text(
      'Simple Chat',
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 40.0,
          color: Colors.lightBlueAccent),
    );
  }

  Widget _getUserNameWidget(bool isShort) {
    return TextFormField(
      keyboardType: isShort ? TextInputType.text : TextInputType.emailAddress,
      autofocus: false,
      controller: _usernameFilter,
      decoration: InputDecoration(
        hintText: isShort ? 'jid' : 'username',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );
  }

  Widget _getPasswordWidget() {
    return TextFormField(
      autofocus: false,
      controller: _passwordFilter,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );
  }

  Widget _getDomainWidget() {
    return TextFormField(
      keyboardType: TextInputType.text,
      autofocus: false,
      controller: _domainFilter,
      decoration: InputDecoration(
        hintText: 'domain',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );
  }

  Widget _getPortWidget() {
    return TextFormField(
      keyboardType: TextInputType.number,
      autofocus: false,
      controller: _portFilter,
      decoration: InputDecoration(
        hintText: 'port',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );
  }

  Widget _getRememberMeWidget(bool checkValue) {
    return CheckboxListTile(
      value: checkValue,
      onChanged: _rememberMePressed,
      title: new Text("Remember me"),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _getLoginButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: _onLoginButtonPressed,
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Log In', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _getExtendedButton(bool isExtended) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: FlatButton(
            onPressed: _extendedPressed,
            child: Text(isExtended ? 'Basic' : 'Advanced',
                style: TextStyle(color: Colors.blueAccent))));
  }

  Widget _getAuthFailedText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  LoginBloc get _loginBloc => widget.loginBloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginEvent, LoginState>(
      bloc: _loginBloc,
      builder: (
        BuildContext context,
        LoginState state,
      ) {
        if (state is LoginInitial) {
          return _getInitialList();
        } else if (state is LoginDataLoaded) {
          _portFilter.text = state.port.toString();
          _usernameFilter.text = state.username;
          _passwordFilter.text = state.password;
          _domainFilter.text = state.domain;
          _authMessage = null;
          _rememberMe = state.rememberMe;
          _isExtended = state.wasExtended;
          return _getListBasedOnState();
        } else if (state is RememberMeChanged) {
          _rememberMe = state.rememberMeValue;
          _getListBasedOnState();
          return _getListBasedOnState();
        } else if (state is LoginExtendedChanged) {
          _isExtended = state.loginExtendValue;
          return _getListBasedOnState();
        } else if (state is LoginFailureState) {
          _authMessage = state.error;
          return _getListBasedOnState();
        }
        else {
          return _getInitialList();
        }
      },
    );
  }

  _getListBasedOnState() {
    var children = <Widget>[
      _getLogoWidget(),
      SizedBox(height: 48.0),
      _getUserNameWidget(false),
      SizedBox(height: 8.0),
      _getPasswordWidget(),
      SizedBox(height: 8.0),
    ];
    if (_isExtended) {
      children.addAll(<Widget>[
        _getDomainWidget(),
        SizedBox(height: 8.0),
        _getPortWidget(),
        SizedBox(height: 8.0),
      ]);
    }
    children.addAll(<Widget>[
      _getRememberMeWidget(_rememberMe),
      SizedBox(height: 8.0),
      _getLoginButton(),
      SizedBox(height: 8.0),
      _getExtendedButton(_isExtended)
    ]);
    if (_authMessage != null && _authMessage.isNotEmpty) {
      children.add(_getAuthFailedText(_authMessage));
    }
    return ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 24.0, right: 24.0),
        children: children);
  }

  _getInitialList() {
    return ListView(
      shrinkWrap: true,
        padding:  EdgeInsets.only(left: 24.0, right: 24.0),
      children: <Widget>[
        _getLogoWidget(),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
        ),
      ],
    );
  }

  _onLoginButtonPressed() {
    _loginBloc.dispatch(LoginButtonPressed(
        username: _usernameFilter.text,
        password: _passwordFilter.text,
        domain: _domainFilter.text,
        port: int.parse(_portFilter.text)));
  }

  void _rememberMePressed(bool value) {
    _loginBloc.dispatch(RememberMePressed(rememberMeValue: value));
  }

  void _extendedPressed() {
    _loginBloc.dispatch(ExtendPressed());
  }
}
