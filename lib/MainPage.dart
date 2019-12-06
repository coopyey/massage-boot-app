import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:convert';
import 'dart:typed_data';

import './DiscoveryPage.dart';

enum Sequencing {off, sequence1, sequence2 , sequence3, stop}  // Enumerator for sequence/state

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

  String lastMessage = "Nothing yet!";
  double pressure1 = 0;
  double pressure2 = 0;
  double pressure3 = 0;
  int pStateI = 0;
  List<String> pStateL = ["Off", "Low", "Normal", "High"];
  int pulse = 0;

  Sequencing _sequence = Sequencing.off; //Starts off by default
  Sequencing _historical; //Data loaded from file
  double _setrate = 0;
  int _bootpressure = 0; //Pressure readout starts                      (To later implement custom
  int _setpressure = 0; //Pressure sent to boot starts 0 by default       pressure levels I assume)

  Timer _discoverableTimeoutTimer;                    // What is this?
  int _discoverableTimeoutSecondsLeft = 0;

  @override
  void initState() {
    super.initState();

    widget.storage.readFile().then((int value) {      // Load default or historical pressure setting from file
      setState(() {
        if (value == 0) {
          _historical = Sequencing.off;
        } else if (value == 1) {
          _historical = Sequencing.sequence1;
        } else if (value == 2) {
          _historical = Sequencing.sequence2;
        } else if (value == 3) {
          _historical = Sequencing.sequence3;
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

  BluetoothConnection connection;
  bool get isConnected => connection != null && connection.isConnected;


  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }


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
                    BluetoothConnection.toAddress(selectedDevice.address).then((_connection) {      // Attaches 'connection' to the actual device...i think?
                      connection = _connection;                                                     // Doesnt matter, sending data at least.
                      connection.input.listen(_onDataReceived);
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
                    new Text('Previous run used ${_historical.toString().substring(_historical.toString().indexOf('.')+1)}.\n'),
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
                            title: const Text('Sequence 1'),
                            value: Sequencing.sequence1,
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
                            title: const Text('Sequence 2'),
                            value: Sequencing.sequence2,
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
                            title: const Text('Sequence 3'),
                            value: Sequencing.sequence3,
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
                      new Row(
                      children: <Widget>[
                            new Flexible(
                            child: new RadioListTile<Sequencing> (
                            title: const Text('Stop'),
                            value: Sequencing.stop,
                            groupValue: _sequence,
                            onChanged: (Sequencing value) {
                              setState(() {
                                _sequence = value;
                                _setpressure = 0;
                                //bluetooth control to send on signal should go here
                                connection.output.add(utf8.encode("off\r\n"));
                              }); 
                            },
                          ),
                        ), // Medium // High
                      ],
                    ),
                    //BLOCK FOR THE PRESSURE READOUT --------------------------------------------------------
                    const Text('\nCurrrent Statistics\n', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                    new Row(
                      children: <Widget>[
                        new Flexible(
                          child: Text('Current Pressure:    $_setpressure\nCurrent Heart Rate:   ${_setrate.toInt()}'),
                        ),
                      ],
                    ),
                    // Adding this more for debugging than anything, totally fine with it being removed - Kevin
                    const Text('\nPressure Sensor Data\n', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        new Flexible(
                          child: Text('Pressure1: $pressure1\nPressure2: $pressure2\nPressure3: $pressure3'),
                        ),
                        new Flexible(
                          child: Text('Pressure\nState:\n${pStateL[pStateI]}'),
                        ),
                      ],
                    ),
                    // End part Kevin added
                  ],
                ),
              ),
            ),
          ], // body          ],
        ),
      ),
    );
  }


  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {           // If ASCII [BS] or [DEL]
      if (byte == 8 || byte == 127) { 
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      }
      else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        }
        else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) { // \r\n
      setState(() {
        
        String newMessage = dataString.substring(0, index);
        if (newMessage.length != 0) {
          lastMessage = newMessage;

          List<String> splitMessage = newMessage.split("*");
          print(splitMessage[0] + " " + splitMessage[1]);

          if      (splitMessage[0] == "pres1"){
            pressure1 = double.parse(splitMessage[1]);
          }
          else if (splitMessage[0] == "pres2"){
            pressure2 = double.parse(splitMessage[1]);
          }
          else if (splitMessage[0] == "pres3"){
            pressure3 = double.parse(splitMessage[1]);
          }
          else if (splitMessage[0] == "pState"){
            pStateI = double.parse(splitMessage[1]).toInt();
          }
          else if (splitMessage[0] == "pulse"){
            pulse = double.parse(splitMessage[1]).toInt();
          }
        }
        
        print(newMessage.length.toString() + " Received: " + newMessage);
      });
    }
  }
}
