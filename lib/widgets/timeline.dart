import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class TimelinePage extends StatefulWidget {
  final DateTime selectedDate;

  TimelinePage({required this.selectedDate, Key? key}) : super(key: key);

  @override
  _TimelinePageState createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final querySnapshot = await _firestore.collection('tasks').get();
      final List<Event> loadedEvents = [];
      final currentUserId = _auth.currentUser?.uid;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        dynamic taskDate = data['date'];

        if (taskDate is Timestamp) {
          taskDate = taskDate.toDate();
        } else if (taskDate is String) {
          taskDate = DateTime.parse(taskDate);
        }

        if (_isSameDay(taskDate, widget.selectedDate) &&
            currentUserId != null &&
            data['selectedMembers'].contains(currentUserId)) {
          final List<String> avatars =
          await _fetchAvatars(List<String>.from(data['selectedMembers']));

          loadedEvents.add(Event(
            time: data['startTime'],
            title: data['taskName'],
            date: taskDate,
            avatars: avatars,
            duration: "${data['startTime']} - ${data['endTime']}",
            color: _getEventColor(loadedEvents.length),
          ));
        }
      }

      setState(() {
        events = loadedEvents;
      });
    } catch (e) {
      print("Error fetching tasks: $e");
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    date1 = DateTime(date1.year, date1.month, date1.day);
    date2 = DateTime(date2.year, date2.month, date2.day);
    return date1.isAtSameMomentAs(date2);
  }

  Future<List<String>> _fetchAvatars(List<String> userIds) async {
    List<String> avatars = [];
    for (String userId in userIds) {
      try {
        final userDoc =
        await _firestore.collection("users").doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final avatar = userData['profileImageBase64'] ?? "";
          avatars.add(avatar);
        }
      } catch (e) {
        avatars.add("");
      }
    }
    return avatars;
  }

  Color _getEventColor(int index) {
    const colors = [Colors.blue, Colors.orange, Colors.green, Colors.purple];
    return colors[index % colors.length].withOpacity(0.8);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  event.time,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ),
              // Event Details
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: event.color,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        event.title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 8.0),
                      // Avatars
                      Row(
                        children: [
                          ...event.avatars.take(3).map((avatar) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: CircleAvatar(
                                radius: 16,
                                backgroundImage: avatar.isNotEmpty
                                    ? MemoryImage(
                                    Base64Decoder().convert(avatar))
                                    : null,
                                child: avatar.isEmpty
                                    ? Icon(Icons.person,
                                    color: Colors.white)
                                    : null,
                              ),
                            );
                          }),
                          if (event.avatars.length > 3)
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey[300],
                              child: Text(
                                "+${event.avatars.length - 3}",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      // Duration
                      Text(
                        event.duration,
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class Event {
  final String time;
  final String title;
  final DateTime date;
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
    home: TimelinePage(
      selectedDate: DateTime.now(),
    ),
  ));
}
