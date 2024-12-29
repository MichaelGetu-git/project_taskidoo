import 'dart:convert'; // For Base64Decoder
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_taskidoo/pages/taskdetailpage.dart';

class CardSlider extends StatelessWidget {
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

            final tasks = taskSnapshot.data!.docs;
            final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

            final now = DateTime.now().subtract(Duration(days: 1)); // Include today's tasks

            final filteredTasks = tasks.where((task) {
              final taskData = task.data() as Map<String, dynamic>;
              final selectedMembers = List<String>.from(taskData['selectedMembers'] ?? []);
              final taskDate = taskData['date'] is String
                  ? DateTime.parse(taskData['date'])
                  : taskData['date']?.toDate();  // Handle case for Timestamp if present


              // Include tasks that are for today or in the future and belong to the user
              return taskDate != null && taskDate.isAfter(now) && selectedMembers.contains(currentUserUid);
            }).toList();

            final cardColors = [
              Colors.blue,
              Colors.green,
              Colors.orange,
              Colors.purple,
              Colors.red,
            ];

            return ListView(
              scrollDirection: Axis.horizontal,
              children: filteredTasks.asMap().entries.map((entry) {
                final index = entry.key;
                final task = entry.value;
                final taskData = task.data() as Map<String, dynamic>;
                final selectedMembers = List<String>.from(taskData['selectedMembers'] ?? []);

                return FutureBuilder<List<String>>(
                  future: _fetchAvatars(selectedMembers),
                  builder: (context, avatarSnapshot) {
                    if (avatarSnapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        width: 300,
                        height: 200,
                        margin: const EdgeInsets.only(right: 15),
                        color: Colors.grey[300],
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final avatars = avatarSnapshot.data ?? [];
                    return _buildCard(
                      taskId: task.id,
                      title: taskData['taskName'] ?? "Unknown Task",
                      subtitle: taskData['taskSubtitle'] ?? "No subtitle",
                      avatars: avatars,
                      progress: taskData['progress'] ?? 0.0,
                      date: taskData['date'] ?? "Unknown Date",
                      startTime: taskData['startTime'] ?? "00:00",
                      endTime: taskData['endTime'] ?? "00:00",
                      color: cardColors[index % cardColors.length], // Alternate colors
                      context: context,
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
        final userDoc = await FirebaseFirestore.instance.collection("users").doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final avatar = userData['profileImageBase64'] ?? "";
          avatars.add(avatar);
        }
      } catch (e) {
        // Handle error (e.g., user not found)
        avatars.add(""); // Add empty string for missing users
      }
    }

    return avatars;
  }



  Widget _buildCard({
    required String title,
    required String subtitle,
    required String startTime,
    required String endTime,
    required List<String> avatars, // Base64-encoded strings
    required Color color,
    required BuildContext context,
    required String taskId,
    required double progress,
    required String date
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
              date: date,
              startTime: startTime,
              endTime: endTime,
            ),
          ),
        );
      },
      child: Container(
        width: 300,
        height: 500,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15.0),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 13),
            Row(
              children: avatars.map((base64Image) {
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
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Progress",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "${(progress * 100).toStringAsFixed(0)}%",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.5),
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
