import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ViewAttendancePage extends StatefulWidget {
  @override
  _ViewAttendancePageState createState() => _ViewAttendancePageState();
}

class _ViewAttendancePageState extends State<ViewAttendancePage> {
  TextEditingController rollNoController = TextEditingController();
  List<dynamic> attendanceData = [];
  List<String> dates = [];

  Future<void> fetchAllAttendance() async {
    final response = await http.get(Uri.parse('http://<YOUR IP ADDRESS>:5000/view_all_attendance'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        dates = List<String>.from(data['dates']);
        attendanceData = data['attendance'];
      });
    } else {
      print('Failed to load attendance');
    }
  }

  Future<void> fetchAttendanceByRollNo() async {
    final rollNo = rollNoController.text;

    if (rollNo.isEmpty) {
      return;
    }

    final response = await http.get(Uri.parse('http://<YOUR IP ADDRESS>:5000/view_attendance_by_rollno/$rollNo'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        dates = List<String>.from(data['dates']);
        attendanceData = data['attendance'];
      });
    } else {
      print('Failed to load attendance');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 228, 225, 240),
      appBar: AppBar(
        title: Text(
          "View Attendance",
          style: TextStyle(color: Color(0xFF5D4B8C), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 228, 225, 240),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Table First
              Container(
                height: 400,  // Set a fixed height so vertical scroll works
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: attendanceData.isNotEmpty
                          ? DataTable(
                              columns: [
                                DataColumn(label: Text('Roll No')),
                                ...dates.map((date) => DataColumn(label: Text(date))),
                              ],
                              rows: attendanceData.map<DataRow>((student) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(student['rollno'] ?? 'No Roll No')),
                                    ...dates.map((date) {
                                      String status = student[date] != null ? student[date].toString() : 'ABSENT';
                                      return DataCell(Text(status));
                                    }).toList(),
                                  ],
                                );
                              }).toList(),
                            )
                          : Text("No attendance records found."),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Now Search Bar and Button below table
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: rollNoController,
                      decoration: InputDecoration(
                        labelText: 'Enter Roll No',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 199, 229, 234),
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    ),
                    onPressed: fetchAttendanceByRollNo,
                    child: Icon(Icons.search),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 199, 229, 234),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
                onPressed: fetchAllAttendance,
                child: Text('View All Attendance'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
