import 'package:flutter/material.dart';

class RegisterClassPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register Class")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField(
              items: ["Course 1", "Course 2"].map((course) {
                return DropdownMenuItem(value: course, child: Text(course));
              }).toList(),
              onChanged: (value) {},
              decoration: InputDecoration(labelText: "Select course"),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField(
              items: ["Class A", "Class B"].map((cls) {
                return DropdownMenuItem(value: cls, child: Text(cls));
              }).toList(),
              onChanged: (value) {},
              decoration: InputDecoration(labelText: "Select class"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text("Register Face"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Back to Dashboard"),
            ),
          ],
        ),
      ),
    );
  }
}
