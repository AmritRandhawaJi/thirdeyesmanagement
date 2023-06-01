import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirdeyesmanagement/modal/assgined_spa.dart';
import 'package:thirdeyesmanagement/screens/getting_started_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:thirdeyesmanagement/screens/home.dart';
import 'package:thirdeyesmanagement/screens/manager_login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
      webRecaptchaSiteKey: "6LcyEQMlAAAAAEnTIRZQiFDyeUzHJFVMYxFzIJ1l",
      androidProvider: AndroidProvider.playIntegrity);
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
  final db2 = FirebaseFirestore.instance;
  DateTime years = DateTime.now();

  @override
  void dispose() {
    db2.terminate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => Future.delayed(const Duration(seconds: 1), () async {
              if (FirebaseAuth.instance.currentUser != null) {
                await FirebaseFirestore.instance
                    .collection("accounts")
                    .doc(FirebaseAuth.instance.currentUser!.email)
                    .get()
                    .then((DocumentSnapshot documentSnapshot) async {
                  if (documentSnapshot.exists) {
                    Spa.setSpaName = await documentSnapshot.get("assignedSpa");
                    goManagerHome();
                  }
                });
              } else {
                await userStateSave();
              }
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

  moveToDecision() async {
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const ManagerLogin(),
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

  Future<void> goManagerHome() async {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const Home(),
        ),
        (route) => false);
  }
}
