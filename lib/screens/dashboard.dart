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
          appBar: AppBar(
            title: Text(
              'Your Projects',
              style: TextStyle(color: Colors.black),
            ),
          ),
          drawer: DashboardDrawer(),
        );
      },
    );
  }
}
