import 'package:flutter/material.dart';

void main() => runApp(doggoApp());

class doggoApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doggo Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal
      ),
      home: DogsPage(title: 'doggo'),
    );
  }
}

class DogsPage extends StatefulWidget {
  DogsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DogsPageState createState() => _DogsPageState();
}

class _DogsPageState extends State<DogsPage> {
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Calendar',
      style: optionStyle,
    ),
    Text(
      'Dogs',
      style: optionStyle,
    ),
    Text(
      'Vet',
      style: optionStyle,
    ),
  ];
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex)
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            title: Text('Calendar'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            title: Text('Dogs'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face),
            title: Text('Vet'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo[300],
        onTap: _onItemTapped,
      ),
    );
  }
}

// class CalendarPage extends StatefulWidget {
//   CalendarPage({Key key, this.title}) : super(key: key);

//   final String title;

//   @override
//   _CalendarPageState createState() => _CalendarPageState();
// }