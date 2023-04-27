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
import 'package:thirdeyesmanagement/modal/twilio.dart';
import 'package:thirdeyesmanagement/modal/walkin_client_cart_data.dart';
import 'package:thirdeyesmanagement/screens/home.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

class BookMembershipFinal extends StatefulWidget {
  final String phoneNumber;
  final String modeOfPayment;
  final bool member;

  final int pendingMassage;

  const BookMembershipFinal(
      {super.key,
      required this.phoneNumber,
      required this.modeOfPayment,
      required this.member,
      required this.pendingMassage});

  @override
  State<BookMembershipFinal> createState() => _BookMembershipFinalState();
}

class _BookMembershipFinalState extends State<BookMembershipFinal> {
  late List<dynamic> values;
  List<dynamic> finalize = [];
  String manager = FirebaseAuth.instance.currentUser!.email.toString();
  final db = FirebaseFirestore.instance;

  bool fetched = false;

  final PanelController _pc1 = PanelController();

  double panelHeightClosed = 0;
  double panelHeightOpen = 0;
  bool loaded = false;

  TextEditingController therapistControl = TextEditingController();
  TextEditingController nameControl = TextEditingController();
  final GlobalKey<FormState> nameKey = GlobalKey<FormState>();
  final GlobalKey<FormState> therapistKey = GlobalKey<FormState>();
  DateTime years = DateTime.now();
  int item = 0;

  bool listEmpty = false;

  bool allSet = false;

late TwilioFlutter twilioFlutter;
  @override
  void initState() {
    twilioFlutter = TwilioFlutter(
        accountSid: Twilio.accountSID,
        authToken: Twilio.authToken,
        twilioNumber: Twilio.number);
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
  void dispose() {

    db.terminate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xff2b6747),
      body: Stack(
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
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0)),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    return Scaffold(
      backgroundColor: const Color(0xffedf8ff),
      resizeToAvoidBottomInset: false,
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
                      color: Colors.deepOrange,
                    )),
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
                          child: const Text("Add Therapist & Client Name")),
                      const SizedBox(
                        height: 20,
                      )
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

  Future<void> createBooking(int index) async {

    await db
        .collection("clients")
        .doc(widget.phoneNumber)
        .update({"pendingMassage": widget.pendingMassage - WalkinClientCartData.list.length})
        .then((value) => {
      db.collection("clients").doc(widget.phoneNumber).set({
        "pastServices": FieldValue.arrayUnion([
          {
            "spaName": Spa.getSpaName,
            "date": DateFormat('dd-MM-yyyy').format(DateTime.now()),
            "time": DateFormat.jm().format(DateTime.now()),
            "clientName": nameControl.value.text,
            "modeOfPayment": widget.modeOfPayment,
            "massageName": WalkinClientCartData
                .values[WalkinClientCartData.list[index]]["massageName"],
            "therapist": therapistControl.value.text,
          },
        ])
      }, SetOptions(merge: true))
    });
    await  saleAddMember(index);
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
                        WalkinClientCartData
                                .values[WalkinClientCartData.list[item]]
                            ["massageName"],
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
            CupertinoButton(
                color: CupertinoColors.activeGreen,
                child: const Text("Start"),
                onPressed: () async {
                  if (!nameKey.currentState!.validate() |
                      !therapistKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Field required")));
                  } else {
                    panelHeightClosed = 0;
                    panelHeightOpen = 0;
                    setState(() {
                      _pc1.close();
                    });
                   await createBooking(item);
                    therapistControl.clear();
                    nameControl.clear();
                    setState(() {
                    WalkinClientCartData.list.removeAt(item);
                    });
                    if (WalkinClientCartData.list.isEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback(
                              (_) => Future.delayed(const Duration(seconds: 2), () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Home(),
                                    ),
                                        (route) => false);
                          }));
                      setState(() {
                        allSet = true;
                        listEmpty = true;
                      });
                    }
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

  int totalTake = WalkinClientCartData.list.length;
  int tillMembers = 0;

  Future<void> saleAddMember(int index) async {
    String month = DateFormat.MMMM().format(DateTime.now());
    String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

    try {
      await db
          .collection(years.year.toString())
          .doc(Spa.getSpaName)
          .collection(month)
          .doc("till Sale").get().then((value) => {
        tillMembers = value["Members"],
        print(tillMembers)
      }).whenComplete(() async => {
      await db
          .collection(years.year.toString())
          .doc(Spa.getSpaName)
          .collection(month)
          .doc("till Sale")
          .update({
      "Members": tillMembers + totalTake
      })
      });

        await db
            .collection(years.year.toString())
            .doc(Spa.getSpaName)
            .collection(month)
            .doc(currentDate)
            .collection("today")
            .doc("Members")
            .set({
          "all": FieldValue.arrayUnion([
            {
              "clientId": widget.phoneNumber,
              "clientType": "Membership",
              "totalMassages": totalTake,
              "therapistName": therapistControl.value.text,
              "serviceClientName": nameControl.value.text,
              "massageName": WalkinClientCartData
                  .values[WalkinClientCartData.list[index]]["massageName"],
              "date": DateFormat('dd-MM-yyyy').format(DateTime.now()),
              "time": DateFormat.jm().format(DateTime.now()),
              "manager": FirebaseAuth.instance.currentUser!.email.toString(),
            }
          ]),
        }, SetOptions(merge: true)).then((value) async => {
        await  db.collection("accounts").doc("support@3rdeyesmanagement.in").get().then((value) => {
            SendMessageCloud.sendPushMessage(value["token"], "You got $totalTake visitor for massage in ${Spa.getSpaName}", "Member Visit")
          })

        });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error")));
    }
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
