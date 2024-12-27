import 'package:flutter/material.dart';
import 'package:project_taskidoo/widgets/progressCardList.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProgressScreen(),
    );
  }
}

class ProgressScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("In Progress"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ProgressCardList(
        tasks: [
          Task("Productivity Mobile App", "Create Detail Booking", 60, "2 min ago"),
          Task("Banking Mobile App", "Revision Home Page", 70, "5 min ago"),
          Task("Online Course", "Working On Landing Page", 80, "7 min ago"),
        ],
      ),
    );
  }
}

