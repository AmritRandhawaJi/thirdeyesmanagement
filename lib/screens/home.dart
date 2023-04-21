import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:thirdeyesmanagement/fragments/all_sale.dart';
import 'package:thirdeyesmanagement/modal/account_setting.dart';
import 'package:thirdeyesmanagement/modal/assgined_spa.dart';
import 'package:thirdeyesmanagement/screens/memebership_add.dart';
import 'package:thirdeyesmanagement/screens/verification.dart';
import 'package:thirdeyesmanagement/screens/walkin_clients.dart';
import '../fragments/membership_benifits.dart';

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
  final double _initFabHeight = 120.0;
  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  final double _panelHeightClosed = 95.0;
  final searchController = TextEditingController();
  final GlobalKey<FormState> searchKey = GlobalKey<FormState>();
  final db = FirebaseFirestore.instance;
  bool loading = false;
  late DocumentSnapshot databaseData;
  String paymentType = "Cash";
  bool walkin = false;
  bool membership = false;
  bool member = false;

  List<dynamic> listed = [];
  List<dynamic> panelData = [];
  String month = DateFormat.MMMM().format(DateTime.now());

  bool panelLoad = false;

  bool panelLoading = false;
  int walkinCash = 0;
  int walkinCard = 0;
  int walkinUPI = 0;
  int walkinWallet = 0;
  int membershipCash = 0;
  int memberShipCard = 0;
  int memberShipUPI = 0;
  int memberShipWallet = 0;
  int members = 0;

  @override
  void initState() {
    _fabHeight = _initFabHeight;
    super.initState();
  }

  int currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  DateTime years = DateTime.now();

  @override
  void dispose() {
    db.terminate();
    _pageController.dispose();
    super.dispose();
  }

  onPageChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height / 1.5;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFe6f0f9),
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
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    children: const [
                      Icon(Icons.bar_chart, color: Colors.green),
                      Text(
                        "Total Sale",
                        style:
                            TextStyle(fontSize: 18, fontFamily: "Montserrat"),
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
              bottom: _fabHeight - 10,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MembershipAdd(),
                      ));
                },
                child: Card(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.width / 8,
                      width: MediaQuery.of(context).size.width / 3,
                      child:  Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                             Padding(
                               padding: EdgeInsets.all(8.0),
                               child: Icon(Icons.menu_book,color: Colors.green),
                             ),
                              Text(

                        "Menu",
                        style: TextStyle(fontFamily: "Montserrat"),
                      ),
                            ],
                          ))),
                ),
              )),
        ],
      ),
    );
  }

  onPanelOpened() async {
    setState(() {
      panelLoading = true;
    });

    try {
      await db
          .collection(years.year.toString())
          .doc("Azon Spa")
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
    } catch (e) {
      setState(() {
        panelLoad = false;
        panelLoading = true;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Not found")));
    }
  }

  Widget _panel(ScrollController sc) {
    String month = DateFormat.MMMM().format(DateTime.now());
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          controller: sc,
          children: <Widget>[
            const SizedBox(
              height: 12.0,
            ),
            Row(
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
            const SizedBox(
              height: 18.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  month,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontFamily: "Montserrat",
                    fontSize: 24.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                panelLoading ? const CircularProgressIndicator() : Container()
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
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountSetting(),
                      ));
                },
                child: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child:
                      Icon(Icons.account_circle_outlined, color: Colors.white),
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
                child: const CircleAvatar(
                  backgroundColor: Colors.black,
                  child: Icon(Icons.business, color: Colors.white),
                ),
              )
            ],
          ),
        ),
        Text(
          Spa.getSpaName,
          style: const TextStyle(
              fontSize: 22,
              fontFamily: "Montserrat",
              fontWeight: FontWeight.bold),
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
        const SizedBox(
          height: 10,
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
                    suffixIcon: loading
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                                color: Colors.black, strokeWidth: 1),
                          )
                        : null,
                    counterText: "",
                    filled: true,
                    hintText: "Search Registered Clients",
                    prefixIcon: const Icon(Icons.search,
                        color: Colors.black54, size: 20),
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide.none,
                    )),
              ),
            ),
          ),
        ),
        DelayedDisplay(
          child: Center(
            child: CupertinoButton(
                color: Colors.green,
                borderRadius: BorderRadius.circular(40),
                onPressed: () {
                  if (searchKey.currentState!.validate()) {
                    setState(() {
                      loading = true;
                    });
                    WidgetsBinding.instance.addPostFrameCallback((_) =>
                        Future.delayed(const Duration(seconds: 1), () {
                          setState(() {
                            loading = false;
                          });
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            return Verification(
                              number: searchController.value.text.toString(),
                            );
                          }));
                        }));
                  }
                },
                child: const Text("Search")),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DelayedDisplay(
                  child: Card(
                color: Colors.green[200],
                child: SizedBox(
                    width: MediaQuery.of(context).size.width / 2.5,
                    height: MediaQuery.of(context).size.width / 2.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        Icon(Icons.card_giftcard, color: Colors.white),
                        Text("Add Membership",
                            style: TextStyle(
                                fontFamily: "Montserrat",
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Icon(Icons.add, color: Colors.white),
                      ],
                    )),
              )),
              DelayedDisplay(
                  child: Card(
                color: Colors.purple[100],
                child: SizedBox(
                    width: MediaQuery.of(context).size.width / 2.5,
                    height: MediaQuery.of(context).size.width / 2.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        Icon(Icons.directions_walk, color: Colors.white),
                        Text("Add Walk-In",
                            style: TextStyle(
                                fontFamily: "Montserrat", color: Colors.white)),
                        Icon(Icons.add, color: Colors.white),
                      ],
                    )),
              )),
            ],
          ),
        ),
      ]),
    ));
  }
}
