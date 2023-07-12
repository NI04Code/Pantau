import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
class ToggleSwitchWidget extends StatefulWidget {
  final Map<String, Map<String, String>> optionsData;

  ToggleSwitchWidget({required this.optionsData});

  @override
  _ToggleSwitchWidgetState createState() => _ToggleSwitchWidgetState();
}

class _ToggleSwitchWidgetState extends State<ToggleSwitchWidget> {
  List<String> options = [];
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    options = widget.optionsData.keys.toList();
  }

  @override
  Widget build(BuildContext context) {
    final headline = widget.optionsData[options[selectedIndex]]?['headline'];
    final content = widget.optionsData[options[selectedIndex]]?['content'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ToggleSwitch(
          minWidth: 90.0,
          initialLabelIndex: selectedIndex,
          labels:options,
          onToggle: (index) {
            setState(() {
              selectedIndex = index!;
            });
          },
        ),
        SizedBox(height: 16.0),
        Text(
          headline ?? '',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(height: 8.0),
        content != ''
            ? Container(
          margin: EdgeInsets.only(right: 8),
          constraints: BoxConstraints(
            minHeight: 100.0,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Text(
              content!,
              style: TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.w400),
            ),
          ),
        )
            : Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8.0),
          margin: EdgeInsets.only(right: 8),
          color: Colors.grey[300],
          child: Text(
            'Belum Tersedia',
            style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}