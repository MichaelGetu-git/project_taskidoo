import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateProjectScreen extends StatefulWidget {
  @override
  _CreateProjectScreenState createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  TextEditingController _projectNameController = TextEditingController();
  TextEditingController _projectDescriptionController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();
  String _selectedTeam = ''; // To store the selected team name
  List<String> _selectedTeamMembers = []; // To store member IDs of the selected team

  // Function to select date
  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        _dateController.text = "${selectedDate.toLocal()}".split(' ')[0]; // Format date as YYYY-MM-DD
      });
    }
  }

  // Function to select time
  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        controller.text = selectedTime.format(context); // Format time as HH:mm AM/PM
      });
    }
  }

  // Handle selected team members from TeamSelectionWidget
  void _onTeamSelected(Map<String, dynamic> selectedTeam) {
    setState(() {
      _selectedTeam = selectedTeam['teamName'];  // Set the selected team name
      _selectedTeamMembers = List<String>.from(selectedTeam['members']); // Store members as a list of IDs
    });
  }

  Future<void> _saveProject() async {
    try {
      CollectionReference projects = FirebaseFirestore.instance.collection('projects');

      // Save project data to Firestore
      await projects.add({
        'projectName': _projectNameController.text,
        'projectDescription': _projectDescriptionController.text,
        'startDate': _dateController.text,
        'startTime': _startTimeController.text,
        'endTime': _endTimeController.text,
        'team': _selectedTeam, // Selected team
        'teamMembers': _selectedTeamMembers, // Save selected team members (IDs)
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Project created successfully!')));

      // Optionally, you can reset the form after saving
      setState(() {
        _projectNameController.clear();
        _projectDescriptionController.clear();
        _dateController.clear();
        _startTimeController.clear();
        _endTimeController.clear();
        _selectedTeamMembers.clear();  // Clear selected members after saving
      });
    } catch (e) {
      // Show error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create project: $e')));
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
          'Create Project',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project Name', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: _projectNameController,
              decoration: InputDecoration(
                hintText: 'Enter project name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(color: Colors.white60, width: 1.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text('Project Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: _projectDescriptionController,
              decoration: InputDecoration(
                hintText: 'Enter project description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(color: Colors.white60, width: 1.0),
                ),
              ),
            ),
            SizedBox(height: 5),
            // Team selection widget
            TeamSelectionWidget(onSelectionChanged: _onTeamSelected),
            Text('Start Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Select a start date',
                labelText: 'Start Date',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(color: Colors.white60, width: 1.0),
                ),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Start Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      TextField(
                        controller: _startTimeController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Select start time',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(color: Colors.white60, width: 1.0),
                          ),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        onTap: () => _selectTime(context, _startTimeController),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('End Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      TextField(
                        controller: _endTimeController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Select end time',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(color: Colors.white60, width: 1.0),
                          ),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        onTap: () => _selectTime(context, _endTimeController),
                      ),
                    ],
                  ),
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
                  onPressed: _saveProject,
                  child: Text('Create Project'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Team selection widget
class TeamSelectionWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onSelectionChanged;

  TeamSelectionWidget({required this.onSelectionChanged});

  @override
  _TeamSelectionWidgetState createState() => _TeamSelectionWidgetState();
}

class _TeamSelectionWidgetState extends State<TeamSelectionWidget> {
  List<Map<String, dynamic>> _teams = [];
  String? _selectedTeamName;

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
        Text('Select Team', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        // DropdownButton for team selection
        DropdownButton<String>(
          isExpanded: true,
          hint: Text('Select a Team'),
          value: _selectedTeamName,
          onChanged: (String? newValue) {
            setState(() {
              _selectedTeamName = newValue;
              // Find the selected team by name and pass it to the parent
              final selectedTeam = _teams.firstWhere((team) => team['teamName'] == newValue);
              widget.onSelectionChanged(selectedTeam);
            });
          },
          items: _teams.map<DropdownMenuItem<String>>((team) {
            return DropdownMenuItem<String>(
              value: team['teamName'],
              child: Text(team['teamName']),
            );
          }).toList(),
        ),
      ],
    );
  }



}
