import 'package:flutter/material.dart';

enum Sequencing {off, one, two, three}

class SequenceSelection extends StatefulWidget {
  @override
  _SequenceSelection createState() => new _SequenceSelection();
}

class _SequenceSelection extends State<SequenceSelection> {
  Sequencing _sequence = Sequencing.off; //Starts off by default
  
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
              //Sequence 0 block
              new RadioListTile<Sequencing>(
                title: const Text('Off'),
                value: Sequencing.off,
                groupValue: _sequence,
                onChanged: (Sequencing value) => setState(() => _sequence = value),
                activeColor: Colors.deepPurple,
              ),
              new Text("Causes system to turn off and air bladders to deflate."),
              //Sequence 1 block
              new RadioListTile<Sequencing>(
                title: const Text('Sequence 1'),
                value: Sequencing.one,
                groupValue: _sequence,
                onChanged: (Sequencing value) => setState(() => _sequence = value),
                activeColor: Colors.deepPurple,
              ),
              new Text("Explanation of what sequence one does."),
              //Sequence 2 block
             new RadioListTile<Sequencing>(
                title: const Text('Sequence 2'),
                value: Sequencing.two,
                groupValue: _sequence,
                onChanged: (Sequencing value) => setState(() => _sequence = value),
                activeColor: Colors.deepPurple,
              ),
              new Text("Explanation of what sequence two does."),
              //Sequence 3 block
              new RadioListTile<Sequencing>(
                title: const Text('Sequence 3'),
                value: Sequencing.three,
                groupValue: _sequence,
                onChanged: (Sequencing value) => setState(() => _sequence = value),
                activeColor: Colors.deepPurple,
              ),
              new Text("Explanation of what sequence three does."),
            ],
          ),
        ),
      ),
    );
  }
}