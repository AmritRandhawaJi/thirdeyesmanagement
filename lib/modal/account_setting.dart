import 'package:cloud_firestore/cloud_firestore.dart';
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 30),
              const Text(
                "Welcome",
                style: TextStyle(
                  fontFamily: "Montserrat",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                FirebaseAuth.instance.currentUser!.email.toString(),
                style:
                    const TextStyle(fontFamily: "Montserrat"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                SizedBox(
                  height: MediaQuery.of(context).size.width/2.5,
                  width: MediaQuery.of(context).size.width/2.5,
                  child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                        Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Text("Add Offers",style:
                              TextStyle(fontFamily: "Montserrat",fontWeight: FontWeight.bold,color: Colors.green)),
                        ),
                        Icon(Icons.local_offer,color: Colors.green
                        ),
                        Icon(Icons.arrow_forward_ios,color: Colors.green)
                      ],)),
                ),
              ],),

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
                  color: Colors.purple[300],
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
                  color: Colors.redAccent[200],
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PasswordReset(),
                        ));
                  },
                  child: const Text("Change Password")),
              const SizedBox(height: 30),
            ]),
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
