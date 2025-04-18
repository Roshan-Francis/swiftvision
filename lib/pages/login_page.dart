import 'package:flutter/material.dart';
import 'auth_service.dart';

class LoginPage extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("SwiftVision", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.login),
              label: Text("Sign in with Google"),
              onPressed: () async {
                final user = await _authService.signInWithGoogle();
                if (user != null) {
                  Navigator.pushReplacementNamed(context, "/home");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
