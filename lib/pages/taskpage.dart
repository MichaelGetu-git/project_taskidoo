import 'package:flutter/material.dart';
import 'package:project_taskidoo/widgets/timeline.dart';

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
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
          "Today Task",
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
              child: TimelinePage(
                selectedDate: selectedDate,
                key: ValueKey(selectedDate),
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
