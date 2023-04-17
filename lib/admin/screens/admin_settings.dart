import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirdeyesmanagement/admin/create_manager.dart';
import 'package:thirdeyesmanagement/screens/decision.dart';

class AdminSettings extends StatefulWidget {
  const AdminSettings({Key? key}) : super(key: key);

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
            child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                                title: const Text("Sign-Out"),
                                content: const Text(
                                    "Would you like to sign-out?",
                                    style: TextStyle(fontFamily: "Montserrat")),
                                actions: <Widget>[
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop();
                                          signOut();
                                        },
                                        child: const Text("Sign-Out",
                                            style:
                                                TextStyle(color: Colors.red)),
                                      )),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop();
                                        },
                                        child: const Text("Cancel"),
                                      )),
                                ],
                              ));
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.power_settings_new_sharp,
                            color: Colors.black54),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Sign-Out",
                          style: TextStyle(color: Colors.black54),
                        )
                      ],
                    ))
              ],
            ),
            const DelayedDisplay(
              child: Text("Hey!",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Montserrat",
                      color: Colors.black87,
                      fontSize: 24)),
            ),
            const SizedBox(
              height: 50,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateManager(),
                    ));
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Create Manager",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "Montserrat",
                              color: Colors.black87,
                              fontSize: 14)),
                      Icon(
                        Icons.manage_accounts,
                        color: Colors.green,
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        )),
      ),
    );
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("spaName");
    navigate();
  }

  void navigate() {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const Decision(),
        ),
            (route) => false);
  }
}
