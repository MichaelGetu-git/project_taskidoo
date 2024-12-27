import 'package:flutter/material.dart';

class TeamChatView extends StatelessWidget {
  final String teamName;

  TeamChatView({required this.teamName});

  final List<Map<String, String>> messages = [
    {"sender": "Alice", "message": "Hi everyone!", "time": "3:00 PM"},
    {"sender": "Bob", "message": "Hey Alice, how's it going?", "time": "3:05 PM"},
    {"sender": "Alice", "message": "All good, thanks! What about you?", "time": "3:10 PM"},
    {"sender": "Charlie", "message": "Meeting at 4 PM, don't forget.", "time": "3:20 PM"},
    {"sender": "Bob", "message": "Got it, thanks!", "time": "3:25 PM"},
    {"sender": "Alice", "message": "See you all there!", "time": "3:30 PM"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(teamName),
        centerTitle: true,

      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message['sender'] == "Alice"; // Example: "Alice" is the current user
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['sender']!,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(message['message']!),
                        SizedBox(height: 5),
                        Text(
                          message['time']!,
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // Send message functionality
                  },
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
