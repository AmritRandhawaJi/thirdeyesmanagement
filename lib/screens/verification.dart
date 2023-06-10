import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:thirdeyesmanagement/modal/assgined_spa.dart';
import 'package:thirdeyesmanagement/modal/member_details_page.dart';
import 'package:thirdeyesmanagement/modal/twilio.dart';
import 'package:thirdeyesmanagement/screens/walking_details_page.dart';
import 'package:twilio_flutter/twilio_flutter.dart';


class Verification extends StatefulWidget {
  final String number;

  const Verification({super.key, required this.number});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final db = FirebaseFirestore.instance;
  late DocumentSnapshot databaseData;
  bool loading = false;
  TextEditingController textEditingController = TextEditingController();
  late int randomNumber;
  late TwilioFlutter twilioFlutter;

  @override
  void dispose() {
    db.terminate();
    super.dispose();
  }

  @override
  void initState() {
    twilioFlutter = TwilioFlutter(
        accountSid: Twilio.accountSID,
        authToken: Twilio.authToken,
        twilioNumber: Twilio.accountNumber);
    sendMessage();
    super.initState();
  }

  void sendMessage() {
    Random random = Random();
    int number = random.nextInt(999);
    randomNumber = number + 1000;
    String otp = randomNumber.toString();
    try {
      twilioFlutter.sendSMS(
          toNumber: "+91${widget.number}",
          messageBody:
              "Welcome to  ${Spa.getSpaName}, Your one time password is $otp");
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: SafeArea(
        child: DelayedDisplay(
          slidingCurve: Curves.easeInOutExpo,
          child: Column(
            children: [
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Verification Required",
                    style: TextStyle(fontFamily: "Montserrat", fontSize: 22)),
              )),
              Center(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text("We have sent an One Time Password",
                        style: TextStyle(fontSize: 14, color: Colors.black54)),
                    Text(widget.number,
                        style: const TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: 22,
                        )),
                    Image.asset(
                      "assets/verification.png",
                      height: MediaQuery.of(context).size.width / 1.2,
                      width: MediaQuery.of(context).size.width / 1.2,
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 30),
                        child: PinCodeTextField(
                          onCompleted: (v) {
                            checkOtp(v);
                          },
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
                          animationDuration:
                              const Duration(milliseconds: 300),
                          controller: textEditingController,
                          keyboardType: TextInputType.number,
                          beforeTextPaste: (text) {
                            return true;
                          },
                          onChanged: (String value) {},
                        )),

                  ],
                ),
              )),
              const SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "You need to verify your identity to move forward",
                  style: TextStyle(fontFamily: "Montserrat", fontSize: 18,color: Colors.black54),
                ),
              )
            ],
          ),
        ),
      )),
    );
  }

  checkOtp(String otp) {
    if (randomNumber.toString() == otp) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Success", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ));

      _searchClient(widget.number);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Wrong OTP", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ));
    }
  }

  Future<void> _searchClient(String query) async {
    await FirebaseFirestore.instance.enableNetwork();
    await db
        .collection('clients')
        .doc(query)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      databaseData = documentSnapshot;
      if (documentSnapshot.exists) {
        goForClient();
      } else {
        setState(() {
          loading = false;
        });
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text(
                    "No Client Found",
                    style: TextStyle(color: Colors.red),
                  ),
                  content: const Text(
                    "Client not registered with us.",
                    style: TextStyle(fontFamily: "Montserrat"),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                        },
                        child: const Text("Try Again"))
                  ],
                ));
      }
    });
  }

  goForClient() {
    if (databaseData["member"]) {
      setState(() {
        loading = false;
      });
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MemberDetailsPage(
              phoneNumber: databaseData["phone"],
              member: databaseData["member"],
              age: databaseData["age"],
              name: databaseData.get("name"),
              registration: databaseData.get("registration"),
              pastServices: databaseData.get("pastServices"),
              validity: databaseData.get("validity"),
              package: databaseData.get("package"),
              massages: databaseData.get("massages"),
              pendingMassage: databaseData.get("pendingMassage"),
              paid: databaseData.get("paid"),
              paymentType: databaseData.get("paymentMode"),
            ),
          ));
    } else if (databaseData["member"] == false) {
      setState(() {
        loading = false;
      });
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => WalkingDetailsPage(
                    name: databaseData.get("name"),
                    age: databaseData.get("ageEligible"),
                    member: databaseData.get("member"),
                    pastServices: databaseData.get("pastServices"),
                    phone: databaseData.get("phone"),
                    registration: databaseData.get("registration"),
                  )));
    }
  }
}
