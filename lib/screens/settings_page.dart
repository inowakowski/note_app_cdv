import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/db_helper/db_helper.dart';
import 'package:azblob/azblob.dart';
import 'package:sqflite/sqflite.dart';
import 'package:notes_app/modal_class/settings.dart';

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
  var user = 'user0';
  SettingsPageState(this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    if (settingsList == null) {
      settingsList = ['Not restored', 'Not synced'];
      updateSettingsView();
    }
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
          body: Column(
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
                          settingsList[0] ??
                              restoreDate ??
                              settingsList[0]['restoreDate'] ??
                              settings.restoreDate,
                          style: TextStyle(color: restoreColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: MaterialButton(
                      onPressed: () {
                        restoreFromAzure();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 8.0, left: 20.0, right: 20.0),
                        child: Text(
                          'Restore',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      color: Colors.blue,
                      textColor: Colors.white,
                      padding: EdgeInsets.all(8.0),
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
                      children: <Widget>[
                        Text(
                          'Last export:',
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          settingsList[1] ??
                              lastSyncDate ??
                              settingsList[1]['lastSyncDate'] ??
                              settings.lastSyncDate,
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
                        syncNotes();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Export',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      color: Colors.blue,
                      textColor: Colors.white,
                      padding: EdgeInsets.all(12.0),
                      splashColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(300.0)),
                    ),
                  ),
                ],
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
        '/$container/$fileName',
        body: content,
      );
      setState(() async {
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
            ' ' +
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

  // TODO - restore from Azure - not working

  restoreFromAzure() async {
    try {
      String container = 'notter-project';
      var storage = AzureStorage.parse(
          'DefaultEndpointsProtocol=https;AccountName=notterprojectuser;AccountKey=ugCVzp4ihOOjoHtZzv9OhYbWpaeLl2Vv3hJ5Vt1y12e0I2NAxIQsSXelVE45Rm13UkwwKHJKT+9dIyh1TCYTHA==;EndpointSuffix=core.windows.net');
      var body = storage.getBlob(
        '/$container/notes.db',
      );

      print('------------------');
      print('------------------');
      print(body);
      print('------------------');
      setState(() async {
        // var restoreStateDB = DateFormat.yMMMd().format(DateTime.now()) +
        //     ' ' +
        //     DateFormat.jms().format(DateTime.now());
        // settingsHelper.restoreDate = restoreStateDB;
        // restoreDate = restoreStateDB;
        // if (settings.id != null) {
        //   await settingsHelper.updateSettings(settings);
        // } else {
        //   await settingsHelper.insertSetiings(settings);
        // }
        statusColor = Colors.green[600];
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
