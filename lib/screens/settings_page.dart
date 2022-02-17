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
  final Settings settings;

  SettingsPage(this.settings, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return SettingsPageState(this.settings, this.appBarTitle);
  }
}

class SettingsPageState extends State<SettingsPage> {
  DatabaseHelper helper = DatabaseHelper();
  SettingsDB settingsHelper = SettingsDB();

  String appBarTitle;
  Note note;
  Settings settings;
  List<Settings> settingsList;
  String lastSyncDate;
  String restoreDate;
  Color statusColor;
  Color restoreColor;
  String username = '/user0';

  SettingsPageState(this.settings, this.appBarTitle);
  var isLogIn = true;

  @override
  Widget build(BuildContext context) {
    if (settingsList == null) {
      settingsList = [];
    }

    print('IMGF id settings: ' + settings.id.toString());
    print('IMGF restoreDate: ' + settings.restoreDate.toString());
    print('IMGF lastSyncDate: ' + settings.lastSyncDate);
    print('IMGF username: ' + settings.username.toString());
    print('IMGF isLogin: ' + settings.isLogin.toString());

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
                        _getRestoreDate(),
                        // Text(
                        //   isLogIn
                        //       ? settings.restoreDate ?? 'Not restored'
                        //       : 'Not logged in',
                        //   style: TextStyle(color: restoreColor),
                        //   overflow: TextOverflow.ellipsis,
                        // ),
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
                        _getLastSyncDate()
                        // Text(
                        //   isLogIn
                        //       ? settings.lastSyncDate ?? 'Not synced'
                        //       : 'Not logged in',
                        //   style: TextStyle(color: statusColor),
                        //   overflow: TextOverflow.ellipsis,
                        // ),
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
                    // helper.deleteAll();
                    deleteNotes(context);
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

  Widget _getLastSyncDate() {
    // if (settingsList[0].isLogin == 'true') {}
    if (settings.lastSyncDate == null) {
      return Text(
        'Not synced',
        style: TextStyle(color: statusColor),
      );
    } else {
      return Text(
        settings.lastSyncDate.replaceAll(' | ', '\n'),
        style: TextStyle(color: statusColor),
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  Widget _getRestoreDate() {
    // if (settingsList[0].isLogin == 'true') {}
    if (settings.restoreDate == null) {
      return Text(
        'Not restored',
        style: TextStyle(color: restoreColor),
      );
    } else {
      return Text(
        settings.restoreDate.replaceAll(' | ', '\n'),
      );
    }
  }

  Widget _getUserName() {
    if (settings.userName == null) {
      return Text(
        'Not logged in',
        style: TextStyle(color: statusColor),
      );
    }
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void deleteNotes(BuildContext context) {
    helper.deleteAll();
    final snackBar = SnackBar(
      content: const Text(
        'Deleted all notes successfully',
        style: TextStyle(color: Colors.white),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  //export to Azure

  void exportToAzure(String username) async {
    try {
      String notePath = await getDatabasesPath();
      String fileName = '$notePath/notes.db';

      List contentList = await helper.getNoteMapList();
      String content = contentList.join();
      String container = 'notter-project';
      var storage = AzureStorage.parse(
          'DefaultEndpointsProtocol=https;AccountName=notterprojectuser;AccountKey=ugCVzp4ihOOjoHtZzv9OhYbWpaeLl2Vv3hJ5Vt1y12e0I2NAxIQsSXelVE45Rm13UkwwKHJKT+9dIyh1TCYTHA==;EndpointSuffix=core.windows.net');

      await storage.putBlob(
        '/$container$username/$fileName',
        body: content,
      );

      var lastSyncDateDB = DateFormat.yMMMd().format(DateTime.now()) +
          ' | ' +
          DateFormat.jms().format(DateTime.now());
      _saveLastSyncDate(lastSyncDateDB);
      setState(() {
        lastSyncDate = lastSyncDateDB.replaceAll(' | ', '\n');
        print('IMGF state: $lastSyncDateDB - $lastSyncDate');

        statusColor = Colors.green[600];
      });
    } on AzureStorageException catch (ex) {
      setState(() {
        lastSyncDate = 'Azure Storage Exception';
        statusColor = Colors.red;
      });
      print('IMGF ex: $ex');
    } catch (err) {
      setState(() {
        lastSyncDate = 'Unknown Error';
        statusColor = Colors.red;
        print('IMGF err: $err');
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
      String replace = content
          .replaceAll('}{', ';')
          .replaceAllMapped(RegExp(r'\{|\}'), (Match m) => '');
      List<String> contentList = replace.split(';');

      for (int i = 0; i < contentList.length; i++) {
        List<String> jsonList = contentList[i].split(',');

        Map<String, dynamic> note = {
          // 'id': id,
          'title': jsonList[1].split(': ')[1],
          'description': jsonList[2].split(': ')[1],
          'color': int.parse(jsonList[3].split(':')[1]),
          'date': jsonList[4].split(':')[1] +
              ',' +
              jsonList[5].split(':')[0] +
              ':' +
              jsonList[5].split(':')[1] +
              ':' +
              jsonList[5].split(':')[2],
          'image': jsonList[6].split(':')[1].replaceAll(' ', ''),
        };
        await helper.insertNote(Note.fromMapObject(note));
      }
      var restoreStateDB = DateFormat.yMMMd().format(DateTime.now()) +
          ' | ' +
          DateFormat.jms().format(DateTime.now());
      _saveRestoreDate(restoreStateDB);
      setState(() async {
        settingsList[0].restoreDate = restoreStateDB.replaceAll(' | ', '\n');

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

  void _saveRestoreDate(String state) async {
    try {
      if (settingsList[0].id != null) {
        await settingsHelper.updateRestoreDate(state, settingsList[0].id);
      } else {
        await settingsHelper.insertRestoreDate(state);
      }
    } catch (e) {
      print('IMGF RD: $e');
    }
  }

  void _saveLastSyncDate(String state) async {
    try {
      if (settingsList[0].id != null) {
        await settingsHelper.updateLastSyncDate(state, settingsList[0].id);
      } else {
        await settingsHelper.insertLastSyncDate(state);
      }
    } catch (e) {
      print('IMGF LSD: $e');
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
