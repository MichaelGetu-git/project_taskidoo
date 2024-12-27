

import 'package:flutter/material.dart';

class IntroPage4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/home-page');
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
          Navigator.pushNamed(context, '/create-profile');
        },
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 35,right: 35),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo4.png'),
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("Implement", style: TextStyle(fontSize: 30),),
                ),
                const Padding(
                  padding: EdgeInsets.only(top:20.0,bottom: 20.0),
                  child: Text(
                    "Change your life for the best "
                        "with a platform that helps you all the way.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 23),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/create-profile');
                        },

                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0)
                            )
                        ),
                        child: const Text(
                          'Create your Profile',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                )

              ],
            ),

          ),

        ),

      ),
    );
  }
}