


import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_taskidoo/app.dart';
import 'package:project_taskidoo/firebase_options.dart';
void main() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform
    );
    runApp(Taskidoo());


}
