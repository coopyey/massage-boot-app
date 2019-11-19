import 'package:flutter/material.dart';

import './MainPage.dart';

void main() => runApp(new CircuAir());

class CircuAir extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.cyan,
        textTheme: TextTheme (
          body1: TextStyle(fontSize: 20.0),
          title: TextStyle(color: Colors.black),
        ),
      ),
      home: MainPage(storage: HistoryStorage(),)
    );
  }
}
