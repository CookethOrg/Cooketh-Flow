import 'dart:io';

import 'package:cookethflow/core/services/supabase_service.dart';
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
        return Stack(
          children: [
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: auth.userPfp != null
                                      ? FileImage(File(auth.userPfp!.path))
                                      : const AssetImage('assets/Frame 268.png')
                                          as ImageProvider,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  auth.userName ?? "UserName",
                                  style: const TextStyle(
                                      fontFamily: 'Frederik', fontSize: 20),
                                ),
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return const ProfileDialog();
                                      },
                                    );
                                  },
                                  icon: const Icon(
                                    PhosphorIconsBold.caretDown,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await auth.logout();
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const SignupPage()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            fixedSize: const Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Add another account',
                            style: TextStyle(
                                fontFamily: 'Frederik',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            PhosphorIconsRegular.trash,
                            color: Colors.black,
                            size: 24,
                          ),
                          label: const Text(
                            'Trash',
                            style: TextStyle(
                                fontFamily: 'Frederik',
                                fontSize: 16,
                                color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            PhosphorIconsRegular.star,
                            color: Colors.black,
                            size: 24,
                          ),
                          label: const Text(
                            'Starred',
                            style: TextStyle(
                                fontFamily: 'Frederik',
                                fontSize: 16,
                                color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            PhosphorIconsRegular.gear,
                            color: Colors.black,
                            size: 24,
                          ),
                          label: const Text(
                            'Settings',
                            style: TextStyle(
                                fontFamily: 'Frederik',
                                fontSize: 16,
                                color: Colors.black),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 24),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await auth.logout();
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            fixedSize: const Size(120, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text(
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
      },
    );
  }
}
