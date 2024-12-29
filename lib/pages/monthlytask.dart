import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_taskidoo/widgets/timeline.dart';

import 'package:flutter/material.dart';
import 'package:project_taskidoo/widgets/timeline.dart';
import 'package:table_calendar/table_calendar.dart';

class TaskPage2 extends StatefulWidget {
  @override
  _TaskPage2State createState() => _TaskPage2State();
}

class _TaskPage2State extends State<TaskPage2> {
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
          "Monthly Task",
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
                    Navigator.pushNamed(context, '/monthly-task');
                  },
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              "15 tasks today",
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
            // Task List
            Expanded(
              child: CalendarPage(
              ),
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

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}
class _CalendarPageState extends State<CalendarPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Store tasks fetched from Firebase
  final Map<DateTime, List<Map<String, dynamic>>> tasks = {};

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // List of possible colors for the task containers
  final List<Color> _containerColors = [
    Colors.blue[500]!,
    Colors.green[500]!,
    Colors.orange[500]!,
    Colors.purple[500]!,
    Colors.red[500]!,
    Colors.teal[500]!,
    Colors.yellow[500]!, // Adding a few more colors
  ];

  @override
  void initState() {
    super.initState();
    _fetchTasks(); // Fetch tasks on initialization
  }

  Future<void> _fetchTasks() async {
    try {
      final querySnapshot = await _firestore.collection('tasks').get();

      final Map<DateTime, List<Map<String, dynamic>>> loadedTasks = {};

      final currentUserId = _auth.currentUser?.uid;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        dynamic taskDate = data['date'];

        if (taskDate is Timestamp) {
          taskDate = taskDate.toDate(); // Convert Timestamp to DateTime
        } else if (taskDate is String) {
          taskDate = DateTime.parse(taskDate); // Convert String to DateTime
        }

        DateTime normalizedDate = _normalizeDate(taskDate);

        if (currentUserId != null && data['selectedMembers'].contains(currentUserId)) {
          if (loadedTasks[normalizedDate] == null) {
            loadedTasks[normalizedDate] = [];
          }

          final List<String> avatars = await _fetchAvatars(List<String>.from(data['selectedMembers']));

          loadedTasks[normalizedDate]?.add({
            'title': data['taskName'],
            'participants': avatars,
            'duration': "${data['startTime']} - ${data['endTime']}",
          });
        }
      }

      setState(() {
        tasks.clear();
        tasks.addAll(loadedTasks);
      });
    } catch (e) {
      print("Error fetching tasks: $e");
    }
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<List<String>> _fetchAvatars(List<String> userIds) async {
    List<String> avatars = [];

    for (String userId in userIds) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection("users").doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final avatar = userData['profileImageBase64'] ?? "";
          avatars.add(avatar);
        }
      } catch (e) {
        avatars.add(""); // Add empty string for missing users
      }
    }

    return avatars;
  }

  // Helper method to get a color based on the task index (cyclical)
  Color _getColorForTask(int taskIndex) {
    return _containerColors[taskIndex % _containerColors.length];
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
        eventLoader: (day) => tasks[_normalizeDate(day)] ?? [],
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });

          // Show popup if tasks exist
          if (tasks[_normalizeDate(selectedDay)] != null &&
              tasks[_normalizeDate(selectedDay)]!.isNotEmpty) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  "Tasks for ${_formatDate(selectedDay)}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: tasks[_normalizeDate(selectedDay)]!.asMap().map((index, task) {
                    // Get a color for each task based on its index (cyclical)
                    Color containerColor = _getColorForTask(index);

                    return MapEntry(
                      index,
                      Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: containerColor, // Set color based on index
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Task Title
                            Text(
                              task['title'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8.0),

                            // Participants Row
                            Row(
                              children: [
                                ...task['participants'].take(3).map((avatar) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundImage: avatar.isNotEmpty
                                          ? MemoryImage(Base64Decoder().convert(avatar))
                                          : null,
                                      child: avatar.isEmpty
                                          ? Icon(Icons.person, color: Colors.white)
                                          : null,
                                    ),
                                  );
                                }),
                                if (task['participants'].length > 3)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.grey[300],
                                      child: Text(
                                        "+${task['participants'].length - 3}",
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8.0),

                            // Duration
                            Text(
                              task['duration'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).values.toList(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Close",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            );
          }
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.blueAccent,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
      ),
    );
  }

  // Helper to format the date
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
