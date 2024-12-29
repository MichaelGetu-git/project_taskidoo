import 'dart:convert'; // For Base64Decoder
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:project_taskidoo/pages/taskdetailpage.dart';

class Progresscardlist extends StatelessWidget {
  final String taskCollection = "tasks"; // Replace with your Firebase collection name
  final String userCollection = "users"; // Replace with your Firebase user collection name

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      child: SizedBox(
        height: 200,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection(taskCollection).snapshots(),
          builder: (context, taskSnapshot) {
            if (taskSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!taskSnapshot.hasData || taskSnapshot.data!.docs.isEmpty) {
              return Center(child: Text("No tasks available"));
            }

            final tasks = taskSnapshot.data!.docs.where((task) {
              final taskData = task.data() as Map<String, dynamic>;
              final taskDate = taskData['date'] ?? "";

              // Only include tasks for today
              return _isTaskForToday(taskDate);
            }).toList();

            if (tasks.isEmpty) {
              return Center(child: Text("No tasks for today"));
            }

            return ListView(
              scrollDirection: Axis.vertical,
              children: tasks.map((task) {
                final taskData = task.data() as Map<String, dynamic>;
                final taskId = task.id; // Unique ID for deletion
                final endTime = taskData['endTime'] ?? "00:00";
                final selectedMembers = List<String>.from(taskData['selectedMembers'] ?? []);

                return FutureBuilder<List<String>>(
                  future: _fetchAvatars(selectedMembers),
                  builder: (context, avatarSnapshot) {
                    if (avatarSnapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        width: double.infinity,
                        height: 80,
                        margin: const EdgeInsets.only(bottom: 15),
                        color: Colors.grey[300],
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final avatars = avatarSnapshot.data ?? [];
                    return _buildListTile(
                      title: taskData['taskName'] ?? "Unknown Task",
                      subtitle: taskData['taskSubtitle'] ?? "No subtitle",
                      startTime: taskData['startTime'] ?? "00:00",
                      endTime: endTime,
                      taskDate: taskData['date'],
                      progress: taskData['progress'] ?? 0.0,
                      avatars: avatars,
                      taskId: task.id,
                      context: context
                    );
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Future<List<String>> _fetchAvatars(List<String> userIds) async {
    List<String> avatars = [];

    for (String userId in userIds) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection(userCollection).doc(userId).get();
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

  bool _isTaskForToday(dynamic taskDate) {
    try {
      final now = DateTime.now();

      // Parse task date
      DateTime taskDateTime;
      if (taskDate is String) {
        // Assuming 'taskDate' is in 'yyyy-MM-dd' format
        taskDateTime = DateFormat("yyyy-MM-dd").parse(taskDate);
      } else if (taskDate is Timestamp) {
        // Firestore Timestamp
        taskDateTime = taskDate.toDate();
      } else {
        // If `taskDate` is not in a valid format
        return false;
      }

      // Check if the task date matches today's date
      final today = DateTime(now.year, now.month, now.day);
      return taskDateTime.year == today.year &&
          taskDateTime.month == today.month &&
          taskDateTime.day == today.day;
    } catch (e) {
      print("Error in _isTaskForToday: $e");
      return false; // Handle errors gracefully
    }
  }

  Widget _buildListTile({
    required String title,
    required String taskId,
    required String subtitle,
    required String startTime,
    required String endTime,
    required double progress,
    required dynamic taskDate,
    required List<String> avatars,
    required BuildContext context,
  }) {

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailPage(
              taskId: taskId,
              title: title,
              subtitle: subtitle,
              avatars: avatars,
              progress: progress,
              startTime: startTime,
              endTime: endTime,
              date: taskDate,
            ),
          ),
        );
      },

      child: Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        border: Border.all(
          color: Colors.grey,
          width: 0.3, // Border width
        ),

      ),
      child: Row(
        children: [
          // Task Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                SizedBox(height: 5),
                Text(
                  "$startTime - $endTime",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          // Circular Progress Indicator
          Column(
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  value: progress.clamp(0.0,100.0),
                  strokeWidth: 6,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
              Text(
                "${(progress*100)}%", // Converts progress to percentage
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}
