import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class SliderStart extends StatelessWidget {
  final List<String> texts = [
    "Watch your Ideas come to life",
    "Store your workflows, as many as you want",
    "Visualise your workflows"
  ];

  final List<String> images = [
    "assets/Group 50.png",
    "assets/Group 50.png",
    "assets/Group 50.png"
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFE0EFFF),
        body: Center(
          child: CarouselSlider(
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              viewportFraction: 1.0,
              enableInfiniteScroll: true,
              scrollPhysics: NeverScrollableScrollPhysics(),
            ),
            items: List.generate(texts.length, (index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    images[index],
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 20),
                  Text(
                    texts[index],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Frederik',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
