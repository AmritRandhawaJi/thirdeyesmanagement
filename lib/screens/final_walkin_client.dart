import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:thirdeyesmanagement/modal/assgined_spa.dart';
import 'package:thirdeyesmanagement/modal/send_push_message.dart';
import 'package:thirdeyesmanagement/modal/walkin_client_cart_data.dart';
import 'package:thirdeyesmanagement/screens/book_session.dart';
import 'package:thirdeyesmanagement/screens/home.dart';

class FinalWalkinClient extends StatefulWidget {
  final int total;
  final String number;
  final String name;
  final String age;
  final bool member;
  final String registration;

  const FinalWalkinClient(
      {super.key,
      required this.total,
      required this.number,
      required this.name,
      required this.age,
      required this.member,
      required this.registration});

  @override
  State<FinalWalkinClient> createState() => _FinalWalkinClientState();
}

class _FinalWalkinClientState extends State<FinalWalkinClient> {
  FirebaseFirestore server = FirebaseFirestore.instance;
  final PanelController _pc1 = PanelController();
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool loading = false;
  int afterOffer = 0;
  String _result = "Cash";
  final GlobalKey<FormState> numberKey = GlobalKey<FormState>();

  bool logoLoad = false;
  DateTime years = DateTime.now();

  bool applied = false;

  @override
  void initState() {
    afterOffer = widget.total;
    super.initState();
  }

  @override
  void dispose() {
    db.terminate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double panelHeightClosed = MediaQuery.of(context).size.height / 4;
    double panelHeightOpen = MediaQuery.of(context).size.height - 50;
    return Scaffold(
      backgroundColor: const Color(0xffedf8ff),
      body: Stack(children: [
        SlidingUpPanel(
          minHeight: panelHeightClosed,
          maxHeight: panelHeightOpen,
          parallaxEnabled: true,
          parallaxOffset: .5,
          body: _body(),
          controller: _pc1,
          panelBuilder: (sc) => _panel(sc),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
        ),
      ]),
    );
  }

  _body() {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                widget.name,
                style: const TextStyle(fontFamily: "Dosis", fontSize: 32),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Thanks for choosing",
                style: TextStyle(fontFamily: "Montserrat", fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                Spa.getSpaName,
                style: const TextStyle(
                  fontFamily: "Dosis",
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset("assets/payScreen.png"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Please Pay RS.${applied ? afterOffer : widget.total}/- on the reception.",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: "Montserrat",
                    fontSize: 32,
                    color: CupertinoColors.darkBackgroundGray),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _panel(ScrollController sc) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.blueGrey[100]),
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(20),
              child: Text("Choose Mode of Payment",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
            Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RadioListTile(
                        activeColor: Colors.green,
                        title: Row(
                          children:  [
                            const Icon(Icons.attach_money),
                            SizedBox(width: MediaQuery.of(context).size.width/12),
                            const Text('Cash',style: TextStyle(fontSize: 18,fontFamily: "Montserrat",)),
                          ],
                        ),
                        value: "Cash",

                        groupValue: _result,
                        onChanged: (value) {
                          setState(() {
                            _result = value!;
                          });
                        }),
                    RadioListTile(
                        activeColor: Colors.green,
                        title: Row(
                          children:  [
                            const Icon(Icons.credit_card_rounded),
                            SizedBox(width: MediaQuery.of(context).size.width/12),
                            const Text('Card',style: TextStyle(fontSize: 18,fontFamily: "Montserrat",)),
                          ],
                        ),
                        value: 'Card',
                        groupValue: _result,
                        onChanged: (value) {
                          setState(() {
                            _result = value!;
                          });
                        }),
                    RadioListTile(
                        activeColor: Colors.green,
                        title: Row(
                          children:  [
                            const Icon(Icons.account_balance),
                            SizedBox(width: MediaQuery.of(context).size.width/12),
                            const Text('UPI',style: TextStyle(fontSize: 18,fontFamily: "Montserrat",)),
                          ],
                        ),
                        value: 'UPI',
                        groupValue: _result,
                        onChanged: (value) {
                          setState(() {
                            _result = value!;
                          });
                        }),
                    RadioListTile(
                        activeColor: Colors.green,
                        title: Row(
                          children:  [
                            const Icon(Icons.payments_rounded),
                            SizedBox(width: MediaQuery.of(context).size.width/12),
                            const Text('Wallet',style: TextStyle(fontSize: 18,fontFamily: "Montserrat",)),
                          ],
                        ),
                        value: "Wallet",
                        groupValue: _result,
                        onChanged: (value) {
                          setState(() {
                            _result = value!;
                          });
                        }),
                    const SizedBox(
                      height: 50,
                    ),
                    loading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    CupertinoButton(
                        color: CupertinoColors.activeGreen,
                        onPressed: logoLoad
                            ? null
                            : () async {
                                await createClient();
                              },
                        child: const Text("Payment Confirmed",
                            style: TextStyle(fontFamily: "Montserrat"))),
                    logoLoad
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Center(
                                    child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                              "assets/checkMark.png"),
                                        ))),
                                SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 1.8,
                                    height:
                                        MediaQuery.of(context).size.width / 1.8,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 1,
                                      color: Colors.green,
                                    ))
                              ],
                            ),
                          )
                        : Container(),
                    Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Center(
                        child: CupertinoButton(
                            color: Colors.red,
                            onPressed: logoLoad
                                ? null
                                : () {
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                              icon: const Icon(
                                                  Icons.add_alert_rounded,
                                                  color: Colors.green),
                                              title: const Text(
                                                "Are you sure?",
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                              content: const Text(
                                                  "Would you like to cancel session.",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          "Montserrat")),
                                              actions: [
                                                TextButton(
                                                    onPressed: () async {
                                                      Navigator.pop(ctx);

                                                      await db
                                                          .collection("clients")
                                                          .doc(widget.number)
                                                          .delete()
                                                          .whenComplete(() => {
                                                                home(),
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(const SnackBar(
                                                                        content:
                                                                            Text("Canceled"))),
                                                              });
                                                    },
                                                    child: const Text("Yes",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.red))),
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(ctx);
                                                    },
                                                    child: const Text(
                                                      "No",
                                                      style: TextStyle(
                                                          color: Colors.green),
                                                    ))
                                              ],
                                            ));
                                  },
                            child: const Text("Cancel Everything")),
                      ),
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }

  createClient() async {
    setState(() {
      logoLoad = true;
    });
    await db
        .collection('clients')
        .doc(widget.number)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        moveForBooking();
      } else {
        await server.collection("clients").doc(widget.number).set({
          "name": widget.name.trim(),
          "ageEligible": widget.age,
          "member": false,
          "phone": widget.number,
          "pastServices": [],
          "registration": widget.registration,
        });
        SetOptions(merge: true);
        moveForBooking();
      }
    });
  }

  int totalTake = WalkinClientCartData.list.length;

  Future<void> moveForBooking() async {
    try {
      await db
          .collection("accounts")
          .doc("support@3rdeyesmanagement.in")
          .get()
          .then((value) => {
                SendMessageCloud.sendPushMessage(
                    value["token"],
                    "You got $totalTake Walk-in Clients for massage in ${Spa.getSpaName} paid by $_result",
                    "Walk-in Clients")
              })
          .whenComplete(() => {
                WidgetsBinding.instance.addPostFrameCallback(
                    (_) => Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookSession(
                                    total: widget.total,
                                    name: widget.name,
                                    phoneNumber: widget.number.toString(),
                                    modeOfPayment: _result,
                                    result: _result,
                                  ),
                                ),
                               );
                          }
                        })),
              });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Something Wrong in cloud")));
    }
  }

  void error() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Something went wrong")));
  }

  home() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Home(),
        ));
  }
}
