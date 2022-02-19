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

  // SettingsPage(this.appBarTitle, {String title});
  SettingsPage(this.settings, this.appBarTitle, {String title});

  @override
  State<StatefulWidget> createState() {
    return SettingsPageState(this.settings, this.appBarTitle);
    // return SettingsPageState(this.appBarTitle);
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
  String username;
  int countSettings = 0;

  SettingsPageState(this.settings, this.appBarTitle);
  // SettingsPageState(this.appBarTitle);

  bool isLogIn = false;

  @override
  Widget build(BuildContext context) {
    // if (settingsList == null) {
    //   settingsList = [];
    //   updateSettingsList();
    // }

    // if (username != null) {
    //   settings.userName = username;
    // } else {
    //   username = settings.userName;
    // }

    if (isLogIn != null) {
      settings.isLogin = this.isLogIn;
    } else {
      this.isLogIn = settings.isLogin;
    }
    settingsHelper.insert(settings);

    // print('imgf settings id: ' + settings.id.toString());
    print('imgf settings lastSync: ' + settings.lastSyncDate);
    print('imgf settings restore: ' + settings.restoreDate);
    print('imgf settings username: ' + settings.userName);
    print('imgf settings isLogin: ' + settings.isLogin.toString());

    // print('imgf count: ' + countSettings.toString());'
    // print('imgf settings length: ' + settingsList.length.toString());

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
          body: Container(
            child: ListView(
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
                  child: _getUserName(),
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
                          //       ? settingsList[0].restoreDate ??
                          //           'Not restored'
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
                          //       ? settingsList[0].lastSyncDate ?? 'Not synced'
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
                    child: _logInButton(isDarkMode)),
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
          ),
        ));
  }

  Widget _logInButton(bool isDarkMode) {
    if (isLogIn) {
      return MaterialButton(
          onPressed: () {
            logOutAction();
          },
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              'Log out',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          padding: EdgeInsets.all(5.0),
          splashColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(300.0),
            side: BorderSide(color: Colors.blue, width: 2.0),
          ));
    } else {
      return MaterialButton(
        onPressed: () {
          logInAction(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            'Log in',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        color: Colors.blue,
        padding: EdgeInsets.all(5.0),
        splashColor: Colors.blueAccent,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(300.0)),
      );
    }
  }

  Widget _getLastSyncDate() {
    // if (settingsList[0].isLogin == 'true') {}
    if (this.countSettings == 0) {
      return Text(
        'Not synced',
        style: TextStyle(color: statusColor),
      );
    } else {
      return Text(
        settingsList[0].lastSyncDate.replaceAll(' | ', '\n'),
        style: TextStyle(color: statusColor),
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  Widget _getRestoreDate() {
    // if (settingsList[0].isLogin == 'true') {}
    if (this.countSettings == 0) {
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
    if (this.isLogIn == false) {
      return Text(
        'You are NOT logged in.',
        style: TextStyle(color: statusColor),
      );
    } else if (this.isLogIn == true) {
      return Text(
        // 'You are logged in as: test',
        'You are logged in as: \n' + settings.userName,
        textAlign: TextAlign.justify,
      );
    }
  }

  void moveToLastScreen() async {
    // try {
    //   if (settings.id != null) {
    //     await settingsHelper.update(settings);
    //   } else {
    //     await settingsHelper.insert(settings);
    //   }
    // } catch (e) {
    //   print(e);
    // }
    _saveSettings();

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
        '/$container/$username/$fileName',
        body: content,
      );

      var lastSyncDateDB = DateFormat.yMMMd().format(DateTime.now()) +
          ' | ' +
          DateFormat.jms().format(DateTime.now());
      _saveLastSyncDate(lastSyncDateDB);

      setState(() {
        lastSyncDate = lastSyncDateDB.replaceAll(' | ', '\n');

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
      // _saveRestoreDate(restoreStateDB);

      setState(() async {
        settings.restoreDate = restoreStateDB.replaceAll(' | ', '\n');
        this.restoreDate = restoreStateDB.replaceAll(' | ', '\n');

        restoreColor = Colors.green[600];
      });
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
      if (settings.id != null) {
        await settingsHelper.updateRestoreDate(state, settings.id);
      } else {
        await settingsHelper.insertRestoreDate(state);
      }
    } catch (e) {
      print(e);
    }
  }

  void _saveLastSyncDate(String state) async {
    // try {
    //   if (settings.id != null) {
    //     await settingsHelper.updateLastSyncDate(state, settings.id);
    //   } else {
    //     await settingsHelper.insertLastSyncDate(state);
    //   }
    // } catch (e) {
    //   print('IMGF LSD: $e');
    // }
    // settings.lastSyncDate = state;
  }

  void _saveSettings() async {
    try {
      if (settings.id != null) {
        await settingsHelper.update(settings);
        print('IMGF saved updated' + settings.toString());
      } else {
        await settingsHelper.insert(settings);
        print('IMGF saved inserted' + settings.toString());
      }
      print('IMGF saved');
    } catch (e) {
      print('IMGF SS: $e');
    }
  }

  //TODO: Add a function to logout
  logOutAction() {
    final snackBar = SnackBar(
      content: const Text(
        'Log out successfully',
        style: TextStyle(color: Colors.white),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    setState(() {
      settings.isLogin = false;
      this.isLogIn = false;
      settings.userName = '';
      this.username = '';
    });
  }

  void logInAction(BuildContext context) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogInPage('Log in'),
      ),
    );

    if (result[0] == true) {
      setState(() {
        settings.isLogin = true;
        this.isLogIn = true;
        settings.userName = result[1];
      });
    } else {
      setState(() {
        settings.isLogin = false;
        this.isLogIn = false;
      });
      // updateSettingsList();
    }
    if (settings.id != 0) {
      await settingsHelper.updateIsLogin(this.isLogIn, settings.id);
      print('IMGF: updateIsLogin');
      await settingsHelper.updateUsername(this.username, settings.id);
      print('IMGF: updateUsername');
      // updateSettingsList();
    } else {
      await settingsHelper.insertIsLogin(this.isLogIn, 1);
      print('IMGF: insertIsLogin');
      await settingsHelper.insertUsername(this.username, 1);
      print('IMGF: insertUsername');
    }
    // updateSettingsList();
    print('IMGF: updateSettingsList');
  }
}
