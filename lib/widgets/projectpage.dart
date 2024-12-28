import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_taskidoo/widgets/timeline.dart';
import 'package:table_calendar/table_calendar.dart';

class ProjectPage extends StatefulWidget {
  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final List<DateTime> dates = List.generate(
    5,
        (index) => DateTime.now().add(Duration(days: index)),
  );
  int selectedDateIndex = 0;

  DateTime get selectedDate => dates[selectedDateIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Monthly Projects",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${selectedDate.monthName}, ${selectedDate.day} ✍️",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today_rounded, color: Colors.blue),
                  onPressed: () {
                    Navigator.pushNamed(context, '/monthly-projects');
                  },
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              "15 projects today",
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            // Horizontal Date Selector
            Container(
              height: 100,
              width: double.infinity,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  final date = dates[index];
                  bool isSelected = selectedDateIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDateIndex = index;
                      });
                    },
                    child: Center(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.only(right: 20),
                        padding: EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.4),
                                blurRadius: 8,
                              ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              date.weekdayName,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "${date.day}",
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            // Project List
            Expanded(
              child: ProjectCalendarPage(),
            ),
          ],
        ),
      ),
    );
  }
}

extension DateTimeExtension on DateTime {
  String get monthName => [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ][month - 1];

  String get weekdayName {
    // Adjust weekday to start from Sunday as 0
    int adjustedWeekday = (weekday % 7);
    return [
      "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"
    ][adjustedWeekday];
  }
}



class ProjectCalendarPage extends StatefulWidget {
  @override
  _ProjectCalendarPageState createState() => _ProjectCalendarPageState();
}

class _ProjectCalendarPageState extends State<ProjectCalendarPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Store projects fetched from Firestore
  final Map<DateTime, List<Map<String, dynamic>>> projects = {};

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _fetchProjects(); // Fetch projects on initialization
  }

  // Fetch projects from Firestore based on selected day
  Future<void> _fetchProjects() async {
    try {
      // Fetch all projects from Firestore
      final querySnapshot = await _firestore.collection('projects').get();

      final Map<DateTime, List<Map<String, dynamic>>> loadedProjects = {};

      final currentUserId = _auth.currentUser?.uid;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        dynamic startDate = data['startDate'];

        if (startDate is String) {
          startDate = DateTime.parse(startDate); // Convert String to DateTime
        }

        DateTime normalizedDate = _normalizeDate(startDate);

        if (currentUserId != null && data['teamMembers'].contains(currentUserId)) {
          if (loadedProjects[normalizedDate] == null) {
            loadedProjects[normalizedDate] = [];
          }

          // Fetch avatars for the team members
          final List<String> avatars = await _fetchAvatars(List<String>.from(data['teamMembers']));

          loadedProjects[normalizedDate]?.add({
            'title': data['projectName'],
            'description': data['projectDescription'],
            'team': data['team'],
            'teamMembers': avatars,
            'startTime': data['startTime'],
            'endTime': data['endTime'],
          });
        }
      }

      // Update state to reflect fetched projects
      setState(() {
        projects.clear();
        projects.addAll(loadedProjects);
      });
    } catch (e) {
      print("Error fetching projects: $e");
    }
  }

  // Normalize DateTime (remove time part)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Fetch avatars for team members
  Future<List<String>> _fetchAvatars(List<String> userIds) async {
    List<String> avatars = [];

    for (String userId in userIds) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection("users").doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final avatar = userData['profileImageBase64'] ?? ""; // Base64 format
          avatars.add(avatar);
        }
      } catch (e) {
        avatars.add(""); // Add empty string for missing users
      }
    }

    return avatars;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TableCalendar(
        focusedDay: _focusedDay,
        firstDay: DateTime(2020),
        lastDay: DateTime(2030),
        calendarFormat: CalendarFormat.month,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: (day) => projects[_normalizeDate(day)] ?? [],
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });

          // Show popup if projects exist
          if (projects[_normalizeDate(selectedDay)] != null &&
              projects[_normalizeDate(selectedDay)]!.isNotEmpty) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  "Projects for ${_formatDate(selectedDay)}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: projects[_normalizeDate(selectedDay)]!.map((project) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.blue[50], // Background color
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Project Title
                          Text(
                            project['title'], // Project name
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),

                          // Project Description
                          Text(
                            project['description'], // Project description
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8.0),

                          // Team Members
                          Row(
                            children: [
                              ...project['teamMembers'].take(3).map((avatar) {
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
                              if (project['teamMembers'].length > 3)
                                Text('+${project['teamMembers'].length - 3}')
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.monthName} ${date.day}, ${date.year}";
  }
}
