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
          width: 350,
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: 340,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                        'assets/pic1.png',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              
              const SizedBox(height: 12), // Reduced spacing to fit within height
              SizedBox(
                  child: Text(
                    pv.fl.flowList[flowId]!.flowName,
                    style: const TextStyle(fontFamily: 'Frederik', fontSize: 20),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

            ],
          ),
        ),
      );
    });
  }
}