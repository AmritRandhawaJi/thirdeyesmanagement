import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:thirdeyesmanagement/modal/assgined_spa.dart';
import 'package:thirdeyesmanagement/modal/twilio.dart';
import 'package:thirdeyesmanagement/modal/walkin_client_cart_data.dart';
import 'package:thirdeyesmanagement/screens/home.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

class BookSession extends StatefulWidget {
  final String phoneNumber;
  final String modeOfPayment;
  final String name;
  final int total;
  final String result;

  const BookSession({
    super.key,
    required this.phoneNumber,
    required this.modeOfPayment,
    required this.name,
    required this.result,
    required this.total,
  });

  @override
  State<BookSession> createState() => _BookSessionState();
}

class _BookSessionState extends State<BookSession> {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  late List<dynamic> values;
  List<dynamic> finalize = [];
  final offerCreateController = TextEditingController();
  String manager = FirebaseAuth.instance.currentUser!.email.toString();
  final db = FirebaseFirestore.instance;
  String month = DateFormat.MMMM().format(DateTime.now());
  String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  bool fetched = false;
  final PanelController _pc1 = PanelController();
  double panelHeightClosed = 0;
  double panelHeightOpen = 0;
  bool loaded = false;
  TextEditingController therapistControl = TextEditingController();
  TextEditingController nameControl = TextEditingController();
  final GlobalKey<FormState> nameKey = GlobalKey<FormState>();
  final GlobalKey<FormState> offerKey = GlobalKey<FormState>();
  final GlobalKey<FormState> therapistKey = GlobalKey<FormState>();
  final offerController = TextEditingController();
  int item = 0;
  bool listEmpty = false;
  DateTime years = DateTime.now();
  bool allSet = false;
  bool loading = false;
  late TwilioFlutter twilioFlutter;
  bool applied = false;

  bool updating = false;

  @override
  void dispose() {
    db.terminate();
    super.dispose();
  }

  late int _tillSale;

  Future<void> getValues() async {
    await db
        .collection(years.year.toString())
        .doc(Spa.getSpaName)
        .collection(month)
        .doc("till Sale")
        .get()
        .then((value) async =>
            {_tillSale = await value.get("Walkin ${widget.modeOfPayment}")});
  }

  @override
  void initState() {
    twilioFlutter = TwilioFlutter(
        accountSid: Twilio.accountSID,
        authToken: Twilio.authToken,
        twilioNumber: Twilio.number);
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => Future.delayed(const Duration(seconds: 2), () {
              getValues();
              server();
            }));

    sendMessage();
    super.initState();
  }

  void sendMessage() {
    try {
      twilioFlutter.sendSMS(
          toNumber: "+91${widget.phoneNumber}",
          messageBody:
              "Welcome to  ${Spa.getSpaName}, Thanks for choosing our services");
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
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
      ],
    );
  }

  Widget _body() {
    return Scaffold(
      backgroundColor: const Color(0xffedf8ff),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            const SizedBox(height: 20),
            Column(
              children: [
                const Text("Welcome,",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "Montserrat",
                      color: Colors.black38,
                    )),
                Text(Spa.getSpaName,
                    style: const TextStyle(
                        fontSize: 24,
                        fontFamily: "Montserrat",
                        color: Colors.green,
                        fontWeight: FontWeight.bold)),
                const Text("Booking Manager", style: TextStyle(fontSize: 18)),
                Text(manager,
                    style: const TextStyle(
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              alignment: Alignment.center,
              child: ClipPath(
                clipper: ClipPathClass(),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 1.5,
                  height: MediaQuery.of(context).size.width / 1.5,
                  child: DelayedDisplay(
                    child: Image.asset(
                      "assets/booking.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            applied
                ? Text("Rs.${offerController.value.text} is applied.")
                : Container(),
            applied
                ? Container()
                : Padding(
                    padding: const EdgeInsets.all(30),
                    child: Form(
                      key: offerKey,
                      child: TextFormField(
                        showCursor: false,
                        maxLength: 10,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        controller: offerController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter discount amount";
                          } else if (WalkinClientCartData.values[item]
                                  ["price"] <=
                              int.parse(offerController.value.text)) {
                            return "Not a valid discount";
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                onPressed: () {
                                  if (offerKey.currentState!.validate()) {
                                    setState(() {
                                      applied = true;
                                    });
                                  }
                                },
                                child: const Text("Apply"),
                              ),
                            ),
                            counterText: "",
                            filled: true,
                            hintText: "Discount",
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide.none,
                            )),
                      ),
                    ),
                  ),
            ListView.builder(
              itemCount: WalkinClientCartData.list.length,
              itemBuilder: (BuildContext context, int index) {
                int sNo = index + 1;
                return Card(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text("($sNo)",
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.black38)),
                          Text(
                              WalkinClientCartData
                                      .values[WalkinClientCartData.list[index]]
                                  ["massageName"],
                              style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 18)),
                        ],
                      ),
                      TextButton(
                          onPressed: () {
                            panelHeightOpen =
                                MediaQuery.of(context).size.height - 100;
                            panelHeightClosed =
                                MediaQuery.of(context).size.height / 3;
                            setState(() {
                              _pc1.open();
                              item = index;
                            });
                          },
                          child: const Text(
                            "Add Therapist & Client Name",
                            style: TextStyle(
                                fontFamily: "Montserrat", color: Colors.green),
                          )),
                    ],
                  ),
                );
              },
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
            ),
            const SizedBox(
              height: 30,
            ),
            allSet
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        "assets/checkMark.png",
                        width: MediaQuery.of(context).size.width / 2,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.width - 100,
                          width: MediaQuery.of(context).size.width - 100,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.green,
                          ))
                    ],
                  )
                : Container(),
          ]),
        ),
      ),
    );
  }

  Future<void> createBooking() async {
    db.collection("clients").doc(widget.phoneNumber).update({
      "pastServices": FieldValue.arrayUnion([
        {
          "spaName": Spa.getSpaName,
          "date": DateFormat('dd-MM-yyyy').format(DateTime.now()),
          "time": DateFormat.jm().format(DateTime.now()),
          "clientName": nameControl.value.text,
          "modeOfPayment": widget.modeOfPayment,
          "massageName": WalkinClientCartData.list[item],
          "therapist": therapistControl.value.text,
        }
      ])
    }).whenComplete(() => {serverCall(item)});
  }

  _panel(ScrollController sc) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 4,
                width: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white),
              ),
            ),
            listEmpty
                ? Container()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        WalkinClientCartData.values[item]["massageName"],
                        style: const TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: nameKey,
                child: TextFormField(
                  showCursor: false,
                  keyboardType: TextInputType.name,
                  controller: nameControl,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter client name";
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      hintText: "Client Name",
                      prefixIcon: const Icon(Icons.search,
                          color: Colors.black54, size: 20),
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      )),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: therapistKey,
                child: TextFormField(
                  showCursor: false,
                  keyboardType: TextInputType.name,
                  controller: therapistControl,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter therapist name";
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      hintText: "Therapist Name",
                      prefixIcon: const Icon(Icons.female,
                          color: Colors.pink, size: 20),
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      )),
                ),
              ),
            ),
            updating
                ? const CircularProgressIndicator(
                    strokeWidth: 1,
                  )
                : CupertinoButton(
                    color: CupertinoColors.activeGreen,
                    child: const Text("Start"),
                    onPressed: () async {
                      if (nameKey.currentState!.validate() |
                          therapistKey.currentState!.validate()) {
                        setState(() {
                          updating = true;
                        });
                        await createBooking();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Field required")));
                      }
                    }),
            DelayedDisplay(child: Image.asset("assets/bookSessionFinal.png")),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: CupertinoButton(
                  color: CupertinoColors.destructiveRed,
                  child: const Text("Cancel"),
                  onPressed: () {
                    panelHeightClosed = 0;
                    panelHeightOpen = 0;
                    setState(() {
                      _pc1.close();
                    });
                  }),
            ),
          ],
        ),
      ),
    );
  }

  late int _newAmount;

  Future<void> serverCall(int item) async {
    if (applied) {
      double discount = double.parse(offerController.value.text) /
          WalkinClientCartData.list.length;
      offerController.text = discount.toString();
      _newAmount =
          WalkinClientCartData.values[item]["price"] - discount.toInt();

      _tillSale = _tillSale + _newAmount;
    } else {
      _tillSale = WalkinClientCartData.list[item]["price"] + _tillSale;
    }

    await db
        .collection(years.year.toString())
        .doc(Spa.getSpaName)
        .collection(month)
        .doc(currentDate)
        .collection("walkin clients")
        .doc(widget.modeOfPayment)
        .update(
      {
        widget.result: FieldValue.arrayUnion([
          {
            "clientId": widget.phoneNumber,
            "clientName": widget.name,
            "massageName": WalkinClientCartData.list[item]["price"],
            "time": DateFormat.jm().format(DateTime.now()),
            "date": currentDate,
            "modeOfPayment": widget.result,
            "manager": FirebaseAuth.instance.currentUser!.email.toString(),
            "amountPaid": applied
                ? _newAmount
                : WalkinClientCartData.list[item]["price"],
          }
        ]),
      },
    ).whenComplete(() async => {
              setState(() {
                panelHeightClosed = 0;
                panelHeightOpen = 0;
                _pc1.close();
                updating = false;
                WalkinClientCartData.list.removeAt(item);
              }),
              if (WalkinClientCartData.list.isEmpty)
                {
                  await db
                      .collection(years.year.toString())
                      .doc(Spa.getSpaName)
                      .collection(month)
                      .doc("till Sale")
                      .update({"Walkin ${widget.result}": _tillSale}),
                  {
                    setState(() {
                      allSet = true;
                      listEmpty = true;
                    }),
                    WidgetsBinding.instance.addPostFrameCallback(
                        (_) => Future.delayed(const Duration(seconds: 2), () {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Home(),
                                  ),
                                  (route) => false);
                            })),
                  }
                }
            });
  }

  Future<void> server() async {
    await db
        .collection(years.year.toString())
        .doc(Spa.getSpaName)
        .collection(month)
        .doc(currentDate)
        .collection("walkin clients")
        .doc(widget.modeOfPayment)
        .get()
        .then((data) async => {
              if (!data.exists)
                {
                  await db
                      .collection(years.year.toString())
                      .doc(Spa.getSpaName)
                      .collection(month)
                      .doc(currentDate)
                      .collection("walkin clients")
                      .doc(widget.modeOfPayment)
                      .set({
                    widget.modeOfPayment: [],
                  })
                }
            });
  }
}

class ClipPathClass extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 30);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstPoint = Offset(size.width / 2, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstPoint.dx, firstPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 4), size.height);
    var secondPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondPoint.dx, secondPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
