// ignore_for_file: unnecessary_statements

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/db_helper/db_helper.dart';
import 'package:notes_app/db_helper/db_settings.dart';
import 'package:azblob/azblob.dart';
import 'package:notes_app/screens/login_page.dart';
import 'package:sqflite/sqflite.dart';
import 'package:notes_app/modal_class/settings.dart';
import 'package:notes_app/modal_class/notes.dart';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  final String appBarTitle;
  // SettingsPage({Key key, this.appBarTitle, this.note}) : super(key: key);
  SettingsPage(this.appBarTitle, {String title});

  @override
  State<StatefulWidget> createState() {
    return SettingsPageState(this.appBarTitle);
  }
}

class SettingsPageState extends State<SettingsPage> {
  DatabaseHelper helper = DatabaseHelper();
  SettingsDB settingsHelper = SettingsDB();

  String appBarTitle;
  Note note;
  Settings settings;
  String lastSyncDate;
  String restoreDate;
  Color statusColor;
  Color restoreColor;
  String username = '/user0';

  SettingsPageState(this.appBarTitle);
  var isLogIn = true;

  @override
  Widget build(BuildContext context) {
    // var settings = Settings();
    // print('paderech: ' + settings.lastSyncDate);
    updateSettingsView();

    final brightness = Theme.of(context).brightness;
    bool isDarkMode = brightness == Brightness.dark;

    return WillPopScope(
        onWillPop: () async {
          moveToLastScreen();
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text(
              appBarTitle,
              style: Theme.of(context).textTheme.headline5,
            ),
            leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  // _saveSettings();
                  moveToLastScreen();
                }),
          ),
          body: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'If you want sync or restore notes from other device, you need to login. ',
                  textAlign: TextAlign.justify,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  isLogIn
                      ? 'You are logged in as: ' + username.replaceAll('/', '')
                      : 'You are not logged in',
                  textAlign: TextAlign.justify,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Last restore:',
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          isLogIn
                              ? restoreDate ?? 'Not restored'
                              : 'Not logged in',
                          style: TextStyle(color: restoreColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: MaterialButton(
                      onPressed: () {
                        isLogIn ? restoreFromAzure(username) : null;
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 5.0, bottom: 5.0, left: 20.0, right: 20.0),
                        child: Text(
                          'Restore',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      disabledColor: Colors.grey,
                      color: Colors.blue,
                      padding: EdgeInsets.all(5.0),
                      splashColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(300.0)),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Last export:',
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          isLogIn
                              ? lastSyncDate ?? 'Not synced'
                              : 'Not logged in',
                          style: TextStyle(color: statusColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: MaterialButton(
                      onPressed: () {
                        isLogIn ? exportToAzure(username) : null;
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 5.0, bottom: 5.0, left: 26.0, right: 26.0),
                        child: Text(
                          'Export',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      disabledColor: Colors.grey,
                      color: Colors.blue,
                      padding: EdgeInsets.all(5.0),
                      splashColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(300.0)),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: MaterialButton(
                  onPressed: () {
                    isLogIn ? logOutAction() : logInAction(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      isLogIn ? 'Log out' : 'Log in',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  color: isLogIn
                      ? isDarkMode
                          ? Colors.grey[850]
                          : Colors.white
                      : Colors.blue,
                  padding: EdgeInsets.all(5.0),
                  splashColor: Colors.blueAccent,
                  shape: isLogIn
                      ? RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(300.0),
                          side: BorderSide(color: Colors.blue, width: 2.0),
                        )
                      : RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(300.0)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: MaterialButton(
                  onPressed: () {
                    helper.deleteAll();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      'Delete all notes',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  color: Colors.blue,
                  padding: EdgeInsets.all(5.0),
                  splashColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(300.0)),
                ),
              ),
            ],
          ),
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  //export to Azure

  void exportToAzure(String username) async {
    try {
      String path = await getDatabasesPath();
      String fileName = '$path/notes.db';
      List contentList = await helper.getNoteMapList();
      String content = contentList.join();
      String container = 'notter-project';
      var storage = AzureStorage.parse(
          'DefaultEndpointsProtocol=https;AccountName=notterprojectuser;AccountKey=ugCVzp4ihOOjoHtZzv9OhYbWpaeLl2Vv3hJ5Vt1y12e0I2NAxIQsSXelVE45Rm13UkwwKHJKT+9dIyh1TCYTHA==;EndpointSuffix=core.windows.net');

      await storage.putBlob(
        '/$container$username/$fileName',
        body: content,
      );
      _saveLastSyncDate();
      setState(
        () {
          var lastSyncDateDB = DateFormat.yMMMd().format(DateTime.now()) +
              ' | ' +
              DateFormat.jms().format(DateTime.now());
          lastSyncDate = lastSyncDateDB.replaceAll(' | ', '\n');
          print('paderech state: $lastSyncDateDB - $lastSyncDate');

          statusColor = Colors.green[600];
        },
      );
    } on AzureStorageException catch (ex) {
      setState(() {
        lastSyncDate = 'Azure Storage Exception';
        statusColor = Colors.red;
      });
      print('paderech ex: $ex');
    } catch (err) {
      setState(() {
        lastSyncDate = 'Unknown Error';
        statusColor = Colors.red;
        print('paderech err: $err');
      });
      print(err);
    }
  }

//restore from Azure
  HttpClient httpClient = new HttpClient();

  void restoreFromAzure(String username) async {
    try {
      String container = 'notter-project';
      Uri url = Uri.parse(
          'https://notterprojectuser.blob.core.windows.net/$container$username//data/user/0/com.example.note_app_cdv/databases/notes.db');

      http.Response response = await http.get(url);
      String content = response.body;
      // print('Dwl Content: $content');
      String replace = content
          .replaceAll('}{', ';')
          .replaceAllMapped(RegExp(r'\{|\}'), (Match m) => '');
      List<String> contentList = replace.split(';');

      for (int i = 0; i < contentList.length; i++) {
        List<String> jsonList = contentList[i].split(',');

        Map<String, dynamic> note = {
          // 'id': id,
          'title': jsonList[1].split(':')[1],
          'description': jsonList[2].split(':')[1],
          'color': int.parse(jsonList[3].split(':')[1]),
          'date': jsonList[4].split(':')[1] +
              ',' +
              jsonList[5].split(':')[0] +
              ':' +
              jsonList[5].split(':')[1] +
              ':' +
              jsonList[5].split(':')[2],
          'image': jsonList[6].split(':')[1],
        };
        await helper.insertNote(Note.fromMapObject(note));
      }
      setState(() async {
        var restoreStateDB = DateFormat.yMMMd().format(DateTime.now()) +
            ' | ' +
            DateFormat.jms().format(DateTime.now());
        restoreDate = restoreStateDB.replaceAll(' ', '\n');

        _saveRestoreDate(restoreStateDB);

        restoreColor = Colors.green[600];
      });
      restoreColor = Colors.green[600];
    } on HttpException catch (ex) {
      setState(() {
        restoreDate = 'Http Exception';
        restoreColor = Colors.red;
      });
      print(ex);
    } catch (err) {
      setState(() {
        restoreDate = 'Unknown Error';
        restoreColor = Colors.red;
      });
      print(err);
    }
  }

  void updateSettingsView() {
    final Future<Database> dbFuture = settingsHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Settings>> settingsListFuture = settingsHelper.getSettings();
      settingsListFuture.then((settingsList) {
        setState(() {
          this.restoreDate = settingsList[1].restoreDate;
          this.lastSyncDate = settingsList[1].lastSyncDate;
          this.isLogIn = settingsList[1].isLogin;
          this.username = settingsList[1].userName;
        });
      });
    });
  }

  void _saveRestoreDate(String state) async {
    // settings.restoreDate = DateFormat.yMMMd().format(DateTime.now()) +
    //     ' | ' +
    //     DateFormat.jms().format(DateTime.now());

    // try {
    //   if (settings.id != null) {
    //     await settingsHelper.updateRestoreDate(state, 1);
    //   } else {
    //     await settingsHelper.insertRestoreDate(state);
    //   }
    // } catch (e) {
    //   print('paderech RD: $e');
    // }
  }

  void _saveLastSyncDate() async {
    print('paderech function 0: $settings');
    settings.lastSyncDate = DateFormat.yMMMd().format(DateTime.now()) +
        ' | ' +
        DateFormat.jms().format(DateTime.now());
    print('paderech function 0: ' + settings.lastSyncDate);
    try {
      print('paderech function 2: $settings');
      if (settings.id != null) {
        // await settingsHelper.updateLastSyncDate(state, 1);
        print('paderech update: $settings');
      } else {
        // await settingsHelper.insertLastSyncDate(state);
        // await settingsHelper.insert(settings);
        print('paderech insert: $settings');
      }
    } catch (e) {
      print('paderech LSD: $e');
    }
  }

  //TODO: Add a function to logout
  logOutAction() {}

  void logInAction(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogInPage('Log in'),
      ),
    );
  }

  //TODO: Add a function to check if the user is logged in or not.
  logInCheck() {}
}
