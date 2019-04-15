import 'package:flutter/material.dart';

class SequenceSelection extends StatefulWidget {
  @override
  _SequenceSelection createState() => new _SequenceSelection();
}

class _SequenceSelection extends State<SequenceSelection> {
  bool val1 = false;
  bool val2 = false;
  bool val3 = false;

  void _change1(bool value) => setState(() => val1 = value);
  void _change2(bool value) => setState(() => val2 = value);
  void _change3(bool value) => setState(() => val3 = value);
  
  @override
  Widget build(BuildContext context) {
    return new Scaffold (
      appBar: new AppBar (
        title: new Text('Sequence Selection'),
        backgroundColor: Colors.deepPurple,
      ),
      body: new Container(
        padding: new EdgeInsets.all(32.0),
        //Sequence Selection Buttons
        child: new Center(
          child: new Column(
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              //Sequence 1 block
              new SwitchListTile(
                value: val1,
                onChanged: _change1,
                title: new Text("Sequence 1", style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                activeTrackColor: Colors.deepPurpleAccent[100],
                activeColor: Colors.deepPurple,
              ),
              //Sequence 2 block
              new SwitchListTile(
                value: val2,
                onChanged: _change2,
                title: new Text("Sequence 2", style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                activeTrackColor: Colors.deepPurpleAccent[100],
                activeColor: Colors.deepPurple,
              ),
              //Sequence 3 block
              new SwitchListTile(
                value: val3,
                onChanged: _change3,
                title: new Text("Sequence 3", style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                activeTrackColor: Colors.deepPurpleAccent[100],
                activeColor: Colors.deepPurple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}