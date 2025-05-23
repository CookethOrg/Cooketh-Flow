import 'dart:io' show File;

import 'package:cookethflow/core/routes/app_route_const.dart';
import 'package:cookethflow/core/services/supabase_service.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/core/widgets/alert_dialogues/popup_box.dart';
import 'package:cookethflow/core/widgets/toggle/theme_toggle.dart';
import 'package:cookethflow/screens/auth_screens/log_in.dart';
import 'package:cookethflow/screens/auth_screens/sign_up.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
                    color: white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: textColor, width: 1),
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
                                ClipOval(
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: auth.userPfp != null &&
                                            auth.userPfp!.path !=
                                                auth.defaultPfpPath
                                        ? kIsWeb
                                            ? FutureBuilder<Uint8List>(
                                                future:
                                                    auth.userPfp!.readAsBytes(),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    return Image.memory(
                                                      snapshot.data!,
                                                      fit: BoxFit.cover,
                                                      width: 40,
                                                      height: 40,
                                                    );
                                                  }
                                                  return Image.asset(
                                                    'assets/Frame 268.png',
                                                    fit: BoxFit.cover,
                                                    width: 40,
                                                    height: 40,
                                                  );
                                                },
                                              )
                                            : Image.file(
                                                File(auth.userPfp!.path),
                                                fit: BoxFit.cover,
                                                width: 40,
                                                height: 40,
                                              )
                                        : Image.asset(
                                            'assets/Frame 268.png',
                                            fit: BoxFit.cover,
                                            width: 40,
                                            height: 40,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  auth.getTruncatedText(
                                      auth.userName ?? "UserName"),
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
                            context.pushReplacement(RoutesPath.signUpScreen);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: textColor,
                            fixedSize: const Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add, color: white),
                          label: const Text(
                            'Add another account',
                            style: TextStyle(
                                fontFamily: 'Frederik',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // ThemeToggle(),
                      // SizedBox(height: 16,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            PhosphorIconsRegular.trash,
                            color: textColor,
                            size: 24,
                          ),
                          label: const Text(
                            'Trash',
                            style: TextStyle(
                                fontFamily: 'Frederik',
                                fontSize: 16,
                                color: textColor),
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
                            color: textColor,
                            size: 24,
                          ),
                          label: const Text(
                            'Starred',
                            style: TextStyle(
                                fontFamily: 'Frederik',
                                fontSize: 16,
                                color: textColor),
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
                            color: textColor,
                            size: 24,
                          ),
                          label: const Text(
                            'Settings',
                            style: TextStyle(
                                fontFamily: 'Frederik',
                                fontSize: 16,
                                color: textColor),
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
                            context.pushReplacement(RoutesPath.loginScreen);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: textColor,
                            fixedSize: const Size(120, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.logout, color: white),
                          label: const Text(
                            'Log Out',
                            style: TextStyle(
                                fontFamily: 'Frederik',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: white),
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
