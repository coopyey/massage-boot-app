import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPage createState() => _HistoryPage();
}

class _HistoryPage extends State<HistoryPage> {
  @override 
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar (title: new Text('Historical Data'),),
      body: new Container(
        //padding: new EdgeInserts.all(32.0),
        child: new Center(
          child: new Column(
            children: <Widget>[ 
              const Text('Hello friendo'),
            ],
          ),
        ),
      ),
    );
  } // Widget build
} // Class _HistoryPage