import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/db_helper/db_helper.dart';
import 'package:azblob/azblob.dart';
import 'package:notes_app/screens/login_page.dart';
import 'package:sqflite/sqflite.dart';
import 'package:notes_app/modal_class/settings.dart';
import 'package:notes_app/modal_class/notes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingsPage extends StatefulWidget {
  final String appBarTitle;

  final isBiometricOn = false;
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
  List settingsList;
  Settings settings;
  String lastSyncDate;
  String restoreDate;
  Color statusColor;
  Color restoreColor;
  bool isLogIn = true;
  var user = 'user0';
  SettingsPageState(this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    if (settingsList == null) {
      // settingsList = ['', ''];
      settingsList = ['Not restored', 'Not synced'];
      updateSettingsView();
    }

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
                  _saveSettings();
                }),
          ),
          body: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'You can sync your notes to the cloud. Click the button "Sync" to sync your notes to the cloud. If your notes are synced to the cloud, you can restore them from the cloud by clicking the "Restore" button.',
                  textAlign: TextAlign.justify,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Last restore:',
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          restoreDate ??
                              settingsList[0] ??
                              settings.restoreDate ??
                              settingsList[0]['restoreDate'],
                          style: TextStyle(color: restoreColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: MaterialButton(
                      disabledColor: Colors.grey,
                      onPressed: isLogIn
                          ? () {
                              restoreFromAzure();
                            }
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 5.0, bottom: 5.0),
                        child: Text(
                          'Restore',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      color: Colors.blue,
                      padding: EdgeInsets.all(8.0),
                      splashColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0)),
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
                      children: <Widget>[
                        Text(
                          'Last export:',
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          lastSyncDate ??
                              settingsList[1] ??
                              settingsList[1]['lastSyncDate'] ??
                              settings.lastSyncDate,
                          style: TextStyle(color: statusColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: MaterialButton(
                      disabledColor: Colors.grey,
                      onPressed: isLogIn
                          ? () {
                              syncNotes();
                            }
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 25.0, right: 25.0, top: 5.0, bottom: 5.0),
                        child: Text(
                          'Export',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      color: Colors.blue,
                      padding: EdgeInsets.all(8.0),
                      splashColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0)),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: MaterialButton(
                  onPressed: () {
//LoginPage();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LogInPage("Log in")),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 40.0, right: 40.0, top: 5.0, bottom: 5.0),
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
                  padding: EdgeInsets.all(8.0),
                  splashColor: Colors.blueAccent,
                  shape: isLogIn
                      ? RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side: BorderSide(color: Colors.blue, width: 2.0))
                      : RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0)),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(20.0),
              //   child: MaterialButton(
              //     onPressed: () {
              //       helper.deleteAll();
              //     },
              //     child: Padding(
              //       padding: const EdgeInsets.only(
              //           left: 40.0, right: 40.0, top: 5.0, bottom: 5.0),
              //       child: Text(
              //         'Delete all notes',
              //         style: Theme.of(context).textTheme.headline6,
              //       ),
              //     ),
              //     color: Colors.blue,
              //     padding: EdgeInsets.all(8.0),
              //     splashColor: Colors.blueAccent,
              //     shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(25.0)),
              //   ),
              // ),
            ],
          ),
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  //TODO: Export notes to Azure - done

  exportToAzure() async {
    try {
      String path = await getDatabasesPath();
      String fileName = '$path/notes.db';
      List contentList = await helper.getNoteMapList();
      String content = contentList.join();
      String container = 'notter-project';
      var storage = AzureStorage.parse(
          'DefaultEndpointsProtocol=https;AccountName=notterprojectuser;AccountKey=ugCVzp4ihOOjoHtZzv9OhYbWpaeLl2Vv3hJ5Vt1y12e0I2NAxIQsSXelVE45Rm13UkwwKHJKT+9dIyh1TCYTHA==;EndpointSuffix=core.windows.net');

      await storage.putBlob(
        '/$container/$fileName',
        // '/$container/$user/$fileName',
        body: content,
      );
      setState(() {
        // settingsHelper.lastSyncDate =
        //     DateFormat.yMMMd().format(DateTime.now()) +
        //         ' ' +
        //         DateFormat.jms().format(DateTime.now());
        // if (settings.id != null) {
        //   await settingsHelper.updateSettings(settings);
        // } else {
        //   await settingsHelper.insertSetiings(settings);
        // }
        lastSyncDate = DateFormat.yMMMd().format(DateTime.now()) +
            '\n' +
            DateFormat.jms().format(DateTime.now());
        statusColor = Colors.green[600];
      });
      // print('---------Export----------\n' + content);
    } on AzureStorageException catch (ex) {
      setState(() {
        lastSyncDate = 'Azure Storage Exception';
        statusColor = Colors.red;
      });
      print(ex.message);
    } catch (err) {
      setState(() {
        lastSyncDate = 'Unknown Error';
        statusColor = Colors.red;
      });
      print(err);
    }
  }

  // TODO - restore from Azure - not working

  restoreFromAzure() async {
    try {
      String container = 'notter-project';

      var httpClient = http.Client();
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://notterprojectuser.blob.core.windows.net/$container/$user//data/user/0/com.example.note_app_cdv/databases/notes.db'));
      var response = await httpClient.send(request);
      var body = await response.stream.bytesToString();
      List<String> str = body
          .replaceAll("}{", ";")
          .replaceAll("{", "")
          .replaceAll("}", "")
          .split(",");
      // Note note = Note.fromJson(jsonDecode(body));
      // print(note.toMap());
      print(str);
      // print(note);
      // await helper.deleteAll();
      // for (int i = 0; i < contentList.length; i++) {
      //   // await helper.insertNote(contentList[i]);
      //   print(contentList[i]);
      // }
      setState(() {
        var restoreStateDB = DateFormat.yMMMd().format(DateTime.now()) +
            '\n' +
            DateFormat.jms().format(DateTime.now());
        // settingsHelper.restoreDate = restoreStateDB;
        restoreDate = restoreStateDB;
        // if (settings.id != null) {
        //   await settingsHelper.updateSettings(settings);
        // } else {
        //   await settingsHelper.insertSetiings(settings);
        // }
        restoreColor = Colors.green[600];
      });
      restoreColor = Colors.green[600];
    } on AzureStorageException catch (ex) {
      setState(() {
        restoreDate = 'Azure Storage Exception';
        restoreColor = Colors.red;
      });
      print(ex.message);
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
          this.settingsList = settingsList;
        });
      });
    });
    print(settingsList);
  }

  void _saveSettings() async {
    try {
      if (settings.id != null) {
        await settingsHelper.updateSettings(settings);
      } else {
        await settingsHelper.insertSetiings(settings);
      }
    } catch (e) {
      print(e);
    }
    moveToLastScreen();
  }

  void syncNotes() {
    exportToAzure();
  }
}
