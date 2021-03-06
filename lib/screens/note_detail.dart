// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/db_helper/db_helper.dart';
import 'package:notes_app/modal_class/notes.dart';
import 'package:notes_app/utils/widgets.dart';
import 'package:image_picker/image_picker.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Note note;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  int color;
  bool isEdited = false;
  List<Note> noteList;

  NoteDetailState(this.note, this.appBarTitle);

  String get date => null;

  String b64Image = '';

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    bool isDarkMode = brightness == Brightness.dark;

    if (note.image != '') {
      setState(() {
        this.b64Image = note.image;
      });
    }

    titleController.text = note.title;
    descriptionController.text = note.description;
    color = note.color;
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
            backgroundColor: isDarkMode ? colorsDark[color] : colors[color],
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                ),
                onPressed: () {
                  isEdited ? showDiscardDialog(context) : moveToLastScreen();
                }),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.save_outlined,
                ),
                onPressed: () {
                  titleController.text.length == 0
                      ? showEmptyTitleDialog(context)
                      : _save();
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  // color: Colors.black,
                ),
                onPressed: () {
                  showDeleteDialog(context);
                },
              )
            ],
          ),
          body: Container(
            color: isDarkMode ? colorsDark[color] : colors[color],
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      _getImage(),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: TextField(
                          controller: titleController,
                          style: Theme.of(context).textTheme.bodyText2,
                          onChanged: (value) {
                            updateTitle();
                          },
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
                            maxLines: 20,
                            controller: descriptionController,
                            style: Theme.of(context).textTheme.bodyText1,
                            onChanged: (value) {
                              updateDescription();
                            },
                            decoration: InputDecoration.collapsed(
                              hintText: 'Description',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: isDarkMode ? colorsDark[color] : colors[color],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.add_photo_alternate_outlined,
                            ),
                            onPressed: () => pickImageNote(ImageSource.gallery),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.camera_alt_outlined,
                            ),
                            onPressed: () => pickImageNote(ImageSource.camera),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.color_lens_outlined,
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 10.0,
                                            top: 10.0,
                                            left: 10.0),
                                        child: ColorPicker(
                                          selectedIndex: note.color,
                                          onTap: (index) {
                                            setState(() {
                                              color = index;
                                            });
                                            isEdited = true;
                                            note.color = index;
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 20.0,
                                          top: 10.0,
                                        ),
                                        child: Text(
                                          'Select Color',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          this.note.date,
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                      ),
                    ],
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
                style: Theme.of(context).textTheme.bodyText2,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                "Yes",
                style: Theme.of(context).textTheme.bodyText2,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                moveToLastScreen();
              },
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
                style: Theme.of(context).textTheme.bodyText2,
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
                _delete();
              },
            ),
          ],
        );
      },
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void updateTitle() {
    isEdited = true;
    note.title = titleController.text;
  }

  void updateDescription() {
    isEdited = true;
    note.description = descriptionController.text;
  }

  // Save data to database
  void _save() async {
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now()) +
        ' ' +
        DateFormat.jms().format(DateTime.now());
    if (this.b64Image != null) {
      note.image = this.b64Image;
    } else {
      note.image = '';
    }

    if (note.id != null) {
      await helper.updateNote(note);
    } else {
      await helper.insertNote(note);
    }
  }

  void _delete() async {
    await helper.deleteNote(note.id);
    moveToLastScreen();
  }

  Future pickImageNote(ImageSource source) async {
    try {
      var image = await ImagePicker.platform.getImage(
        source: source,
      );
      if (image == null) return;
      File imageFile = File(image.path);
      final base64 = base64UrlEncode(imageFile.readAsBytesSync());
      setState(() {
        this.b64Image = base64;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Widget _getImage() {
    if (note.image != '') {
      return Image.memory(
        base64Decode(note.image),
        fit: BoxFit.cover,
      );
    } else if (this.b64Image != '') {
      return Image.memory(
        base64Decode(this.b64Image),
        fit: BoxFit.cover,
      );
    } else {
      return Container();
    }
  }
}
