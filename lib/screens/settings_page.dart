import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/db_helper/db_helper.dart';
import 'package:azblob/azblob.dart';
import 'package:notes_app/screens/login_page.dart';
import 'package:notes_app/screens/note_list.dart';
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
  List settingsList;
  Settings settings;
  String lastSyncDate;
  String restoreDate;
  Color statusColor;
  Color restoreColor;
  var user = 'user0';
  SettingsPageState(this.appBarTitle);
  var isLogIn = true;

  @override
  Widget build(BuildContext context) {
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Last restore:',
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          restoreDate ?? 'Not restored',
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
                        isLogIn ? restoreFromAzure('') : null;
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
                          lastSyncDate ?? 'Not synced',
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
                        isLogIn ? syncNotes() : null;
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
                    logInAction(context);
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
        '/$container/user0/$fileName',
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

  HttpClient httpClient = new HttpClient();
  // Future<F

  // TODO - restore from Azure - not working

  restoreFromAzure(String username) async {
    try {
      String container = 'notter-project';
      Uri url = Uri.parse(
          'https://notterprojectuser.blob.core.windows.net/$container$username//data/user/0/com.example.note_app_cdv/databases/notes.db');

      http.Response response = await http.get(url);
      String content = response.body;
      print('Dwl Content: $content');
      String replace = content
          .replaceAll('}{', ';')
          .replaceAllMapped(RegExp(r'\{|\}'), (Match m) => '');
      print('Dwl Replace: ' + replace);
      List<String> contentList = replace.split(';');
      print('Dwl ContentList: $contentList');

      for (int i = 0; i < contentList.length; i++) {
        List<String> json = contentList[i].split(',');

        Note note = Note.fromMapObject(json);

        await helper.updateNote(note);
        for (int j = 0; j < json.length; j++) {
          print('Dwl Json[$j]: ${json[j]}');
        }
      }
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
      print('Dwl Restore Success');
    } on HttpException catch (ex) {
      setState(() {
        restoreDate = 'Http Exception';
        restoreColor = Colors.red;
      });
      print('Dwl Restore error http:' + ex.message.toString());
    } catch (err) {
      setState(() {
        restoreDate = 'Unknown Error';
        restoreColor = Colors.red;
      });
      print('Dwl Restore error: ' + err.toString());
    }
  }

  // void updateSettingsView() {
  //   final Future<Database> dbFuture = settingsHelper.initializeDatabase();
  //   dbFuture.then((database) {
  //     Future<List<Settings>> settingsListFuture = settingsHelper.getSettings();
  //     settingsListFuture.then((settingsList) {
  //       setState(() {
  //         this.settingsList = settingsList;
  //       });
  //     });
  //   });
  //   print(settingsList);
  // }

  // void _saveSettings() async {
  //   try {
  //     if (settings.id != null) {
  //       await settingsHelper.updateSettings(settings);
  //     } else {
  //       await settingsHelper.insertSetiings(settings);
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  //   moveToLastScreen();
  // }

  void syncNotes() {
    exportToAzure();
  }
}

void logInAction(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => LogInPage('Log in'),
    ),
  );
}
