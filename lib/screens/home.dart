import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:thirdeyesmanagement/fragments/all_sale.dart';
import 'package:thirdeyesmanagement/modal/account_setting.dart';
import 'package:thirdeyesmanagement/modal/assgined_spa.dart';
import 'package:thirdeyesmanagement/modal/twilio.dart';
import 'package:thirdeyesmanagement/screens/test.dart';
import 'package:thirdeyesmanagement/screens/verification.dart';
import 'package:thirdeyesmanagement/screens/walkin_clients.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final double _initFabHeight = 120.0;
  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  final GlobalKey<FormState> searchKey = GlobalKey<FormState>();
  final double _panelHeightClosed = 95.0;
  final searchController = TextEditingController();
  final db = FirebaseFirestore.instance;

  late DocumentSnapshot databaseData;
  String paymentType = "Cash";

  List<dynamic> listed = [];
  List<dynamic> panelData = [];
  String month = DateFormat.MMMM().format(DateTime.now());

  bool panelLoad = false;

  bool panelLoading = false;
  dynamic walkinCash = 0;
  dynamic walkinCard = 0;
  dynamic walkinUPI = 0;
  dynamic walkinWallet = 0;
  dynamic membershipCash = 0;
  dynamic memberShipCard = 0;
  dynamic memberShipUPI = 0;
  dynamic memberShipWallet = 0;
  dynamic members = 0;

  bool loading = false;

  bool server = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    _fabHeight = _initFabHeight;
    super.initState();
  }

  int currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  DateTime years = DateTime.now();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  onPageChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  setValues() async {
    try {
      FirebaseFirestore.instance
          .collection(years.year.toString())
          .doc(Spa.getSpaName)
          .collection(month)
          .doc("till Sale")
          .get()
          .then((value) => {
                if (!value.exists)
                  {
                    db
                        .collection(years.year.toString())
                        .doc(Spa.getSpaName)
                        .collection(month)
                        .doc("till Sale")
                        .set({
                      "Walkin Cash": walkinCash,
                      "Walkin Card": walkinCard,
                      "Walkin UPI": walkinUPI,
                      "Walkin Wallet": walkinWallet,
                      "Membership Cash": membershipCash,
                      "Membership Card": memberShipCard,
                      "Membership UPI": memberShipUPI,
                      "Membership Wallet": memberShipWallet,
                      "Members": members,
                    }, SetOptions(merge: true)),
                  }
              });
    } catch (e) {
      db
          .collection(years.year.toString())
          .doc(Spa.getSpaName)
          .collection(month)
          .doc("till Sale")
          .set({
        "Walkin Cash": walkinCash,
        "Walkin Card": walkinCard,
        "Walkin UPI": walkinUPI,
        "Walkin Wallet": walkinWallet,
        "Membership Cash": membershipCash,
        "Membership Card": memberShipCard,
        "Membership UPI": memberShipUPI,
        "Membership Wallet": memberShipWallet,
        "Members": members,
      }, SetOptions(merge: true));
    }
    setTokens();
  }

  @override
  Widget build(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height / 1.5;
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => Future.delayed(const Duration(seconds: 1), () async {
          server = true;
          if(server){
            await setValues();

          }
        }));
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFf5eee6),
      body: Stack(
        children: <Widget>[
          SlidingUpPanel(
            maxHeight: _panelHeightOpen,
            minHeight: _panelHeightClosed,
            parallaxEnabled: true,
            parallaxOffset: .5,
            body: _body(),
            onPanelOpened: () {
              onPanelOpened();
            },
            onPanelClosed: () {
              setState(() {
                panelLoad = false;
              });
            },
            collapsed: Container(
              decoration: const BoxDecoration(
                  color: Color(0xfffffff3),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30))),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      const Icon(Icons.bar_chart, color: Colors.green),
                      DelayedDisplay(
                        child: Text(
                          "•${Spa.getSpaName} Sale•",
                          style: const TextStyle(
                              fontSize: 18,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            panelBuilder: (sc) => _panel(sc),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0)),
            onPanelSlide: (double pos) => setState(() {
              _fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) +
                  _initFabHeight;
            }),
          ),
          Positioned(
              right: 20.0,
              left: 20,
              bottom: _fabHeight,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WalkinClients(),
                      ));
                },
                child: DelayedDisplay(
                  child: Card(

                    shape:  const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      //set border radius more than 50% of height and width to make circle
                    ),
                    child: SizedBox(
                        height: MediaQuery.of(context).size.width / 6,
                        width: MediaQuery.of(context).size.width /0.5,
                        child:  const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add,
                                color: Colors.green),
                            Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Text(
                                "Add-Clients",
                                style: TextStyle(
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        )),
                  ),
                ),
              )),

        ],
      ),
    );
  }

  onPanelOpened() async {
    Test test = Test();
    test.updateClients();
    setState(() {
      panelLoading = true;
    });

    await db
        .collection(years.year.toString())
        .doc(Spa.getSpaName)
        .collection(month)
        .doc("till Sale")
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        walkinCash = documentSnapshot.get("Walkin Cash");
        walkinCard = documentSnapshot.get("Walkin Card");
        walkinUPI = documentSnapshot.get("Walkin UPI");
        walkinWallet = documentSnapshot.get("Walkin Wallet");
        membershipCash = documentSnapshot.get("Membership Cash");
        memberShipCard = documentSnapshot.get("Membership Card");
        memberShipUPI = documentSnapshot.get("Membership UPI");
        memberShipWallet = documentSnapshot.get("Membership Wallet");
        members = documentSnapshot.get("Members");
        setState(() {
          panelLoad = true;
          panelLoading = false;
        });
      }
    });
  }

  Widget _panel(ScrollController sc) {
    String month = DateFormat.MMMM().format(DateTime.now());
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          controller: sc,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 30,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12.0))),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllSale(),
                    ));
              },
              child:  const Card(
                color: Colors.black54,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          "Today's Sale",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            fontFamily: "Montserrat",
                            fontSize: 24.0,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text("Total Sale :  ",
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.normal,
                        fontFamily: "Montserrat",
                      )),
                  Text(
                    month,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontFamily: "Montserrat",
                      fontSize: 24.0,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                panelLoad
                    ? DelayedDisplay(
                        child: Column(
                          children: [
                            Card(
                              child: Column(
                                children: [
                                   const Row(
                                    children: [
                                      Text(
                                        "Walkin Clients",
                                        style: TextStyle(
                                            fontFamily: "Montserrat",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      Icon(
                                        Icons.show_chart,
                                        color: Colors.green,
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Text("Cash- Rs.",
                                                style: TextStyle(
                                                    color: Colors.black54)),
                                            Text(walkinCash.toString(),
                                                style: const TextStyle(
                                                    fontFamily: "Montserrat",
                                                    fontSize: 22)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Text("Card- Rs.",
                                                style: TextStyle(
                                                    color: Colors.black54)),
                                            Text(walkinCard.toString(),
                                                style: const TextStyle(
                                                    fontFamily: "Montserrat",
                                                    fontSize: 22)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Text("UPI- Rs.",
                                                style: TextStyle(
                                                    color: Colors.black54)),
                                            Text(walkinUPI.toString(),
                                                style: const TextStyle(
                                                    fontFamily: "Montserrat",
                                                    fontSize: 22)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Text("Wallet- Rs.",
                                                style: TextStyle(
                                                    color: Colors.black54)),
                                            Text(walkinWallet.toString(),
                                                style: const TextStyle(
                                                    fontFamily: "Montserrat",
                                                    fontSize: 22)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Card(
                              child: Column(
                                children: [
                                   const Row(
                                    children: [
                                      Text(
                                        "Membership Sold",
                                        style: TextStyle(
                                            fontFamily: "Montserrat",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      Icon(
                                        Icons.graphic_eq,
                                        color: Colors.orange,
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Text("Cash- Rs.",
                                                style: TextStyle(
                                                    color: Colors.black54)),
                                            Text(membershipCash.toString(),
                                                style: const TextStyle(
                                                    fontFamily: "Montserrat",
                                                    fontSize: 22)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Text("Card- Rs.",
                                                style: TextStyle(
                                                    color: Colors.black54)),
                                            Text(memberShipCard.toString(),
                                                style: const TextStyle(
                                                    fontFamily: "Montserrat",
                                                    fontSize: 22)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Text("UPI- Rs.",
                                                style: TextStyle(
                                                    color: Colors.black54)),
                                            Text(memberShipUPI.toString(),
                                                style: const TextStyle(
                                                    fontFamily: "Montserrat",
                                                    fontSize: 22)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Text("Wallet- Rs.",
                                                style: TextStyle(
                                                    color: Colors.black54)),
                                            Text(memberShipWallet.toString(),
                                                style: const TextStyle(
                                                    fontFamily: "Montserrat",
                                                    fontSize: 22)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Card(
                              child: Column(
                                children: [
                                   const Row(
                                    children: [
                                      Text(
                                        "Members Visit",
                                        style: TextStyle(
                                            fontFamily: "Montserrat",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      Icon(
                                        Icons.directions_walk,
                                        color: Colors.blue,
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Text("Count.",
                                                style: TextStyle(
                                                    color: Colors.black54)),
                                            Text(members.toString(),
                                                style: const TextStyle(
                                                    fontFamily: "Montserrat",
                                                    fontSize: 22)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    : Container(),
                panelLoading
                    ? const CircularProgressIndicator(
                        strokeWidth: 2,
                      )
                    : Container()
              ],
            ),
          ],
        ));
  }

  Widget _body() {
    return SafeArea(
        child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DelayedDisplay(
                  child: Text(Spa.getSpaName,
                      style: const TextStyle(
                          fontSize: 22,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.bold)),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountSetting(),
                        ));
                  },
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_circle,
                        size: MediaQuery.of(context).size.width / 10,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

           const Padding(
            padding: EdgeInsets.only(left: 10, top: 10),
            child: Row(

              children: [
                DelayedDisplay(
                  child: Text("How you feeling\nToday?",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontFamily: "Montserrat",
                          color: Colors.black54,
                          fontSize: 16)),
                ),
              ],
            ),
          ),
          DelayedDisplay(
            child: Form(
              key: searchKey,
              child: Padding(
                padding: const EdgeInsets.only(top: 50,left: 10,right: 10),
                child: TextFormField(

                  showCursor: false,
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: searchController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter number";
                    } else if (value.length < 10) {
                      return "Enter 10 digits";
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      suffixIcon: loading
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 1),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                  onTap: () {
                                    if (searchKey.currentState!.validate()) {
                                      setState(() {
                                        loading = true;
                                      });
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) =>
                                              Future.delayed(
                                                  const Duration(seconds: 1), () {
                                                setState(() {
                                                  loading = false;
                                                });
                                                Navigator.push(context,
                                                    MaterialPageRoute(builder:
                                                        (BuildContext context) {
                                                  return Verification(
                                                    number: searchController
                                                        .value.text
                                                        .toString(),
                                                  );
                                                }));
                                              }));
                                    }
                                  },
                                  child: const CircleAvatar(
                                      backgroundColor: Colors.green,
                                      child: Icon(
                                        Icons.search,
                                        color: Colors.white,
                                      ))),
                            ),
                      hintText: "Search Registered Clients",
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: BorderSide.none,
                      )),
                ),
              ),
            ),
          ),

          Lottie.asset(
            'assets/mindfulness.json',
            controller: _controller,
            onLoaded: (composition) {
              // Configure the AnimationController with the duration of the
              // Lottie file and start the animation.
              _controller
                ..duration = composition.duration
                ..repeat();
            },
          ),
        ]),
      ),
    ));
  }
  Future<void> setTokens() async {
  await  db
        .collection("twilio")
        .doc("tokens").get().then((value) async => {
      Twilio.accountSID = await value.get("accountSID"),
      Twilio.authToken = await value.get("authToken"),
      Twilio.accountNumber =await value.get("accountNumber"),

    });
  }
}
