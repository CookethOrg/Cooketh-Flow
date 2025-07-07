import 'package:cookethflow/features/dashboard/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return Drawer(
          elevation: 0,
          backgroundColor: Colors.white,
          shadowColor: Colors.black,
          child: Column(
            children: [
              // Column for upper items
              Column(
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 70.w,
                          height: 70.h,
                          child: Image.asset('assets/images/Frame 402.png',fit: BoxFit.cover,),
                        ),
                      ),
                      SizedBox(width: 25.w,),
                      
                      ElevatedButton(
                        onPressed: () {
                          provider.toggleDrawer();
                        },
                        child: Text('Close'),
                      ),
                    ],
                  ),
                ],
              ),

              Divider(color: Colors.grey),
              //column for lower items
              Column(),
            ],
          ),
        );
      },
    );
  }
}
