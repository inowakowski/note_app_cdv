import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/db_helper/db_helper.dart';
import 'package:notes_app/modal_class/notes.dart';
import 'package:notes_app/utils/widgets.dart';

class SettingsPage extends StatefulWidget {
  final String appBarTitle;

  SettingsPage(this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return SettingsPageState(this.appBarTitle);
  }
}

class SettingsPageState extends State<SettingsPage> {
  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;

  SettingsPageState(this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
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
                icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () {}),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.save,
                  color: Colors.black,
                ),
                onPressed: () {
                  // titleController.text.length == 0
                  //     ? showEmptyTitleDialog(context)
                  //     : _save();
                },
              ),
              // IconButton(
              //   icon: Icon(
              //     Icons.close,
              //     color: Colors.black,
              //   ),
              //   onPressed: () {
              //     showDeleteDialog(context);
              //   },
              // )
            ],
          ),
          body: Container(
            child: Column(
              children: <Widget>[
                PriorityPicker(
                  onTap: (index) {},
                ),
                ColorPicker(
                  onTap: (index) {
                    setState(() {});
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextField(
                    maxLength: 255,
                    style: Theme.of(context).textTheme.bodyText2,
                    // onChanged: () async {},
                    decoration: InputDecoration.collapsed(
                      hintText: 'Title',
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 10,
                      maxLength: 255,
                      style: Theme.of(context).textTheme.bodyText1,
                      // onChanged: () {},
                      decoration: InputDecoration.collapsed(
                        hintText: 'Description',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
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
}
