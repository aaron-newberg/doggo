import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  CalendarPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarController _controller = CalendarController();
  Widget build(BuildContext context) {
    return Scaffold(
      body: TableCalendar(
        availableCalendarFormats: const {
          CalendarFormat.month : 'Month',
          CalendarFormat.week : 'Week'
        },
        calendarController: _controller
        ),
    );
  }
}