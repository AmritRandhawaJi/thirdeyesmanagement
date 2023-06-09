import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:thirdeyesmanagement/modal/assgined_spa.dart';
import 'package:thirdeyesmanagement/modal/send_push_message.dart';
import 'package:thirdeyesmanagement/screens/home.dart';

import 'book_session_membership.dart';

class MoveToMemberPay extends StatefulWidget {
  final String name;
  final int amount;
  final bool age;
  final bool member;
  final String package;
  final int massages;
  final String validity;
  final String number;

  const MoveToMemberPay(
      {super.key,
      required this.name,
      required this.amount,
      required this.age,
      required this.member,
      required this.package,
      required this.massages,
      required this.validity,
      required this.number});

  @override
  State<MoveToMemberPay> createState() => _MoveToMemberPayState();
}

class _MoveToMemberPayState extends State<MoveToMemberPay> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  PanelController pc = PanelController();
  bool loading = false;
  bool paymentSelected = true;
  String _result = "Cash";
  final offerController = TextEditingController();
  final GlobalKey<FormState> offerKey = GlobalKey<FormState>();
  double panelHeightClosed = 0;
  double panelHeightOpen = 0;
  late int valid = 0;
  DateTime years = DateTime.now();
  bool applied = false;

  late Timer timer;

  bool logoLoad = false;

  var pastServices = [];

  @override
  void dispose() {
    db.terminate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double panelHeightClosed = MediaQuery.of(context).size.height / 4.5;
    double panelHeightOpen = MediaQuery.of(context).size.height - 220;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          pc.open();
        },
        child: SlidingUpPanel(
          minHeight: panelHeightClosed,
          maxHeight: panelHeightOpen,
          parallaxEnabled: true,
          parallaxOffset: .5,
          body: _body(),
          controller: pc,
          panelBuilder: (sc) => panel(sc),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
        ),
      ),
    );
  }

  Future<void> createClient() async {
    final today = DateTime.now();

    await db
        .collection("clients")
        .doc(widget.number)
        .get()
        .then((value) => {pastServices = value.get("pastServices")})
        .whenComplete(() async => await db.collection("clients").doc(widget.number).set({
                "name": widget.name,
                "age": widget.age ? "Eligible" : "Not Eligible",
                "member": true,
                "phone": widget.number,
                "registration": DateFormat.yMMMd().add_jm().format(today),
                "package": widget.package,
                "notify": false,
                "paymentMode": _result,
                "paid": widget.amount,
                "validity": widget.validity,
                "massages": widget.massages,
                "pendingMassage": widget.massages,
                "pastServices": pastServices
              }, SetOptions(merge: true)).then((value) => {
                    setState(() {
                      loading = false;
                    }),
                    saleAddingToServer()
                  })
            );
  }

  saleAddingToServer() async {
    String month = DateFormat.MMMM().format(DateTime.now());
    String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

    await db
        .collection(years.year.toString())
        .doc(Spa.getSpaName)
        .collection(month)
        .doc("till Sale")
        .update({"Membership $_result": widget.amount});

    await db
        .collection(years.year.toString())
        .doc(Spa.getSpaName)
        .collection(month)
        .doc(currentDate)
        .collection("Membership Sold")
        .doc("Membership Sold")
        .set({
      _result: FieldValue.arrayUnion([
        {
          "clientType": "Membership Sold",
          "clientName": widget.name,
          "clientId": widget.number,
          "date": currentDate,
          "time": DateFormat.jm().format(DateTime.now()),
          "paymentMode": _result,
          "manager": FirebaseAuth.instance.currentUser!.email.toString(),
          "amountPaid": widget.amount,
          "package": widget.package,
          "massages": widget.massages,
        }
      ]),
    }, SetOptions(merge: true)).then((value) async => {
              await db
                  .collection("accounts")
                  .doc("support@3rdeyesmanagement.in")
                  .get()
                  .then((value) => {
                        SendMessageCloud.sendPushMessage(
                            value["token"],
                            "One Membership Sold to ${widget.name} client paid by $_result in ${Spa.getSpaName}",
                            "Membership Sold"),
                      }),
              setState(() {
                loading = false;
              }),
            });
    showAlert();
  }

  _body() {
    return DelayedDisplay(
      slidingCurve: Curves.bounceInOut,
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 15),
                child: Text(
                  "Congratulations 🎉",
                  style: TextStyle(fontFamily: "Montserrat", fontSize: 18),
                ),
              ),
              Text(
                widget.name,
                style: const TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              Image.asset(
                "assets/memberPayScreen.png",
                width: MediaQuery.of(context).size.width - 100,
                height: MediaQuery.of(context).size.width - 100,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Your ${widget.package} package is activated till ${widget.validity} Please pay Rs.${widget.amount}/- on the reception to start your membership",
                  style: const TextStyle(
                      wordSpacing: 2,
                      fontFamily: "Montserrat",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                    "You got ${widget.massages} Massages in this package",
                    style: const TextStyle(
                        wordSpacing: 2,
                        fontFamily: "Montserrat",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.activeGreen)),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 3,
              )
            ],
          ),
        ),
      ),
    );
  }

  panel(ScrollController sc) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    color: Colors.blueGrey[200]),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text("Choose Mode of Payment",
                  style: TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
            Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        child: RadioListTile(
                            activeColor: Colors.green,
                            title:  const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text('Cash'),
                                Icon(
                                  Icons.currency_rupee_outlined,
                                  color: Colors.green,
                                )
                              ],
                            ),
                            value: "Cash",
                            groupValue: _result,
                            onChanged: (value) {
                              setState(() {
                                paymentSelected = true;
                                _result = value!;
                              });
                            }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        child: RadioListTile(
                            activeColor: Colors.green,
                            title:  const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text('Card'),
                                Icon(
                                  Icons.credit_card,
                                  color: Colors.blueGrey,
                                )
                              ],
                            ),
                            value: 'Card',
                            groupValue: _result,
                            onChanged: (value) {
                              setState(() {
                                paymentSelected = true;

                                _result = value!;
                              });
                            }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        child: RadioListTile(
                            activeColor: Colors.green,
                            title:  const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text('UPI'),
                                Icon(
                                  Icons.online_prediction_rounded,
                                  color: Colors.blue,
                                )
                              ],
                            ),
                            value: 'UPI',
                            groupValue: _result,
                            onChanged: (value) {
                              setState(() {
                                paymentSelected = true;
                                _result = value!;
                              });
                            }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        child: RadioListTile(
                            activeColor: Colors.green,
                            title:  const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text('Wallet'),
                                Icon(Icons.wallet),
                              ],
                            ),
                            value: "Wallet",
                            groupValue: _result,
                            onChanged: (value) {
                              setState(() {
                                paymentSelected = true;
                                _result = value!;
                              });
                            }),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    loading
                        ?  const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                        onPressed: loading
                            ? null
                            : () async {
                                setState(() {
                                  loading = true;
                                });
                                timer =
                                    Timer(const Duration(seconds: 2), () async {
                                  setState(() {
                                    logoLoad = true;
                                  });
                                  await createClient();
                                });
                              },
                        child: const Text("Payment Confirmed",
                            style: TextStyle(fontFamily: "Montserrat"))),
                    logoLoad
                        ? Center(
                            child: SizedBox(
                                width: MediaQuery.of(context).size.width / 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset("assets/checkMark.png"),
                                )))
                        : Container(),
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Center(
                        child: CupertinoButton(
                            color: Colors.red,
                            onPressed: () {
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                        icon: const Icon(
                                            Icons.add_alert_rounded,
                                            color: Colors.green),
                                        title: const Text(
                                          "Are you sure?",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        content: const Text(
                                            "Would you like to cancel membership?.",
                                            style: TextStyle(
                                                fontFamily: "Montserrat")),
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
                                                              .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          "Canceled"))),
                                                        });
                                              },
                                              child: const Text("Yes",
                                                  style: TextStyle(
                                                      color: Colors.red))),
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

  void home() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Home(),
        ));
  }

  void showAlert() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) => AlertDialog(
              icon: const Icon(Icons.add_alert_rounded, color: Colors.green),
              title: const Text(
                "All Set!",
                style: TextStyle(color: Colors.green),
              ),
              content: const Text("Would you like to book session or go home?.",
                  style: TextStyle(fontFamily: "Montserrat")),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookSessionMembership(
                              totalMassages: widget.massages,
                              pendingMassages: widget.massages,
                              number: widget.number,
                              package: widget.package,
                              member: widget.member,
                              paymentMode: _result,
                            ),
                          ),
                          (route) => false);
                    },
                    child: const Text(
                      "Book Session",
                      style: TextStyle(color: Colors.green),
                    )),
                TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Home(),
                          ),
                          (route) => false);
                    },
                    child: const Text("Home"))
              ],
            ));
  }
}
