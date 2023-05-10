import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:thirdeyesmanagement/fragments/all_sale.dart';
import 'package:thirdeyesmanagement/modal/account_setting.dart';
import 'package:thirdeyesmanagement/modal/assgined_spa.dart';
import 'package:thirdeyesmanagement/screens/memebership_add.dart';
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

class HomePageState extends State<HomePage> {
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
  bool draggable = false;

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

  bool notSet = true;

  @override
  void initState() {
    analytics.app.setAutomaticDataCollectionEnabled(true);
    _fabHeight = _initFabHeight;
    super.initState();
  }

  int currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  DateTime years = DateTime.now();

  @override
  void dispose() {
    db.clearPersistence();
    db.terminate();
    _pageController.dispose();
    super.dispose();
  }

  onPageChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  Future<void> getValues() async {
    FirebaseFirestore.instance
        .collection("accounts")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        Spa.setSpaName = await documentSnapshot.get("assignedSpa");
        setState(() {
          notSet = false;
          draggable = true;
          if (mounted) {
            setValues();
          }
        });
      }
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
  }

  @override
  Widget build(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height / 1.5;
    if (notSet) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => Future.delayed(const Duration(seconds: 1), () async {
                if (mounted) {
                  await getValues();
                }
              }));
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFe6f0f9),
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/home.png"),
                fit: BoxFit.contain,
                alignment: Alignment.center)),
        child: Stack(
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
              isDraggable: draggable,
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
                       notSet ?  SizedBox(
                           height: MediaQuery.of(context).size.width/12,
                           width: MediaQuery.of(context).size.width/12,
                           child: const CircularProgressIndicator(strokeWidth: 1,)) : DelayedDisplay(
                             child: Text(
                          "•${Spa.getSpaName} Sale•",
                          style: const TextStyle(
                                fontSize: 18, fontFamily: "Montserrat",fontWeight: FontWeight.bold),
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
                bottom: _fabHeight + 40,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WalkinClients(),
                        ));
                  },
                  child: Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30),
                          bottomRight: Radius.circular(30)),
                      //set border radius more than 50% of height and width to make circle
                    ),
                    child: SizedBox(
                        height: MediaQuery.of(context).size.width / 6,
                        width: MediaQuery.of(context).size.width / 2.3,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
                              Icon(Icons.directions_walk, color: Colors.green),
                              Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Text(
                                  "Walkin-Clients",
                                  style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ),
                )),
            Positioned(
                left: 20.0,
                bottom: _fabHeight + 40,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MembershipAdd(),
                        ));
                  },
                  child: Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          bottomLeft: Radius.circular(30)),
                    ),
                    child: SizedBox(
                        height: MediaQuery.of(context).size.width / 6,
                        width: MediaQuery.of(context).size.width / 2.3,
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Text(
                                "Membership",
                                style: TextStyle(
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Icon(Icons.add_card_sharp,
                                  color: Colors.green),
                            ),
                          ],
                        ))),
                  ),
                )),
          ],
        ),
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
              padding: const EdgeInsets.all(8.0),
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
              child: Card(
                color: Colors.black54,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
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
                                  Row(
                                    children: const [
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
                                  Row(
                                    children: const [
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
                                  Row(
                                    children: const [
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
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
             notSet ? SizedBox(
                 height: MediaQuery.of(context).size.width/12,
                 width: MediaQuery.of(context).size.width/12,
                 child: const CircularProgressIndicator(strokeWidth: 1,)): DelayedDisplay(
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
                child: CircleAvatar(
                  maxRadius: MediaQuery.of(context).size.width / 18,
                  backgroundColor: Colors.blueAccent,
                  child: const Icon(
                    Icons.account_circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 10),
          child: Row(
            children: const [
              DelayedDisplay(
                child: Text("Hey!",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Montserrat",
                        color: Colors.black87,
                        fontSize: 24)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 10),
          child: Row(
            children: const [
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
              padding: const EdgeInsets.all(30.0),
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
                                    backgroundColor: Colors.blueAccent,
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
      ]),
    ));
  }
}
