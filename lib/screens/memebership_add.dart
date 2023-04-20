import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'member_pay_screen.dart';

class MembershipAdd extends StatefulWidget {
  const MembershipAdd({Key? key}) : super(key: key);

  @override
  State<MembershipAdd> createState() => _MembershipAddState();
}

class _MembershipAddState extends State<MembershipAdd> {
  late TwilioFlutter twilioFlutter;
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  late int randomNumber;
  final GlobalKey<FormState> nameKey = GlobalKey<FormState>();
  final GlobalKey<FormState> numberKey = GlobalKey<FormState>();

  String spaName ="";


  Future<void> setSpa() async {
    final prefs = await SharedPreferences.getInstance();

    spaName = prefs.getString("spaName").toString();
  }
  late int index;
  int colorIndex = 2;
  late int paid;
  List<dynamic> values = [];
  late String assignedSpa;

  late int valid = 0;
  late int massagesInclude;

  late String packageType;

  bool buttonShow = false;

  late double height;

  bool serverResponded = false;

  bool gold = false;
  bool platinum = false;



  @override
  void initState() {
    twilioFlutter = TwilioFlutter(
        accountSid: 'AC86f0b9d571e249e479c016fc892ce23f',
        // replace *** with Account SID
        authToken: 'b65377bebe0a0cef1a587b92d4d94a2a',
        // replace xxx with Auth Token
        twilioNumber: '+15076688607' // .... with Twilio Number
        );
    setSpa();
    super.initState();
  }


  String manager = FirebaseAuth.instance.currentUser!.email.toString();
  final db = FirebaseFirestore.instance;
  late DocumentSnapshot ds;
  final PanelController _pc1 = PanelController();
  bool visible = true;

  bool loading = false;
  bool data = false;
  var arr = [];
  double panelHeightClosed = 0;
  double panelHeightOpen = 0;

  @override
  void dispose() {
    nameController.dispose();
    numberController.dispose();
    super.dispose();
  }
 List<dynamic> colorData = [const Color(0xfffcfbe8), const Color(0xfff7edff),const Color(0xffebf2ff),];
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorData[colorIndex],
      body: Stack(
        children: [
          SlidingUpPanel(
            minHeight: panelHeightClosed,
            maxHeight: panelHeightOpen,
            parallaxEnabled: true,
            parallaxOffset: .5,
            body: _body(),
            controller: _pc1,
            panelBuilder: (sc) => _panel(sc),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0)),
          ),
        ],
      ),
    );
  }


  void showError() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) => AlertDialog(
              icon: const Icon(Icons.warning, color: Colors.yellow),
              title: const Text(
                "Already Registered",
                style: TextStyle(color: Colors.green),
              ),
              content: const Text(
                  "Client is already registered with us. Please go back & search",
                  style: TextStyle(fontFamily: "Montserrat")),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: const Text("Go Back"))
              ],
            ));
  }

  Future<void> checkUser() async {
    loading = true;
    try {
      await db
          .collection("clients")
          .doc(numberController.value.text)
          .get()
          .then((value) async {
        if (value.exists) {
          setState(() {
            loading = false;
          });
          showError();
        } else {
          panelHeightClosed = MediaQuery.of(context).size.height / 2;
          panelHeightOpen = MediaQuery.of(context).size.height - 50;
          sendOtp();
        }
      });
    } catch (e) {
      panelHeightClosed = MediaQuery.of(context).size.height / 2;
      panelHeightOpen = MediaQuery.of(context).size.height - 50;
      sendOtp();
    }

  }

  Future<void> sendOtp() async {
    await db
        .collection("spa")
        .doc(spaName)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        values = documentSnapshot.get("membership");
        valid = values[index]["valid"];
        paid = values[index]["amount"];
        packageType = values[index]["type"];
        massagesInclude = values[index]["massages"];
      }
    });
    setState(() {
      loading = true;
    });
    try {
    sendMessage();
      serverResponded = true;
      setState(() {
        loading = false;
        _pc1.open();
      });
    } catch (e) {
      error();
    }
  }
void sendMessage(){
  Random random = Random();
  int number = random.nextInt(999);
  randomNumber = number + 1000;
  String otp = randomNumber.toString();

  twilioFlutter.sendSMS(
      toNumber: "+91${numberController.value.text.toString()}",
      messageBody:
      "Welcome to  $spaName, Your one time password is $otp");
}
  void error() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Something went wrong"),
      duration: Duration(seconds: 1),
    ));
  }

  Widget _body() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: const [
                Text(
                  "Welcome,",
                  style: TextStyle(
                      color: Colors.black45,
                      fontSize: 14,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "Membership",
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text("Booking Manager", style: TextStyle(fontSize: 18)),
          Text(manager,
              style: const TextStyle(
                fontFamily: "Montserrat",
                fontWeight: FontWeight.w500,
              )),
          Column(children: [
            Form(
              key: nameKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  keyboardType: TextInputType.name,
                  controller: nameController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Can't Empty";
                    } else if (value.length < 2) {
                      return "Incorrect Name";
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      hintText: "Client Name",
                      prefixIcon: const Icon(Icons.person,
                          color: Colors.black54, size: 20),
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      )),
                ),
              ),
            ),
            Form(
              key: numberKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: numberController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Can't Empty";
                    } else if (value.length < 10) {
                      return "Incorrect Number";
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      hintText: "Phone Number",
                      prefixIcon: const Icon(Icons.phone,
                          color: Colors.black54, size: 20),
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      )),
                ),
              ),
            ),
            const Text("Choose Membership",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,fontFamily: "Montserrat"),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
              Text("•",style: TextStyle(fontSize: 32,color: Colors.amberAccent)),
              Text("•",style: TextStyle(fontSize: 32,color: Colors.deepPurple)),
            ],),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                    onTap: () {
                      setState(() {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Gold Membership Selected",style: TextStyle(color: Colors.black)),
                          duration: Duration(seconds: 1),backgroundColor: Color(0xfffff387),
                        ));
                        gold = true;
                        platinum = false;
                        colorIndex = 0;
                        index = 0;
                      });
                    },
                    child: Chip(
                        label: SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
                            child:  Center(
                                child: Text(
                              "Gold",
                              style: TextStyle(color: gold ? Colors.black :Colors.white),
                            ))),
                        backgroundColor: gold
                            ?
                            Colors.amberAccent[100] :Colors.grey)),
                GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Platinum Membership Selected"),
                        duration: Duration(seconds: 1),backgroundColor: Colors.deepPurple,
                      ));
                      setState(() {
                        platinum = true;
                        gold = false;
                        index = 1;
                        colorIndex = 1;
                      });
                    },
                    child: Chip(
                        label: SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
                            child:  Center(child: Text("Platinum",style: TextStyle(color: platinum ? Colors.white : Colors.white),))),
                        backgroundColor: platinum ? Colors.deepPurple : Colors.grey)),
              ],
            ),

            const SizedBox(height: 20),
            Column(
              children: [
                const Text(
                  "Are you over 18?",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                Center(
                  child: CupertinoSwitch(
                    activeColor: Colors.green,
                    value: data,
                    onChanged: (value) => setState(() {
                      data = value;
                    }),
                  ),
                ),
              ],
            ),
            loading
                ? const CircularProgressIndicator(
                    strokeWidth: 2,
                  )
                : Container(),
            const SizedBox(height: 50),
            CupertinoButton(
                color: CupertinoColors.activeGreen,
                onPressed: loading
                    ? null
                    : () async {
                        if (nameKey.currentState!.validate() &
                            numberKey.currentState!.validate()) {
                          if (!gold && !platinum ) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Choose Membership")));
                          } else {
                            if (data) {
                              await checkUser();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Are you over 18?")));
                            }
                          }
                        }
                      },
                child: const Text("Create")),
            Container(
                margin: const EdgeInsets.all(50),
                child: Image.asset(
                  "assets/addForm.png",
                )),
          ]),
        ]),
      ),
    );
  }

  TextEditingController textEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Widget _panel(ScrollController sc) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Enter OTP",
              style: TextStyle(fontFamily: "Montserrat", fontSize: 18),
            ),
          ),
          Form(
              key: formKey,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 4,
                    obscureText: true,
                    obscuringCharacter: '*',
                    blinkWhenObscuring: true,
                    animationType: AnimationType.fade,
                    validator: (v) {
                      if (v!.length < 3) {
                        return "Enter OTP";
                      } else {
                        return null;
                      }
                    },
                    animationDuration: const Duration(milliseconds: 300),
                    controller: textEditingController,
                    keyboardType: TextInputType.number,
                    beforeTextPaste: (text) {
                      debugPrint("Allowing to paste $text");
                      //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                      //but you can show anything you want here, like your pop up saying wrong paste format or etc
                      return true;
                    },
                    onChanged: (String value) {},
                  ))),
          CupertinoButton(
              borderRadius: BorderRadius.circular(30),
              color: CupertinoColors.activeGreen,
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    loading = true;
                  });
                  if (serverResponded) {
                    if (randomNumber.toString() ==
                        textEditingController.value.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Success",style: TextStyle(color: Colors.white)),backgroundColor: Colors.green,duration: Duration(seconds: 1),));
                      moveToScreen();
                    } else {
                      setState(() {
                        loading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Wrong OTP"),backgroundColor: Colors.redAccent,));
                    }
                  }
                }
              },
              child: const Text("Verify & Next")),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset("assets/otpCustomer.png"),
                SizedBox(
                    width: MediaQuery.of(context).size.width-50,
                    height: MediaQuery.of(context).size.width-50,
                    child: const CircularProgressIndicator(strokeWidth: 1,))
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "OTP sent to your device, After the submission of one time password you are accepting our terms & conditions mentioned in Membership Benifits.",
              style: TextStyle(
                  fontFamily: "Montserrat", fontSize: 12, wordSpacing: 5),
            ),
          ),
          const SizedBox(height: 20),
          CupertinoButton(
              borderRadius: BorderRadius.circular(30),
              color: CupertinoColors.destructiveRed,
              onPressed: () async {
                setState(() {
                  panelHeightClosed = 0;
                  panelHeightOpen = 0;
                  _pc1.close();
                });
                Navigator.pop(context);
              },
              child: const Text("Cancel")),
          loading
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Container(),
          const SizedBox(
            height: 50,
          )
        ],
      ),
    );
  }

  void moveToScreen() {
    setState(() {
      loading = true;
    });
    final today = DateTime.now();
    final validTill = today.add(Duration(days: valid));
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(
        builder: (context) => MemberPayScreen(
        massages: massagesInclude,
        number: numberController.value.text.toString(),
        amount: paid,
        name: nameController.value.text,
        package: packageType,
        validity: DateFormat.yMMMd().add_jm().format(validTill), age: data, member: true,)));
  }
}
