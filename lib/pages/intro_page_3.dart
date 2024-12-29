

import 'package:flutter/material.dart';

class IntroPage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/fourth-page');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text (
                  'Skip', style: TextStyle(color: Colors.white, fontSize: 16),
                )
            ),
          )
        ],
      ),
      body: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/fourth-page');
        },
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 35,right: 35),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo2.png',
                  height: 180,
                  width: 180,
                ),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("Collaborate", style: TextStyle(fontSize: 30),),
                ),
                const Padding(
                  padding: EdgeInsets.only(top:10.0),
                  child: Text(
                    "This platform is best for"
                        "for students of the best working caliber and help.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              ],
            ),
          ),

        ),
      ),
    );
  }
}