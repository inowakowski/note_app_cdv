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
  String lastSyncDate = '';
  String restoreDate = '';
  Color statusColor;
  Color restoreColor;
  String username = '';
  int countSettings = 0;
  bool darkMode;

  SettingsPageState(this.settings, this.appBarTitle);
  // SettingsPageState(this.appBarTitle);

  bool isLogIn;

  @override
  Widget build(BuildContext context) {
    if (settings.userName != '') {
      setState(() {
        this.isLogIn = true;
        this.username = settings.userName;
      });
    } else {
      setState(() {
        this.isLogIn = false;
      });
    }

    if (username != null) {
      setState(() {
        settings.userName = username;
      });
    } else {
      username = settings.userName;
    }

    final brightness = Theme.of(context).brightness;
    bool isDarkMode = brightness == Brightness.dark;
    this.darkMode = isDarkMode;

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
                        onPressed:
                            isLogIn ? () => restoreFromAzure(username) : null,
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
                          _getLastSyncDate(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: MaterialButton(
                        onPressed:
                            isLogIn ? () => exportToAzure(username) : null,
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
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: MaterialButton(
                    onPressed: () {
                      deleteAllSettings(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        'Delete all settings',
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
    if (this.lastSyncDate == '') {
      return Text(
        'Not synced',
        style: TextStyle(color: statusColor),
        textAlign: TextAlign.justify,
      );
    } else {
      return Text(
        this.lastSyncDate,
        style: TextStyle(color: statusColor),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.justify,
      );
    }
  }

  Widget _getRestoreDate() {
    // if (settingsList[0].isLogin == 'true') {}
    if (this.restoreDate == '') {
      return Text(
        'Not restored',
        style: TextStyle(color: restoreColor),
        textAlign: TextAlign.justify,
      );
    } else {
      return Text(
        this.restoreDate,
        style: TextStyle(color: restoreColor),
        textAlign: TextAlign.justify,
      );
    }
  }

  Widget _getUserName() {
    if (this.isLogIn == false) {
      return Text(
        'You are NOT logged in.',
        textAlign: TextAlign.justify,
      );
    } else {
      return Text(
        // 'You are logged in as: test',
        'You are logged in as: \n' + this.username,
        textAlign: TextAlign.justify,
      );
    }
  }

  void moveToLastScreen() async {
    _saveSettings();

    Navigator.pop(context, true);
  }

  void deleteNotes(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
            "Delete all notes?",
            style: Theme.of(context).textTheme.bodyText2,
          ),
          content: Text("Are you sure you want to delete all notes?",
              style: Theme.of(context).textTheme.bodyText1),
          actions: <Widget>[
            TextButton(
              child: Text(
                "No",
                style: Theme.of(context).textTheme.bodyText2,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Yes", style: Theme.of(context).textTheme.bodyText2),
              onPressed: () {
                Navigator.of(context).pop();
                helper.deleteAll();
                final snackBar = SnackBar(
                  content: const Text(
                    'Deleted all notes successfully',
                    style: TextStyle(color: Colors.white),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
            ),
          ],
        );
      },
    );
  }

  void deleteAllSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
            "Delete all settings?",
            style: Theme.of(context).textTheme.bodyText2,
          ),
          content: Text("Are you sure you want to delete all settings?",
              style: Theme.of(context).textTheme.bodyText1),
          actions: <Widget>[
            TextButton(
              child: Text(
                "No",
                style: Theme.of(context).textTheme.bodyText2,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Yes", style: Theme.of(context).textTheme.bodyText2),
              onPressed: () {
                Navigator.of(context).pop();
                settingsHelper.deleteAllSetiings();
                final snackBar = SnackBar(
                  content: const Text(
                    'Deleted all settings successfully',
                    style: TextStyle(color: Colors.white),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
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
          ' - ' +
          DateFormat.jms().format(DateTime.now());

      setState(() {
        settings.lastSyncDate = lastSyncDateDB;
        this.lastSyncDate = lastSyncDateDB.replaceAll(' - ', '\n');
        statusColor = Colors.green[600];
      });
    } on AzureStorageException catch (ex) {
      setState(() {
        lastSyncDate = 'Azure Storage Exception';
        statusColor = Colors.red;
      });
      print('$ex');
    } catch (err) {
      setState(() {
        lastSyncDate = 'Unknown Error';
        statusColor = Colors.red;
        print('$err');
      });
      print(err);
    }
  }

//restore from Azure

  HttpClient httpClient = new HttpClient();

  void restoreFromAzure(String username) async {
    try {
      String container = 'notter-project';
      Uri url = Uri.https(
        'notterprojectuser.blob.core.windows.net',
        '/$container/$username//data/user/0/com.example.note_app_cdv/databases/notes.db',
        {'q': '{http}'},
      );

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
          ' - ' +
          DateFormat.jms().format(DateTime.now());

      setState(() {
        this.restoreDate = restoreStateDB.replaceAll(' - ', '\n');
        settings.restoreDate = restoreStateDB;
        this.restoreColor = Colors.green[600];
      });
    } on HttpException catch (ex) {
      setState(() {
        this.restoreDate = 'Http Exception';
        restoreColor = Colors.red;
      });
      print(ex);
    } catch (err) {
      setState(() {
        this.restoreDate = 'Unknown Error';
        restoreColor = Colors.red;
      });
      print(err);
    }
  }

  void _saveSettings() async {
    settings.userName = this.username;

    if (settings.id != null) {
      await settingsHelper.update(settings);
    } else {
      await settingsHelper.insert(settings);
    }
  }

  void logOutAction() {
    final snackBar = SnackBar(
      content: const Text(
        'Log out successfully',
        style: TextStyle(color: Colors.white),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    setState(() {
      this.isLogIn = false;
      this.username = '';
      this.lastSyncDate = '';
      this.restoreDate = '';
      this.restoreColor = darkMode ? Colors.white : Colors.black;
      this.statusColor = darkMode ? Colors.white : Colors.black;
      settings.lastSyncDate = '';
      settings.userName = '';
      settings.restoreDate = '';
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
        this.isLogIn = true;
        this.username = result[1];
        settings.userName = result[1];
      });
    } else {
      setState(() {
        this.isLogIn = false;
      });
    }
  }
}
