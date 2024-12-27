import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_taskidoo/widgets/teammember.dart';
class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  // Controllers for date, time, task name, and subtitle fields
  TextEditingController _dateController = TextEditingController();
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();
  TextEditingController _taskNameController = TextEditingController();
  TextEditingController _taskSubtitleController = TextEditingController();
  String _selectedBoard = 'Urgent'; // Default board selection
  List<Map<String, dynamic>> _selectedMembers = []; // List to store selected members

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

  // Handle selected team members from TeamMemberWidget
  void _onTeamMembersSelected(List<Map<String, dynamic>> selectedMembers) {
    setState(() {
      _selectedMembers = selectedMembers;  // Update the list of selected members
    });
  }

  Future<void> _saveTask() async {
    try {
      CollectionReference tasks = FirebaseFirestore.instance.collection('tasks');

      // Save task data to Firestore
      await tasks.add({
        'taskName': _taskNameController.text,
        'taskSubtitle': _taskSubtitleController.text, // Save task subtitle
        'date': _dateController.text,
        'startTime': _startTimeController.text,
        'endTime': _endTimeController.text,
        'board': _selectedBoard,
        'selectedMembers': _selectedMembers.map((member) => member['uid']).toList(),  // Save selected members
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Task saved successfully!')));

      // Optionally, you can reset the form after saving
      setState(() {
        _taskNameController.clear();
        _taskSubtitleController.clear(); // Clear subtitle
        _dateController.clear();
        _startTimeController.clear();
        _endTimeController.clear();
        _selectedMembers.clear();  // Clear selected members after saving
      });
    } catch (e) {
      // Show error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save task: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Task',
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
              'Task Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _taskNameController, // Connect task name controller
              decoration: InputDecoration(
                hintText: 'Enter task name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(color: Colors.white60, width: 1.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Task Subtitle',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _taskSubtitleController, // Connect subtitle controller
              decoration: InputDecoration(
                hintText: 'Enter task subtitle',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(color: Colors.white60, width: 1.0),
                ),
              ),
            ),
            SizedBox(height: 5),
            TeamMemberWidget(onSelectionChanged: _onTeamMembersSelected),  // Pass the callback to TeamMemberWidget
            Text(
              'Date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Select a date',
                labelText: 'Date',
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
                      Text(
                        'Start Time',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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
                      Text(
                        'End Time',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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
            Text(
              'Board',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChoiceChip(
                  label: Text('Urgent'),
                  selected: _selectedBoard == 'Urgent',
                  onSelected: (value) {
                    setState(() {
                      _selectedBoard = 'Urgent';
                    });
                  },
                ),
                SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Running'),
                  selected: _selectedBoard == 'Running',
                  onSelected: (value) {
                    setState(() {
                      _selectedBoard = 'Running';
                    });
                  },
                ),
                SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Ongoing'),
                  selected: _selectedBoard == 'Ongoing',
                  onSelected: (value) {
                    setState(() {
                      _selectedBoard = 'Ongoing';
                    });
                  },
                ),
              ],
            ),
            Spacer(),
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
                  onPressed: _saveTask,
                  child: Text('Save'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
