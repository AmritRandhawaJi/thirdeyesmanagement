import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirdeyesmanagement/modal/assgined_spa.dart';
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
  final db2 = FirebaseFirestore.instance;
  DateTime years = DateTime.now();

  @override
  void dispose() {
    db2.terminate();
    super.dispose();
  }

  setValues() async {
    String month = DateFormat.MMMM().format(DateTime.now());
    await db2
        .collection(years.year.toString())
        .doc(Spa.getSpaName)
        .collection(month)
        .doc("till Sale")
        .get()
        .then((value) => {
              if (value.exists)
                {userState()}
              else
                {
                  db2
                      .collection(years.year.toString())
                      .doc(Spa.getSpaName)
                      .collection(month)
                      .doc("till Sale")
                      .set({
                    "Walkin Cash": 0,
                    "Walkin Card": 0,
                    "Walkin UPI": 0,
                    "Walkin Wallet": 0,
                    "Membership Cash": 0,
                    "Membership Card": 0,
                    "Membership UPI": 0,
                    "Membership Wallet": 0,
                    "Members": 0,
                  }, SetOptions(merge: true)).then((value) => {userState()}),
                }
            });
  }

  Future<void> getValues() async {
    try {
      await db2
          .collection("accounts")
          .doc(FirebaseAuth.instance.currentUser!.email)
          .get()
          .then((DocumentSnapshot documentSnapshot) async {
        if (documentSnapshot.exists) {
          Spa.setSpaName = await documentSnapshot.get("assignedSpa");
          setState(() {
            setValues();
          });
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Something went wrong")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => Future.delayed(const Duration(seconds: 2), () async {
              getValues();

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
        if (mounted) {
          goManagerHome();
        }
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

  void goManagerHome() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const Home(),
        ),
        (route) => false);
  }
}
