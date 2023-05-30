import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thirdeyesmanagement/fragments/membership_services.dart';
import 'package:thirdeyesmanagement/modal/assgined_spa.dart';

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

  final db = FirebaseFirestore.instance;
  String address = "";
  String number = "";
  String description = "";
  bool loadPanel = false;
  var arr = [];
  var arr2 = [];
  var arr3 = [];
  var arr4 = [];


  late String assignedSpa;

  Future<void> getData() async {
    await db
        .collection("accounts")
        .doc(FirebaseAuth.instance.currentUser?.email.toString())
        .get()
        .then((value) async => {
              await valuesGet(),
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
                    child: Text(Spa.getSpaName,
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
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
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
                                child: Row(
                                  children: [
                                    const Text("• "),
                                    Expanded(
                                      child: Text(
                                        arr[index],
                                        style: const TextStyle(
                                            fontFamily: "Montserrat",fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
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
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const MembershipServices(),));
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
                  color: const Color(0xfff7edff),
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
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text("Facility",
                                style: TextStyle(
                                    fontFamily: "Montserrat",
                                    fontSize: 18,)),
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
                                child: Row(
                                  children: [
                                    const Text("• "),

                                    Expanded(
                                      child: Text(
                                        arr3[index],
                                        style: const TextStyle(
                                            fontFamily: "Montserrat",fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
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
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const MembershipServices(),));

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
          ))
    );
  }

  Future<void> valuesGet() async {
    try {
      await db
          .collection("spa")
          .doc(Spa.getSpaName)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          values = documentSnapshot.get("membership");
          address = documentSnapshot.get("address");
          number = documentSnapshot.get("phoneNumber");
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

}
