

import 'package:flutter/material.dart';

class IntroPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/third-page');
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
          Navigator.pushNamed(context, '/third-page');
        },
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 35,right: 35),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo3.png'),
                const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("Research", style: TextStyle(fontSize: 30),),
                ),
                const Padding(
                    padding: EdgeInsets.only(top:10.0),
                    child: Text(
                        "This platform is best for scheduling and research purposes"
                        "for students of the best working caliber and help.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 23),
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