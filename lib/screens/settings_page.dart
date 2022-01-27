import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/db_helper/db_helper.dart';
import 'package:azblob/azblob.dart';
import 'package:sqflite/sqflite.dart';

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

  String appBarTitle;
  bool isEdited = false;
  // bool _value;
  String lastSyncDate;
  String restoreState;
  Color statusColor;
  Color restoreColor;
  SettingsPageState(this.appBarTitle);

  @override
  Widget build(BuildContext context) {
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
                  moveToLastScreen();
                }),
          ),
          body: Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'You can sync your notes to the cloud. Click the button "Sync" to sync your notes to the cloud. If your notes are synced to the cloud, you can restore them from the cloud by clicking the "Restore" button.',
                    textAlign: TextAlign.justify,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: MaterialButton(
                    onPressed: () {},
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
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '$restoreState',
                      style: TextStyle(
                        color: restoreColor,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Last sync: ',
                          ),
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(lastSyncDate ?? '',
                                style: TextStyle(color: statusColor)),
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
                            'Sync',
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
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: MaterialButton(
                    onPressed: () {},
                    color: Colors.orange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(300.0)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, bottom: 8.0, left: 20.0, right: 20.0),
                      child: Text(
                        'Login to the cloud',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

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
      setState(() {
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

  restoreToAzure() async {
    try {
      String container = 'notter-project';
      var storage = AzureStorage.parse(
          'DefaultEndpointsProtocol=https;AccountName=notterprojectuser;AccountKey=ugCVzp4ihOOjoHtZzv9OhYbWpaeLl2Vv3hJ5Vt1y12e0I2NAxIQsSXelVE45Rm13UkwwKHJKT+9dIyh1TCYTHA==;EndpointSuffix=core.windows.net');
      await storage.getBlob(
        '/$container/notes.db',
        String body = '',
        (String body) {
          helper.insertNote (body);
        },
      );
      restoreState = 'Restored';
      restoreColor = Colors.green[600];
    } on AzureStorageException catch (ex) {
      setState(() {
        restoreState = 'Azure Storage Exception';
        restoreColor = Colors.red;
      });
      print(ex.message);
    } catch (err) {
      setState(() {
        restoreState = 'Unknown Error';
        restoreColor = Colors.red;
      });
      print(err);
    }
  }

  void syncNotes() {
    exportToAzure();
  }
}
