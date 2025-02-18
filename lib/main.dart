import 'package:daily_routine/screens/home_screen.dart';
import 'package:daily_routine/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await checkNotificationPermission();
  await NotificationService().initNotification();
  tz.initializeTimeZones();
  runApp(const MyApp());
}

Future<bool> checkNotificationPermission() async {
  var status = await Permission.notification.status;

  // If permission is granted
  if (status.isGranted) {
    return true;
  }

  // Request permission if not already granted
  if (status.isDenied) {
    var result = await Permission.notification.request();
    return result.isGranted;
  }

  // If permission is permanently denied
  return false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Notifications',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),

    );
  }
}
