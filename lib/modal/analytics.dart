import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:thirdeyesmanagement/screens/home.dart';

class Analytics extends StatefulWidget {
  const Analytics({Key? key}) : super(key: key);

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.instance;
  int _value = 0;

  var clientType = ["Walk-in", "Google Ads", "Reference", "SMS"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color(0xffdad299),
          Color(0xffb0dab9),
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          const DelayedDisplay(
            child: Center(
              child: Text(
                "We love to hear your feedback",
                style: TextStyle(
                    fontFamily: "Montserrat",
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Flexible(child: Image.asset("assets/saleSlider.png")),
          ),
          Wrap(
            spacing: 5.0,
            children: List<Widget>.generate(
              4,
              (int index) {
                return ChoiceChip(
                  backgroundColor: Colors.black54,
                  pressElevation: 0.0,
                  selectedColor: Colors.green,
                  label: Text(clientType[index],
                      style: const TextStyle(color: Colors.white)),
                  selected: _value == index,
                  onSelected: (bool selected) {
                    setState(() {
                      _value = (selected ? index : null)!;
                    });
                  },
                );
              },
            ).toList(),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CupertinoButton(
                  onPressed: () {
                    sendToServer();
                  },
                  color: Colors.green,
                  child: const Text("Submit")),
            ],
          )
        ]),
      ),
    );
  }

  sendToServer() async {
    await FirebaseAnalytics.instance.logEvent(
      name: "Spa Clients",
      parameters: {
        "Client Visiting Type": clientType[_value],
      },
    ).whenComplete(() => () {

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const Home(),
              ),
              (route) => false);
        }).onError((error, stackTrace) => (){
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Check internet connection")));
    });
  }
}
