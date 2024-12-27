import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

import 'package:project_taskidoo/widgets/taskpage.dart'; // For Base64Decoder

class TimelinePage extends StatefulWidget {
  final DateTime selectedDate;

  TimelinePage({required this.selectedDate, Key? key}) : super(key:key);

  @override
  _TimelinePageState createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // To store events fetched from Firebase
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  // Function to fetch tasks from Firebase
  Future<void> _fetchTasks() async {
    try {
      // Convert the selectedDate string to DateTime
      DateTime selectedDate = widget.selectedDate; // No need to convert it again
      print("Converted selectedDate: ${selectedDate.toString()}");

      // Get data from Firebase Firestore
      final querySnapshot = await _firestore.collection('tasks').get();

      final List<Event> loadedEvents = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        // Check if the 'date' field is a Timestamp or a String
        dynamic taskDate = data['date'];

        if (taskDate is Timestamp) {
          taskDate = taskDate.toDate(); // Convert Timestamp to DateTime
        } else if (taskDate is String) {
          taskDate = DateTime.parse(taskDate); // Convert String to DateTime
        }

        // Check if the task's date matches the selected date
        if (_isSameDay(taskDate, selectedDate)) {
          // Fetch avatars for selected members
          final List<String> avatars = await _fetchAvatars(List<String>.from(data['selectedMembers']));

          // Convert Firebase data to Event object
          loadedEvents.add(Event(
            time: data['startTime'],
            title: data['taskName'],
            date: taskDate,
            avatars: avatars,
            duration: "${data['startTime']} - ${data['endTime']}",
            color: Colors.blue[100]!, // You can use any logic for color here
          ));
        } else {
          print("no tasks");
        }
      }

      // Update the state to reflect the fetched data
      setState(() {
        events = loadedEvents;
      });
    } catch (e) {
      print("Error fetching tasks: $e");
    }
  }


  // Function to check if two DateTime objects represent the same day
  // Function to check if two DateTime objects represent the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    // Normalize both dates to midnight to ignore the time part
    print(date1);
    print(date2);
    date1 = DateTime( date1.day);
    date2 = DateTime(date2.day);
    return date1.isAtSameMomentAs(date2);
  }


  // Function to fetch avatars based on user IDs
  Future<List<String>> _fetchAvatars(List<String> userIds) async {
    List<String> avatars = [];

    for (String userId in userIds) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection("users").doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final avatar = userData['profileImageBase64'] ?? ""; // Assuming the avatar is stored in base64 format
          avatars.add(avatar);
        }
      } catch (e) {
        // Handle error (e.g., user not found)
        avatars.add(""); // Add empty string for missing users
      }
    }

    return avatars;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];

        // Calculate offset based on time
        final offset = _calculateOffset(event.time);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Column
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Column(
                children: [
                  Text(
                    event.time,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // Event Details Column
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  top: 8.0,
                  bottom: 8.0,
                  left: offset, // Apply dynamic offset here
                ),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: event.color,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Title
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    // Participants Row
                    Row(
                      children: [
                        ...event.avatars.take(3).map((avatar) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundImage: avatar.isNotEmpty
                                  ? MemoryImage(Base64Decoder().convert(avatar))
                                  : null,
                              child: avatar.isEmpty
                                  ? Icon(Icons.person, color: Colors.white) // Fallback icon
                                  : null,
                            ),
                          );
                        }),
                        if (event.avatars.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey[300],
                              child: Text(
                                "+${event.avatars.length - 3}",
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    // Duration
                    Text(
                      event.duration,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to calculate horizontal offset based on time
  double _calculateOffset(String time) {
    final regex = RegExp(r"(\d+):(\d+)(am|pm)"); // Match time like 10:30am
    final match = regex.firstMatch(time);

    if (match != null) {
      final hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);

      // You can scale this factor (e.g., 2.0 for more spacing)
      return minute * 2.0; // Offset based on minutes (scale factor: 2.0)
    }
    return 0.0; // Default to no offset
  }
}

class Event {
  final String time;
  final String title;
  final DateTime date; // Store as DateTime
  final List<String> avatars;
  final String duration;
  final Color color;

  Event({
    required this.time,
    required this.title,
    required this.date,
    required this.avatars,
    required this.duration,
    required this.color,
  });
}

void main() {
  runApp(MaterialApp(
    home: TaskPage(),
  ));
}
