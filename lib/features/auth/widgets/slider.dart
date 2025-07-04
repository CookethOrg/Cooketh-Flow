import 'package:carousel_slider/carousel_slider.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        backgroundColor: const Color(0xFFFDE2CF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 0.8.sh, // 640
                child: CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: true,
                    autoPlayInterval: const Duration(milliseconds: 2500),
                    viewportFraction: 1.0,
                    enableInfiniteScroll: true,
                    scrollPhysics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index, reason) {
                      currentIndex.value = index;
                    },
                  ),
                  items: images.map((image) {
                    return Image.asset(
                      image,
                      fit: BoxFit.cover,
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 10.h),
              ValueListenableBuilder<int>(
                valueListenable: currentIndex,
                builder: (context, index, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: 12.w,
                        height: 12.h,
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