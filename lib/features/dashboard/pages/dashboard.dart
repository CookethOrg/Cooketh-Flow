import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SupabaseService>(
      builder: (context,supa,child) {
        return Scaffold(body: Center(child: Column(children: [
          Text(supa.userName ?? "No user"),
          Text(supa.email ?? "No user"),
          // Text(supa.userData.user!.userMetadata!["raw_user_meta_data"]["userName"]?? "not found")
        ],),),);
      }
    );
  }
}