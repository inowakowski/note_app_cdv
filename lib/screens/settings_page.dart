import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/db_helper/db_helper.dart';
import 'package:path_provider/path_provider.dart';

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
  bool _value;
  String lastSyncDate;
  SettingsPageState(this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          isEdited ? showDiscardDialog(context) : moveToLastScreen();
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
                  isEdited ? showDiscardDialog(context) : moveToLastScreen();
                }),
          ),
          body: Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                      'Export your notes to a text file. Click the button below to backup or restore your notes.'),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      MaterialButton(
                        onPressed: () {
                          exportToFile();
                        },
                        child: Text(
                          'Export',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        color: Colors.blue,
                        textColor: Colors.white,
                        padding: EdgeInsets.all(12.0),
                        splashColor: Colors.blueAccent,
                      ),
                      MaterialButton(
                        onPressed: () {
                          // importFromFile();
                          importNotes();
                        },
                        child: Text(
                          'Restore',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        color: Colors.blue,
                        textColor: Colors.white,
                        padding: EdgeInsets.all(12.0),
                        splashColor: Colors.blueAccent,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'You can sync your notes with the cloud. Click the button below to sync your notes with the cloud.',
                  ),
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Sync with the cloud'),
                          Switch.adaptive(
                            value: _value,
                            onChanged: (newValue) =>
                                setState(() => _value = newValue),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                'last sync: ',
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                              Text(
                                lastSyncDate ?? '',
                                // '${DateFormat.yMMMd().format(DateTime.now())} ' +
                                // '${DateFormat.jms().format(DateTime.now())}',
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: MaterialButton(
                            onPressed: () {
                              syncNotes();
                            },
                            child: Text(
                              'Sync',
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            color: Colors.blue,
                            textColor: Colors.white,
                            padding: EdgeInsets.all(12.0),
                            splashColor: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void importNotes() {
    Navigator.pop(context, true);
  }

  void showDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
            "Discard Changes?",
            style: Theme.of(context).textTheme.bodyText2,
          ),
          content: Text("Are you sure you want to discard changes?",
              style: Theme.of(context).textTheme.bodyText1),
          actions: <Widget>[
            TextButton(
              child: Text(
                "No",
              ),
              onPressed: () {},
            ),
            TextButton(
              child: Text(
                "Yes",
              ),
              onPressed: () {},
            ),
          ],
        );
      },
    );
  }

  void showEmptyTitleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
            "Title is empty!",
            style: Theme.of(context).textTheme.bodyText2,
          ),
          content: Text('The title of the note cannot be empty.',
              style: Theme.of(context).textTheme.bodyText1),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Okay",
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
            "Delete Note?",
            style: Theme.of(context).textTheme.bodyText2,
          ),
          content: Text("Are you sure you want to delete this note?",
              style: Theme.of(context).textTheme.bodyText1),
          actions: <Widget>[
            TextButton(
              child: Text(
                "No",
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Yes",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(color: Colors.purple)),
              onPressed: () {},
            ),
          ],
        );
      },
    );
  }

  Future<void> exportToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/notes.txt');
    await file.writeAsString('');
  }

  void importFromFile() {}

  void syncNotes() {
    setState(() {
      lastSyncDate = DateFormat.yMMMd().format(DateTime.now()) +
          ' ' +
          DateFormat.jms().format(DateTime.now());
    });
  }
}
