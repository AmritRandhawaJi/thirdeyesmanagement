import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:thirdeyesmanagement/modal/assgined_spa.dart';
import 'package:thirdeyesmanagement/modal/book_session_membership.dart';
import 'package:thirdeyesmanagement/modal/send_push_message.dart';
import 'package:thirdeyesmanagement/screens/home.dart';

class Renew extends StatefulWidget {
  final int massages;
  final int pendingMassage;
  final int amount;
  final String package;
  final String number;
  final String name;
  final String validity;

  const Renew(
      {super.key,
      required this.massages,
      required this.pendingMassage,
      required this.amount,
      required this.package,
      required this.validity, required this.number, required this.name,});

  @override
  State<Renew> createState() => _RenewState();
}

class _RenewState extends State<Renew> {
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

  bool logoLoad = false;

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

  Future<void> updateClient() async {
      await db.collection("clients").doc(widget.number).update({
        "package": widget.package,
        "notify": false,
        "paymentMode": _result,
        "paid": widget.amount,
        "validity": widget.validity,
        "massages": widget.massages,
        "pendingMassage": widget.pendingMassage + widget.massages,
      },).then((value) => {
            setState(() {
              loading = false;
            }),
            saleAddingToServer()
          });
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
        .collection("today")
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
                            "Membership Sold to ${widget.name} paid by $_result in ${Spa.getSpaName}",
                            "Membership Sold")
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
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: const [
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
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: const [
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
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: const [
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
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: const [
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
                        onPressed: loading
                            ? null
                            : () async {
                                setState(() {
                                  loading = true;
                                });
                                WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => Future.delayed(
                                            const Duration(seconds: 2),
                                            () async {
                                          setState(() {
                                            logoLoad = true;
                                          });
                                          await updateClient();
                                        }));
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
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Home(),), (route) => false);
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
                          pendingMassages: widget.pendingMassage + widget.massages,
                          number: widget.number,
                          package: widget.package,
                          member: true,
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

class RenewClient extends StatefulWidget {
  final int pendingMassage;
  final String number;
  final String name;

  const RenewClient({super.key, required this.pendingMassage, required this.number, required this.name});

  @override
  State<RenewClient> createState() => _RenewClientState();
}

class _RenewClientState extends State<RenewClient> {

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

  String manager = FirebaseAuth.instance.currentUser!.email.toString();
  final db = FirebaseFirestore.instance;
  bool visible = true;

  bool loading = false;
  bool data = false;
  var arr = [];

  List<dynamic> colorData = [
    const Color(0xfffcfbe8),
    const Color(0xfff7edff),
    const Color(0xffebf2ff),
  ];

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorData[colorIndex],
      body:  SingleChildScrollView(
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

            const Text("Booking Manager", style: TextStyle(fontSize: 18)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(manager,
                  style: const TextStyle(
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w500,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [

                const Text(
                  "Choose Membership",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: "Montserrat"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Text("•",
                        style: TextStyle(fontSize: 32, color: Colors.amberAccent)),
                    Text("•",
                        style: TextStyle(fontSize: 32, color: Colors.deepPurple)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Gold Membership Selected",
                                  style: TextStyle(color: Colors.black)),
                              duration: Duration(seconds: 1),
                              backgroundColor: Color(0xfffff387),
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
                                child: Center(
                                    child: Text(
                                      "Gold",
                                      style: TextStyle(
                                          color: gold ? Colors.black : Colors.white),
                                    ))),
                            backgroundColor:
                            gold ? Colors.amberAccent[100] : Colors.grey)),
                    GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Platinum Membership Selected"),
                            duration: Duration(seconds: 1),
                            backgroundColor: Colors.deepPurple,
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
                                child: Center(
                                    child: Text(
                                      "Platinum",
                                      style: TextStyle(
                                          color:
                                          platinum ? Colors.white : Colors.white),
                                    ))),
                            backgroundColor:
                            platinum ? Colors.deepPurple : Colors.grey)),
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
                      if (!gold && !platinum) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Choose Membership")));
                      } else {
                        if (data) {
                          await check();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Are you over 18?")));
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
            ),
          ]),
        ),
      )
    );
  }



  Future<void> check() async {
  try {
    await db
        .collection("spa")
        .doc(Spa.getSpaName)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        values = documentSnapshot.get("membership");
        valid = values[index]["valid"];
        paid = values[index]["amount"];
        packageType = values[index]["type"];
        massagesInclude = values[index]["massages"];
      }
    }).whenComplete(() => {
      moveToScreen()
    });
    setState(() {
      loading = true;
    });
  }catch(e){
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something went wrong")));
  }

  }


  void moveToScreen() {
    setState(() {
      loading = false;
    });
    final today = DateTime.now();
    final validTill = today.add(Duration(days: valid));
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Renew(
              massages: massagesInclude,
              pendingMassage: widget.pendingMassage,
              amount: paid,
              number : widget.number,
              package: packageType,
              name : widget.name,
              validity: DateFormat.yMMMd().add_jm().format(validTill),
            )));
  }
}
