// bottom_sheet_calendar.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:provider/provider.dart';
import 'package:planova/utilities/theme.dart';

class BottomSheetCalendar extends StatefulWidget {
  final EasyInfiniteDateTimelineController controller;
  final Function(DateTime) onDateSelected;

  const BottomSheetCalendar({super.key, required this.controller, required this.onDateSelected});

  @override
  _BottomSheetCalendarState createState() => _BottomSheetCalendarState();
}

class _BottomSheetCalendarState extends State<BottomSheetCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    CustomThemeData theme = ThemeColors.getTheme(themeProvider.themeValue);

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: theme.borderColor,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          Expanded(
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2024, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                widget.onDateSelected(selectedDay);
                widget.controller.jumpToDate(selectedDay);
                Navigator.pop(context);
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(color: theme.calenderDays),
                weekendTextStyle: TextStyle(color: theme.calenderDays.withOpacity(0.7)),
                outsideTextStyle: TextStyle(color: theme.calenderDays.withOpacity(0.5)),
                selectedDecoration: BoxDecoration(
                  color: theme.focusDayColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: theme.activeDayColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(color: theme.calenderNumbers, fontSize: 18),
                leftChevronIcon: Icon(Icons.chevron_left, color: theme.calenderNumbers),
                rightChevronIcon: Icon(Icons.chevron_right, color: theme.calenderNumbers),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: theme.calenderDays),
                weekendStyle: TextStyle(color: theme.calenderDays.withOpacity(0.7)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
