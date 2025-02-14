import 'package:flutter/material.dart';

class AddProjectCard extends StatelessWidget {
  const AddProjectCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.add, size: 50, color: Colors.black),
          SizedBox(height: 8),
          Text(
            'Start a new Project',
            style: TextStyle(fontFamily: 'Frederik', fontSize: 20),
          ),
        ],
      ),
    );
  }
}
