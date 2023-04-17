import 'package:flutter/material.dart';
import 'package:thirdeyesmanagement/modal/page_view_data.dart';

class SlideItem extends StatelessWidget {
  final int index;

  const SlideItem(this.index, {super.key});


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("3rd Eyes Management",style: TextStyle(
        fontFamily: "Montserrat",
        fontSize: 18,
        color: Colors.black54,
        fontWeight: FontWeight.bold),),
        Image.asset(slideList[index].image,
            width: MediaQuery.of(context).size.width-50,
            height: MediaQuery.of(context).size.width),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(

            children: [
              Text(
                slideList[index].title,
                style: const TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: 28,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),

            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            children: [
              Text(
                slideList[index].description,
                style: const TextStyle(
                  fontFamily: "Montserrat",
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
            width: MediaQuery.of(context).size.width/2.5,
            height: MediaQuery.of(context).size.width/2.5,
            child: Image.asset("assets/logo.png"))
      ],
    );
  }
}
