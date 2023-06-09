import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thirdeyesmanagement/main.dart';
import 'package:thirdeyesmanagement/screens/password_reset.dart';

class AccountSetting extends StatefulWidget {
  const AccountSetting({Key? key}) : super(key: key);

  @override
  State<AccountSetting> createState() => _AccountSettingState();
}

class _AccountSettingState extends State<AccountSetting> {
  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcf0ff),
      body: SafeArea(
        child: DelayedDisplay(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Row(
                          children: [
                           Icon(Icons.arrow_back_ios),
                            Text("Back"),
                          ],
                        )),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 18.0),
                  child: Text(
                    "Welcome",
                    style: TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: 20,
                    ),
                  ),
                ),
                const Text(
                  "Manager's",
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    FirebaseAuth.instance.currentUser!.email.toString(),
                    style: const TextStyle(
                        fontFamily: "Montserrat", fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Image.asset("assets/addClient.png",
                            height: MediaQuery.of(context).size.height / 3.5,
                            width: MediaQuery.of(context).size.width / 1.5),
                      ),
                    ),
                  ],
                ),
                CupertinoButton(
                    color: Colors.green,
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.signOut();
                        _logout();
                      } on FirebaseAuthException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.code.toString())));
                      }
                    },
                    child: const Text("Sign-Out")),
                const SizedBox(height: 30),
                CupertinoButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PasswordReset(),
                          ));
                    },
                    child: const Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Change Password",
                              style: TextStyle(color: Colors.black),
                            ),
                            Icon(Icons.arrow_forward_ios)
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "would you like to change password?",
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      ],
                    )),
              ]),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MyApp(),
        ),
        (route) => false);
  }
}
