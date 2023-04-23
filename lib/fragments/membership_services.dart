import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thirdeyesmanagement/modal/assgined_spa.dart';

class MembershipServices extends StatefulWidget {
  const MembershipServices({Key? key}) : super(key: key);

  @override
  State<MembershipServices> createState() => _MembershipServicesState();
}

class _MembershipServicesState extends State<MembershipServices> {
  bool loadPanel = false;

  final db = FirebaseFirestore.instance;
  List<dynamic> panelValues = [];

  @override
  void initState() {
    valuesGet();
    super.initState();
  }

  Future<void> valuesGet() async {
    try {
      await db
          .collection("spa")
          .doc(Spa.getSpaName)
          .get()
          .then((DocumentSnapshot documentSnapshot) async {
        if (documentSnapshot.exists) {
          panelValues = await documentSnapshot.get("services");
          setState(() {
            loadPanel = true;
          });
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Services Coming Soon")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: loadPanel
            ? SingleChildScrollView(
                child: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "We offer",
                              style: TextStyle(
                                  fontFamily: "Montserrat", fontSize: 22),
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Go Back"))
                          ],
                        ),
                      ),
                      ListView.builder(
                        itemCount: panelValues.length - 1,
                        itemBuilder: (BuildContext context, int index) {
                          List array = panelValues[index]["includeServices"];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        panelValues[index]["massageName"],
                                        style: const TextStyle(
                                            fontFamily: "Montserrat",
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        "Rs.${panelValues[index]["price"]}",
                                        style: const TextStyle(
                                            fontFamily: "Montserrat",
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        "Room Type: ${panelValues[index]["roomType"]}",
                                        style: const TextStyle(
                                            fontFamily: "Montserrat",
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return Column(
                                          children: [
                                            Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      const Text("• "),
                                                      Text(array[index],
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  "Montserrat")),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        );
                                      },
                                      itemCount: array.length)
                                ],
                              ),
                            ),
                          );
                        },
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                      ),
                    ],
                  ),
                ),
              )
            : Container(),
      ),
    );
  }
}
