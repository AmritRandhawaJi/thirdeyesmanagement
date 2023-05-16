import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Analytics extends StatefulWidget {
  const Analytics({Key? key}) : super(key: key);

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(child: SafeArea(child: Column(children: [

        CupertinoButton(child: const Text("Check"), onPressed:(){
          sendToServer();
        })
      ]))),
    );
  }
  sendToServer() async {

    await FirebaseAnalytics.instance.logEvent(
      name: "Users",
      parameters: {
        "Age": 18,
        "Type": "Walkin",
      },
    );
  }
}
