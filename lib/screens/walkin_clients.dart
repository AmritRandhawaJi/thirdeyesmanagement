import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:thirdeyesmanagement/modal/assgined_spa.dart';
import 'package:thirdeyesmanagement/modal/twilio.dart';
import 'package:thirdeyesmanagement/screens/walkin_clients_add.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

class WalkinClients extends StatefulWidget {
  const WalkinClients({Key? key}) : super(key: key);

  @override
  State<WalkinClients> createState() => _WalkinClientsState();
}

class _WalkinClientsState extends State<WalkinClients> {
  final nameController = TextEditingController();
  final textEditing = TextEditingController();
  final numberController = TextEditingController();
  final GlobalKey<FormState> nameKey = GlobalKey<FormState>();
  final GlobalKey<FormState> key = GlobalKey<FormState>();
  final GlobalKey<FormState> numberKey = GlobalKey<FormState>();
  final GlobalKey<FormState> pendingAmountKey = GlobalKey<FormState>();

  final _server = FirebaseFirestore.instance;
  bool loading = false;
  bool data = false;

  late int randomNumber;
  double panelHeightClosed = 0;
  double panelHeightOpen = 0;
  PanelController pc = PanelController();

  late TwilioFlutter twilioFlutter;
  bool serverResponded = false;

  bool indicator = false;

  @override
  void dispose() {
    _server.terminate();
    nameController.dispose();
    numberController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    twilioFlutter = TwilioFlutter(
        accountSid: Twilio.accountSID,
        authToken: Twilio.authToken,
        twilioNumber: Twilio.number
    );

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        SlidingUpPanel(
          minHeight: panelHeightClosed,
          maxHeight: panelHeightOpen,
          parallaxEnabled: true,
          parallaxOffset: .5,
          body: body(),
          controller: pc,
          panelBuilder: (sc) => panel(sc),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
        ),
      ],
    ));
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
      await _server
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
          sendOtp();
        }
      });
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.code)));
    }
  }

  void sendOtp() {
    setState(() {
      loading = true;
    });

    Random random = Random();
    int number = random.nextInt(999);
    randomNumber = number + 1000;
    String otp = randomNumber.toString();
    try {
      twilioFlutter.sendSMS(
          toNumber: "+91${numberController.value.text.toString()}",
          messageBody: "Welcome to  ${Spa.getSpaName}, Your one time password is $otp");
      panelHeightClosed = MediaQuery.of(context).size.height / 2;
      panelHeightOpen = MediaQuery.of(context).size.height - 50;
      serverResponded = true;
      setState(() {
        loading = false;
        pc.open();
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void moveToCreateClient() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WalkinClientsAdd(
              name: nameController.value.text,
              age: data ? "Eligible" : "Not Eligible",
              number: numberController.value.text),
        ));
  }

  Widget body() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SafeArea(
        child: Column(children: [
          DelayedDisplay(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(Spa.getSpaName,
                  style:
                      const TextStyle(fontFamily: "Montserrat", fontSize: 18)),
            ),
          ),
          DelayedDisplay(
            child: Container(
                margin: const EdgeInsets.all(50),
                child: Image.asset(
                  "assets/walkin.png",
                )),
          ),
          loading
              ? const Center(child: CircularProgressIndicator())
              : Container(),
           DelayedDisplay(
            child: Column(
              children: const [
                Text("Hello,",
                    style: TextStyle(fontSize: 22, fontFamily: "Montserrat")),
                Text("Nice to see you here",
                    style: TextStyle(fontSize: 22, fontFamily: "Montserrat")),
              ],
            ),
          ),
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
          Column(
            children: [
              const Text(
                "Are you over 18?",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              Center(
                child: Switch(
                  // thumb color (round icon)
                  activeColor: Colors.lightGreenAccent,
                  activeTrackColor: Colors.grey.shade400,
                  inactiveThumbColor: Colors.blueGrey.shade600,
                  inactiveTrackColor: Colors.grey.shade400,
                  splashRadius: 50.0,
                  // boolean variable value
                  value: data,
                  // changes the state of the switch
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
          CupertinoButton(
              color: CupertinoColors.activeGreen,
              onPressed: loading
                  ? null
                  : () async {
                      if (nameKey.currentState!.validate() &
                          numberKey.currentState!.validate()) {
                        if (data) {
                          checkUser();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Are you over 18?")));
                        }
                      }
                    },
              child: const Text("Register Client")),
          SizedBox(
            height: MediaQuery.of(context).size.height / 3,
          )
        ]),
      ),
    );
  }

  Widget panel(ScrollController sc) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
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
              key: key,
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
                    controller: textEditing,
                    keyboardType: TextInputType.number,
                    beforeTextPaste: (text) {
                      debugPrint("Allowing to paste $text");

                      return true;
                    },
                    onChanged: (String value) {},
                  ))),
          CupertinoButton(
              borderRadius: BorderRadius.circular(30),
              color: CupertinoColors.activeGreen,
              onPressed: () async {
                if (key.currentState!.validate()) {
                  setState(() {
                    loading = true;
                  });
                  if (serverResponded) {
                    if (randomNumber.toString() == textEditing.value.text) {
                      setState(() {
                        indicator = true;
                      });
                      WidgetsBinding.instance.addPostFrameCallback(
                          (_) => Future.delayed(const Duration(seconds: 2), () {
                                moveToCreateClient();
                              }));
                    } else {
                      setState(() {
                        loading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Wrong OTP")));
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
                indicator
                    ? SizedBox(
                        height: MediaQuery.of(context).size.width - 50,
                        width: MediaQuery.of(context).size.width - 50,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Container(),
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
                  pc.close();
                });
                Navigator.pop(context);
              },
              child: const Text("Cancel")),
          const SizedBox(
            height: 50,
          )
        ],
      ),
    );
  }
}
