import 'dart:convert'; // For Base64Decoder
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

            return ListView(
              scrollDirection: Axis.horizontal,
              children: tasks.map((task) {
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
                      title: taskData['taskName'] ?? "Unknown Task",
                      subtitle: taskData['taskSubtitle'] ?? "No subtitle",
                      startTime: taskData['startTime'] ?? "00:00",
                      endTime: taskData['endTime'] ?? "00:00",
                      avatars: avatars,
                      color: Colors.blue, // Customize based on task priority
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

  double _calculateProgress(String startTime, String endTime) {
    try {
      final now = DateTime.now();
      final startDateTime = DateFormat("HH:mm").parse(startTime);
      final endDateTime = DateFormat("HH:mm").parse(endTime);

      final start = DateTime(now.year, now.month, now.day, startDateTime.hour, startDateTime.minute);
      final end = DateTime(now.year, now.month, now.day, endDateTime.hour, endDateTime.minute);

      if (now.isBefore(start)) return 0;
      if (now.isAfter(end)) return 1;

      final elapsed = now.difference(start).inSeconds;
      final totalDuration = end.difference(start).inSeconds;

      return elapsed / totalDuration;
    } catch (e) {
      return 0;
    }
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required String startTime,
    required String endTime,
    required List<String> avatars, // Base64-encoded strings
    required Color color,
  }) {
    final progress = _calculateProgress(startTime, endTime);

    return Container(
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
    );
  }
}
