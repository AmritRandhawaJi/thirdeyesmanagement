import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thirdeyesmanagement/modal/assgined_spa.dart';

class Cash extends StatefulWidget {
  const Cash({Key? key}) : super(key: key);

  @override
  State<Cash> createState() => _CashState();
}

class _CashState extends State<Cash> {
  bool loaded = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
            (_) => Future.delayed(const Duration(seconds: 2), () {
          todayCash();
        }));
    super.initState();
  }
  int total = 0;

  bool loading = true;

  bool indicator = false;
  DateTime years = DateTime.now();
  bool image = false;
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<dynamic> cashListed = [];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
          child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Column(
                children: [
                  CupertinoButton(
                      onPressed: () {
                        todayCash();
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh,
                            color: Colors.green,
                          ),
                          Text("Refresh",
                              style: TextStyle(color: Colors.green)),
                        ],
                      ))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Till Sale : ",
                      style: TextStyle(color: Colors.black38)),
                  Text(
                    "Rs.${total.toString()}",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.green),
                  )
                ],
              ),
              if (loaded)
                ListView.separated(
                  itemBuilder: (context, index) {
                    int sNo = index + 1;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(cashListed[index]["date"],
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400)),
                              Text(cashListed[index]["time"],
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text("$sNo.",
                                      style: const TextStyle(fontSize: 16)),
                                  Text("${cashListed[index]["clientName"]}",
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Text(cashListed[index]["clientId"],
                                  style: const TextStyle(
                                      fontSize: 18, fontFamily: "Montserrat")),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(cashListed[index]["massageName"],
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text(
                                  "Rs.${cashListed[index]["amountPaid"].toString()}/-",
                                  style: const TextStyle(
                                      fontSize: 22, color: Colors.green)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text("Mode of payment:  ",
                                  style: TextStyle(fontSize: 16)),
                            ),
                            Text(cashListed[index]["modeOfPayment"],
                                style: const TextStyle(fontSize: 22)),
                          ],
                        ),
                        const Row(
                          children: [
                            Icon(Icons.account_circle, color: Colors.blue),
                            Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text("Booking Manager",
                                  style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text(cashListed[index]["manager"],
                                  style: const TextStyle(
                                      fontFamily: "Montserrat")),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                  itemCount: cashListed.length,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (context, index) => const Divider(),
                )
              else
                loading
                    ? const CircularProgressIndicator(
                        color: Colors.green,
                        strokeWidth: 2,
                      )
                    : Container(),
              image
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width / 1.1,
                      height: MediaQuery.of(context).size.width / 1.1,
                      child: Image.asset("assets/noSale.png"))
                  : Container(),
            ],
          ),
        ),
      )),
    );
  }

  Future<void> todayCash() async {
    String month = DateFormat.MMMM().format(DateTime.now());
    String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

    await db
        .collection(years.year.toString())
        .doc(Spa.getSpaName)
        .collection(month)
        .doc(currentDate)
        .collection("walkin clients").doc("Cash")
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        cashListed = await documentSnapshot.get("Cash");
        calculate();

      } else {
        if (mounted) {
          setState(() {
            total = 0;
            image = true;
            loaded = false;
            loading = false;
          });
        }
      }
    });
  }

  refresh() async {
    if (mounted) {
      setState(() {
        loaded = true;
      });
    }
  }

  calculate() {
    List<int> array = [];
    for (int i = 0; i < cashListed.length; i++) {
      array.add(cashListed[i]["amountPaid"]);
    }
    total = array.fold(0, (p, c) => p + c);
    refresh();
  }
}
