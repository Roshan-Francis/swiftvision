import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class RegisterClassPage extends StatefulWidget {
  @override
  _RegisterClassPageState createState() => _RegisterClassPageState();
}

class _RegisterClassPageState extends State<RegisterClassPage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollNoController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  // Your PC's Flask server address (IMPORTANT: use your actual PC IP)
  final String serverUrl = 'http://<YOUR IP ADDRESS>:5000/register_student';

  // Function to take a picture using the camera
  Future<void> _takePhoto() async {
    final XFile? imageFile = await _picker.pickImage(source: ImageSource.camera);
    if (imageFile != null) {
      setState(() {
        _image = File(imageFile.path);
      });
    }
  }

  // Function to send data to Flask server
  Future<void> _sendDataToServer(BuildContext context) async {
    if (_image == null ||
        _nameController.text.isEmpty ||
        _rollNoController.text.isEmpty ||
        _courseController.text.isEmpty ||
        _departmentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields and select a photo")));
      return;
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(serverUrl));
      request.fields['name'] = _nameController.text;
      request.fields['rollno'] = _rollNoController.text;
      request.fields['course'] = _courseController.text;
      request.fields['department'] = _departmentController.text;
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          _image!.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Student registered successfully")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to register student")));
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error sending data")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 228, 225, 240),
      appBar: AppBar(title: Center(
        child: Text("Register Student",
          style: TextStyle(color: Color(0xFF5D4B8C), fontWeight: FontWeight.bold),
        ),
      ),
        backgroundColor: const Color.fromARGB(255, 228, 225, 240),
        iconTheme: IconThemeData(color: Colors.black), // Change the color of the back button
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _image == null
                ? Text("No image selected", style: TextStyle(fontSize: 16))
                : Image.file(_image!, height: 200),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: _rollNoController,
              decoration: InputDecoration(labelText: "Roll Number"),
            ),
            TextField(
              controller: _courseController,
              decoration: InputDecoration(labelText: "Course"),
            ),
            TextField(
              controller: _departmentController,
              decoration: InputDecoration(labelText: "Department"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 199, 229, 234)),
              onPressed: _takePhoto,
              child: Text("Take a Photo"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 199, 229, 234)),
              onPressed: () => _sendDataToServer(context),
              child: Text("Register Student"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 189, 233, 198)),
              onPressed: () => Navigator.pop(context),
              child: Text("Back to Dashboard"),
            ),
          ],
        ),
      ),
    );
  }
}
