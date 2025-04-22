import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:aturin/core/theme/app_theme.dart';
import 'package:aturin/features/home/ui/home_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:alarm/alarm.dart';
// import 'package:aturin/features/alarm/services/alarm_service.dart';
import 'package:aturin/features/alarm/ui/alarm_ring_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestPermissions();
  await Alarm.init();
  Alarm.ringStream.stream.listen(
    (alarmSettings) => navigateToRingScreen(alarmSettings)
  );
  runApp(const MyApp());
}

// Global navigator key untuk mengakses navigator dari mana saja
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Fungsi untuk menavigasi ke AlarmRingScreen ketika alarm berbunyi
void navigateToRingScreen(AlarmSettings alarmSettings) {
  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (_) => AlarmRingScreen(alarmSettings: alarmSettings),
    ),
  );
}

Future<void> _requestPermissions() async {
  await Permission.notification.request();
  await Permission.storage.request();
  await Permission.audio.request();
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    
    return MaterialApp(
      title: 'aturin APP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      navigatorKey: navigatorKey,
    );
  }
}