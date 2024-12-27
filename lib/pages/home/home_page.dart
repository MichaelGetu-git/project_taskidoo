import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_taskidoo/widgets/cardSlider.dart';
import 'package:project_taskidoo/widgets/navbar.dart';
import 'package:project_taskidoo/widgets/progressCardList.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _pages = [
    Center(child: Text('Home page')),
    Center(child: Text('Projects Page')),
    Center(child: Text('Profile page')),
    Center(child: Text('Messages page')),
  ];

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, d').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        leading: PopupMenuButton<String>(
          icon: const Icon(
            Icons.menu,
            color: Colors.blue,
          ),
          onSelected: (value) {
            print('Selected: $value');
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'option 1',
              child: Text('tasks'),
            ),
            const PopupMenuItem(
              value: 'option 2',
              child: Text('projects'),
            ),
            const PopupMenuItem(
              value: 'option 1',
              child: Text('teams'),
            ),
          ],
        ),
        title: Text(
          formattedDate,
          style: const TextStyle(
            fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.blue,
              ),
              onPressed: () async{
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Let's make a lot of good habits together",
                style: TextStyle(fontSize: 28),
              ),
            ),
            CardSlider(),
            Container(
              height: 500,
              padding: const EdgeInsets.all(16.0), // Optional: Adds padding around the container
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,  // Align the title and arrow to the left
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'In Progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_forward,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/progress-page');
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),  // Add spacing between the title/arrow and the list
                  Expanded(
                    child: ProgressCardList(
                      tasks: [
                        Task("Productivity Mobile App", "Create Detail Booking", 60, "2 min ago"),
                        Task("Banking Mobile App", "Revision Home Page", 70, "5 min ago"),
                        Task("Online Course", "Working On Landing Page", 80, "7 min ago"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Add spacing between widgets
          ],
        ),
      ),

      bottomNavigationBar: Navbar(
        currentIndex: _currentIndex,
        onTabChanged: _onTabChanged, // Pass the tab change handler
      ),

    );
  }
}
