import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau/screen/create_post_screen.dart';

class CoolDateTimePicker extends ConsumerStatefulWidget {
  final void Function(DateTime) onSelectedDate;
  final void Function(TimeOfDay) onSelectedTime;
  const CoolDateTimePicker({super.key, required this.onSelectedTime, required this.onSelectedDate});
  @override
  _CoolDateTimePickerState createState() => _CoolDateTimePickerState();
}

class _CoolDateTimePickerState extends ConsumerState<CoolDateTimePicker> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        widget.onSelectedDate(_selectedDate);
      });
      ref.read(dateTimeSelectedRemember.notifier).state = pickedDate;

    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
        widget.onSelectedTime(_selectedTime);
      });
      ref.read(timeOfDaySelectedRemember.notifier).state = pickedTime;
    }
  }

  String formatDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    return '$day-$month-$year';
  }

  String formatTime(TimeOfDay time) {
    String hour = time.hour.toString().padLeft(2, '0');
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    _selectedDate = ref.watch(dateTimeSelectedRemember);
    _selectedTime = ref.watch(timeOfDaySelectedRemember);
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => _selectDate(context),
              icon: Icon(Icons.calendar_today),
              label: Text('Select Date', style:  Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black),),
            ),
            SizedBox(width: 8),
            TextButton.icon(
              onPressed: () => _selectTime(context),
              icon: Icon(Icons.access_time),
              label: Text('Select Time', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black)),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          constraints: BoxConstraints(maxWidth: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.indigoAccent,
          ),
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    'Selected Date:',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    formatDate(_selectedDate),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16),
              Column(
                children: [
                  Text(
                    'Selected Time:',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    formatTime(_selectedTime),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}