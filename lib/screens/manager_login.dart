import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thirdeyesmanagement/modal/assgined_spa.dart';
import 'package:thirdeyesmanagement/screens/home.dart';
import 'package:thirdeyesmanagement/screens/password_reset.dart';

class ManagerLogin extends StatefulWidget {
  const ManagerLogin({Key? key}) : super(key: key);

  @override
  State<ManagerLogin> createState() => _ManagerLoginState();
}

class _ManagerLoginState extends State<ManagerLogin> {
  var emailController = TextEditingController();
  final GlobalKey<FormState> _emailKey = GlobalKey<FormState>();
  var passwordController = TextEditingController();
  final GlobalKey<FormState> _passwordKey = GlobalKey<FormState>();

  bool showPassword = true;

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xffecece4),
        body: SafeArea(
          child: DelayedDisplay(
            slidingCurve: Curves.bounceOut,
            child: LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Welcome, Manager's",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontFamily: "Montserrat",
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset("assets/emailPassword.png"),
                        ),
                        Column(
                          children: [
                            Form(
                              key: _emailKey,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Enter your email";
                                    } else if (!EmailValidator.validate(
                                        emailController.value.text)) {
                                      return "Email invalid";
                                    } else {
                                      return null;
                                    }
                                  },
                                  showCursor: true,
                                  decoration: InputDecoration(
                                      errorStyle:
                                          const TextStyle(color: Colors.black),
                                      filled: true,
                                      hintText: "Email",
                                      prefixIcon: const Icon(
                                          Icons.email_outlined,
                                          color: Colors.black54,
                                          size: 20),
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      )),
                                ),
                              ),
                            ),
                            Form(
                              key: _passwordKey,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: TextFormField(
                                  obscureText: showPassword,
                                  controller: passwordController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Enter password";
                                    } else if (value.length < 8) {
                                      return "8 characters required";
                                    } else {
                                      return null;
                                    }
                                  },
                                  showCursor: true,
                                  decoration: InputDecoration(
                                      errorStyle:
                                          const TextStyle(color: Colors.black),
                                      filled: true,
                                      hintText: "Password",
                                      prefixIcon: const Icon(Icons.lock_outline,
                                          color: Colors.black54, size: 20),
                                      fillColor: Colors.white,
                                      suffixIcon: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (showPassword) {
                                                showPassword = false;
                                              } else {
                                                showPassword = true;
                                              }
                                            });
                                          },
                                          child: Icon(
                                            Icons.remove_red_eye,
                                            color: showPassword
                                                ? Colors.grey
                                                : Colors.blueAccent,
                                          )),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      )),
                                ),
                              ),
                            ),
                          ],
                        ),
                        loading
                            ? const CircularProgressIndicator(
                                strokeWidth: 1,
                                color: Colors.blueAccent,
                              )
                            : Container(
                                height: 20,
                              ),
                        const SizedBox(height: 5),
                        CupertinoButton(
                            color: Colors.blueAccent,
                            onPressed: loading
                                ? null
                                : () {
                                    _authenticateUser();
                                  },
                            child: const Text("Login",
                                style: TextStyle(color: Colors.white))),
                        const Padding(
                          padding: EdgeInsets.all(18.0),
                          child: Text(
                              textAlign: TextAlign.start,
                              "Your account and data are safe on secured server.",
                              style: TextStyle(
                                  fontFamily: "Montserrat",
                                  color: Colors.black54)),
                        ),
                        CupertinoButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PasswordReset(),
                                  ));
                            },
                            child: const Text(
                              "Reset Password?",
                              style: TextStyle(
                                  fontFamily: "Montserrat",
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ));
              },
            ),
          ),
        ),
      ),
    );
  }

  void _authenticateUser() {
    setState(() {});
    if (_passwordKey.currentState!.validate() &
        _emailKey.currentState!.validate()) {
      _login(emailController.value.text, passwordController.value.text);
    }
  }

  Future<void> _login(String emailAddress, String password) async {
    try {
      setState(() {
        loading = true;
      });
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);
      _loggedIn();
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      if (e.code == 'user-not-found') {
        error("User not found", "Your account is not registered");
      } else if (e.code == 'user-disabled') {
        error("User Disabled", 'User is disabled by admin');
      } else if (e.code == "wrong-password") {
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text("Wrong Password",
                      style: TextStyle(color: Colors.red)),
                  content: const Text("Would like to reset?"),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PasswordReset(),
                              ));
                        },
                        child: const Text(
                          "Reset",
                          style: TextStyle(color: Colors.red),
                        )),
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
      } else if (e.code == "too-many-requests") {
        error("Too many attempts",
            "Account is temporary disabled\nto activate your account again Reset your password");
      }
    }
  }

  Future error(String title, String description) {
    return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(title),
              content: Text(description),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: const Text("OK"),
                    )),
              ],
            ));
  }

  Future<void> _loggedIn() async {
    await FirebaseFirestore.instance
        .collection("accounts")
        .doc(emailController.value.text.trim())
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        Spa.setSpaName = await documentSnapshot.get("assignedSpa");
      } else {
        showDialog(
          context: context,
          builder: (ctx) =>  AlertDialog(
            content: const Text("You are not the part of association"),
          title: const Text("Error",style: TextStyle(color: Colors.red)),
            actions: [
              TextButton(onPressed: (){
                Navigator.pop(ctx);
              }, child: const Text("Ok"))
            ],
          ),
        );
      }
    });
  }

  void move() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const Home(),
        ),
        (route) => false);
  }
}
