import 'package:carousel_slider/carousel_slider.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SliderStart2 extends StatelessWidget {
  final List<String> images = [
    'assets/images/Frame 400.png',
    'assets/images/Frame 401.png',
    'assets/images/Frame 402.png',
  ];

  SliderStart2({super.key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<int> currentIndex = ValueNotifier<int>(0);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        color: const Color(0xFFFDE2CF),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 0.5.sh, // 640
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
                items:
                    images.map((image) {
                      return Image.asset(image, fit: BoxFit.cover);
                    }).toList(),
              ),
            ),
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
                        color: i == index ? primaryColor : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
