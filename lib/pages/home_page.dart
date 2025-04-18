import 'package:flutter/material.dart';
import 'auth_service.dart';

class HomePage extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to SwiftVision!", style: TextStyle(fontSize: 22)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/dashboard'),
              child: Text("Go to Dashboard"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
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
