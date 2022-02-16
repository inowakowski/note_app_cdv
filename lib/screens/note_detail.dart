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
import 'package:path_provider/path_provider.dart';

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

  File image;
  String b64Image;

  Widget _buildImage(BuildContext context) {
    return new FutureBuilder(
      future: convertBase64ToImage(b64Image),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container(); // or some other placeholder
        return new Image.file(snapshot.data);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('IMGF note: ${note.image}');

    if (note.image != '') {
      // _buildImage();
    }

    final brightness = Theme.of(context).brightness;
    bool isDarkMode = brightness == Brightness.dark;

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
                      if (image == null)
                        Container()
                      else
                        // _buildImage(context),
                        Image.file(
                          this.image,
                          fit: BoxFit.cover,
                        ),
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
                            onPressed: () => pickImageNote(),
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
    if (this.image != null) {
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

  Future pickImageNote() async {
    try {
      var image = await ImagePicker.platform.getImage(
        source: ImageSource.gallery,
      );
      if (image == null) return;
      final base64 = await convertImageToBase64(image.path);
      final imageFile = await convertBase64ToImage(base64);
      setState(() {
        this.image = imageFile;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  // Future<File> saveImage(String imagePath) async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final name = path.basename(imagePath);
  //   final image = File('${directory.path}/$name');
  //   print(File(imagePath).copy(image.path));
  //   return File(imagePath).copy(image.path);
  // }

  Future convertImageToBase64(String imagePath) async {
    File file = File(imagePath);
    // this.fileName = file.path.split('/').last;
    String base64Image = base64UrlEncode(file.readAsBytesSync());
    return base64Image;
  }

  Future convertBase64ToImage(String base64Image) async {
    var dateTime = DateTime.now().hashCode.toString(); //image_$dateTime
    File file = File(
        '${(await getApplicationDocumentsDirectory()).path}/image_$dateTime.jpg');
    print('IMGF file B2I: $file');
    file.writeAsBytesSync(base64Decode(base64Image));
    return File(file.path);
  }
}
