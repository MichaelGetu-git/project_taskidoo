import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskDetailPage extends StatefulWidget {
  final String taskId;
  final String title;
  final String subtitle;
  final List<String> avatars;
  final double progress;
  final String date;
  final String startTime;
  final String endTime;


  const TaskDetailPage({
    Key? key,
    required this.taskId,
    required this.title,
    required this.subtitle,
    required this.avatars,
    required this.date,
    required this.progress,
    required this.startTime,
    required this.endTime,
  }) : super(key: key);

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.progress;
  }

  Future<void> _updateProgressInFirebase() async {
    try {
      // Use `set` with `merge: true` to add or update the progress field
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskId)
          .set({'progress': _currentProgress}, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Progress updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update progress: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    widget.subtitle,
                    style: TextStyle(fontSize: 16, color: Colors.blue[600]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Task Details Section
            _buildDetailCard("Date", widget.date),
            SizedBox(height: 10),
            _buildDetailCard("Start Time", widget.startTime),
            SizedBox(height: 10),
            _buildDetailCard("End Time", widget.endTime),

            SizedBox(height: 20),

            // Assigned Members (Avatars)
            Text(
              "Assigned Members",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: widget.avatars.map((base64Image) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: base64Image.isNotEmpty
                        ? MemoryImage(Base64Decoder().convert(base64Image))
                        : null,
                    child: base64Image.isEmpty
                        ? Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 30),

            // Progress Section
            Text(
              "Progress",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: _currentProgress,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
              minHeight: 10,
            ),
            SizedBox(height: 10),
            Text(
              "${(_currentProgress * 100).toStringAsFixed(0)}% Complete",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            Slider(
              value: _currentProgress,
              min: 0,
              max: 1,
              divisions: 100,
              label: "${(_currentProgress * 100).toStringAsFixed(0)}%",
              onChanged: (value) {
                setState(() {
                  _currentProgress = value;
                });
              },
            ),
            SizedBox(height: 20),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: _updateProgressInFirebase,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Colors.blue[800],
                ),
                child: Text(
                  "Save Progress",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Helper Widget for Detail Cards
  Widget _buildDetailCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }


}
