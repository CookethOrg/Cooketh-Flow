import 'package:cookethflow/core/widgets/drawers/dashboard_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          body: Stack(
            children: [
              DashboardDrawer(),
              
            ],
          ),
        );
      },
    );
  }
}
