import 'package:cookethflow/features/dashboard/providers/dashboard_provider.dart';
import 'package:cookethflow/features/dashboard/widgets/dashboard_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardMobile extends StatelessWidget {
  const DashboardMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(builder: (context, provider, child) => 
    Scaffold(drawer: DashboardDrawer(),appBar: AppBar(),body: Container(),),);
  }
}