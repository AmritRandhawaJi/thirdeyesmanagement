import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thirdeyesmanagement/modal/assgined_spa.dart';


class MembershipWallet extends StatefulWidget {
  const MembershipWallet({Key? key}) : super(key: key);

  @override
  State<MembershipWallet> createState() => _MembershipWalletState();
}

class _MembershipWalletState extends State<MembershipWallet> {

  bool loaded = false;

  int total = 0;

  bool loading = true;

  bool indicator = false;

  bool image = false;
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<dynamic> walletListed = [];
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
            (_) => Future.delayed(const Duration(seconds: 2), () {
              todayWallet();

            }));
    return Scaffold(
      body: SingleChildScrollView(child: SafeArea(child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Column(
                children:  [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 30),
                    child: Text("Today's Sales",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 30),
                    child: Text("Membership Sold",
                        style: TextStyle(fontFamily: "Montserrat", fontSize: 22)),
                  ),
                  CupertinoButton(onPressed: (){
                    todayWallet();

                  }, child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.refresh,color: Colors.green,),
                      Text("Refresh",style: TextStyle(color: Colors.green)),
                    ],
                  ))
                ],
              ),
              Card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text("Till Sale : ",
                        style: TextStyle(color: Colors.black38)),
                    Text(
                      "Rs.$total",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.green),
                    )
                  ],
                ),
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
                              Text(walletListed[index]["date"],
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.w400)),
                              Text(walletListed[index]["time"],
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.w400)),
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
                                  Text("${walletListed[index]["clientName"]}",
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Text(walletListed[index]["clientId"],
                                  style: const TextStyle(
                                      fontSize: 18, fontFamily: "Montserrat")),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(walletListed[index]["package"],
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.bold,
                                      color:
                                      walletListed[index]["package"] == "Platinum"
                                          ? Colors.purple
                                          : Colors.amber)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text(
                                  "Rs.${walletListed[index]["amountPaid"].toString()}/-",
                                  style: const TextStyle(
                                      fontSize: 22, color: Colors.green)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text(
                                "Massages :",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text(
                                walletListed[index]["massages"].toString(),
                                style: const TextStyle(fontSize: 18),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text("Mode of payment:  ",
                                  style: TextStyle(fontSize: 16)),
                            ),
                            Text(walletListed[index]["paymentMode"],
                                style: const TextStyle(fontSize: 22)),
                          ],
                        ),
                        Row(
                          children: const [
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
                              child: Text(walletListed[index]["manager"],
                                  style:
                                  const TextStyle(fontFamily: "Montserrat")),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                  itemCount: walletListed.length,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (context, index) => const Divider(),
                )
              else
                loading
                    ? const CircularProgressIndicator(color: Colors.green,
                  strokeWidth: 2,
                ):
                Container(),
              image ?  SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width / 1.1,
                  height: MediaQuery
                      .of(context)
                      .size
                      .width / 1.1,
                  child: Image.asset("assets/noSale.png")):Container(),
            ],
          ),
        ),
      ),)),
    );
  }
  Future<void> todayWallet() async {
    String month = DateFormat.MMMM().format(DateTime.now());
    String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    DateTime years = DateTime.now();

    await db
        .collection(years.year.toString())
        .doc(Spa.getSpaName)
        .collection(month)
        .doc(currentDate).collection("Membership Sold").doc("Membership Sold")
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        try{
          walletListed = await documentSnapshot.get("Wallet");
          calculate();
        }
        catch(e){
          if(mounted)
          {
            setState(() {
              total = 0;
              image = true;
              loaded = false;
              loading = false;
            });
          }
        }

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
  refresh() {
    if (mounted) {
      setState(() {
        loaded = true;
      });
    }
  }
  calculate() {
    List<int> array = [];
    for (int i = 0; i < walletListed.length; i++) {
      array.add(walletListed[i]["amountPaid"]);
    }
    total = array.fold(0, (p, c) => p + c);
    refresh();
  }
}
