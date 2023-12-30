import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final int quality;
  final Function changeQuality;

  const SettingsPage(
      {super.key, required this.quality, required this.changeQuality});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.quality == 0
        ? 'Normal'
        : widget.quality == 1
            ? 'High'
            : 'Ultimate';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Quality: ',
                style: TextStyle(fontSize: 20),
              ),
              DropdownButton<String>(
                value: dropdownValue,
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue;
                    widget.changeQuality(newValue == 'Normal'
                        ? 0
                        : newValue == 'High'
                            ? 1
                            : 2);
                  });
                },
                items: <String>['Normal', 'High', 'Ultimate']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          // Add more settings widgets here
        ],
      ),
    );
  }
}
