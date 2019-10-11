import 'package:flutter/material.dart';

enum Sequencing {off, ison}
class SequenceSelection extends StatefulWidget {
  @override
  _SequenceSelection createState() => new _SequenceSelection();
}

class _SequenceSelection extends State<SequenceSelection> {
  Sequencing _sequence = Sequencing.off; //Starts off by default
  double _bootpressure = 0; //Pressure readout starts 0 by default
  double _sliderValue = 0; //Slider value 0 by default
  double _setpressure = 0; //Pressure sent to boot starts 0 by default
  
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar (title: new Text('Sequence Selection and Settings'),),
      body: new Container(
        padding: new EdgeInsets.all(32.0),
        child: new Center(
          child: new Column( 
            children: <Widget>[ 
              // BLOCK FOR TURNING STUFF ON AND OFF ----------------------------------------------------
              const Text('Power', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              new Row( 
                children: <Widget>[
                  new Flexible(
                      child: new RadioListTile<Sequencing> (
                      title: const Text('Off'),
                      value: Sequencing.off,
                      groupValue: _sequence,
                      onChanged: (Sequencing value) => setState(() => _sequence = value),
                    ), // Off Radio
                  ),
                  new Flexible(
                      child: new RadioListTile<Sequencing> (
                      title: const Text('On'),
                      value: Sequencing.ison,
                      groupValue: _sequence,
                      onChanged: (Sequencing value) => setState(() => _sequence = value),
                    ), // On Radio
                  ),
                ],
              ),
              //BLOCK FOR THE PRESSURE READOUT --------------------------------------------------------
              const Text('\n\nCurrrent Pressure\n', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              new Row(
                children: <Widget>[
                  new Flexible(
                    child: Text('\nCurrent Pressure:    ${_setpressure.toInt()}'),
                  ),
                ],
              ),
              //BLOCK FOR THE PRESSURE SLIDER --------------------------------------------------------
              const Text('\n\nPressure Control\n', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              new Row(
                children: <Widget>[
                  new Flexible(
                    child: Slider(
                      min: 0.0,
                      max: 10.0,
                      onChanged: (_bootpressure) {
                        setState(() => _sliderValue = _bootpressure);
                        _setpressure = _bootpressure;
                      },
                      value: _sliderValue,
                    ),
                  ),
                  Container(
                    width: 50.0,
                    child: Text('${_sliderValue.toInt()}', style: Theme.of(context).textTheme.body1),
                  ),
                ],
              ),
              const Text('\nPlease note that setting the pressure to zero will result in removing all air from the boot.')

            ],
          ),
        ),
      ), // body
    );
  } // Widget build
} // Class _SequenceSelection