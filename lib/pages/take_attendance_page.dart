import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class TakeAttendancePage extends StatefulWidget {
  @override
  _TakeAttendancePageState createState() => _TakeAttendancePageState();
}

class _TakeAttendancePageState extends State<TakeAttendancePage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;

  // Your PC's Flask server address
  final String serverUrl = 'http://<YOUR IP ADDRESS>:5000/attendance';

  Future<void> _takePhoto() async {
    final XFile? imageFile = await _picker.pickImage(source: ImageSource.camera);
    if (imageFile != null) {
      setState(() {
        _image = File(imageFile.path);
      });
    }
  }

  Future<void> _sendDataToServer(BuildContext context) async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please take a photo")),
      );
      return;
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(serverUrl));
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          _image!.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Attendance marked successfully")),
        );
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to mark attendance")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending data")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 228, 225, 240),
      appBar: AppBar(
        title: Text(
          "Take Attendance",
          style: TextStyle(color: Color(0xFF5D4B8C), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 228, 225, 240),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
            children: [
              _image == null
                  ? Text("No image selected", style: TextStyle(fontSize: 16))
                  : Image.file(_image!, height: 200),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 199, 229, 234),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
                onPressed: _takePhoto,
                child: Text("Take a Photo"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 199, 229, 234),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
                onPressed: () => _sendDataToServer(context),
                child: Text("Mark Attendance"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 187, 236, 213),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text("Back to Dashboard"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
