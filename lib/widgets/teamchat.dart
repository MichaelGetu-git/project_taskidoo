import 'package:flutter/material.dart';
import 'package:project_taskidoo/widgets/teamchatview.dart';

void main() {
  runApp(TeamChatList());
}

class TeamChatList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TeamChatScreen(),
    );
  }
}

class TeamChatScreen extends StatelessWidget {
  final List<Map<String, String>> teams = [
    {"name": "Team Alpha", "message": "Have a good one!", "time": "3:02 PM"},
    {"name": "Team Beta", "message": "Are you available for tonight?", "time": "8h-25min"},
    {"name": "Team Gamma", "message": "Good bye!", "time": "7h-15min"},
    {"name": "Team Delta", "message": "See you again!", "time": "7h-00min"},
    {"name": "Team Omega", "message": "Okay, Thank you!", "time": "5h-35min"},
    {"name": "Team Sigma", "message": "Okay, Thank you!", "time": "4h-20min"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Team Chats"),
        centerTitle: true,

      ),
      body: ListView.builder(
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final team = teams[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(team['name']![0]), // First letter of team name
              backgroundColor: Colors.blueAccent,
            ),
            title: Text(team['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(team['message']!),
            trailing: Text(team['time']!, style: TextStyle(color: Colors.grey)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeamChatView(teamName: team['name']!),
                ),
              );
            },

          );
        },
      ),
    );
  }
}
