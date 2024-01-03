import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:woolify/Auth/signup.dart';
import 'package:woolify/Home/home.dart';
import 'package:flutter/services.dart';
import 'package:woolify/Screens/graph.dart';
import 'package:woolify/Screens/warehouse.dart';

import 'Screens/profile.dart';
import 'firebase_options.dart';

var email;
var userid;
var name;
var profilephoto;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);


  SharedPreferences prefs = await SharedPreferences.getInstance();
  email = prefs.getString('email');
  userid = prefs.getString('userid');
  name = prefs.getString('name');
  profilephoto = prefs.getString('profilephoto');

  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Woolify',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        canvasColor: Colors.white,


      ),
      // home: MapScreen(),
      home: email==null?Signup():Home(),
      routes: {
        '/settings': (context) => Settingss(),
      },

    );
  }
}
