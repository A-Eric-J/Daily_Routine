import 'package:daily_routine/database/db_helper.dart';
import 'package:flutter/material.dart';

class DataDisplayScreen extends StatelessWidget {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  DataDisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stored Data'),
      ),
      body: FutureBuilder(
        future: Future.wait([
          _dbHelper.getSleepData(),
          _dbHelper.getWaterIntake(),
          _dbHelper.getSmokingData(),
        ]),
        builder: (context, AsyncSnapshot<List<List<Map<String, dynamic>>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final sleepData = snapshot.data![0];
            final waterIntake = snapshot.data![1];
            final smokingData = snapshot.data![2];

            return ListView(
              children: [
                Text('Sleep Data', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ...sleepData.map((data) => ListTile(
                  title: Text('Bedtime: ${data['bedtime']}'),
                  subtitle: Text('Wakeup Time: ${data['wakeup_time']}'),
                )).toList(),
                Divider(),
                Text('Water Intake', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ...waterIntake.map((data) => ListTile(
                  title: Text('Glasses: ${data['glasses']}'),
                  subtitle: Text('Date: ${data['date']}'),
                )).toList(),
                Divider(),
                Text('Smoking Data', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ...smokingData.map((data) => ListTile(
                  title: Text('Cigarettes: ${data['cigarettes']}'),
                  subtitle: Text('Date: ${data['date']}'),
                )).toList(),
              ],
            );
          }
        },
      ),
    );
  }
}