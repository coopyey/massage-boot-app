import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';

// page files
import './pages/sequence.dart'; //used to control the app
import './pages/history.dart'; //for files n such
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
      home: LandingScreen(),
    );
  }
}

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreen createState() => _LandingScreen();
}

class _LandingScreen extends State<LandingScreen> {
  int currentTab = 0;

  LandingScreen land;
  HistoryPage hist;
  Bluetooth blue;
  SequenceSelection seq;
  List<Widget> pages;
  Widget currentPage;

  HistoryStorage caller;

  @override 
  void initState() {
    hist = HistoryPage(storage: HistoryStorage(caller));
    blue = Bluetooth();
    seq = SequenceSelection();

    pages = [blue, seq, hist];

    currentPage = blue;
    super.initState();
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentPage,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentTab,
        onTap: (int index) {
          setState(() {
            currentTab = index;
            currentPage = pages[index];
          });
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.bluetooth),
            title: Text('Bluetooth'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('Boot Control'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            title: Text('Run History'),
          ),
        ],
      ),
    );
  }
}

class Data {
  final int id;
  bool expanded;
  final String title;
  Data(this.id, this.expanded, this.title);
}