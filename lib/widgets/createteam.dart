import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateteamScreen extends StatefulWidget {
  @override
  _CreateteamScreenState createState() => _CreateteamScreenState();
}

class _CreateteamScreenState extends State<CreateteamScreen> {
  final TextEditingController _teamNameController = TextEditingController();
  String _teamType = 'Public'; // Default type
  List<String> _selectedMembers = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _createTeam() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You must be logged in to create a team.")),
        );
        return;
      }

      // Create team object
      final team = {
        'teamName': _teamNameController.text,
        'members': [currentUser.uid, ..._selectedMembers],
        'type': _teamType,
        'creatorId': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await _firestore.collection('teams').add(team);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Team created successfully!")),
      );

      Navigator.pop(context); // Go back after creating the team
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create team: $e")),
      );
    }
  }

  // Helper function to decode Base64 to an image
  Uint8List? _decodeBase64ToImage(String base64String) {
    try {
      if (base64String.isEmpty) {
        return null;  // If Base64 is empty, return null
      }
      return base64Decode(base64String); // Convert Base64 string back to bytes
    } catch (e) {
      print("Error decoding Base64 image: $e");
      return null;  // Return null if decoding fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Team',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Team Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _teamNameController,
              decoration: InputDecoration(
                hintText: 'Enter team name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Members',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final userId = user.id;
                      final userName = user['name'];
                      final userProfileBase64 = user['profileImageBase64'];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: userProfileBase64 != null && userProfileBase64.isNotEmpty
                              ? MemoryImage(_decodeBase64ToImage(userProfileBase64)!)
                              : AssetImage('assets/default_profile_image.png') as ImageProvider, // Default image if no profile image
                        ),
                        title: Text(user['name']),
                        trailing: Checkbox(
                          value: _selectedMembers.contains(userId),
                          onChanged: (isChecked) {
                            setState(() {
                              if (isChecked == true) {
                                _selectedMembers.add(userId);
                              } else {
                                _selectedMembers.remove(userId);
                              }
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChoiceChip(
                  label: Text('Private'),
                  selected: _teamType == 'Private',
                  onSelected: (value) {
                    setState(() {
                      _teamType = 'Private';
                    });
                  },
                ),
                SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Public'),
                  selected: _teamType == 'Public',
                  onSelected: (value) {
                    setState(() {
                      _teamType = 'Public';
                    });
                  },
                ),
                SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Secret'),
                  selected: _teamType == 'Secret',
                  onSelected: (value) {
                    setState(() {
                      _teamType = 'Secret';
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 300,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _createTeam,
                  child: Text('Create Team'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
