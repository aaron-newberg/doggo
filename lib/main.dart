import 'package:flutter/material.dart';
import 'dog.dart';
import 'calendar.dart';

void main() => runApp(DoggoApp());

class DoggoApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doggo Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal
      ),
      home: RootPage(title: 'doggo'),
    );
  }
}

class RootPage extends StatefulWidget {
  final String title;
  RootPage({Key key, this.title = 'doggo'}) : super(key: key);

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> bodyList = <Widget>[
    CalendarPage(title: 'Calendar'),
    DogPage(),
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
        title: Text(widget.title)
      ),
      body: IndexedStack(
        children: bodyList,
        index:_selectedIndex
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