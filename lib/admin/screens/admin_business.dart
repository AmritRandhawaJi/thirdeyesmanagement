import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../modal/member_details_page.dart';
import '../../screens/walking_details_page.dart';

class AdminBusiness extends StatefulWidget {
  const AdminBusiness({Key? key}) : super(key: key);

  @override
  State<AdminBusiness> createState() => _AdminBusinessState();
}

class _AdminBusinessState extends State<AdminBusiness> {
  final searchController = TextEditingController();
  final GlobalKey<FormState> searchKey = GlobalKey<FormState>();
  final db = FirebaseFirestore.instance;
  bool loading = false;
  late DocumentSnapshot databaseData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      body: SingleChildScrollView(
          child: SafeArea(
              child: Column(
        children: [
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
          CupertinoButton(
              color: Colors.green,
              onPressed: (){
            _searchClient(searchController.value.text);
          }, child: const Text("Search"))
        ],
      ))),
    );
  }

  Future<void> _searchClient(String query) async {
    await FirebaseFirestore.instance.enableNetwork();
    await db
        .collection('clients')
        .doc(query)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      databaseData = documentSnapshot;
      if (documentSnapshot.exists) {
        goForClient();
      } else {
        setState(() {
          loading = false;
        });
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text(
                    "No Client Found",
                    style: TextStyle(color: Colors.red),
                  ),
                  content: const Text(
                    "Client not registered with us.",
                    style: TextStyle(fontFamily: "Montserrat"),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                        },
                        child: const Text("Try Again"))
                  ],
                ));
      }
    });
  }

  goForClient() {
    if (databaseData["member"]) {
      setState(() {
        loading = false;
      });
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemberDetailsPage(
              phoneNumber: databaseData["phone"],
              member: databaseData["member"],
              age: databaseData["age"],
              name: databaseData.get("name"),
              registration: databaseData.get("registration"),
              pastServices: databaseData.get("pastServices"),
              validity: databaseData.get("validity"),
              package: databaseData.get("package"),
              massages: databaseData.get("massages"),
              pendingMassage: databaseData.get("pendingMassage"),
              paid: databaseData.get("paid"),
              paymentType: databaseData.get("paymentMode"),
            ),
          ));
    } else if (databaseData["member"] == false) {
      setState(() {
        loading = false;
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WalkingDetailsPage(
                    name: databaseData.get("name"),
                    age: databaseData.get("ageEligible"),
                    member: databaseData.get("member"),
                    pastServices: databaseData.get("pastServices"),
                    phone: databaseData.get("phone"),
                    registration: databaseData.get("registration"),
                  )));
    }
  }
}
