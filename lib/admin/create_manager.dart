import 'package:flutter/material.dart';

class CreateManager extends StatefulWidget {
  const CreateManager({Key? key}) : super(key: key);

  @override
  State<CreateManager> createState() => _CreateManagerState();
}

class _CreateManagerState extends State<CreateManager> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: SafeArea(
              child: Column(
        children: [
          Center(child: Image.asset("assets/business.png",width: MediaQuery.of(context).size.width-100,height: MediaQuery.of(context).size.width-100,))
        ],
      ))),
    );
  }
}
