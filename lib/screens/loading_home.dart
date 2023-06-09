
import 'package:flutter/material.dart';

class LoadingHome extends StatefulWidget {
  const LoadingHome({Key? key}) : super(key: key);

  @override
  State<LoadingHome> createState() => _LoadingHomeState();
}

class _LoadingHomeState extends State<LoadingHome> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
            (_) =>
            Future.delayed(const Duration(seconds: 1), () async {

            }));

    return const Scaffold(
      body: Center(
          child: CircularProgressIndicator(
            strokeWidth: 1,
            backgroundColor: Colors.black54,
          )),
    );
  }

  void move() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoadingHome(),
        ),
            (route) => false);
  }
}