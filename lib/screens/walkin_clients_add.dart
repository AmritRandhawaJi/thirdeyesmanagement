import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:thirdeyesmanagement/modal/assgined_spa.dart';
import 'package:thirdeyesmanagement/modal/walkin_client_cart_data.dart';
import 'package:thirdeyesmanagement/screens/final_walkin_client.dart';

class WalkinClientsAdd extends StatefulWidget {
  final String name;
  final String number;
  final String age;

  const WalkinClientsAdd(
      {super.key, required this.name, required this.number, required this.age});

  @override
  State<WalkinClientsAdd> createState() => _WalkinClientsAddState();
}

class _WalkinClientsAddState extends State<WalkinClientsAdd> {
  final FirebaseFirestore _server = FirebaseFirestore.instance;
  final PanelController _pc1 = PanelController();

  List<dynamic> values = [];
  List<int> list = [];
  bool fetching = false;
  late int total = 1;
  late String description;
  late String address;
  bool loader = false;
  bool selectMassage = false;
  late int selectedIndex = 100;
  bool panelReady = false;

  bool uiLoad = false;

  @override
  void dispose() {
    _server.terminate();
    super.dispose();
  }

  @override
  void initState() {
    getValuesServices();
    super.initState();
  }



  bool loading = false;
  double panelHeightClosed = 0;
  double panelHeightOpen = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SlidingUpPanel(
            minHeight: panelHeightClosed,
            maxHeight: panelHeightOpen,
            parallaxEnabled: true,
            parallaxOffset: .5,
            body: _body(),
            controller: _pc1,
            panelBuilder: (sc) => _panel(sc),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0)),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.shopping_bag),
        onPressed: () {
          panelHeightOpen = MediaQuery.of(context).size.height;
          panelHeightClosed = MediaQuery.of(context).size.height / 1.5;
          setState(() {
            _pc1.open();
          });
        },
      ),
      body: uiLoad ?  SingleChildScrollView(
          child: SafeArea(
              child: fetching
                  ? Column(
                      children: [
                        Text(
                          Spa.getSpaName,
                          style: const TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          description,
                          style: const TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 14,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(address,
                              style: const TextStyle(
                                  fontFamily: "Montserrat", fontSize: 10),
                              textAlign: TextAlign.center),
                        ),
                        ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: values.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                  panelHeightOpen =
                                      MediaQuery.of(context).size.height;
                                  panelHeightClosed =
                                      MediaQuery.of(context).size.height / 1.5;
                                  list.add(index);
                                  _pc1.open();
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        duration: const Duration(seconds: 1),
                                        backgroundColor: Colors.green,
                                        content: Text(
                                            values[index]["massageName"])));
                              },
                              child: Card(
                                color: Colors.green.shade50,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      selectedIndex == index
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: const [
                                                Icon(
                                                  Icons.check,
                                                  color: Colors.green,
                                                )
                                              ],
                                            )
                                          : Container(),
                                      const Text("Massage Name",
                                          style:
                                              TextStyle(color: Colors.black45)),
                                      Text(
                                        values[index]["massageName"],
                                        style: const TextStyle(
                                             fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      const Text("Price",
                                          style:
                                              TextStyle(color: Colors.black45)),
                                      Text(
                                        "Rs.${values[index]["price"]}",
                                        style: const TextStyle(
                                            fontFamily: "Montserrat",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      const Text("Room Type",
                                          style:
                                              TextStyle(color: Colors.black45)),
                                      Text(
                                        values[index]["roomType"],
                                        style: const TextStyle(
                                            fontFamily: "Montserrat",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          shrinkWrap: true,
                        ),
                      ],
                    )
                  : Container())): const Center(child: CircularProgressIndicator(value: 1)),
    );
  }

  Widget _panel(ScrollController sc) {
    return SingleChildScrollView(
        child: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.blueGrey[200],
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
          const Text("Choose Massage", style: TextStyle(fontSize: 22)),
          GestureDetector(
              onTap: () {
                panelHeightOpen = 0;
                panelHeightClosed = 0;
                setState(() {
                  _pc1.close();
                });
              },
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    Row(
                      children: const [
                        Text("Add More"),
                        Icon(
                          Icons.add,
                          size: 30,
                          color: Colors.green,
                        )
                      ],
                    ),
                  ])),
          ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Massage Name",
                      style: TextStyle(color: Colors.black45)),
                  Text(
                    values[list[index]]["massageName"],
                    style: const TextStyle(
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  const Text("Price", style: TextStyle(color: Colors.black45)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rs.${values[list[index]]["price"]}",
                        style: const TextStyle(
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                        icon: const Icon(Icons.delete),
                                        title: const Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        content: const Text(
                                          "Would you like to remove from massage cart?",
                                          style: TextStyle(
                                              fontFamily: "Montserrat"),
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  list.removeAt(index);
                                                });
                                                Navigator.pop(ctx);
                                              },
                                              child: const Text(
                                                "Yes",
                                                style: TextStyle(
                                                    color: Colors.green),
                                              )),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                              },
                                              child: const Text(
                                                "No",
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ))
                                        ],
                                      ));
                            },
                            child: const Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Text("Room Type",
                      style: TextStyle(color: Colors.black45)),
                  Text(
                    values[list[index]]["roomType"],
                    style: const TextStyle(
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ],
              ),
            ),
            separatorBuilder: (BuildContext context, int index) {
              return Container(
                decoration: const BoxDecoration(color: Colors.green),
                height: 1,
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: CupertinoButton(
                color: Colors.blue,
                onPressed: () {
                  WalkinClientCartData.list = list;
                  calculate();
                },
                child: const Text("Proceed")),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset("assets/clientSlider.png"),
              loader
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                          height: MediaQuery.of(context).size.width - 20,
                          width: MediaQuery.of(context).size.width - 20,
                          child: const CircularProgressIndicator(
                            strokeWidth: 1,
                          )),
                    )
                  : Container()
            ],
          )
        ],
      ),
    ));
  }

  Future<void> calculate() async {
    List<int> array = [];
    for (int i = 0; i < list.length; i++) {
      int data = values[list[i]]["price"];
      array.add(data);
    }
    int sum = array.fold(0, (p, c) => p + c);
    if (sum == 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Cart is empty")));
    } else {
      setState(() {
        loader = true;
      });
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => Future.delayed(const Duration(seconds: 2), () {
                finalWalkinClient(sum);
              }));
    }
  }

  getValuesServices() async {
    await _server
        .collection("spa")
        .doc(Spa.getSpaName)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      values = documentSnapshot.get("services");
      WalkinClientCartData.values = values;
      address = documentSnapshot.get("address");
      description = documentSnapshot.get("description");
      setState(() {
        uiLoad = true;
        fetching = true;
      });
    });
  }

  void finalWalkinClient(int sum) {
    Timestamp timestamp = Timestamp.now();

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FinalWalkinClient(
            total: sum,
            number: widget.number,
            age: widget.age,
            registration:
                DateFormat.yMMMd().add_jm().format(timestamp.toDate()),
            name: widget.name,
            member: false,
          ),
        ));
  }
}
