import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskDetailPage extends StatefulWidget {
  final String taskId;
  final String title;
  final String subtitle;
  final List<String> avatars;
  final double progress;

  const TaskDetailPage({
    Key? key,
    required this.taskId,
    required this.title,
    required this.subtitle,
    required this.avatars,
    required this.progress,
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
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.subtitle,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Row(
              children: widget.avatars.map((base64Image) {
                return Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: CircleAvatar(
                    radius: 20,
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
            Text(
              "Edit Progress",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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
            ElevatedButton(
              onPressed: _updateProgressInFirebase,
              child: Text("Save Progress"),
            ),
          ],
        ),
      ),
    );
  }
}
