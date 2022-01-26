import 'dart:io';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class FirebaseHelper {
  // String noteTable = 'note_table';
  // String colId = 'id';
  // String colTitle = 'title';
  // String colDescription = 'description';
  // String colImage = 'image';
  // String colColor = 'color';
  // String colDate = 'date';

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  firebase_storage.Reference ref =
      firebase_storage.FirebaseStorage.instance.ref('/notes.db');

  Future<void> uploadExample() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = '${appDocDir.absolute}/notes.db';
    await uploadFile(filePath);
  }

  Future<void> uploadFile(String filePath) async {
    File file = File(filePath);

    try {
      await firebase_storage.FirebaseStorage.instance
          .ref('uploads/notes.db')
          .putFile(file);
    } on firebase_core.FirebaseException catch (e) {
      print('upload error' + e.toString());
    }
  }

  Future<void> downloadFileExample() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    File downloadToFile = File('${appDocDir.path}/notes.db');

    try {
      await firebase_storage.FirebaseStorage.instance
          .ref('uploads/notes.db')
          .writeToFile(downloadToFile);
    } on firebase_core.FirebaseException catch (e) {
      print('download error' + e.toString());
    }
  }
}
