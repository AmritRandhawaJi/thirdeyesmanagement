import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminWalkin extends StatefulWidget {
  const AdminWalkin({Key? key}) : super(key: key);

  @override
  State<AdminWalkin> createState() => _AdminWalkinState();
}

class _AdminWalkinState extends State<AdminWalkin> {
  bool loaded = false;

  int total = 0;

  bool loading = true;

  bool indicator = false;

  bool image = false;

  @override
  void initState() {
    super.initState();
  }

  FirebaseFirestore db = FirebaseFirestore.instance;
  List<dynamic> listed = [];

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
            (_) =>
            Future.delayed(const Duration(seconds: 2), () {
              today();
            }));
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Column(
              children: [
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
                  child: Text("Walk-in Clients",
                      style: TextStyle(fontFamily: "Montserrat", fontSize: 22)),
                ),
                CupertinoButton(onPressed: () {
                  today();
                }, child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.refresh, color: Colors.green,),
                    Text("Refresh", style: TextStyle(color: Colors.green)),
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
                            Text(listed[index]["date"],
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w400)),
                            Text(listed[index]["time"],
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
                                Text("${listed[index]["clientName"]}",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Text(listed[index]["clientId"],
                                style: const TextStyle(
                                    fontSize: 18, fontFamily: "Montserrat")),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(listed[index]["massageName"],
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
                                "Rs.${listed[index]["amountPaid"]
                                    .toString()}/-",
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
                              "Offer Applied: ",
                              style: TextStyle(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                              listed[index]["offerApplied"]
                                  ? "Yes"
                                  : "Not Applied",
                              style: const TextStyle(),
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Text(
                              "Offer Amount: ",
                              style: TextStyle(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                              listed[index]["offerAmount"].toString(),
                              style: const TextStyle(color: Colors.green),
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
                          Text(listed[index]["modeOfPayment"],
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
                            child: Text(listed[index]["manager"],
                                style:
                                const TextStyle(fontFamily: "Montserrat")),
                          ),
                        ],
                      ),
                    ],
                  );
                },
                itemCount: listed.length,
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
                child: Image.asset("assets/adminNoSale.png")):Container(),

          ],
        ),
      ),
    );
  }

  refresh() {

    if(mounted){  setState(() {
      loaded = true;
    });
    }
  }

  Future<void> today() async {
    final prefs = await SharedPreferences.getInstance();
    String month = DateFormat.MMMM().format(DateTime.now());
    String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

    try{
      await db
          .collection(prefs.getString("spaName").toString())
          .doc(month)
          .collection(currentDate)
          .doc("sale").collection("Walkin Clients").doc("today")
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          listed =  documentSnapshot.get("Walkin Clients");
          calculate();
        } else {
          if(mounted){
            setState(() {
              total = 0;
              image= true;
              loaded = false;
              loading = false;
            });
          }
        }
      });
    }catch(e){
      setState(() {
        image= true;
        loading = false;
      });
    }


  }

  calculate() {
    List<int> array = [];
    for (int i = 0; i < listed.length; i++) {
      array.add(listed[i]["amountPaid"]);
    }
    total = array.fold(0, (p, c) => p + c);
    refresh();
  }
}
