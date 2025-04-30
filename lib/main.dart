import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/register_class_page.dart';
import 'pages/take_attendance_page.dart';
import 'pages/view_attendance_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  
  runApp(SwiftVisionApp());
}

class SwiftVisionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/dashboard': (context) => DashboardPage(),
        '/register_class': (context) => RegisterClassPage(),
        '/takeAttendance': (context) => TakeAttendancePage(),
        '/viewAttendance': (context) => ViewAttendancePage(),
      },
    );
  }
}
