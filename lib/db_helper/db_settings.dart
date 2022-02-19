import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:notes_app/modal_class/settings.dart';

class SettingsDB {
  static SettingsDB _settingsHelper; // Singleton DatabaseHelper
  static Database _database;

  String settingsTable = 'settings_table';
  String restoreDate = 'restore_date';
  String lastSyncDate = 'last_sync_date';
  String colId = 'id';
  String isLogin = 'is_login';
  String userName = 'username';

  SettingsDB._createInstance();

  factory SettingsDB() {
    if (_settingsHelper == null) {
      _settingsHelper = SettingsDB
          ._createInstance(); // This is executed only once, singleton object
    }
    return _settingsHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'settings.db';

    // Open/create the database at a given path
    var settingsDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return settingsDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
      'CREATE TABLE $settingsTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $restoreDate TEXT, '
      '$lastSyncDate TEXT, $isLogin BOOL, $userName TEXT)',
    );
  }

  Future<int> insert(Settings settings) async {
    Database db = await this.database;
    var result = await db.insert(
      settingsTable,
      settings.toMap(),
    );
    print('imgf result:' + result.toString());
    return result;
  }

  Future<int> update(Settings settings) async {
    Database db = await this.database;
    var result = await db.update(settingsTable, settings.toMap(),
        where: '$colId = ?', whereArgs: [settings.id]);
    return result;
  }

  Future<int> insertLastSyncDate(String date) async {
    Database db = await this.database;
    var result = await db.insert(settingsTable, {lastSyncDate: date});
    return result;
  }

  Future<int> updateLastSyncDate(String date, int id) async {
    var db = await this.database;
    var result = await db.update(settingsTable, {lastSyncDate: date},
        where: '$colId = ?', whereArgs: [id]);
    return result;
  }

  Future<int> insertRestoreDate(String date) async {
    Database db = await this.database;
    var result = await db.insert(settingsTable, {restoreDate: date});
    return result;
  }

  Future<int> updateRestoreDate(String date, int id) async {
    var db = await this.database;
    var result = await db.update(settingsTable, {restoreDate: date},
        where: '$colId = ?', whereArgs: [id]);
    return result;
  }

  Future<bool> insertIsLogin(bool dane, int id) async {
    Database db = await this.database;
    var result = await db.insert(settingsTable, {isLogin: dane, colId: id});
    return result.toInt() > 0 ? true : false;
  }

  Future<bool> updateIsLogin(bool dane, int id) async {
    Database db = await this.database;
    var result = await db.update(settingsTable, {isLogin: dane},
        where: '$colId = ?', whereArgs: [id]);
    return result.toInt() > 0 ? true : false;
  }

  Future<int> insertUsername(String dane, int id) async {
    Database db = await this.database;
    var result = await db.insert(settingsTable, {userName: dane, colId: id});
    return result;
  }

  Future<int> updateUsername(String dane, int id) async {
    Database db = await this.database;
    var result = await db.update(settingsTable, {userName: dane},
        where: '$colId = ?', whereArgs: [id]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getLogin() async {
    var db = await this.database;
    var result = await db.rawQuery('SELECT $isLogin FROM $settingsTable');
    return result;
  }

  Future<List<Map<String, dynamic>>> getRestore() async {
    Database db = await this.database;
    var result = await db.rawQuery('SELECT $restoreDate from $settingsTable');
    return result;
  }

  Future<List<Map<String, dynamic>>> getSync() async {
    Database db = await this.database;
    var result = await db.rawQuery('SELECT $lastSyncDate from $settingsTable');
    return result;
  }

  Future<List<Map<String, dynamic>>> getUserName() async {
    Database db = await this.database;
    var result = await db
        .rawQuery('SELECT $userName from $settingsTable WHERE $colId = 1');
    return result;
  }

  Future<int> getId() async {
    Database db = await this.database;
    var result = await db.rawQuery('SELECT $colId from $settingsTable');
    return result[0]['id'];
  }

  Future<List<Map<String, dynamic>>> getSettingsMapList() async {
    Database db = await this.database;
    var result = await db.rawQuery('SELECT * from $settingsTable');
    return result;
  }

  Future<List<Settings>> getSettingsList() async {
    var settingsMapList = await getSettingsMapList();
    int count = settingsMapList.length;

    List<Settings> settingsList = [];
    for (int i = 0; i < count; i++) {
      settingsList.add(Settings.fromMap(settingsMapList[i]));
    }

    return settingsList;
  }
}
