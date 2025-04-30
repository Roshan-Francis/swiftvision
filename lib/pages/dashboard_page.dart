import 'package:flutter/material.dart';
import 'auth_service.dart';
class DashboardPage extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 228, 225, 240),
      appBar: AppBar(title: Center(
        child: Text("DASHBOARD",
          style: TextStyle(color: Color(0xFF5D4B8C), fontWeight: FontWeight.bold),
        ),
      ),
        backgroundColor: const Color.fromARGB(255, 228, 225, 240), 
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 199, 229, 234)),
              onPressed: () => Navigator.pushNamed(context, '/register_class'),
              child: Text("Register Student"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 199, 229, 234)),
              onPressed: () => Navigator.pushNamed(context, '/takeAttendance'),
              child: Text("Take Attendance"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 199, 229, 234)),
              onPressed: () => Navigator.pushNamed(context, '/viewAttendance'),
              child: Text("View Attendance"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 232, 189, 186)),
              onPressed: () async {
                await _authService.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
