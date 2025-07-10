import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.idx});
  final String idx;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(
              'assets/images/Frame 400.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get Started',
                      style: TextStyle(
                        fontFamily: 'Fredrik',
                        fontSize: 20.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Last edited 2 hours ago',
                      style: TextStyle(
                        fontFamily: 'Fredrik',
                        color: Colors.grey,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                IconButton(onPressed: (){}, icon: Icon(PhosphorIcons.star()))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
