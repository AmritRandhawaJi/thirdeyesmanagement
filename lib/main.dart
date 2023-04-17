import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirdeyesmanagement/admin/screens/admin_home.dart';
import 'package:thirdeyesmanagement/screens/decision.dart';
import 'package:thirdeyesmanagement/screens/getting_started_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:thirdeyesmanagement/screens/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance
      .activate(androidProvider: AndroidProvider.debug);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MaterialApp(home: MyApp()));
  });
}



class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  List<dynamic> list = [];
  final db = FirebaseFirestore.instance;


  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => Future.delayed(const Duration(seconds: 2), () {
              userState();
            }));
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text("3rd Eyes Management",
              style: TextStyle(fontFamily: "Montserrat", fontSize: 18)),
          SizedBox(
              height: MediaQuery.of(context).size.height / 5,
              width: MediaQuery.of(context).size.width / 3,
              child: Center(
                child: Image.asset(
                  "assets/logo.png",
                ),
              )),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.width / 2,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xff2b6747),
              ),
            ),
          ),
          const Text("One\nApp for\nall solution.",
              style: TextStyle(fontFamily: "Montserrat", fontSize: 32)),
        ],
      ),
    ); // widget tree
  }

  Future<void> userState() async {
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser != null) {
        moveToHome(FirebaseAuth.instance.currentUser!.email.toString());
      } else {
        await userStateSave();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-disabled") {
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text("Account is disabled",
                      style: TextStyle(color: Colors.red)),
                  content: const Text(
                      "Your account is disabled by admin or something went wrong?",
                      style: TextStyle(fontFamily: "Montserrat")),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          "Try again",
                          style: TextStyle(color: Colors.green),
                        ))
                  ],
                ));
      }
    }
  }

  moveToDecision() {
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const Decision(),
      ));
    }
  }

  moveToGettingStart() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const GettingStartedScreen(),
    ));
  }

  Future<void> userStateSave() async {
    final value = await SharedPreferences.getInstance();
    if (value.getInt("userState") != 1) {
      moveToGettingStart();
    } else {
      moveToDecision();
    }
  }

  Future<void> moveToHome(String email) async {
    await db
        .collection("accounts")
        .doc(email.toLowerCase())
        .get()
        .then((DocumentSnapshot documentSnapshot) => {
              if (documentSnapshot.get("adminAccess"))
                {
                  if (mounted) {goAdminHome()}
                }
              else
                {
                  if (mounted) {goManagerHome()}
                }
            });
  }

  void goManagerHome() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const Home(),
        ),
        (route) => false);
  }

  void goAdminHome() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminHome(),
        ),
        (route) => false);
  }
}
