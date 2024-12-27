

import 'package:flutter/material.dart';

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/sec-page');
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png'),
              const Text("Taskidoo-App", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.lightBlueAccent, fontStyle: FontStyle.italic ),),
            ],

          ),
        ),
      ),
    );
  }
}