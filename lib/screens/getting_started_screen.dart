import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirdeyesmanagement/modal/page_view_data.dart';
import 'package:thirdeyesmanagement/modal/slide_item.dart';

import 'package:thirdeyesmanagement/screens/decision.dart';
import 'package:thirdeyesmanagement/widget/slide_dots.dart';



class GettingStartedScreen extends StatefulWidget {
  const GettingStartedScreen({super.key});

  @override
  GettingStartedScreenState createState() => GettingStartedScreenState();
}

class GettingStartedScreenState extends State<GettingStartedScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      home: Scaffold(
          body: PageView.builder(
            physics: const BouncingScrollPhysics(),
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: slideList.length,
            itemBuilder: (ctx, i) => SlideItem(i),
          ),
          bottomSheet: _currentPage != slideList.length - 1
              ? Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:const Color(0xff2b6747),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          for (int i = 0; i < slideList.length; i++)
                            if (i == _currentPage)
                              const SlideDots(true)
                            else
                              const SlideDots(false)
                        ],
                      ),
                      TextButton(
                          onPressed: () {
                            _pageController.animateToPage(_currentPage + 1,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeIn);
                          },
                          child: const Row(
                            children: [
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                              )
                            ],
                          )),
                    ],
                  ),
                )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: CupertinoButton(
                        onPressed: () async {
                          userStateSave();
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const Decision(),
                          ));
                        },
                        color: const Color(0xff2b6747),
                        child: const Text(
                          "Let's Start",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                  ),
                ],
              )),
    );
  }
}

void userStateSave() async {
  final data = await SharedPreferences.getInstance();
  data.setInt("userState", 1);
}
