import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TeamSelectionWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onSelectionChanged;

  TeamSelectionWidget({required this.onSelectionChanged});

  @override
  _TeamSelectionWidgetState createState() => _TeamSelectionWidgetState();
}

class _TeamSelectionWidgetState extends State<TeamSelectionWidget> {
  List<Map<String, dynamic>> _teams = [];

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('teams').get();
      setState(() {
        _teams = snapshot.docs.map((doc) {
          return {
            'teamName': doc['teamName'],
            'teamId': doc.id,  // Using team ID to ensure uniqueness
            'members': List<String>.from(doc['members']), // Store as a list of strings (user IDs)
          };
        }).toList();
      });
    } catch (e) {
      print('Error loading teams: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _teams.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Team',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        SizedBox(height: 10),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,  // Two columns
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _teams.length,
            itemBuilder: (context, index) {
              final team = _teams[index];
              return GestureDetector(
                onTap: () {
                  widget.onSelectionChanged(team);
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.blue[200]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          team['teamName'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Members: ${team['members'].length}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
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
      ],
    );
  }
}
