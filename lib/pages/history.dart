import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HistoryStorage {
  final HistoryStorage caller;
  HistoryStorage(this.caller);

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

      // Read the file
      String contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<File> writeFile(double val) async {
    final file = await _localFile;

    // Write the file
    debugPrint('writing value: $val');
    return file.writeAsString('$val');
  }
}

class HistoryPage extends StatefulWidget {
  final HistoryStorage storage;

  HistoryPage({Key key, @required this.storage}) : super(key: key);

  @override
  _HistoryPage createState() => _HistoryPage();
}

class _HistoryPage extends State<HistoryPage> {
  int _historical;

  @override
  void initState() {
    super.initState();
    widget.storage.readFile().then((int value) {
      setState(() {
        _historical = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historical Data')),
      body: new Container(
        padding: new EdgeInsets.all(32.0),
        child: Text('Pressure reading on previous run was ${_historical}',),
      )
    );
  }
}