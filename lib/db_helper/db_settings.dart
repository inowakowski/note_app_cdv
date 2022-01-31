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

  Future<int> insertLastSyncDate(String date) async {
    Database db = await this.database;
    var result = await db.rawInsert(
        'INSERT INTO $settingsTable($lastSyncDate) VALUES (?)', [date]);
    return result;
  }

  Future<int> updateLastSyncDate(String date, int id) async {
    var db = await this.database;
    var result = await db.rawUpdate(
        'UPDATE $settingsTable SET $lastSyncDate = $date WHERE $colId = $id');
    return result;
  }

  Future<int> insertRestoreDate(String date) async {
    Database db = await this.database;
    var result = await db.rawInsert(
        'INSERT INTO $settingsTable($restoreDate) VALUES (?)', [date]);
    return result;
  }

  Future<int> updateRestoreDate(String date, int id) async {
    var db = await this.database;
    var result = await db.rawUpdate(
        'UPDATE $settingsTable SET $restoreDate = $date WHERE $colId = $id');
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

  Future<List<Settings>> getSettings() async {
    var restoreDate = await getRestore();
    var lastSyncDate = await getSync();
    var isLogin = await getLogin();
    var userName = await getUserName();
    List settingsList = [restoreDate, lastSyncDate, isLogin, userName];
    return settingsList;
  }
}
