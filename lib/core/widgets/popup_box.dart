import 'dart:io';

import 'package:cookethflow/core/services/file_services.dart';
import 'package:cookethflow/core/services/supabase_service.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/providers/authentication_provider.dart';
import 'package:cookethflow/screens/log_in.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SupabaseService>(
      builder: (context, pv, child) {
        return FutureBuilder(
          future: pv.fetchCurrentUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            var user = snapshot.data;
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(
                  color: Colors.black,
                  width: 2.0,
                  style: BorderStyle.solid,
                ),
              ),
              child: SizedBox(
                width: 800,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Close Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(
                              PhosphorIconsRegular.xCircle,
                              size: 40,
                              color: Colors.black,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),

                      // Username Section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Image
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: pv.userPfp != null
                                      ? FileImage(File(pv.userPfp!.path))
                                      : const AssetImage('assets/Frame 271.png') as ImageProvider),
                              border: Border.all(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                width: 1.0,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0)),
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: IconButton(
                                        style: IconButton.styleFrom(
                                            backgroundColor: transparent,
                                            hoverColor: transparent),
                                        onPressed: () async {
                                          try {
                                            XFile? file = await FileServices()
                                              .selectImages();
                                          pv.setUserPfp(file);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Profile picture changed')));
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      '$e')));
                                          }
                                        },
                                        icon: const Icon(Icons.edit, size: 12)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Username
                      const Text(
                        "User Name",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            user?['userName'] ?? "John Doe",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              showEditDialog(context, 'User Name',
                                  user?['userName'] ?? "John Doe",
                                  (newValue) async {
                                final result =
                                    await pv.updateUserName(userName: newValue);
                                return result;
                              });
                            },
                            icon: Icon(Icons.edit,
                                size: 16, color: Colors.blue.shade400),
                          )
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Email Address
                      const Text(
                        "Email Address",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            user?['email'] ?? "john.doe@example.com",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Email update requires verification. Coming soon!')));
                            },
                            icon: Icon(Icons.edit,
                                size: 16, color: Colors.blue.shade400),
                          )
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Password
                      const Text(
                        "Password",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          showPasswordChangeDialog(context);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Change Password",
                          style: TextStyle(
                              fontSize: 18, color: Colors.blue.shade400),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Delete Account Button (uncomment if needed)
                      // SizedBox(
                      //   height: 44,
                      //   width: 180,
                      //   child: ElevatedButton(
                      //     onPressed: () async {
                      //       final confirmed = await showDialog<bool>(
                      //         context: context,
                      //         builder: (context) => AlertDialog(
                      //           title: const Text('Delete Account Data'),
                      //           content: const Text(
                      //             'Are you sure you want to delete your account data? This action cannot be undone.',
                      //             style: TextStyle(fontFamily: 'Frederik'),
                      //           ),
                      //           actions: [
                      //             TextButton(
                      //               onPressed: () => Navigator.pop(context, false),
                      //               child: const Text('Cancel'),
                      //             ),
                      //             TextButton(
                      //               onPressed: () => Navigator.pop(context, true),
                      //               child: const Text('Delete',
                      //                   style: TextStyle(color: Color(0xFFC30101))),
                      //             ),
                      //           ],
                      //         ),
                      //       );

                      //       if (confirmed == true) {
                      //         try {
                      //           // Show loading indicator
                      //           if (context.mounted) {
                      //             showDialog(
                      //               context: context,
                      //               barrierDismissible: false,
                      //               builder: (context) => const Center(
                      //                 child: CircularProgressIndicator(),
                      //               ),
                      //             );
                      //           }

                      //           // Delete account
                      //           await pv.deleteUserAccount();

                      //           // Close the loading dialog and the profile dialog
                      //           if (context.mounted) {
                      //             Navigator.of(context, rootNavigator: true)
                      //                 .pop(); // Close loading
                      //             Navigator.of(context, rootNavigator: true)
                      //                 .pop(); // Close profile dialog

                      //             // Navigate to login page
                      //             // Navigator.of(context, rootNavigator: true)
                      //             //     .pushAndRemoveUntil(
                      //             //   MaterialPageRoute(builder: (context) => const LoginPage()),
                      //             //   (route) => false,
                      //             // );
                      //           }
                      //         } catch (e) {
                      //           // Close loading dialog
                      //           if (context.mounted) {
                      //             Navigator.of(context, rootNavigator: true).pop();

                      //             // Show error
                      //             ScaffoldMessenger.of(context).showSnackBar(
                      //               SnackBar(
                      //                 content: Text('Error deleting account data: ${e.toString()}'),
                      //                 backgroundColor: Colors.red,
                      //               ),
                      //             );
                      //           }
                      //         }
                      //       }
                      //     },
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.red,
                      //       shape: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(8)),
                      //     ),
                      //     child: const Text("Delete Account Data",
                      //         style: TextStyle(
                      //             color: Colors.white,
                      //             fontSize: 16,
                      //             fontWeight: FontWeight.w500)),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

void showProfileDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const ProfileDialog();
    },
  );
}

void showEditDialog(BuildContext context, String attribute, String currentValue,
    Future<String> Function(String) onUpdate) {
  final TextEditingController controller =
      TextEditingController(text: currentValue);
  bool isProcessing = false;
  String? errorMessage;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text('Update $attribute'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Enter new $attribute',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(width: 1, color: Colors.black),
                  ),
                  errorText: errorMessage,
                ),
                enabled: !isProcessing,
              ),
              if (isProcessing)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isProcessing ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: isProcessing
                  ? null
                  : () async {
                      final newValue = controller.text.trim();
                      if (newValue.isEmpty) {
                        setState(() {
                          errorMessage = 'Value cannot be empty';
                        });
                        return;
                      }

                      if (newValue == currentValue) {
                        Navigator.pop(context);
                        return;
                      }

                      setState(() {
                        isProcessing = true;
                        errorMessage = null;
                      });

                      try {
                        final result = await onUpdate(newValue);

                        if (context.mounted) {
                          Navigator.pop(context);

                          // Show success message and refresh the parent dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('$attribute updated successfully')),
                          );

                          // Close and reopen profile dialog to refresh content
                          Navigator.pop(context);
                          showProfileDialog(context);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          setState(() {
                            isProcessing = false;
                            errorMessage = 'Error: ${e.toString()}';
                          });
                        }
                      }
                    },
              child: const Text('Update'),
            ),
          ],
        );
      });
    },
  );
}

void showPasswordChangeDialog(BuildContext context) {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isProcessing = false;
  String? errorMessage;
  bool obscureCurrentPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Change Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrentPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureCurrentPassword = !obscureCurrentPassword;
                        });
                      },
                    ),
                  ),
                  enabled: !isProcessing,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureNewPassword = !obscureNewPassword;
                        });
                      },
                    ),
                  ),
                  enabled: !isProcessing,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText: errorMessage,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  enabled: !isProcessing,
                ),
                if (isProcessing)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isProcessing ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: isProcessing
                    ? null
                    : () async {
                        // Get the values
                        final currentPassword = currentPasswordController.text;
                        final newPassword = newPasswordController.text;
                        final confirmPassword = confirmPasswordController.text;

                        // Validate inputs
                        if (currentPassword.isEmpty ||
                            newPassword.isEmpty ||
                            confirmPassword.isEmpty) {
                          setState(() {
                            errorMessage = 'All fields are required';
                          });
                          return;
                        }

                        if (newPassword != confirmPassword) {
                          setState(() {
                            errorMessage = 'New passwords do not match';
                          });
                          return;
                        }

                        if (newPassword.length < 6) {
                          setState(() {
                            errorMessage =
                                'Password must be at least 6 characters';
                          });
                          return;
                        }

                        setState(() {
                          isProcessing = true;
                          errorMessage = null;
                        });

                        try {
                          // TODO: Implement password change functionality in SupabaseService
                          // For now, we'll just show a success message
                          await Future.delayed(const Duration(seconds: 1));

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Password updated successfully')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            setState(() {
                              isProcessing = false;
                              errorMessage = 'Error: ${e.toString()}';
                            });
                          }
                        }
                      },
                child: const Text('Update Password'),
              ),
            ],
          );
        },
      );
    },
  );
}
