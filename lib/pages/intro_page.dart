

import 'package:flutter/material.dart';

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/sec-page');
        },
          child: Container(
            padding: EdgeInsets.all(30.0),
            decoration: BoxDecoration(

              borderRadius: BorderRadius.circular(20.0),

            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 150,
                    width: 150,
                  ),
                  SizedBox(height: 20),
                  const Text(
                    "Collabflow",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Colors.lightBlueAccent,
                      fontStyle: FontStyle.italic,
                      shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Colors.black38,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  const Text(
                    "Simplify your tasks beautifully!",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ),
    );
  }
}