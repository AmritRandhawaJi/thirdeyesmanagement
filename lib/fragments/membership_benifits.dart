import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MembershipBenifits extends StatefulWidget {
  const MembershipBenifits({
    super.key,
  });

  @override
  State<MembershipBenifits> createState() => _MembershipBenifitsState();
}

class _MembershipBenifitsState extends State<MembershipBenifits> {
  bool loaded = false;
  List<dynamic> values = [];
  List<dynamic> panelValues = [];

  final db = FirebaseFirestore.instance;
  String spaName = "";
  String address = "";
  String number = "";
  String description = "";

  var arr = [];
  var arr2 = [];
  var arr3 = [];
  var arr4 = [];
  PanelController pc = PanelController();
  final _panelHeightClosed = 0.0;
  var _panelHeightOpen = 0.0;

  late String assignedSpa;

  Future<void> getData() async {
    await db
        .collection("accounts")
        .doc(FirebaseAuth.instance.currentUser?.email.toString())
        .get()
        .then((value) async => {
            await valuesGet(value.get("assignedSpa")),
              await goldFacility(),
              await goldNotes(),
              await platinumFacility(),
              await platinumNotes(),
            });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          SlidingUpPanel(
            maxHeight: _panelHeightOpen,
            minHeight: _panelHeightClosed,
            parallaxEnabled: true,
            parallaxOffset: .5,
            body: _body(),
            controller: pc,
            panelBuilder: (sc) => _panel(sc),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0)),
            onPanelSlide: (double pos) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Future<void> valuesGet(String spaType) async {

    try {
      await db
          .collection("spa")
          .doc(spaType)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          values = documentSnapshot.get("membership");
          address = documentSnapshot.get("address");
          panelValues = documentSnapshot.get("services");
          number = documentSnapshot.get("phoneNumber");
          spaName = documentSnapshot.get("spaName");
          description = documentSnapshot.get("description");
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Services Coming Soon")));
    }
  }

  CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('spa');

  Future<void> goldFacility() async {
    QuerySnapshot querySnapshot = await collectionRef.get();

    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();

    List<dynamic> data1 = allData;

    Map map1;
    map1 = data1[0]["membership"][0]["facility"];
    map1.forEach((key, value) {
      arr.add(value);
    });
  }

  Future<void> goldNotes() async {
    QuerySnapshot querySnapshot = await collectionRef.get();
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    List<dynamic> data2 = allData;
    Map map2;
    map2 = data2[0]["membership"][0]["note"];
    map2.forEach((key, value) {
      arr2.add(value);
    });
  }

  Future<void> platinumFacility() async {
    QuerySnapshot querySnapshot = await collectionRef.get();

    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    List<dynamic> data3 = allData;

    Map map3;
    map3 = data3[0]["membership"][1]["facility"];
    map3.forEach((key, value) {
      arr3.add(value);
    });
  }

  Future<void> platinumNotes() async {
    QuerySnapshot querySnapshot = await collectionRef.get();

    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();

    List<dynamic> data4 = allData;

    Map map4;
    map4 = data4[0]["membership"][1]["note"];
    map4.forEach((key, value) {
      arr4.add(value);
    });
    setState(() {
      loaded = true;
    });
  }

  _body() {
    return Scaffold(
        body: loaded
            ? SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: SafeArea(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(spaName,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(description,
                                style: const TextStyle(
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                textAlign: TextAlign.center,
                                address,
                                style: const TextStyle(
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w400)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(number,
                                style: const TextStyle(
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w400)),
                          ),
                        ]),
                        Card(
                          color: const Color(0xfffcfbe8),
                          margin: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              ListView.builder(
                                itemCount: 1,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    children: [
                                      Text(
                                        values[0]["type"],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Montserrat",
                                            fontSize: 22),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Row(
                                            children: [
                                              const Text("Rs."),
                                              Text(
                                                  values[0]["amount"]
                                                      .toString(),
                                                  style:
                                                      const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontSize: 22)),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text("Massages: "),
                                              Text(
                                                  values[0]["massages"]
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: "Montserrat",
                                                      fontSize: 22)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: const [
                                    Text("Facility",
                                        style: TextStyle(
                                            fontFamily: "Montserrat",
                                            fontSize: 18)),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                itemCount: arr.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          arr[index],
                                          style: const TextStyle(
                                              fontFamily: "Montserrat"),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: const [
                                    Text(
                                      "Note :",
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontSize: 18,
                                          color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                itemCount: arr2.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          arr2[index],
                                          style: const TextStyle(
                                              fontFamily: "Montserrat"),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                              ),
                              CupertinoButton(
                                  color: Colors.white,
                                  onPressed: () {

                                  },
                                  child: const Text(
                                    "Massages Include",
                                    style: TextStyle(color: Colors.black),
                                  )),
                              const SizedBox(
                                height: 15,
                              )
                            ],
                          ),
                        ),
                        Card(
                          color:  const Color(0xfff7edff),
                          margin: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              ListView.builder(
                                itemCount: 1,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    children: [
                                      Text(
                                        values[1]["type"],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Montserrat",
                                            fontSize: 22),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Row(
                                            children: [
                                              const Text("Rs."),
                                              Text(
                                                  values[1]["amount"]
                                                      .toString(),
                                                  style:
                                                      const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontSize: 22)),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text("Massages: "),
                                              Text(
                                                  values[1]["massages"]
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: "Montserrat",
                                                      fontSize: 22)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: const [
                                    Text("Facility",
                                        style: TextStyle(
                                            fontFamily: "Montserrat",
                                            fontSize: 18)),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                itemCount: arr3.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          arr3[index],
                                          style: const TextStyle(
                                              fontFamily: "Montserrat"),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: const [
                                    Text(
                                      "Note :",
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontSize: 18,
                                          color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                itemCount: arr4.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          arr4[index],
                                          style: const TextStyle(
                                              fontFamily: "Montserrat"),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                              ),
                              CupertinoButton(
                                  color: Colors.white,
                                  onPressed: () async {
                                    _panelHeightOpen =
                                        MediaQuery.of(context).size.height - 80;
                                    pc.open();

                                  },
                                  child: const Text(
                                    "Massages Include",
                                    style: TextStyle(color: Colors.black),
                                  )),
                              const SizedBox(
                                height: 10,
                              )
                            ],
                          ),
                        ),
                      ]),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(
                strokeWidth: 2,
              )));
  }

  _panel(ScrollController sc) {

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      pc.close();
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.close, color: Colors.redAccent),
                        Text("Close", style: TextStyle(color: Colors.red)),
                      ],
                    ))
              ],
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "We offer",
            style: TextStyle(fontFamily: "Montserrat", fontSize: 22),
          ),
          const SizedBox(height: 15),
          ListView.builder(
            itemCount: panelValues.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(panelValues[index]["massageName"],style: const TextStyle(fontFamily: "Montserrat",fontSize: 16)),
                ],
              );
            },
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
          ),
        ],
      ),
    );
  }

}
