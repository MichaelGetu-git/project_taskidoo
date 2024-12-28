

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class Navbar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabChanged;
  Navbar({required this.currentIndex, required this.onTabChanged});

  @override
  _NavbarState createState() => _NavbarState();
}


class _NavbarState extends State<Navbar> {

  bool _isMenuOpen = false;

  void _toggleMenu() {
    setState(() {
      _isMenuOpen =!_isMenuOpen;
    });

    if (_isMenuOpen) {
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),

                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,

                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Colors.grey,
                                width: 1,
                              ),

                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/add-task');
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Icon(
                                  Icons.edit_calendar_outlined, color: Colors.black,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Create Task',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/create-project');
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Icon(
                                  Icons.add_box_outlined, color: Colors.black,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Create Project',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Colors.grey,
                                width: 1.0
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/create-team');
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Icon(
                                  Icons.group, color: Colors.black,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Create Team',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 100),
                        IconButton(
                          icon: Icon(
                            Icons.close, size: 40, color: Colors.blue,),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          }
      ).then((_) {
        setState(() {
          _isMenuOpen = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
            shape: CircularNotchedRectangle(),
            notchMargin: 6.0,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.home),
                  color: Colors.blue,
                  onPressed: () {
                    widget.onTabChanged(0);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.folder),
                  color: Colors.blue,
                  onPressed: () {
                    widget.onTabChanged(1);
                    Navigator.pushNamed(context, '/task-page');
                  },
                ),
                IconButton(
                    icon: Icon(
                      _isMenuOpen ? Icons.close : Icons.add_circle,
                      color: Colors.blue,
                      size: 50,
                    ),
                    onPressed: _toggleMenu,
                  ),
                IconButton(
                  icon: Icon(Icons.task_sharp),
                  color: Colors.blue,
                  onPressed: () {
                    widget.onTabChanged(2);
                    Navigator.pushNamed(context, '/project-page');
                  },
                ),
                IconButton(
                  icon: Icon(Icons.person),
                  color: Colors.blue,
                  onPressed: () {
                    widget.onTabChanged(3);
                    Navigator.pushNamed(context, '/settings-page');
                  },
                ),

              ],
            ),

          );
        // Floating Action Button (centered above BottomAppBar)

  }
}