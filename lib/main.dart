import 'package:flutter/material.dart';
import 'package:notes_app/screens/note_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoteKeeper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // primarySwatch: Colors.white,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Colors.black),
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            actionsIconTheme: IconThemeData(color: Colors.black),
            iconTheme: IconThemeData(color: Colors.black)),
        textTheme: TextTheme(
          headline5: TextStyle(color: Colors.black, fontSize: 24),
          bodyText2: TextStyle(color: Colors.black, fontSize: 20),
          bodyText1: TextStyle(color: Colors.black, fontSize: 18),
          subtitle2: TextStyle(color: Colors.black, fontSize: 14),
          subtitle1: TextStyle(color: Colors.black, fontSize: 12),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.grey,
        iconTheme: IconThemeData(color: Colors.white),
        colorScheme: ColorScheme.dark(
          primary: Colors.grey[900],
          secondary: Colors.grey[900],
          surface: Colors.grey[900],
          background: Colors.grey[900],
          error: Colors.grey[900],
          onBackground: Colors.grey[900],
          onError: Colors.grey[900],
          onPrimary: Colors.grey[900],
          onSecondary: Colors.grey[900],
          onSurface: Colors.grey[900],
          secondaryVariant: Colors.grey[900],
          brightness: Brightness.dark,
        ),
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey[850],
            actionsIconTheme: IconThemeData(color: Colors.white),
            iconTheme: IconThemeData(color: Colors.white)),
        textTheme: TextTheme(
          headline5: TextStyle(color: Colors.white, fontSize: 24),
          bodyText2: TextStyle(color: Colors.white, fontSize: 20),
          bodyText1: TextStyle(color: Colors.white, fontSize: 18),
          subtitle2: TextStyle(color: Colors.white, fontSize: 14),
          subtitle1: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      // debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      home: NoteList(),
    );
  }
}
