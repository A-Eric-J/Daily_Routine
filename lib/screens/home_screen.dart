import 'package:daily_routine/database/db_helper.dart';
import 'package:daily_routine/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  TimeOfDay _bedtime = TimeOfDay.now();
  TimeOfDay _wakeupTime = TimeOfDay.now();
  TimeOfDay _desiredBedtime = TimeOfDay.now();
  TimeOfDay _desiredWakeupTime = TimeOfDay.now();
  bool _napDuringDay = false;
  int _glassesOfWater = 0;
  int _cigarettes = 0;

  Future<void> _selectTime(BuildContext context, bool isBedtime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isBedtime ? _bedtime : _wakeupTime,
    );
    if (picked != null) {
      setState(() {
        if (isBedtime) {
          _bedtime = picked;
        } else {
          _wakeupTime = picked;
        }
      });
    }
  }

  Future<void> _selectDesiredTime(BuildContext context, bool isBedtime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isBedtime ? _desiredBedtime : _desiredWakeupTime,
    );
    if (picked != null) {
      setState(() {
        if (isBedtime) {
          _desiredBedtime = picked;
        } else {
          _desiredWakeupTime = picked;
        }
      });
    }
  }

  void _saveData() async {
    final notificationService = NotificationService();
    await _dbHelper.insertSleepData({
      'bedtime': _bedtime.format(context),
      'wakeup_time': _wakeupTime.format(context),
      'desired_bedtime': _desiredBedtime.format(context),
      'desired_wakeup_time': _desiredWakeupTime.format(context),
      'nap_during_day': _napDuringDay ? 1 : 0,
    });

    await _dbHelper.insertWaterIntake({
      'glasses': _glassesOfWater,
      'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
    });

    await _dbHelper.insertSmokingData({
      'cigarettes': _cigarettes,
      'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
    });


    final now =  DateTime.now();
    notificationService.scheduleNotification(
        title: 'Bed Time: ${_bedtime.hour}:${_bedtime.minute}',
        body: 'It is time to sleep',
        scheduledNotificationDateTime: DateTime(now.year, now.month, now.day, _bedtime.hour, _bedtime.minute));

    // Schedule sleep notifications
    // await notificationService.scheduleSleepNotifications(
    //   bedtime: _bedtime,
    //   wakeupTime: _wakeupTime,
    //   napDuringDay: _napDuringDay,
    // );

    // Schedule water reminders
    // await notificationService.scheduleWaterReminders(
    //   wakeupTime: _wakeupTime,
    //   bedtime: _bedtime,
    // );

    // // Schedule cigarette reminders
    // await notificationService.scheduleCigaretteReminders(
    //   cigarettes: _cigarettes,
    // );


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Routine',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              title: 'Sleep Data',
              icon: FontAwesomeIcons.bed,
              iconColor: Colors.green,
              content: Column(
                children: [
                  _buildListTile('Bedtime', _bedtime.format(context), () => _selectTime(context, true)),
                  _buildListTile('Wakeup Time', _wakeupTime.format(context), () => _selectTime(context, false)),
                  _buildListTile('Desired Bedtime', _desiredBedtime.format(context), () => _selectDesiredTime(context, true)),
                  _buildListTile('Desired Wakeup Time', _desiredWakeupTime.format(context), () => _selectDesiredTime(context, false)),
                  SwitchListTile(
                    title: const Text('Nap during the day?'),
                    value: _napDuringDay,
                    activeColor: Colors.green,
                    onChanged: (value) => setState(() => _napDuringDay = value),
                  ),
                ],
              ),
              color: Colors.green.shade100,
            ),
            _buildCard(
              title: 'Water Intake',
              icon: FontAwesomeIcons.droplet,
              iconColor: Colors.blue,
              content: TextField(
                decoration: const InputDecoration(labelText: 'Glasses of water'),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() => _glassesOfWater = int.tryParse(value) ?? 0),
              ),
              color: Colors.lightBlue.shade100,
            ),
            _buildCard(
              title: 'Smoking Data',
              iconColor: Colors.orangeAccent,
              icon: FontAwesomeIcons.smoking,
              content: TextField(
                decoration: const InputDecoration(labelText: 'Cigarettes per day'),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() => _cigarettes = int.tryParse(value) ?? 0),
              ),
              color: Colors.yellow.shade100,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Save Data', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget content, required Color color,Color? iconColor}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor ?? Colors.black54),
                const SizedBox(width: 16),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, color: Colors.black54)),
        trailing: const Icon(Icons.edit, color: Colors.black54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: Colors.white,
        onTap: onTap,
      ),
    );
  }
}