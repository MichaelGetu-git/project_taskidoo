import 'dart:convert';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final User? user = FirebaseAuth.instance.currentUser; // Get the logged-in user
  String? profileImageBase64;


  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  @override
  void initState() {
    super.initState();
    _fetchProfilePicture();
  }

  Future<void> _fetchProfilePicture() async {
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        if (doc.exists) {
          setState(() {
            profileImageBase64 = doc.data()?['profileImageBase64'];
          });
        }
      } catch (e) {
        print('Error fetching profile picture: $e');
      }
    }
  }

  // Convert Base64 string to an image widget
  Widget _buildProfileImage() {
    return GestureDetector(

      onTap: () {Navigator.pushNamed(context,'/profile-page');},
        child: ClipOval(

          child: profileImageBase64 != null ?
          Image.memory(
            base64Decode(profileImageBase64!),
            height: 45,
            width: 45,
            fit: BoxFit.cover,
          ) : const Icon(
            Icons.person,
            size: 25,
            color: Colors.grey,
          ),
        ),
    );
  }

  final List<Widget> _pages = [
    Center(child: Text('Home page')),
    Center(child: Text('Tasks Page')),
    Center(child: Text('Profile page')),
    Center(child: Text('Projects page')),
  ];

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, d').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          formattedDate,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.blue),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 25.0),
            child: _buildProfileImage(),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                image: DecorationImage(
                  image: AssetImage('assets/header_image.jpg'), // Replace with your asset
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Drawer Items
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.blue),
              title: Text('Tasks', style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.pushNamed(context, '/task-page');
                print('Tasks clicked');
              },
            ),
            ListTile(
              leading: Icon(Icons.folder, color: Colors.orange),
              title: Text('Projects', style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.pushNamed(context, '/project-page');
                print('Projects clicked');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person_2_sharp, color: Colors.grey),
              title: Text('Profile', style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.pushNamed(context, '/profile-page');
                print('profile clicked');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.purple),
              title: Text('Logout', style: TextStyle(fontSize: 18)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Let's make a lot of good habits together✍️",
                style: TextStyle(fontSize: 22),
              ),
            ),
            CardSlider(),
            Container(
              height: 500,
              padding: const EdgeInsets.all(16.0),
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  SizedBox(height: 16),
                  Expanded(
                    child: Progresscardlist(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Navbar(
        currentIndex: _currentIndex,
        onTabChanged: _onTabChanged,
      ),
    );
  }
}
