import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  String? mToken = '';

  final db = FirebaseFirestore.instance;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling a background message ${message.messageId}');
  }

  static const List<Widget> _widgetOptions = <Widget>[
    AdminNavHomeScreen(),
    AdminBusiness(),
    AdminSettings(),
  ];

@override
  void initState() {
  FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage((message) => _firebaseMessagingBackgroundHandler(message));
  requestPermission();
  getToken();
  saveToken();
  initInfo();
  super.initState();
}
  initInfo() {
    var androidInit =
    const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initSetting = InitializationSettings(android: androidInit);
    flutterLocalNotificationsPlugin.initialize(
      initSetting,
      onDidReceiveBackgroundNotificationResponse: (details) {
        if (details.payload!.isNotEmpty) {
          print(details.payload);
        }
      },
      onDidReceiveNotificationResponse: (details) {
        print(details.payload);
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("...............onMessage................");
      print(
          "onMessage: ${message.notification?.title}/ ${message.notification?.body}");

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatContentTitle: true,
      );

      AndroidNotificationDetails androidPlatformChannelSpecific =
      AndroidNotificationDetails('Sale', 'Sales',
          importance: Importance.max,
          styleInformation: bigTextStyleInformation,
          priority: Priority.max,
          playSound: true);

      NotificationDetails platformChannelSpecific =
      NotificationDetails(android: androidPlatformChannelSpecific);
      await flutterLocalNotificationsPlugin.show(0, message.notification?.title,
          message.notification?.body, platformChannelSpecific,
          payload: message.data['body']);
    });
  }

  Future<void> getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) => {
      setState(() {
        mToken = token;

      }),
    });
  }

  saveToken() async {
    await FirebaseFirestore.instance
        .collection("accounts")
        .doc(FirebaseAuth.instance.currentUser?.email)
        .update({"token": mToken}).then((value) => {

    });

  }

  Future<void> requestPermission() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    NotificationSettings notificationSettings =
    await firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      getToken();
    }
    else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      getToken();
    } else {
      if (kDebugMode) {
        print("permission denied");
      }
    }
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

