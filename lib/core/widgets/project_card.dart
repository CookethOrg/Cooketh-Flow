import 'dart:ui';
import 'package:cookethflow/providers/flowmanage_provider.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProjectCard extends StatelessWidget {
  final Function() onTap;
  final String flowId;
  const ProjectCard({super.key, required this.onTap, required this.flowId});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(builder: (context, pv, child) {
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
                  borderRadius:
                      BorderRadius.circular(10), // Apply border radius
                  child: ImageFiltered(
                    imageFilter:
                        ImageFilter.blur(sigmaX: 2, sigmaY: 2), // Blur effect
                    child: Image.asset(
                      height: 320,
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
                pv.flowManager.flowName,
                style: TextStyle(fontFamily: 'Frederik', fontSize: 20),
              )
            ],
          ),
        ),
      );
    });
  }
}
