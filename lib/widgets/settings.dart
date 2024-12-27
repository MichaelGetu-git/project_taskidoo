import 'package:flutter/material.dart';

void main() {
  runApp(const Settings());
}

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool permissionEnabled = true;
  bool pushNotificationEnabled = false;
  bool darkModeEnabled = false;

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
            title: "Permission",
            value: permissionEnabled,
            onChanged: (value) {
              setState(() {
                permissionEnabled = value;
              });
            },
          ),
          _buildSwitchTile(
            title: "Push Notification",
            value: pushNotificationEnabled,
            onChanged: (value) {
              setState(() {
                pushNotificationEnabled = value;
              });
            },
          ),
          _buildSwitchTile(
            title: "Dark Mood",
            value: darkModeEnabled,
            onChanged: (value) {
              setState(() {
                darkModeEnabled = value;
              });
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
