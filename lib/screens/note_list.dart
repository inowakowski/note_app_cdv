import 'dart:async';
import 'dart:convert';
// import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:notes_app/db_helper/db_helper.dart';
import 'package:notes_app/db_helper/db_settings.dart';
import 'package:notes_app/modal_class/notes.dart';
import 'package:notes_app/modal_class/settings.dart';
import 'package:notes_app/screens/note_detail.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notes_app/screens/search_note.dart';
import 'package:notes_app/utils/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:notes_app/screens/settings_page.dart';

class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  SettingsDB settingsHelper = SettingsDB();

  List<Note> noteList;
  List<Settings> settingsList;
  int countSettings = 0;
  int count = 0;
  int axisCount = 2;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = [];
      updateListView();
      updateSettingsView();
    }
    test();

    if (settingsList == null) {
      settingsList = [];
    }
    // settingsHelper.deleteAllSetiings();
    databaseHelper.getNoteMapList();
    databaseHelper.getNoteList();

    settingsHelper.getSettingsMapList();
    settingsHelper.getSettingsList();
    print('imgf20 settingsList : ' + settingsList.toString());

    final brightness = Theme.of(context).brightness;
    bool isDarkMode = brightness == Brightness.dark;

    Widget myAppBar() {
      return AppBar(
        title: Text(
          'Notter',
          style: Theme.of(context).textTheme.headline5,
        ),
        centerTitle: true,
        elevation: 0,
        // backgroundColor: Colors.white,
        leading: noteList.length == 0
            ? Container()
            : IconButton(
                icon: Icon(
                  Icons.search,
                ),
                onPressed: () async {
                  final Note result = await showSearch(
                      context: context, delegate: NotesSearch(notes: noteList));
                  if (result != null) {
                    navigateToDetail(result, 'Edit Note');
                  }
                },
              ),
        actions: <Widget>[
          noteList.length == 0
              ? Container()
              : IconButton(
                  icon: Icon(
                    axisCount == 2 ? Icons.list : Icons.grid_on,
                  ),
                  onPressed: () {
                    setState(() {
                      axisCount = axisCount == 2 ? 4 : 2;
                    });
                  },
                ),
          IconButton(
            icon: Icon(
              Icons.settings,
            ),
            onPressed: () {
              settingsList.length == 0
                  ? navigateToSettings(Settings('', '', ''), 'Settings')
                  : navigateToSettings(settingsList[0], 'Settings');
            },
          ),
        ],
      );
    }

    return Scaffold(
      appBar: myAppBar(),
      body: noteList.length == 0
          ? Container(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Click on the add button to add a new note!',
                      style: Theme.of(context).textTheme.bodyText2),
                ),
              ),
            )
          : Container(
              child: getNotesList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Note('', '', 0, ''), 'Add Note');
        },
        tooltip: 'Add Note',
        child: Icon(
          Icons.add,
          color: isDarkMode ? Colors.black : Colors.white,
        ),
        backgroundColor: isDarkMode ? Colors.grey[200] : Colors.grey[700],
      ),
    );
  }

  Widget getNotesList() {
    final brightness = Theme.of(context).brightness;
    bool isDarkMode = brightness == Brightness.dark;

    return StaggeredGridView.countBuilder(
      physics: BouncingScrollPhysics(),
      crossAxisCount: 4,
      itemCount: count,
      itemBuilder: (BuildContext context, int index) => GestureDetector(
        onTap: () {
          navigateToDetail(this.noteList[index], 'Edit Note');
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            // padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                color: isDarkMode
                    ? colorsDark[this.noteList[index].color]
                    : colors[this.noteList[index].color],
                border: Border.all(width: 1, color: Colors.grey),
                borderRadius: BorderRadius.circular(10.0)),
            child: Column(
              children: <Widget>[
                _getImage(index),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          this.noteList[index].title,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                            this.noteList[index].description == null
                                ? ''
                                : this
                                    .noteList[index]
                                    .description
                                    .replaceAll('/', '\n'),
                            style: Theme.of(context).textTheme.bodyText1),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      staggeredTileBuilder: (int index) => StaggeredTile.fit(axisCount),
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
    );
  }

  Widget _getImage(int index) {
    if (this.noteList[index].image != '') {
      return ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
          child: Image.memory(
            base64Decode(this.noteList[index].image),
          ));
    } else {
      return Container();
    }
  }

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => NoteDetail(note, title)));

    if (result == true) {
      updateListView();
    }
  }

  void navigateToSettings(Settings settings, String title) async {
    bool result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => SettingsPage(settings, title)));

    if (result == true) {
      updateListView();
      updateSettingsView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }

  void updateSettingsView() {
    final Future<Database> dbFuture = settingsHelper.initializeDatabase();
    dbFuture.then((database) {
      final Future<List<Settings>> settingsListFuture =
          settingsHelper.getSettingsList();
      settingsListFuture.then((settingsLists) {
        setState(() {
          this.settingsList = settingsLists;
          this.countSettings = settingsLists.length;
        });
        print('imgf length: ${settingsLists.length}');
      });
    });
  }

  void test() {
    final Future<Database> dbFuture = settingsHelper.initializeDatabase();
    dbFuture.then((database) {
      final Future<Settings> settingsFuture = settingsHelper.getSettings();
      settingsFuture.then((settings) {
        print('imgf settings: ${settings.toString()}');
      });
    });
  }
}
