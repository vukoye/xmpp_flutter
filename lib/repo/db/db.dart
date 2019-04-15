
import 'dart:async';

import 'dart:io';

import 'package:path/path.dart';
import 'package:simple_chat/repo/db/db_chat.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {

  static final _databaseName = "chat.db";
  static final _databaseVersion = 1;


  DatabaseHelper() {
    initDatabase();
  }

  Database _db;

  initDatabase() async {
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, _databaseName);
    _db = await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(DbChat.getTableCreateString());
  }


  Future<DbChat> insert(DbChat chat) async {
    chat.uuid = await _db.insert(DbChat.TABLE, chat.toMap());
    return chat;
  }

  Future<List<DbChat>> getAllDbChats() async {
    var result = await _db.rawQuery("SELECT * FROM ${DbChat.TABLE}");
    var chats = result.toList().map((item) => DbChat.fromMap(item));
    return chats;
  }

  //@formatter:off
  Future<List<Map<String, dynamic>>> getAllDbChatsForAccountId(String
  accountId) async {
    return  _db.rawQuery('SELECT * FROM ${DbChat.TABLE} WHERE ${DbChat.COLUMN_ACCOUNT_ID} = "$accountId"');
  }
  //@formatter:on

  Future<int> delete(DbChat chat) async {
    return await _db.rawDelete('DELETE FROM Customer WHERE "${DbChat.COLUMN_UUID} = ${chat
        .uuid}"');
  }

  close() {

  }
}

