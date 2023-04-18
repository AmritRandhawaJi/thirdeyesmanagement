import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:thirdeyesmanagement/admin/screens/admin_business.dart';
import 'package:thirdeyesmanagement/admin/screens/fragments/members.dart';
import 'package:thirdeyesmanagement/admin/screens/fragments/membership_sold.dart';
import 'package:thirdeyesmanagement/admin/screens/fragments/walkin.dart';


import 'admin_settings.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {


  int _selectedIndex = 0;

  final db = FirebaseFirestore.instance;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }



  static const List<Widget> _widgetOptions = <Widget>[
    AdminNavHomeScreen(),
    AdminBusiness(),
    AdminSettings(),
  ];

@override
  void initState() {


  super.initState();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGrey5,
      bottomNavigationBar: createBottomBar(context),
      body: SafeArea(
          child: _widgetOptions.elementAt(_selectedIndex)
      ),
    );
  }


  BottomNavigationBar createBottomBar(BuildContext context) {
    return BottomNavigationBar(
      selectedFontSize: 16,
      backgroundColor: Colors.white,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.graphic_eq),
          label: 'Business',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.green,
      onTap: _onItemTapped,
    );
  }


}
class AdminNavHomeScreen extends StatefulWidget {
  const AdminNavHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminNavHomeScreen> createState() => _AdminNavHomeScreenState();
}

class _AdminNavHomeScreenState extends State<AdminNavHomeScreen> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
            (_) => Future.delayed(const Duration(seconds: 2), () {


        }));
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              TabBar(
                physics: BouncingScrollPhysics(),

                tabs: [
                  Tab(
                    text: 'Walk-In',
                  ),
                  Tab(
                    text: 'Membership',
                  ),
                  Tab(
                    text: 'Members',
                  ),
                ],
              )
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminWalkin(),
            AdminMembershipSold(),
            AdminMembers()
          ],
        ),
      ),
    );
  }
}

