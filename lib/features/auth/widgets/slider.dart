import 'package:carousel_slider/carousel_slider.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class SliderStart extends StatelessWidget {
  final List<String> images = [
    'assets/images/Frame 400.png',
    'assets/images/Frame 401.png',
    'assets/images/Frame 402.png',
  ];

  SliderStart({super.key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<int> currentIndex = ValueNotifier<int>(0);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF5E6CC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 300,
                  autoPlay: true,
                  autoPlayInterval: const Duration(milliseconds: 2500),
                  viewportFraction: 1.0,
                  enableInfiniteScroll: true,
                  scrollPhysics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index, reason) {
                    currentIndex.value = index; // Update the index when slide changes
                  },
                ),
                items: images.map((image) {
                  return Image.asset(
                    image,
                    fit: BoxFit.cover,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<int>(
                valueListenable: currentIndex,
                builder: (context, index, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == index
                              ? primaryColor
                              : Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}