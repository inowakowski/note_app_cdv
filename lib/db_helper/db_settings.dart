import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:notes_app/modal_class/settings.dart';

class SettingsDB {
  static SettingsDB _settingsHelper;
  static Database _database;

  String settingsTable = 'settings_table';
  String restoreDate = 'restore_date';
  String lastSyncDate = 'last_sync_date';
  String colId = 'id';
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
      '$lastSyncDate TEXT, $userName TEXT)',
    );
  }

  Future<int> insert(Settings settings) async {
    Database db = await this.database;
    // await db.delete(settingsTable);
    var result = await db.insert(
      settingsTable,
      settings.toMap(),
    );
    return result;
  }

  Future<int> update(Settings settings) async {
    Database db = await this.database;
    var result = await db.update(settingsTable, settings.toMap(),
        where: '$colId = ?', whereArgs: [settings.id]);
    return result;
  }

  Future<int> deleteAllSetiings() async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $settingsTable');
    // db.rawDelete(
    //     'DELETE FROM SQLITE_SEQUENCE SET SEQ=0 WHERE name = $settingsTable');
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
      settingsList.add(Settings.fromMapObject(settingsMapList[i]));
    }

    return settingsList;
  }
}
