import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
//import './sequence.dart';

//Sequencing _sequence = Sequencing.off;

//Default page: device selection
//Sequence: sequence select & pressure settings
//History: historical data information

void main() => runApp(MyApp());

//TItle and default theme for app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Circu-Air',
      theme: ThemeData(primarySwatch: Colors.cyan),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Devices'),
        ),
        body: Center(
          child: Text('Welcome to Circu-Air!'),
        ),
      ),
    );
  }
} 
