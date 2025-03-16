import 'package:cookethflow/core/services/supabase_service.dart';
import 'package:cookethflow/providers/authentication_provider.dart';
import 'package:cookethflow/providers/dashboard_provider.dart';
import 'package:cookethflow/core/widgets/popup_box.dart';
import 'package:cookethflow/screens/log_in.dart';
import 'package:cookethflow/screens/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SupabaseService>(
      builder: (context, auth, child) {
        return FutureBuilder(
            future: auth.fetchCurrentUserName(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox();
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              var user = snapshot.data;
              return Stack(
                children: [
                  // Main Floating Drawer
                  Positioned(
                    top: 24,
                    left: 24,
                    child: Material(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 350,
                        height: MediaQuery.of(context).size.height * 0.95,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 32),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween, // Distributes space evenly
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage:
                                            AssetImage('assets/pic1.png'),
                                      ),
                                      SizedBox(
                                          width:
                                              12), // Slightly increased spacing
                                      Text(
                                        user?['userName'] ?? "UserName",
                                        style: TextStyle(
                                            fontFamily: 'Frederik',
                                            fontSize: 20),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          // Show the ProfileDialog
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return const ProfileDialog();
                                            },
                                          );
                                        },
                                        icon: Icon(
                                          PhosphorIconsBold.caretDown,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // IconButton(
                                  //   onPressed: () {},
                                  //   iconSize: 30,
                                  //   icon: Icon(
                                  //     PhosphorIconsRegular.bell,
                                  //     color: Colors.black,
                                  //     size: 24,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      20), // Consistent horizontal padding
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await auth.logout();
                                  Navigator.of(context)
                                      .pushReplacement(MaterialPageRoute(builder: (context) => SignupPage(),));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  fixedSize: Size(200, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Add another account',
                                  style: TextStyle(
                                      fontFamily: 'Frederik',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(
                                height:
                                    40), // Slightly increased for better spacing
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      20), // Consistent horizontal padding
                              child: TextButton.icon(
                                onPressed: () {},
                                icon: Icon(
                                  PhosphorIconsRegular.file,
                                  color: Colors.black,
                                  size: 24,
                                ),
                                label: Text(
                                  'Drafts',
                                  style: TextStyle(
                                      fontFamily: 'Frederik',
                                      fontSize: 16,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                            SizedBox(
                                height: 16), // Increased spacing between items
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      20), // Consistent horizontal padding
                              child: TextButton.icon(
                                onPressed: () {},
                                icon: Icon(
                                  PhosphorIconsRegular.trash,
                                  color: Colors.black,
                                  size: 24,
                                ),
                                label: Text(
                                  'Trash',
                                  style: TextStyle(
                                      fontFamily: 'Frederik',
                                      fontSize: 16,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                            SizedBox(height: 16), // Increased spacing
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      20), // Consistent horizontal padding
                              child: TextButton.icon(
                                onPressed: () {},
                                icon: Icon(
                                  PhosphorIconsRegular.star,
                                  color: Colors.black,
                                  size: 24,
                                ),
                                label: Text(
                                  'Starred',
                                  style: TextStyle(
                                      fontFamily: 'Frederik',
                                      fontSize: 16,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                            SizedBox(height: 16), // Increased spacing
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      20), // Consistent horizontal padding
                              child: TextButton.icon(
                                onPressed: () {},
                                icon: Icon(
                                  PhosphorIconsRegular.gear,
                                  color: Colors.black,
                                  size: 24,
                                ),
                                label: Text(
                                  'Settings',
                                  style: TextStyle(
                                      fontFamily: 'Frederik',
                                      fontSize: 16,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 24), // Increased vertical padding
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await auth.logout();
                                  Navigator.of(context)
                                      .pushReplacement(MaterialPageRoute(
                                    builder: (context) {
                                      return LoginPage();
                                    },
                                  ));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  fixedSize: Size(120, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Log Out',
                                  style: TextStyle(
                                      fontFamily: 'Frederik',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            });
      },
    );
  }
}
