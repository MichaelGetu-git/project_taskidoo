import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class TeamMemberWidget extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onSelectionChanged; // Callback parameter

  const TeamMemberWidget({Key? key, required this.onSelectionChanged}) : super(key: key);

  @override
  _TeamMemberWidgetState createState() => _TeamMemberWidgetState();
}

class _TeamMemberWidgetState extends State<TeamMemberWidget> {
  List<Map<String, dynamic>> _teamMembers = [];
  List<Map<String, dynamic>> _selectedMembers = [];

  // Fetch users from Firestore
  Future<void> _fetchTeamMembers() async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('users').get();

    List<Map<String, dynamic>> teamMembers = [];
    for (var doc in snapshot.docs) {
      teamMembers.add({
        'uid': doc.id, // Include uid (document ID) here
        'name': doc['name'] ?? 'Unknown',
        'image': doc['profileImageBase64'] ?? '',  // Assuming image is stored as base64
        'selected': false,
      });
    }

    setState(() {
      _teamMembers = teamMembers;
    });
  }


  // Decode Base64 to an image
  ImageProvider _decodeBase64ToImage(String base64String) {
    try {
      if (base64String.isEmpty) {
        return AssetImage('assets/default-avatar.png');
      }
      final decodedBytes = base64Decode(base64String);
      return MemoryImage(Uint8List.fromList(decodedBytes));
    } catch (e) {
      print("Error decoding Base64 image: $e");
      return AssetImage('assets/default-avatar.png');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTeamMembers();
  }

  // Toggle member selection
// Toggle member selection
  void _toggleSelection(int index) {
    setState(() {
      _teamMembers[index]['selected'] = !_teamMembers[index]['selected'];

      if (_teamMembers[index]['selected']) {
        _selectedMembers.add(_teamMembers[index]);
      } else {
        _selectedMembers.removeWhere(
              (member) => member['uid'] == _teamMembers[index]['uid'], // Compare using uid
        );
      }
    });

    // Send the updated list of selected members to the parent widget
    widget.onSelectionChanged(_selectedMembers);
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Team Members',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        // Display the selected members
        Wrap(
          children: _selectedMembers.map((selectedMember) {
            return Chip(
              label: Text(selectedMember['name']),
              deleteIcon: Icon(Icons.close),
              onDeleted: () {
                setState(() {
                  _selectedMembers.remove(selectedMember);
                  final index = _teamMembers.indexWhere(
                        (member) => member['name'] == selectedMember['name'],
                  );
                  if (index != -1) {
                    _teamMembers[index]['selected'] = false;
                  }
                });
                widget.onSelectionChanged(_selectedMembers); // Send updated list
              },
            );
          }).toList(),
        ),
        // Display available members
        if (_teamMembers.isEmpty)
          Center(child: CircularProgressIndicator())
        else
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: _teamMembers.length,
            itemBuilder: (context, index) {
              final member = _teamMembers[index];
              return GestureDetector(
                onTap: () => _toggleSelection(index),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: _decodeBase64ToImage(member['image']),
                      child: member['selected']
                          ? Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                    SizedBox(height: 4),
                    Text(
                      member['name'],
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
