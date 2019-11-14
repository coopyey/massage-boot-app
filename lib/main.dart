import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import './pages/bluetooth.dart';

void main() => runApp(MyApp());

//Title and default theme for app
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "CircuAir",
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.cyan,
        textTheme: TextTheme (
          body1: TextStyle(fontSize: 20.0),
          title: TextStyle(color: Colors.black),
        ),
      ),
      home: SequenceSelection(storage: HistoryStorage(),
    ),);
  }
}

// Radio button state enum
enum Sequencing {off, low, medium, high}

// File control stuff
class HistoryStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/history.txt');
  }

  Future<int> readFile() async {
    try {
      final file = await _localFile;

      String contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {

      return 0;
    }
  }

  Future<File> writeFile(int val) async {
    final file = await _localFile;

    debugPrint('writing value: $val');
    return file.writeAsString('$val');
  }
}

class SequenceSelection extends StatefulWidget {
  final HistoryStorage storage;
  SequenceSelection({Key key, @required this.storage}) : super(key: key);
  
  @override
  _SequenceSelection createState() => new _SequenceSelection();
}

class _SequenceSelection extends State<SequenceSelection> {
  Sequencing _sequence = Sequencing.off; //Starts off by default
  double _setrate = 0; //Heartrate value (unused)

  Sequencing _historical; //Data loaded from file
  int _bootpressure = 0; //Pressure readout starts
  int _setpressure = 0; //Pressure sent to boot starts 0 by default

  @override 
  void initState() {
    super.initState();
    widget.storage.readFile().then((int value) {
      setState(() {
        if (value == 1) {
          _historical = Sequencing.low;
        } else if (value ==2) {
          _historical = Sequencing.medium;
        } else if (value == 3) {
          _historical = Sequencing.high;
        }
      });
    });
  }

  // Accessing the write function
  Future<File> _updateFile(int val) {
    return widget.storage.writeFile(val);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar (title: new Text('Sequence Selection and Settings'),),
      // NAVIGATION TO BLUETOOTH PAGE -------------------------------------------------------------
      drawer: new Drawer(
        child: ListView(
          children: <Widget>[
            new ListTile(
              title: new Text('Bluetooth', style: TextStyle(fontSize: 20.0)),
              onTap: () {
                Navigator.push(context, new MaterialPageRoute(
                  builder: (BuildContext context) => new Bluetooth())
                );
              },
            ),
          ],
        ),
      ),
      body: new Container(
        padding: new EdgeInsets.all(32.0),
        child: new Center(
          child: new Column( 
            children: <Widget>[ 
              // BLOCK FOR CONTROLLING PRESSURE ---------------------------------------------------
              const Text('Power', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              new Text('Previous run used ${_historical.toString().substring(_historical.toString().indexOf('.')+1)} setting.\n'),
              new Row( 
                children: <Widget>[
                  new Flexible(
                      child: new RadioListTile<Sequencing> (
                      title: const Text('Off'),
                      value: Sequencing.off,
                      groupValue: _sequence,
                      onChanged: (Sequencing value) {
                        setState(() {
                          _sequence = value;
                          //bluetooth control to send off signal should go here
                        });
                      },
                    ), // Off
                  ),
                  new Flexible(
                      child: new RadioListTile<Sequencing> (
                      title: const Text('Low'),
                      value: Sequencing.low,
                      groupValue: _sequence,
                      onChanged: (Sequencing value) {
                        setState(() {
                          _sequence = value;
                          _setpressure = value.index;
                          _updateFile(value.index);
                          //bluetooth control to send on signal should go here
                        }); 
                      }, 
                    ), // Low
                  ),
                ],
              ),
              new Row(
                children: <Widget>[
                      new Flexible(
                      child: new RadioListTile<Sequencing> (
                      title: const Text('Medium'),
                      value: Sequencing.medium,
                      groupValue: _sequence,
                      onChanged: (Sequencing value) {
                        setState(() {
                          _sequence = value;
                          _setpressure = value.index;
                          _updateFile(value.index);
                          //bluetooth control to send on signal should go here
                        }); 
                      },
                    ),
                  ), // Medium
                  new Flexible(
                      child: new RadioListTile<Sequencing> (
                      title: const Text('High'),
                      value: Sequencing.high,
                      groupValue: _sequence,
                      onChanged: (Sequencing value) {
                        setState(() {
                          _sequence = value;
                          _setpressure = value.index;
                          _updateFile(value.index);
                          //bluetooth control to send on signal should go here
                        }); 
                      }, 
                    ),
                  ), // High
                ],
              ),
              //BLOCK FOR THE PRESSURE READOUT --------------------------------------------------------
              const Text('\n\nCurrrent Statistics\n', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              new Row(
                children: <Widget>[
                  new Flexible(
                    child: Text('Current Pressure:    $_setpressure\nCurrent Heart Rate:   ${_setrate.toInt()}'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ), // body
    );
  } // Widget build
} // Class _SequenceSelection