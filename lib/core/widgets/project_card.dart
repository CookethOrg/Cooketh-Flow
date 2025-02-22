import 'dart:ui';
import 'package:flutter/material.dart';

class ProjectCard extends StatelessWidget {
  final Function() onTap;
  const ProjectCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 280,
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10), // Apply border radius
                child: ImageFiltered(
                  imageFilter:
                      ImageFilter.blur(sigmaX: 2, sigmaY: 2), // Blur effect
                  child: Image.asset(
                    'assets/pic1.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // SizedBox(
            //   height: 8,
            // ),
            Spacer(),
            Text(
              'Untitled',
              style: TextStyle(fontFamily: 'Frederik', fontSize: 20),
            )
          ],
        ),
      ),
    );
  }
}
