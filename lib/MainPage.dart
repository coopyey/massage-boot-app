import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:convert';

import './DiscoveryPage.dart';

enum Sequencing {off, low, medium, high}  // Enumerator for sequence/state

class MainPage extends StatefulWidget {
  final HistoryStorage storage;
  MainPage({Key key, @required this.storage}) : super(key: key);

  @override
  _MainPage createState() => new _MainPage();
}

class HistoryStorage {                  // For persistent logs
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


class _MainPage extends State<MainPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;            // Initialize btState

  String _address = "...";
  String _name = "...";

  Sequencing _sequence = Sequencing.off; //Starts off by default
  Sequencing _historical; //Data loaded from file
  double _setrate = 0;
  int _bootpressure = 0; //Pressure readout starts                      (To later implement custom
  int _setpressure = 0; //Pressure sent to boot starts 0 by default       pressure levels I assume)

  Timer _discoverableTimeoutTimer;                    // Come back to this, idk what it is
  int _discoverableTimeoutSecondsLeft = 0;

  @override
  void initState() {
    super.initState();

    widget.storage.readFile().then((int value) {      // Load custom default or historical pressure setting from file
      setState(() {
        if (value == 0) {
          _historical = Sequencing.off;
        } else if (value == 1) {
          _historical = Sequencing.low;
        } else if (value == 2) {
          _historical = Sequencing.medium;
        } else if (value == 3) {
          _historical = Sequencing.high;
        }
      });
    });
    
    // Get current state

    FlutterBluetoothSerial.instance.state.then((state) {        // Checks the phone's bt adapter state
      setState(() { _bluetoothState = state; });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() { _address = address; });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() { _name = name; });
    });
    
    // Listen for futher state changes
    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  Future<File> _updateFile(int val) {
    return widget.storage.writeFile(val);
  } 

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  BluetoothConnection connection;
  bool get isConnected => connection != null && connection.isConnected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CircuAir'),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: RaisedButton(      //Discover Devices button
                child: const Text('Discover Bluetooth Devices'),
                onPressed: () async {
                  final BluetoothDevice selectedDevice = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) { return DiscoveryPage(); })
                  );

                  if (selectedDevice != null) {
                    print('Discovery -> selected ' + selectedDevice.address);
                    BluetoothConnection.toAddress(selectedDevice.address).then((_connection) {      // Attaches 'connection' to the actual device...i think.
                      connection = _connection;                                                     // Doesnt matter, sending data at least.
                    });
                  }
                  else {
                    print('Discovery -> no device selected');
                  }
                }
              ),
            ),
            Divider(),
            new Container(
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
                                connection.output.add(utf8.encode("offPos\r\n"));
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
                                connection.output.add(utf8.encode("seq1\r\n"));
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
                                connection.output.add(utf8.encode("seq2\r\n"));
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
                                connection.output.add(utf8.encode("seq3\r\n"));
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
            ),
          ], // body          ],
        ),
      ),
    );
  }
}
