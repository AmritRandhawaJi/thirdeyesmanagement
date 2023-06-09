import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:thirdeyesmanagement/fragments/membership_benifits.dart';
import 'package:thirdeyesmanagement/modal/assgined_spa.dart';
import 'package:thirdeyesmanagement/modal/move_to_member_pay.dart';

class MoveToMember extends StatefulWidget {
  final String number;
  final String name;

  const MoveToMember({super.key, required this.number, required this.name});

  @override
  State<MoveToMember> createState() => _MoveToMemberState();
}

class _MoveToMemberState extends State<MoveToMember> {
  final nameController = TextEditingController();
  final numberController = TextEditingController();

  @override
  void initState() {

    nameController.text = widget.name;
    numberController.text = widget.number;
    super.initState();
  }

  late int index;
  int colorIndex = 2;
  late int paid;
  List<dynamic> values = [];
  late String assignedSpa;
  late int valid = 0;
  late int massagesInclude;
  late String packageType;
  bool buttonShow = false;
  bool gold = false;
  bool platinum = false;
  String manager = FirebaseAuth.instance.currentUser!.email.toString();
  final db = FirebaseFirestore.instance;
  late DocumentSnapshot ds;
  bool loading = false;
  bool data = false;
  var arr = [];


  @override
  void dispose() {
    nameController.dispose();
    numberController.dispose();
    super.dispose();
  }

  List<dynamic> colorData = [
    const Color(0xfffcfbe8),
    const Color(0xfff7edff),
    const Color(0xffebf2ff),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Did you know?",
                      style: TextStyle(
                          color: Colors.black54, fontFamily: "Montserrat")),
                ),
                CupertinoButton(
                    color: Colors.blueGrey,
                    child:  const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.card_giftcard),
                          Text("Membership benifits?",
                              style: TextStyle(
                                  fontFamily: "Montserrat", fontSize: 18)),
                        ]),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MembershipBenifits(),
                          ));
                    }),
                const Divider(thickness: 5, color: Colors.green),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20, top: 20),
                    child: Column(
                      children: [
                        Image.asset("assets/checkMark.png",
                            width: MediaQuery
                                .of(context)
                                .size
                                .width / 5,
                            height: MediaQuery
                                .of(context)
                                .size
                                .width / 5),
                         const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text("New Registration",
                                  style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              Icon(
                                Icons.add,
                                color: Colors.green,
                              )
                            ],
                          ),
                        ),
                        Card(
                          child: TextFormField(
                            keyboardType: TextInputType.name,
                            controller: nameController,
                            enabled: false,
                            decoration: InputDecoration(
                                counterText: "",
                                filled: true,
                                hintText: "Client Name",
                                prefixIcon: const Icon(Icons.person,
                                    color: Colors.black54, size: 20),
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                )),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Card(
                            child: TextFormField(
                              maxLength: 10,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              controller: numberController,
                             enabled: false,
                              decoration: InputDecoration(
                                  counterText: "",
                                  filled: true,
                                  hintText: "Phone Number",
                                  prefixIcon: const Icon(Icons.phone,
                                      color: Colors.black54, size: 20),
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  )),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            "Choose Membership",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                fontFamily: "Montserrat"),
                          ),
                        ),
                         const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("•",
                                style: TextStyle(
                                    fontSize: 32, color: Colors.amberAccent)),
                            Text("•",
                                style: TextStyle(
                                    fontSize: 32, color: Colors.deepPurple)),
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
                                        width:
                                        MediaQuery
                                            .of(context)
                                            .size
                                            .width / 4,
                                        child: Center(
                                            child: Text(
                                              "Gold",
                                              style: TextStyle(
                                                  color: gold
                                                      ? Colors.black
                                                      : Colors.white),
                                            ))),
                                    backgroundColor: gold
                                        ? Colors.amberAccent[100]
                                        : Colors.grey)),
                            GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
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
                                        width:
                                        MediaQuery
                                            .of(context)
                                            .size
                                            .width / 4,
                                        child: Center(
                                            child: Text(
                                              "Platinum",
                                              style: TextStyle(
                                                  color: platinum
                                                      ? Colors.white
                                                      : Colors.white),
                                            ))),
                                    backgroundColor: platinum
                                        ? Colors.deepPurple
                                        : Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            const Text(
                              "Are you over 18?",
                              style:
                              TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                            Center(
                              child: CupertinoSwitch(
                                activeColor: Colors.green,
                                value: data,
                                onChanged: (value) =>
                                    setState(() {
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
                            onPressed:  () async {
                                if (!gold && !platinum) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                      content:
                                      Text("Choose Membership")));
                                } else {
                                  if (data) {
                                   await getDataValues();
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                        content:
                                        Text("Are you over 18?")));
                                  }
                                }

                            },
                            child: const Text("Create")),
                      ],
                    ),
                  ),
                ),
                Container(
                    margin: const EdgeInsets.all(50),
                    child: Image.asset(
                      "assets/addForm.png",
                    )),
                Text(manager,
                    style: const TextStyle(
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w500,
                    )),
              ]),
            )
          ]),
        ),
      ),
    );
  }


  Future<void> getDataValues() async {
    setState(() {
      loading = true;
    });
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
    });
moveToScreen();
  }

  void moveToScreen() {
    setState(() {
      loading = true;
    });
    final today = DateTime.now();
    final validTill = today.add(Duration(days: valid));
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) =>
            MoveToMemberPay(
              massages: massagesInclude,
              number: numberController.value.text.toString(),
              amount: paid,
              name: nameController.value.text,
              package: packageType,
              validity: DateFormat.yMMMd().add_jm().format(validTill),
              age: data,
              member: true,
            )));
  }
}
