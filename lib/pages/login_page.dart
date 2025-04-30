import 'package:flutter/material.dart';
import 'auth_service.dart';

class LoginPage extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 228, 225, 240),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.visibility, color: Color(0xFF3E2767), size: 32), 
                SizedBox(width: 8),
                Text(
                  "SWIFTVISION",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2767), 
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.login),
              label: Text("Sign in with Google"),
              onPressed: () async {
                final user = await _authService.signInWithGoogle();
                if (user != null) {
                  Navigator.pushReplacementNamed(context, "/dashboard");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
