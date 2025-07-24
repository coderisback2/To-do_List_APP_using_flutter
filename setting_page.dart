import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool dailyReminder = false;
  bool vibrationEnabled = false;

  String selectedSound = 'Default';
  String alarmRingBefore = '5 minutes';
  String savedLog = '';

  final List<String> ringBeforeOptions = [
    '5 minutes',
    '10 minutes',
    '15 minutes',
    '30 minutes',
    '1 hour',
  ];

  final List<String> availableSounds = [
    'Default',
    'Chime',
    'Beep',
    'Digital Alarm',
    'Gentle Wake',
    'Classic Bell',
  ];

  Future<String> get _settingsLogPath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/settings_log.txt';
  }

  Future<void> _saveSettingsLog() async {
    try {
      final filePath = await _settingsLogPath;
      final log = '''
[Settings Updated]
Notifications Enabled: $notificationsEnabled
Daily Reminder: $dailyReminder
Vibration Enabled: $vibrationEnabled
Alarm Ring Before: $alarmRingBefore
Notification Sound: $selectedSound
Timestamp: ${DateTime.now()}
--------------------------
''';
      final file = File(filePath);
      await file.writeAsString(log, mode: FileMode.append);
      debugPrint("Settings saved to log at: $filePath");
    } catch (e) {
      debugPrint("Failed to save log: $e");
    }
  }

  void _updateSetting(Function updateFn) async {
    setState(() {
      updateFn();
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('notificationsEnabled', notificationsEnabled);
    prefs.setBool('dailyReminder', dailyReminder);
    prefs.setBool('vibrationEnabled', vibrationEnabled);
    prefs.setString('selectedSound', selectedSound);
    prefs.setString('alarmRingBefore', alarmRingBefore);

    _saveSettingsLog(); // existing log file code
  }


  Future<void> _readLog() async {
    try {
      final filePath = await _settingsLogPath;
      final file = File(filePath);
      if (await file.exists()) {
        final log = await file.readAsString();
        setState(() {
          savedLog = log;
        });
      } else {
        setState(() {
          savedLog = "No logs found.";
        });
      }
    } catch (e) {
      setState(() {
        savedLog = "Error reading log: $e";
      });
    }
  }

  void _resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all settings

    setState(() {
      notificationsEnabled = true;
      dailyReminder = false;
      vibrationEnabled = false;
      selectedSound = 'Default';
      alarmRingBefore = '5 minutes';
    });

    _saveSettingsLog();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Settings reset to default')),
    );
  }


  void _showLogDialog() async {
    await _readLog();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Settings Log"),
        content: SingleChildScrollView(child: Text(savedLog)),
        actions: [
          TextButton(
            child: Text("Close"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  void _vibrateToggleEffect(bool enabled) async {
    if (await Vibration.hasVibrator() ?? false) {
      if (enabled) {
        Vibration.vibrate(duration: 100);
      } else {
        Vibration.vibrate(pattern: [0, 50, 50, 50]);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      dailyReminder = prefs.getBool('dailyReminder') ?? false;
      vibrationEnabled = prefs.getBool('vibrationEnabled') ?? false;
      selectedSound = prefs.getString('selectedSound') ?? 'Default';
      alarmRingBefore = prefs.getString('alarmRingBefore') ?? '5 minutes';
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text("Notifications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: Text("Enable Notifications"),
            value: notificationsEnabled,
            onChanged: (val) => _updateSetting(() => notificationsEnabled = val),
            secondary: Icon(Icons.notifications_active),
          ),
          SwitchListTile(
            title: Text("Daily Reminder"),
            value: dailyReminder,
            onChanged: (val) => _updateSetting(() => dailyReminder = val),
            secondary: Icon(Icons.alarm),
          ),
          SwitchListTile(
            title: Text("Vibration"),
            value: vibrationEnabled,
            onChanged: (val) {
              _vibrateToggleEffect(val);
              _updateSetting(() => vibrationEnabled = val);
            },
            secondary: Icon(Icons.vibration),
          ),
          ListTile(
            leading: Icon(Icons.alarm_on),
            title: Text("Alarm ring before task ends"),
            subtitle: Text(alarmRingBefore),
            trailing: Icon(Icons.arrow_drop_down),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => ListView(
                  shrinkWrap: true,
                  children: ringBeforeOptions.map((option) {
                    return ListTile(
                      title: Text(option),
                      onTap: () {
                        _updateSetting(() => alarmRingBefore = option);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          Divider(height: 32),
          Text("Sound Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListTile(
            leading: Icon(Icons.music_note),
            title: Text("Notification Sound"),
            subtitle: Text(selectedSound),
            trailing: Icon(Icons.arrow_drop_down),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => ListView(
                  shrinkWrap: true,
                  children: availableSounds.map((sound) {
                    return ListTile(
                      title: Text(sound),
                      onTap: () {
                        _updateSetting(() => selectedSound = sound);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          Divider(height: 32),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("App Version"),
            subtitle: Text("1.0.0"),
          ),
          Divider(height: 32),
          ElevatedButton.icon(
            icon: Icon(Icons.remove_red_eye),
            label: Text("View Saved Log"),
            onPressed: _showLogDialog,
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            icon: Icon(Icons.restart_alt),
            label: Text("Reset to Default"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: _resetSettings,
          ),
        ],
      ),
    );
  }
}

