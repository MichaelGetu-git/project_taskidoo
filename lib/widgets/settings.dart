import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkModeEnabled = false;
  bool pushNotificationEnabled = false;
  bool permissionEnabled = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Load settings from Firestore when the screen initializes
  }

  // Load settings from Firestore
  Future<void> _loadSettings() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot settingsDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('settings')
            .doc('preferences')
            .get();

        if (settingsDoc.exists) {
          setState(() {
            darkModeEnabled = settingsDoc['darkModeEnabled'] ?? false;
            pushNotificationEnabled = settingsDoc['pushNotificationEnabled'] ?? false;
            permissionEnabled = settingsDoc['permissionEnabled'] ?? false;
          });
        }
      }
    } catch (e) {
      print("Error loading settings: $e");
    }
  }

  // Save settings to Firestore
  Future<void> _saveSettings() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('settings')
            .doc('preferences')
            .set({
          'darkModeEnabled': darkModeEnabled,
          'pushNotificationEnabled': pushNotificationEnabled,
          'permissionEnabled': permissionEnabled,
        });
      }
    } catch (e) {
      print("Error saving settings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          _buildSwitchTile(
            title: "Dark Mode",
            value: darkModeEnabled,
            onChanged: (value) {
              setState(() {
                darkModeEnabled = value;
              });
              _saveSettings(); // Save updated settings to Firebase
            },
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            title: "Push Notifications",
            value: pushNotificationEnabled,
            onChanged: (value) {
              setState(() {
                pushNotificationEnabled = value;
              });
              _saveSettings(); // Save updated settings to Firebase
            },
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            title: "Permissions",
            value: permissionEnabled,
            onChanged: (value) {
              setState(() {
                permissionEnabled = value;
              });
              _saveSettings(); // Save updated settings to Firebase
            },
          ),
          const SizedBox(height: 16),
          _buildNavigationTile(
            title: "Security",
            onTap: () {
              // Navigate to Security
            },
          ),
          _buildNavigationTile(
            title: "Help",
            onTap: () {
              // Navigate to Help
            },
          ),
          _buildNavigationTile(
            title: "Language",
            onTap: () {
              // Navigate to Language
            },
          ),
          _buildNavigationTile(
            title: "About Application",
            onTap: () {
              // Navigate to About Application
            },
          ),
          const SizedBox(height: 16),
          _buildNavigationTile(
            title: "Delete Account",
            titleColor: Colors.red,
            onTap: () {
              _showDeleteAccountDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      children: [
        SwitchListTile(
          title: Text(title, style: const TextStyle(fontSize: 16)),
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blue,
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }

  Widget _buildNavigationTile({
    required String title,
    Color titleColor = Colors.black,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: TextStyle(fontSize: 16, color: titleColor),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: onTap,
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text(
              "Are you sure you want to delete your account? This action cannot be undone."),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                // Handle account deletion
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
