

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_taskidoo/pages/addproject.dart';
import 'package:project_taskidoo/pages/addtask.dart';
import 'package:project_taskidoo/pages/createteam.dart';
import 'package:project_taskidoo/pages/home_page.dart';
import 'package:project_taskidoo/pages/intro_page.dart';
import 'package:project_taskidoo/pages/intro_page_2.dart';
import 'package:project_taskidoo/pages/intro_page_3.dart';
import 'package:project_taskidoo/pages/intro_page_4.dart';
import 'package:project_taskidoo/pages/login.dart';
import 'package:project_taskidoo/pages/profiledetailpage.dart';
import 'package:project_taskidoo/pages/progressScreen.dart';
import 'package:project_taskidoo/pages/projectpage.dart';
import 'package:project_taskidoo/pages/task/task_creation_page.dart';
import 'package:project_taskidoo/pages/team/profilecreationpage.dart';
import 'package:project_taskidoo/pages/team/team_management_page.dart';
import 'package:project_taskidoo/widgets/cardSlider.dart';
import 'package:project_taskidoo/pages/monthlytask.dart';
import 'package:project_taskidoo/pages/taskpage.dart';


class Taskidoo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Scheduler',
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/home-page',
      routes: {
        '/login': (context) => LoginPage(),
        '/home-page': (context) => HomePage(),
        '/create-task': (context) => TaskCreationPage(),
        '/create-profile': (context) => ProfileCreationPage(),
        'team': (context) => TeamManagementPage(),
        '/intro-page': (context) => IntroPage(),
        '/sec-page': (context) => IntroPage2(),
        '/third-page': (context) => IntroPage3(),
        '/fourth-page': (context) => IntroPage4(),
        '/card-slider': (context) => CardSlider(),
        '/progress-page': (context) => ProgressScreen(),
        '/task-page': (context) => TaskPage(),
        '/monthly-task': (context) => TaskPage2(),
        '/add-task': (context) =>AddTaskScreen(),
        '/create-team': (context) => CreateteamScreen(),
        '/create-project': (context) => CreateProjectScreen(),
        '/project-page': (context) => ProjectPage(),
        '/profile-page': (context) => ProfileDetailWidget(),

      },
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          toolbarHeight: 100,
          toolbarTextStyle: TextStyle(
            color: Colors.blue
          ),
          iconTheme: IconThemeData(color: Colors.blue, size: 40.0),
        ),
      ),
    );
  }
}